// Decompile functions to one .c file each.
// Args: <outDir> [name:<substring>] [addr:<hex>[,<hex>...]]
// With no filter, every function is written.
import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileOptions;
import ghidra.app.decompiler.DecompileResults;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;

public class DecompileFunctions extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] a = getScriptArgs();
        File out = new File(a[0]);
        out.mkdirs();
        String nameFilter = null;
        List<Address> addrs = new ArrayList<>();
        for (int i = 1; i < a.length; i++) {
            if (a[i].startsWith("name:")) nameFilter = a[i].substring(5);
            if (a[i].startsWith("addr:")) {
                for (String h : a[i].substring(5).split(",")) addrs.add(toAddr(Long.parseLong(h, 16)));
            }
        }
        DecompInterface d = new DecompInterface();
        d.setOptions(new DecompileOptions());
        d.openProgram(currentProgram);
        List<Function> funcs = new ArrayList<>();
        if (!addrs.isEmpty()) {
            for (Address ad : addrs) {
                Function f = getFunctionContaining(ad);
                if (f == null) println("no function at " + ad); else if (!funcs.contains(f)) funcs.add(f);
            }
        } else {
            FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
            while (it.hasNext()) {
                Function f = it.next();
                if (nameFilter == null || f.getName(true).contains(nameFilter)) funcs.add(f);
            }
        }
        int n = 0;
        for (Function f : funcs) {
            if (monitor.isCancelled()) break;
            DecompileResults r = d.decompileFunction(f, 120, monitor);
            String code = r.decompileCompleted() ? r.getDecompiledFunction().getC()
                                                 : "// decompile failed: " + r.getErrorMessage();
            String fn = f.getEntryPoint().toString() + "_" + f.getName(true).replaceAll("[^A-Za-z0-9_.]", "_");
            if (fn.length() > 150) fn = fn.substring(0, 150);
            try (PrintWriter w = new PrintWriter(new File(out, fn + ".c"), "UTF-8")) {
                w.print(code);
            }
            n++;
        }
        d.dispose();
        println("decompiled " + n + " functions to " + out);
    }
}
