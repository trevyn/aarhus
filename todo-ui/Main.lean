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

  -- Check for overlaps (runtime verification)
  let elements := sample.layout
  let noOverlaps := checkNoOverlaps elements
  IO.println s!"Overlap check: {if noOverlaps then "PASS - No overlaps!" else "FAIL - Overlaps detected!"}"

  -- Show any overlaps found
  let overlaps := findOverlaps elements
  if overlaps.isEmpty then
    IO.println "All UI elements are properly separated."
  else
    IO.println s!"Found {overlaps.length} overlapping pairs:"
    for (e1, e2) in overlaps do
      IO.println s!"  - \"{e1.content}\" overlaps with \"{e2.content}\""
  IO.println ""

  -- Demonstrate the proofs exist (they type-check at compile time!)
  IO.println "Compile-time proofs verified:"
  IO.println "  - todoItems_noOverlap: adjacent todo items don't overlap"
  IO.println "  - title_above_items: title doesn't overlap any item"
  IO.println "  - verticalStack_disjoint: general vertical stacking theorem"
  IO.println "  - horizontalStack_disjoint: general horizontal stacking theorem"
  IO.println ""

  -- Create a deliberately overlapping layout to show detection works
  IO.println "=== Testing overlap detection with bad layout ==="
  let badElem1 : UIElement := {
    kind := .button
    bounds := { pos := { x := 10, y := 10 }, size := { width := 100, height := 50 } }
    content := "Button A"
  }
  let badElem2 : UIElement := {
    kind := .button
    bounds := { pos := { x := 50, y := 30 }, size := { width := 100, height := 50 } }
    content := "Button B"
  }
  let badLayout := [badElem1, badElem2]

  let badCheck := checkNoOverlaps badLayout
  IO.println s!"Bad layout overlap check: {if badCheck then "PASS" else "FAIL - Overlaps detected!"}"
  let badOverlaps := findOverlaps badLayout
  for (e1, e2) in badOverlaps do
    IO.println s!"  - \"{e1.content}\" at {e1.bounds} overlaps \"{e2.content}\" at {e2.bounds}"
