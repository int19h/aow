// Create and name functions that Ghidra's call-following analysis cannot reach in a Delphi 3 binary:
//   1. every export entry point,
//   2. every slot of every class VMT (virtual methods are only reached through the table),
//   3. every entry of a class's published method table (event handlers, named in RTTI).
// Unnamed VMT targets get the name ClassName.vmtNN, published methods get ClassName.MethodName.
// Run it as a -preScript so that the analysis afterwards disassembles everything that was created.
import java.util.ArrayList;
import java.util.List;

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Function;
import ghidra.program.model.mem.MemoryBlock;
import ghidra.program.model.symbol.SourceType;
import ghidra.program.model.symbol.Symbol;
import ghidra.program.model.symbol.SymbolIterator;

public class CreateDelphiFunctions extends GhidraScript {
    // Delphi 3 VMT layout, relative to the first user virtual slot.
    static final int SELF = -64, METHODTABLE = -40, CLASSNAME = -32, PARENT = -24, FIRST_FIXED = -20;
    static final String[] FIXED = { "SafeCallException", "DefaultHandler", "NewInstance", "FreeInstance", "Destroy" };

    List<MemoryBlock> code = new ArrayList<>();
    int created = 0, renamed = 0;

    boolean inCode(long v) {
        for (MemoryBlock b : code) {
            if (v >= b.getStart().getOffset() && v < b.getEnd().getOffset()) return true;
        }
        return false;
    }

    long u32(Address a) throws Exception { return getInt(a) & 0xFFFFFFFFL; }

    String shortString(Address a) throws Exception {
        int n = getByte(a) & 0xFF;
        if (n == 0 || n > 64) return null;
        byte[] raw = getBytes(a.add(1), n);
        String s = new String(raw, "ISO-8859-1");
        return s.matches("[A-Za-z_][A-Za-z0-9_]*") ? s : null;
    }

    void ensureFunction(Address target, String name) throws Exception {
        Function f = getFunctionAt(target);
        if (f == null) {
            f = createFunction(target, null);
            if (f == null) return;
            created++;
        }
        if (name != null && f.getName().startsWith("FUN_")) {
            f.setName(name, SourceType.ANALYSIS);
            renamed++;
        }
    }

    @Override
    public void run() throws Exception {
        for (MemoryBlock b : currentProgram.getMemory().getBlocks()) {
            if (b.isExecute() && b.isInitialized()) code.add(b);
        }
        // 1. exports. Delphi also exports data: VMTs ("Unit..TClass"), type infos ("Unit.TName" whose bytes
        //    start with a kind byte and the type name), and constants. Those must not become functions,
        //    because the decompiler then chews on garbage for minutes.
        SymbolIterator syms = currentProgram.getSymbolTable().getAllSymbols(false);
        int removed = 0;
        while (syms.hasNext()) {
            Symbol s = syms.next();
            if (!s.isExternalEntryPoint() || !inCode(s.getAddress().getOffset())) continue;
            boolean data = isDataExport(s);
            Function existing = getFunctionAt(s.getAddress());
            if (data) {
                if (existing != null) {
                    removeFunction(existing);
                    clearListing(s.getAddress(), s.getAddress().add(Math.max(1, dataLength(s)) - 1));
                    removed++;
                }
                continue;
            }
            if (existing == null && getDataAt(s.getAddress()) == null && looksLikeCode(s.getAddress())) {
                Function f = createFunction(s.getAddress(), null);
                if (f != null) created++;
            }
        }
        println("CreateDelphiFunctions: removed " + removed + " functions at data exports");
        // 2./3. VMTs: scan for the self pointer
        int classes = 0;
        for (MemoryBlock b : code) {
            Address a = b.getStart().add(64);
            Address end = b.getEnd();
            while (a.compareTo(end) < 0 && !monitor.isCancelled()) {
                try {
                    if (u32(a.add(SELF)) == a.getOffset()) {
                        long cn = u32(a.add(CLASSNAME));
                        String name = inCode(cn) ? shortString(toAddr(cn)) : null;
                        if (name != null) {
                            classes++;
                            handleClass(a, name);
                        }
                    }
                } catch (Exception e) {
                    // unreadable memory at the edge of a block: ignore
                }
                a = a.add(4);
            }
        }
        println(String.format("CreateDelphiFunctions: %d classes, %d functions created, %d renamed", classes, created, renamed));
    }

    /** Exported type info: the bytes at the symbol are <kind><len><name> and the name is the symbol's last part. */
    boolean isDataExport(Symbol s) throws Exception {
        String n = s.getName();
        if (n.contains("..")) return true;                      // class VMT
        String last = n.split("@")[0];
        last = last.substring(last.lastIndexOf('.') + 1);
        if (last.isEmpty()) return false;
        int kind = getByte(s.getAddress()) & 0xFF;
        if (kind <= 0x11) {
            String ts = shortString(s.getAddress().add(1));
            if (ts != null && ts.equals(last)) return true;      // type info
        }
        return false;
    }

    int dataLength(Symbol s) throws Exception {
        int n = getByte(s.getAddress().add(1)) & 0xFF;
        return 2 + n;
    }

    /** Reject entry points that start with bytes no Delphi 3 prologue begins with. */
    boolean looksLikeCode(Address a) throws Exception {
        int b = getByte(a) & 0xFF;
        if (b == 0x00 || b == 0xFF || b == 0xCC) return false;
        return true;
    }

    void handleClass(Address vmt, String name) throws Exception {
        if (getSymbolAt(vmt) == null || getSymbolAt(vmt).getName().startsWith("DAT_")) {
            createLabel(vmt, name + ".VMT", true, SourceType.ANALYSIS);
        }
        // fixed slots: only name them when the target is not shared with the parent (an override)
        long parentVmt = 0;
        try {
            long pp = u32(vmt.add(PARENT));
            if (pp != 0 && currentProgram.getMemory().contains(toAddr(pp))) parentVmt = u32(toAddr(pp));
        } catch (Exception e) { }
        for (int i = 0; i < FIXED.length; i++) {
            int off = FIRST_FIXED + 4 * i;
            long t = u32(vmt.add(off));
            if (!inCode(t)) continue;
            boolean inherited = parentVmt != 0 && inCode(parentVmt) && u32(toAddr(parentVmt).add(off)) == t;
            ensureFunction(toAddr(t), inherited ? null : name + "." + FIXED[i]);
        }
        // user slots: run until the value is no longer a code pointer
        for (int idx = 0; idx < 512; idx++) {
            Address slot = vmt.add(4 * idx);
            long t;
            try { t = u32(slot); } catch (Exception e) { break; }
            if (!inCode(t)) break;
            boolean inherited = false;
            try {
                inherited = parentVmt != 0 && inCode(parentVmt) && u32(toAddr(parentVmt).add(4 * idx)) == t;
            } catch (Exception e) { }
            ensureFunction(toAddr(t), inherited ? null : String.format("%s.vmt%02X", name, 4 * idx));
        }
        // published methods
        long mt = u32(vmt.add(METHODTABLE));
        if (mt != 0 && inCode(mt)) {
            Address p = toAddr(mt);
            int count = getShort(p) & 0xFFFF;
            p = p.add(2);
            for (int i = 0; i < count && i < 2000; i++) {
                int size = getShort(p) & 0xFFFF;
                long addr = u32(p.add(2));
                String mname = shortString(p.add(6));
                if (inCode(addr) && mname != null) ensureFunction(toAddr(addr), name + "." + mname);
                if (size < 7) break;
                p = p.add(size);
            }
        }
    }
}
