-- Todo List Graphical UI with Text Position Output

/-- A 2D position on screen -/
structure Position where
  x : Nat
  y : Nat
deriving Repr, Inhabited

/-- A 2D size (width, height) -/
structure Size where
  width : Nat
  height : Nat
deriving Repr, Inhabited

/-- A bounding box defined by position and size -/
structure Bounds where
  pos : Position
  size : Size
deriving Repr, Inhabited

/-- A todo item with text and completion status -/
structure TodoItem where
  id : Nat
  text : String
  completed : Bool
deriving Repr, Inhabited

/-- Types of UI elements that can be rendered -/
inductive UIElementKind
  | checkbox (checked : Bool)
  | button
  | label
  | textInput
  | panel
deriving Repr

/-- A UI element with its kind, position, and content -/
structure UIElement where
  kind : UIElementKind
  bounds : Bounds
  content : String
deriving Repr

/-- The complete todo list UI state -/
structure TodoListUI where
  title : String
  items : List TodoItem
  windowBounds : Bounds
deriving Repr, Inhabited

namespace Position

def toString (p : Position) : String :=
  s!"({p.x}, {p.y})"

instance : ToString Position := ⟨Position.toString⟩

end Position

namespace Bounds

def toString (b : Bounds) : String :=
  s!"({b.pos.x}, {b.pos.y})-({b.pos.x + b.size.width}, {b.pos.y + b.size.height})"

instance : ToString Bounds := ⟨Bounds.toString⟩

end Bounds

namespace UIElementKind

def name : UIElementKind → String
  | .checkbox _ => "checkbox"
  | .button => "button"
  | .label => "label"
  | .textInput => "textInput"
  | .panel => "panel"

def toString : UIElementKind → String
  | .checkbox checked => if checked then "[x]" else "[ ]"
  | .button => "[button]"
  | .label => "[label]"
  | .textInput => "[input]"
  | .panel => "[panel]"

instance : ToString UIElementKind := ⟨UIElementKind.toString⟩

end UIElementKind

namespace UIElement

/-- Pad a string to the right with spaces -/
def padRight (s : String) (width : Nat) : String :=
  let padding := String.ofList (List.replicate (width - s.length) ' ')
  s ++ padding

/-- Render a UI element to text with position information -/
def render (elem : UIElement) : String :=
  let kindStr := padRight s!"{elem.kind}" 10
  let posStr := s!"{elem.bounds.pos}"
  s!"{kindStr} {posStr} \"{elem.content}\""

instance : ToString UIElement := ⟨UIElement.render⟩

end UIElement

namespace TodoListUI

/-- Layout configuration -/
def titleY : Nat := 10
def itemStartY : Nat := 50
def itemHeight : Nat := 30
def itemX : Nat := 20
def buttonY (numItems : Nat) : Nat := itemStartY + numItems * itemHeight + 20
def inputY (numItems : Nat) : Nat := buttonY numItems + 40

/-- Enumerate a list with indices -/
def enumerate (xs : List α) : List (Nat × α) :=
  let rec go (idx : Nat) : List α → List (Nat × α)
    | [] => []
    | x :: xs => (idx, x) :: go (idx + 1) xs
  go 0 xs

/-- Generate UI elements from the todo list state -/
def layout (ui : TodoListUI) : List UIElement :=
  let titleElem : UIElement := {
    kind := .label
    bounds := { pos := { x := itemX, y := titleY }, size := { width := 200, height := 30 } }
    content := ui.title
  }

  let itemElems := (enumerate ui.items).map fun (idx, item) =>
    let elem : UIElement := {
      kind := .checkbox item.completed
      bounds := {
        pos := { x := itemX, y := itemStartY + idx * itemHeight }
        size := { width := 300, height := 25 }
      }
      content := item.text
    }
    elem

  let addButton : UIElement := {
    kind := .button
    bounds := {
      pos := { x := itemX, y := buttonY ui.items.length }
      size := { width := 100, height := 30 }
    }
    content := "Add Task"
  }

  let clearButton : UIElement := {
    kind := .button
    bounds := {
      pos := { x := itemX + 120, y := buttonY ui.items.length }
      size := { width := 140, height := 30 }
    }
    content := "Clear Completed"
  }

  let inputField : UIElement := {
    kind := .textInput
    bounds := {
      pos := { x := itemX, y := inputY ui.items.length }
      size := { width := 280, height := 30 }
    }
    content := "Enter new task..."
  }

  [titleElem] ++ itemElems ++ [addButton, clearButton, inputField]

/-- Render the complete UI to text output -/
def render (ui : TodoListUI) : String :=
  let elements := ui.layout
  let header := "=== Todo List UI (Position Output) ===\n"
  let elemStrs := elements.map UIElement.render
  header ++ String.intercalate "\n" elemStrs

instance : ToString TodoListUI := ⟨TodoListUI.render⟩

/-- Create a sample todo list for demonstration -/
def sample : TodoListUI := {
  title := "My Todo List"
  windowBounds := {
    pos := { x := 0, y := 0 }
    size := { width := 400, height := 500 }
  }
  items := [
    { id := 1, text := "Buy groceries", completed := false },
    { id := 2, text := "Walk the dog", completed := true },
    { id := 3, text := "Write Lean code", completed := false },
    { id := 4, text := "Review pull request", completed := true },
    { id := 5, text := "Plan weekend trip", completed := false }
  ]
}

/-- Add a new todo item -/
def addItem (ui : TodoListUI) (text : String) : TodoListUI :=
  let newId := ui.items.length + 1
  let newItem : TodoItem := { id := newId, text := text, completed := false }
  { ui with items := ui.items ++ [newItem] }

/-- Toggle completion status of an item by id -/
def toggleItem (ui : TodoListUI) (itemId : Nat) : TodoListUI :=
  let newItems := ui.items.map fun item =>
    if item.id == itemId then { item with completed := !item.completed }
    else item
  { ui with items := newItems }

/-- Remove completed items -/
def clearCompleted (ui : TodoListUI) : TodoListUI :=
  { ui with items := ui.items.filter (!·.completed) }

end TodoListUI

-- Export for Main
def hello := "Todo List UI"
