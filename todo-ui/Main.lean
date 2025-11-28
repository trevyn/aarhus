import TodoUi

open TodoListUI

def main : IO Unit := do
  IO.println "Todo List Graphical UI - Text Position Output"
  IO.println "============================================="
  IO.println ""

  -- Show the sample todo list
  IO.println "Initial state:"
  IO.println TodoListUI.sample.render
  IO.println ""

  -- NO runtime overlap checking needed!
  -- The proofs below are verified at COMPILE TIME.
  -- If this file compiles, the layout is guaranteed correct.
  IO.println "=== Compile-Time Verification ==="
  IO.println ""
  IO.println "The following are proven at compile time (not runtime):"
  IO.println "If any were false, this program would not compile."
  IO.println ""
  IO.println "  theorem sample_layout_noOverlaps:"
  IO.println "    checkNoOverlaps sample.layout = true"
  IO.println ""
  IO.println "  theorem todoItems_noOverlap (i j : Nat) (hi : i < j):"
  IO.println "    Bounds.disjoint (item i) (item j)"
  IO.println ""
  IO.println "  theorem title_above_items (idx : Nat):"
  IO.println "    Bounds.disjoint title (item idx)"
  IO.println ""

  -- We can still DEMONSTRATE the proofs exist by referencing them
  -- These lines cause compile errors if the proofs don't exist
  let _ := sample_layout_noOverlaps      -- : checkNoOverlaps sample.layout = true
  let _ := empty_layout_noOverlaps       -- : checkNoOverlaps empty.layout = true
  let _ := todoItems_noOverlap 0 1       -- : Bounds.disjoint item0 item1
  let _ := title_above_items 0           -- : Bounds.disjoint title item0

  IO.println "All compile-time proofs verified! ✓"
  IO.println ""
  IO.println "(Runtime overlap checking has been completely eliminated)"
