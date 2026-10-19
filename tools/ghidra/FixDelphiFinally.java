// Delphi compiles the end of a try/finally block as "push <continue>; <finally body>; ret".
// Ghidra reads that RET as a function return, so everything after the finally block is lost.
// This script turns such a RET into a branch to the pushed address and repairs the function body.
// Run it after auto-analysis. No arguments.
import ghidra.app.cmd.function.CreateFunctionCmd;
import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.lang.OperandType;
import ghidra.program.model.listing.FlowOverride;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.InstructionIterator;
import ghidra.program.model.scalar.Scalar;
import ghidra.program.model.symbol.RefType;
import ghidra.program.model.symbol.SourceType;
import java.util.HashSet;
import java.util.Set;

public class FixDelphiFinally extends GhidraScript {
    @Override
    public void run() throws Exception {
        InstructionIterator it = currentProgram.getListing().getInstructions(true);
        Set<Function> touched = new HashSet<>();
        int fixed = 0;
        while (it.hasNext() && !monitor.isCancelled()) {
            Instruction ret = it.next();
            if (!ret.getMnemonicString().equals("RET") || ret.getFlowOverride() != FlowOverride.NONE) continue;
            // Walk back through fall-through predecessors looking for PUSH imm32 within 16 instructions.
            Instruction cur = ret;
            Address target = null;
            for (int i = 0; i < 16; i++) {
                Instruction prev = cur.getPrevious();
                if (prev == null || prev.getFallThrough() == null || !prev.getFallThrough().equals(cur.getAddress())) break;
                cur = prev;
                if (cur.getMnemonicString().equals("PUSH") && cur.getNumOperands() == 1
                        && (cur.getOperandType(0) & OperandType.SCALAR) != 0) {
                    Object[] ops = cur.getOpObjects(0);
                    if (ops.length == 1 && ops[0] instanceof Scalar) {
                        Address a = toAddr(((Scalar) ops[0]).getUnsignedValue());
                        // The continue address usually follows the RET, so analysis never reached it.
                        // Only accept targets inside executable memory, and disassemble them on demand.
                        if (currentProgram.getMemory().contains(a)
                                && currentProgram.getMemory().getBlock(a).isExecute()) {
                            if (currentProgram.getListing().getInstructionAt(a) == null
                                    && currentProgram.getListing().getDefinedDataAt(a) == null) {
                                disassemble(a);
                            }
                            if (currentProgram.getListing().getInstructionAt(a) != null) target = a;
                        }
                    }
                    break;
                }
                if (cur.getFlowType().isCall() || cur.getFlowType().isJump()) {
                    // calls inside the finally body are fine; a jump means we left the block
                    if (cur.getFlowType().isJump()) break;
                }
            }
            if (target == null) continue;
            ret.setFlowOverride(FlowOverride.BRANCH);
            ret.addMnemonicReference(target, RefType.COMPUTED_JUMP, SourceType.USER_DEFINED);
            ret.setComment(ghidra.program.model.listing.CommentType.EOL, "try/finally: continue at " + target);
            Function f = getFunctionContaining(ret.getAddress());
            if (f != null) {
                touched.add(f);
                // Tell the decompiler the single destination of this "indirect" branch.
                java.util.ArrayList<Address> dests = new java.util.ArrayList<>();
                dests.add(target);
                ghidra.program.model.pcode.JumpTable jt =
                        new ghidra.program.model.pcode.JumpTable(ret.getAddress(), dests, true, 0);
                jt.writeOverride(f);
            }
            fixed++;
        }
        for (Function f : touched) {
            CreateFunctionCmd.fixupFunctionBody(currentProgram, f, monitor);
        }
        println("FixDelphiFinally: " + fixed + " returns converted in " + touched.size() + " functions");
    }
}
