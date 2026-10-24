import Lake
open Lake DSL

package equiv_lean

@[default_target]
lean_lib Equiv where
  roots := #[`Equiv, `Examples]
