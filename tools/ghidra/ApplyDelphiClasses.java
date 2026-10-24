// Create a struct and a vtable struct for every Delphi class in classes.json, then type the Self
// parameter of every method of the classes that live in this program. After this the decompiler
// shows "this->FExperience" and "(*this->vtbl->GetExperience)(this)" instead of raw offsets.
// Args: <classes.json>
// Run as -postScript after analysis (and after CreateDelphiFunctions / FixDelphiFinally).
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import ghidra.app.script.GhidraScript;
import ghidra.program.model.data.ArrayDataType;
import ghidra.program.model.data.BooleanDataType;
import ghidra.program.model.data.ByteDataType;
import ghidra.program.model.data.CategoryPath;
import ghidra.program.model.data.CharDataType;
import ghidra.program.model.data.DataType;
import ghidra.program.model.data.DataTypeConflictHandler;
import ghidra.program.model.data.DataTypeManager;
import ghidra.program.model.data.DoubleDataType;
import ghidra.program.model.data.FloatDataType;
import ghidra.program.model.data.IntegerDataType;
import ghidra.program.model.data.PointerDataType;
import ghidra.program.model.data.ShortDataType;
import ghidra.program.model.data.StructureDataType;
import ghidra.program.model.data.UnsignedIntegerDataType;
import ghidra.program.model.data.UnsignedShortDataType;
import ghidra.program.model.data.VoidDataType;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;
import ghidra.program.model.listing.Parameter;
import ghidra.program.model.listing.ParameterImpl;
import ghidra.program.model.listing.Function.FunctionUpdateType;
import ghidra.program.model.symbol.SourceType;

public class ApplyDelphiClasses extends GhidraScript {
    static final CategoryPath CAT = new CategoryPath("/Delphi");
    DataTypeManager dtm;
    JsonObject classes;
    Map<String, StructureDataType> structs = new HashMap<>();
    Map<String, StructureDataType> vtbls = new HashMap<>();
    Set<String> building = new HashSet<>();

    @Override
    public void run() throws Exception {
        dtm = currentProgram.getDataTypeManager();
        JsonObject root = JsonParser.parseReader(new FileReader(getScriptArgs()[0])).getAsJsonObject();
        classes = root.getAsJsonObject("classes");
        int tx = dtm.startTransaction("Delphi classes");
        try {
            for (String name : classes.keySet()) {
                structFor(name);
            }
        } finally {
            dtm.endTransaction(tx, true);
        }
        println("ApplyDelphiClasses: " + structs.size() + " structs created");
        // type Self on this program's methods
        int typed = 0, created = 0;
        String module = currentProgram.getName();
        Map<String, String> fnToClass = new HashMap<>();
        for (String name : classes.keySet()) {
            JsonObject c = classes.getAsJsonObject(name);
            if (!module.equalsIgnoreCase(c.get("module").getAsString())) continue;
            fnToClass.put(name, name);
        }
        // A function without stored parameters must first get the parameters the decompiler infers;
        // storing only "this" would lock a one-argument prototype and hide the real arguments.
        ghidra.app.decompiler.DecompInterface ifc = new ghidra.app.decompiler.DecompInterface();
        ifc.setOptions(new ghidra.app.decompiler.DecompileOptions());
        ifc.openProgram(currentProgram);
        FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
        while (it.hasNext() && !monitor.isCancelled()) {
            Function f = it.next();
            if (f.isThunk()) continue;
            String cls = classOf(f.getName(), fnToClass);
            if (cls == null) continue;
            if (f.getSignatureSource() == SourceType.USER_DEFINED) continue;
            DataType self = new PointerDataType(structs.get(cls), dtm);
            boolean readWrite = f.getName().contains(".ReadWrite@");
            try {
                boolean mine = f.getParameterCount() > 0 && f.getParameter(0).getName().equals("this")
                        && f.getParameterCount() <= 2 && f.getSignatureSource() == SourceType.ANALYSIS;
                if (f.getParameterCount() == 0 || mine) {
                    // unlock, let the decompiler recover the parameter list, store it
                    f.updateFunction(null, null, new ArrayList<Parameter>(), FunctionUpdateType.DYNAMIC_STORAGE_ALL_PARAMS, true, SourceType.DEFAULT);
                    f.setSignatureSource(SourceType.DEFAULT);
                    ghidra.app.decompiler.DecompileResults r = ifc.decompileFunction(f, 60, monitor);
                    ghidra.program.model.pcode.HighFunction hf = r.getHighFunction();
                    if (hf == null) continue;
                    ghidra.program.model.pcode.HighFunctionDBUtil.commitParamsToDatabase(hf, true,
                            ghidra.program.model.pcode.HighFunctionDBUtil.ReturnCommitOption.NO_COMMIT, SourceType.ANALYSIS);
                    created++;
                }
                if (f.getParameterCount() == 0) {
                    List<Parameter> ps = new ArrayList<>();
                    ps.add(new ParameterImpl("this", self, currentProgram));
                    f.updateFunction(null, null, ps, FunctionUpdateType.DYNAMIC_STORAGE_ALL_PARAMS, true, SourceType.ANALYSIS);
                } else {
                    Parameter p0 = f.getParameter(0);
                    p0.setDataType(self, SourceType.ANALYSIS);
                    if (p0.getName().startsWith("param_")) p0.setName("this", SourceType.ANALYSIS);
                }
                if (readWrite && f.getParameterCount() > 1 && structs.containsKey("TEStorageStream")) {
                    Parameter p1 = f.getParameter(1);
                    p1.setDataType(new PointerDataType(structs.get("TEStorageStream"), dtm), SourceType.ANALYSIS);
                    if (p1.getName().startsWith("param_")) p1.setName("stream", SourceType.ANALYSIS);
                }
                typed++;
            } catch (Exception e) {
                println("  could not type " + f.getName() + ": " + e.getMessage());
            }
        }
        ifc.dispose();
        println("ApplyDelphiClasses: Self typed on " + typed + " methods (" + created + " parameter lists recovered)");
    }

