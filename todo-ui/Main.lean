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

  -- Demonstrate adding an item
  IO.println "After adding 'Learn Lean 4':"
  let ui2 := sample.addItem "Learn Lean 4"
  IO.println ui2.render
  IO.println ""

  -- Demonstrate toggling an item
  IO.println "After toggling item 1 (Buy groceries):"
  let ui3 := ui2.toggleItem 1
  IO.println ui3.render
  IO.println ""

  -- Demonstrate clearing completed
  IO.println "After clearing completed items:"
  let ui4 := ui3.clearCompleted
  IO.println ui4.render
