// Print how many functions a program has, how many carry a real name, and their total size.
// Appends one line per program to the file given as the first argument.
import java.io.FileWriter;
import java.io.PrintWriter;

import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;

public class FunctionStats extends GhidraScript {
    @Override
    public void run() throws Exception {
        int total = 0, named = 0, thunks = 0;
        long bytes = 0;
        FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
        while (it.hasNext()) {
            Function f = it.next();
            if (f.isThunk()) { thunks++; continue; }
            total++;
            bytes += f.getBody().getNumAddresses();
            if (!f.getName().startsWith("FUN_")) named++;
        }
        String line = String.format("%-18s functions=%6d named=%6d (%.0f%%) thunks=%5d code_bytes=%8d",
                currentProgram.getName(), total, named, total == 0 ? 0 : 100.0 * named / total, thunks, bytes);
        println(line);
        try (PrintWriter w = new PrintWriter(new FileWriter(getScriptArgs()[0], true))) {
            w.println(line);
        }
    }
}