    // Parameter lists of the Engine.TEStorageStream virtual methods (after Self). "p" = pointer,
    // "i" = int, "b" = byte, "w" = word, "c" = char. From doc/persistence.md.
    static final Map<String, String[]> STORAGE_SIGS = new HashMap<>();
    static {
        STORAGE_SIGS.put("StorageMode", new String[] {});
        STORAGE_SIGS.put("OpenPropertyStream", new String[] {"i:ID"});
        STORAGE_SIGS.put("rwCreateEObject", new String[] {"p:Obj", "p:Owner", "i:ID"});
        STORAGE_SIGS.put("rwEObject", new String[] {"p:Obj", "i:ID"});
        STORAGE_SIGS.put("rwEObjectStream", new String[] {"p:Obj"});
        STORAGE_SIGS.put("rwChildren", new String[] {"p:Node", "i:ID"});
        STORAGE_SIGS.put("rwStreamProc", new String[] {"i:ID", "p:Obj", "p:LoadProc", "p:SaveProc"});
        STORAGE_SIGS.put("rwData", new String[] {"p:Buffer", "i:Size", "i:ID"});
        STORAGE_SIGS.put("rwString", new String[] {"p:S", "i:ID"});
        STORAGE_SIGS.put("rwStrings", new String[] {"p:Strings", "i:ID"});
        STORAGE_SIGS.put("rwStringsEx", new String[] {"p:Strings", "i:ID"});
        STORAGE_SIGS.put("rwInteger", new String[] {"p:I", "i:ID"});
        STORAGE_SIGS.put("rwByte", new String[] {"p:B", "i:ID"});
        STORAGE_SIGS.put("rwWord", new String[] {"p:W", "i:ID"});
        STORAGE_SIGS.put("rwBool", new String[] {"p:B", "i:ID"});
        STORAGE_SIGS.put("rwShortint", new String[] {"p:S", "i:ID"});
        STORAGE_SIGS.put("rwIntegerEx", new String[] {"p:I", "i:Default", "i:ID"});
        STORAGE_SIGS.put("rwByteEx", new String[] {"p:B", "b:Default", "i:ID"});
        STORAGE_SIGS.put("rwWordEx", new String[] {"p:W", "w:Default", "i:ID"});
        STORAGE_SIGS.put("rwShortintEx", new String[] {"p:S", "c:Default", "i:ID"});
    }

