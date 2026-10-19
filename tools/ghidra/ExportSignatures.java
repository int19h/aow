// Export every function's name, address, size, return type, parameters, and calling convention as JSON.
// Args: <outDir>   (one file per program: <outDir>/<programName>.json)
// The Pascal emitter (tools/emit_pascal.py) turns these into method declarations.
import java.io.File;
import java.io.PrintWriter;

import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;
import ghidra.program.model.listing.Parameter;

public class ExportSignatures extends GhidraScript {
    static String esc(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"") + "\"";
    }

    @Override
    public void run() throws Exception {
        File out = new File(getScriptArgs()[0]);
        out.mkdirs();
        File f = new File(out, currentProgram.getName() + ".json");
        int n = 0;
        try (PrintWriter w = new PrintWriter(f, "UTF-8")) {
            w.println("[");
            FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
            boolean first = true;
            while (it.hasNext() && !monitor.isCancelled()) {
                Function fn = it.next();
                if (fn.isThunk()) continue;
                if (!first) w.println(",");
                first = false;
                StringBuilder sb = new StringBuilder();
                sb.append("{\"name\":").append(esc(fn.getName(true)));
                sb.append(",\"addr\":").append(esc(fn.getEntryPoint().toString()));
                sb.append(",\"size\":").append(fn.getBody().getNumAddresses());
                sb.append(",\"ret\":").append(esc(fn.getReturnType().getName()));
                sb.append(",\"cc\":").append(esc(fn.getCallingConventionName()));
                sb.append(",\"src\":").append(esc(fn.getSignatureSource().toString()));
                sb.append(",\"params\":[");
                Parameter[] ps = fn.getParameters();
                for (int i = 0; i < ps.length; i++) {
                    if (i > 0) sb.append(",");
                    sb.append("{\"name\":").append(esc(ps[i].getName()));
                    sb.append(",\"type\":").append(esc(ps[i].getDataType().getName()));
                    sb.append(",\"storage\":").append(esc(ps[i].getVariableStorage().toString())).append("}");
                }
                sb.append("]}");
                w.print(sb);
                n++;
            }
            w.println();
            w.println("]");
        }
        println("ExportSignatures: " + n + " functions -> " + f);
    }
}
