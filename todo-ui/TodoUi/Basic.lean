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

/-- Right edge x-coordinate -/
def right (b : Bounds) : Nat := b.pos.x + b.size.width

/-- Bottom edge y-coordinate -/
def bottom (b : Bounds) : Nat := b.pos.y + b.size.height

/-- Check if two 1D intervals overlap: [a1, a2) and [b1, b2) -/
def intervalsOverlap (a1 a2 b1 b2 : Nat) : Bool :=
  a1 < b2 && b1 < a2

/-- Check if two bounds overlap (have non-empty intersection) -/
def overlaps (b1 b2 : Bounds) : Bool :=
  intervalsOverlap b1.pos.x b1.right b2.pos.x b2.right &&
  intervalsOverlap b1.pos.y b1.bottom b2.pos.y b2.bottom

/-- Two bounds are disjoint (do not overlap) -/
def disjoint (b1 b2 : Bounds) : Prop := overlaps b1 b2 = false

instance : Decidable (disjoint b1 b2) :=
  inferInstanceAs (Decidable (overlaps b1 b2 = false))

/-- Proof: if b2 starts at or after b1 ends vertically, they're disjoint -/
theorem disjoint_if_vertical_gap (b1 b2 : Bounds)
    (h : b1.bottom ≤ b2.pos.y) : disjoint b1 b2 := by
  unfold disjoint overlaps intervalsOverlap bottom right
  have hNotLt : ¬(b2.pos.y < b1.pos.y + b1.size.height) := Nat.not_lt.mpr h
  simp [hNotLt]

/-- Proof: if b2 starts at or after b1 ends horizontally, they're disjoint -/
theorem disjoint_if_horizontal_gap (b1 b2 : Bounds)
    (h : b1.right ≤ b2.pos.x) : disjoint b1 b2 := by
  unfold disjoint overlaps intervalsOverlap right bottom
  have hNotLt : ¬(b2.pos.x < b1.pos.x + b1.size.width) := Nat.not_lt.mpr h
  simp [hNotLt]

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

/-- Two UI elements are disjoint if their bounds don't overlap -/
def disjoint (e1 e2 : UIElement) : Prop := Bounds.disjoint e1.bounds e2.bounds

instance : Decidable (disjoint e1 e2) :=
  inferInstanceAs (Decidable (Bounds.disjoint e1.bounds e2.bounds))

end UIElement

/-- Check if element e is disjoint from all elements in a list -/
def disjointFromAll (e : UIElement) : List UIElement → Bool
  | [] => true
  | e' :: es => !Bounds.overlaps e.bounds e'.bounds && disjointFromAll e es

/-- Check if all UI elements in a list are pairwise disjoint (computable) -/
def checkNoOverlaps : List UIElement → Bool
  | [] => true
  | e :: es => disjointFromAll e es && checkNoOverlaps es

/-- All pairs of elements in a list are disjoint (propositional version) -/
def AllPairwiseDisjoint (elements : List UIElement) : Prop :=
  checkNoOverlaps elements = true

/-- Get all overlapping pairs (for debugging) -/
def findOverlaps (elements : List UIElement) : List (UIElement × UIElement) :=
  let rec collectPairs : List UIElement → List (UIElement × UIElement)
    | [] => []
    | e1 :: rest =>
      let overlapsWithE1 := rest.filterMap fun e2 =>
        if Bounds.overlaps e1.bounds e2.bounds then some (e1, e2) else none
      overlapsWithE1 ++ collectPairs rest
  collectPairs elements

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

/-! ## Layout Proofs -/

/-- Helper: create a bounds at given position -/
def mkBounds (x y w h : Nat) : Bounds :=
  { pos := { x := x, y := y }, size := { width := w, height := h } }

/-- Theorem: Two vertically stacked elements with gap ≥ height don't overlap -/
theorem verticalStack_disjoint (y1 y2 h1 w1 w2 h2 x : Nat)
    (hGap : y1 + h1 ≤ y2) :
    Bounds.disjoint (mkBounds x y1 w1 h1) (mkBounds x y2 w2 h2) := by
  apply Bounds.disjoint_if_vertical_gap
  simp [mkBounds, Bounds.bottom]
  exact hGap

/-- Theorem: Two horizontally adjacent elements with gap don't overlap -/
theorem horizontalStack_disjoint (x1 x2 y w1 h1 w2 h2 : Nat)
    (hGap : x1 + w1 ≤ x2) :
    Bounds.disjoint (mkBounds x1 y w1 h1) (mkBounds x2 y w2 h2) := by
  apply Bounds.disjoint_if_horizontal_gap
  simp [mkBounds, Bounds.right]
  exact hGap

/-- Our item layout: each item is at y = 50 + idx * 30, height 25.
    Gap of 5 pixels between items. -/
theorem todoItems_noOverlap (i j : Nat) (hi : i < j) :
    Bounds.disjoint
      (mkBounds itemX (itemStartY + i * itemHeight) 300 25)
      (mkBounds itemX (itemStartY + j * itemHeight) 300 25) := by
  apply Bounds.disjoint_if_vertical_gap
  simp [mkBounds, Bounds.bottom, itemStartY, itemHeight]
  omega

/-- Title is above all todo items -/
theorem title_above_items (idx : Nat) :
    Bounds.disjoint
      (mkBounds itemX titleY 200 30)
      (mkBounds itemX (itemStartY + idx * itemHeight) 300 25) := by
  apply Bounds.disjoint_if_vertical_gap
  simp [mkBounds, Bounds.bottom, titleY, itemStartY, itemHeight]
  omega

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