    boolean isStorageStream(String cls) {
        String c = cls;
        for (int i = 0; i < 16 && c != null && classes.has(c); i++) {
            if (c.equals("TEStorageStream")) return true;
            JsonElement p = classes.getAsJsonObject(c).get("parent");
            c = p.isJsonNull() ? null : p.getAsString();
        }
        return false;
    }

    ghidra.program.model.data.FunctionDefinitionDataType storageSignature(String cls, String method) {
        ghidra.program.model.data.FunctionDefinitionDataType fd =
                new ghidra.program.model.data.FunctionDefinitionDataType(CAT, "TEStorageStream_" + method);
        String[] spec = STORAGE_SIGS.get(method);
        ghidra.program.model.data.ParameterDefinition[] ps = new ghidra.program.model.data.ParameterDefinition[spec.length + 1];
        ps[0] = new ghidra.program.model.data.ParameterDefinitionImpl("this",
                new PointerDataType(structs.get(cls), dtm), null);
        for (int i = 0; i < spec.length; i++) {
            String[] kv = spec[i].split(":");
            DataType t;
            switch (kv[0]) {
                case "i": t = IntegerDataType.dataType; break;
                case "b": t = ByteDataType.dataType; break;
                case "w": t = UnsignedShortDataType.dataType; break;
                case "c": t = CharDataType.dataType; break;
                default: t = new PointerDataType(VoidDataType.dataType, dtm);
            }
            ps[i + 1] = new ghidra.program.model.data.ParameterDefinitionImpl(kv[1], t, null);
        }
        fd.setArguments(ps);
        fd.setReturnType(method.equals("StorageMode") ? ByteDataType.dataType
                : method.equals("OpenPropertyStream") ? new PointerDataType(VoidDataType.dataType, dtm) : VoidDataType.dataType);
        try {
            fd.setCallingConvention(currentProgram.getCompilerSpec().getDefaultCallingConvention().getName());
        } catch (Exception e) { }
        return fd;
    }

    /** "AoWE.THero.GetExperience@23EDC2EF" or "THero.vmt1C" or "THero.Destroy" -> "THero" when known. */
    String classOf(String fname, Map<String, String> known) {
        String n = fname.split("@")[0];
        String[] parts = n.split("\\.");
        for (int i = parts.length - 2; i >= 0; i--) {
            if (parts[i].startsWith("T") && known.containsKey(parts[i])) return parts[i];
        }
        return null;
    }

    DataType primitive(String t, int size) {
        switch (t) {
            case "int": return IntegerDataType.dataType;
            case "uint": return UnsignedIntegerDataType.dataType;
            case "word": return UnsignedShortDataType.dataType;
            case "short": return ShortDataType.dataType;
            case "byte": return ByteDataType.dataType;
            case "char": return CharDataType.dataType;
            case "bool": return BooleanDataType.dataType;
            case "float": return FloatDataType.dataType;
            case "double": return DoubleDataType.dataType;
            case "AnsiString": return new PointerDataType(CharDataType.dataType, dtm);
            case "pointer": return new PointerDataType(VoidDataType.dataType, dtm);
        }
        if (t.startsWith("byte[")) {
            int n = Integer.parseInt(t.substring(5, t.length() - 1));
            return new ArrayDataType(ByteDataType.dataType, n, 1);
        }
        if (t.startsWith("T") && classes.has(t)) {
            return new PointerDataType(structFor(t), dtm);
        }
        if (t.contains("(")) {   // "Boolean(tkEnumeration)" style from RTTI
            String base = t.substring(0, t.indexOf('('));
            if (base.equals("Boolean")) return BooleanDataType.dataType;
            if (base.equals("Integer") || base.equals("Longint")) return IntegerDataType.dataType;
            if (base.equals("Byte")) return ByteDataType.dataType;
            if (base.equals("Word")) return UnsignedShortDataType.dataType;
            if (base.equals("String")) return new PointerDataType(CharDataType.dataType, dtm);
            if (t.contains("tkClass") && classes.has(base)) return new PointerDataType(structFor(base), dtm);
            if (t.contains("tkEnumeration")) return ByteDataType.dataType;
            if (t.contains("tkInteger")) return IntegerDataType.dataType;
        }
        return size == 1 ? ByteDataType.dataType : size == 2 ? UnsignedShortDataType.dataType
                : new PointerDataType(VoidDataType.dataType, dtm);
    }

    StructureDataType structFor(String name) {
        if (structs.containsKey(name)) return structs.get(name);
        JsonObject c = classes.getAsJsonObject(name);
        int size = Math.max(4, c.get("size").getAsInt());
        StructureDataType st = new StructureDataType(CAT, name, size, dtm);
        structs.put(name, st);           // register early: fields may point back at this class
        building.add(name);
        // vtable
        StructureDataType vt = new StructureDataType(CAT, name + "_vtbl", 0, dtm);
        JsonArray slots = c.getAsJsonArray("vmt");
        Set<String> used = new HashSet<>();
        boolean storage = isStorageStream(name);
        for (JsonElement e : slots) {
            JsonObject s = e.getAsJsonObject();
            String mn = s.get("name").isJsonNull() ? null : s.get("name").getAsString();
            if (mn == null) mn = "vmt" + Integer.toHexString(s.get("offset").getAsInt()).toUpperCase();
            mn = mn.replaceAll("[^A-Za-z0-9_]", "_");
            if (!used.add(mn)) mn = mn + "_" + s.get("offset").getAsInt();
            DataType slotType = new PointerDataType(VoidDataType.dataType, dtm);
            if (storage && STORAGE_SIGS.containsKey(mn)) {
                // exact prototypes for the storage stream: without them the decompiler drops the
                // trailing stack argument (the property id) of every rw* call
                slotType = new PointerDataType(storageSignature(name, mn), dtm);
            }
            vt.add(slotType, 4, mn, s.get("symbol").isJsonNull() ? null : s.get("symbol").getAsString());
        }
        if (vt.getLength() == 0) vt.add(new PointerDataType(VoidDataType.dataType, dtm), 4, "vmt0", null);
        vtbls.put(name, vt);
        dtm.addDataType(vt, DataTypeConflictHandler.REPLACE_HANDLER);
        // fields: parent chain first, own fields override
        List<String> chain = new ArrayList<>();
        for (String p = name; p != null && classes.has(p); p = classes.getAsJsonObject(p).get("parent").isJsonNull() ? null : classes.getAsJsonObject(p).get("parent").getAsString()) {
            chain.add(0, p);
            if (chain.size() > 64) break;
        }
        try {
            st.replaceAtOffset(0, new PointerDataType(vt, dtm), 4, "vtbl", null);
        } catch (Exception ex) { }
        for (String p : chain) {
            JsonObject fields = classes.getAsJsonObject(p).getAsJsonObject("fields");
            for (String offStr : fields.keySet()) {
                JsonObject fd = fields.getAsJsonObject(offStr);
                int off = Integer.parseInt(offStr);
                String fname = fd.has("name") ? fd.get("name").getAsString() : "field_" + off;
                String ftype = fd.has("type") && !fd.get("type").isJsonNull() ? fd.get("type").getAsString() : "int";
                int fsize = fd.has("size") ? fd.get("size").getAsInt() : 0;
                DataType dt = primitive(ftype, fsize);
                if (dt.getLength() <= 0) dt = IntegerDataType.dataType;
                if (off < 4 || off + dt.getLength() > size) continue;
                try {
                    st.replaceAtOffset(off, dt, dt.getLength(), fname.replaceAll("[^A-Za-z0-9_]", "_"), fd.has("src") ? fd.get("src").getAsString() : null);
                } catch (Exception ex) {
                    // overlapping or out-of-range field: skip, the layout table is the place to fix it
                }
            }
        }
        dtm.addDataType(st, DataTypeConflictHandler.REPLACE_HANDLER);
        building.remove(name);
        return st;
    }
}
