# Runnable Spec Demo - iOS

A demonstration iOS app showcasing two powerful approaches to "runnable specifications":

1. **UI Specs** - Describe user interfaces in plain text, rendered at runtime
2. **Behavior Specs** - Executable tests as living documentation

## What are Runnable Specs?

Runnable specifications are executable documentation that bridges the gap between human-readable descriptions and working code. This demo shows two complementary approaches:

### UI Specifications (Spec-Driven UI)
Write UI descriptions in natural language that the runtime parses and renders:

```
Screen "Login"
  VStack spacing: 20
    Image "person.circle.fill" size: 80
    Text "Welcome Back" style: title
    TextField "Email" binding: "email"
    SecureField "Password" binding: "password"
    Button "Sign In" action: "login"
```

The runtime **parses** this specification and **generates** the actual SwiftUI interface. Edit the spec, see the UI update instantly.

### Behavior Specifications (Executable Tests)
Traditional specs that verify implementation correctness:
- Specifications written in human-readable language
- Each spec executes to verify the implementation
- Results provide immediate pass/fail feedback
- Documentation stays in sync with code

## Features

### UI Specification Framework
A runtime parser and renderer that builds UIs from plain text specs:

- **Human-Readable DSL**: Describe screens, buttons, text fields in natural language
- **Runtime Parsing**: Specs are parsed on-the-fly and rendered as SwiftUI
- **Live Editing**: Edit specs and see UI update immediately
- **Interactive Preview**: Split-pane view with spec editor and live preview
- **Error Handling**: Parse errors are caught and displayed clearly

**Included UI Spec Examples:**
1. Login Screen - Authentication interface
2. Todo List - Task management UI
3. Settings - Toggles and preferences
4. Profile - User information display
5. Onboarding - Welcome flow
6. Contact Form - Data collection

### Behavior Specification Framework
A lightweight BDD-style testing framework:

- **Readable DSL**: Write specs in natural language
- **Multiple Assertion Types**: `expect()`, `expectNotNil()`, `expectThrows()`, etc.
- **Feature Grouping**: Organize specs by feature
- **Real-time Results**: See pass/fail status immediately

**Included Behavior Examples:**
1. **Calculator** - Arithmetic operations (includes intentional bug)
2. **User Authentication** - Session management (includes intentional bug)
3. **String Utilities** - String manipulation helpers

### Interactive UI

Built with SwiftUI, featuring:
- **Tab-Based Navigation**: Switch between UI specs and behavior specs
- **Live Spec Editor**: Edit UI specs and see changes instantly
- **Split-Pane View**: Spec source on one side, rendered UI on the other
- **Visual Feedback**: Color-coded pass/fail for behavior specs
- **Example Gallery**: Browse 6 UI specs and 20+ behavior specs

## Project Structure

```
RunnableSpecDemo/
├── RunnableSpecDemo.xcodeproj/      # Xcode project file
└── RunnableSpecDemo/
    ├── RunnableSpecDemoApp.swift     # App entry point
    ├── ContentView.swift             # Main UI with tabs
    ├── SpecFramework/
    │   ├── SpecFramework.swift       # Behavior spec framework
    │   ├── UISpecParser.swift        # UI spec parser
    │   └── UISpecBuilder.swift       # UI spec renderer
    ├── Examples/
    │   ├── Calculator.swift          # Calculator implementation
    │   └── UserAuth.swift            # User auth implementation
    ├── Specs/
    │   ├── ExampleSpecs.swift        # Behavior specifications
    │   └── UISpecs.swift             # UI specifications
    └── Assets.xcassets/              # App assets
```

## How to Use

### Running the App

1. Open `RunnableSpecDemo.xcodeproj` in Xcode
2. Select a simulator or device (iOS 17.0+)
3. Build and run (Cmd+R)

### Exploring UI Specs

1. **Browse Examples**: The app opens to the UI Specs tab showing 6 example screens
2. **Select a Spec**: Tap any example from the sidebar to see it rendered
3. **View Spec Source**: Click "Show Spec" to see the spec text side-by-side with the rendered UI
4. **Edit Live**: Modify the spec text and click "Update" to see changes instantly
5. **Experiment**: Try changing text, adding elements, or creating new layouts

### Exploring Behavior Specs

1. **Switch Tabs**: Tap the "Behavior Specs" tab at the bottom
2. **Browse Features**: Select features from the sidebar
3. **Run Specs**:
   - Click the play button next to individual specs
   - Use "Run Feature" to run all specs in a feature
   - Use "Run All" to execute the entire suite
4. **View Results**: Green checkmarks indicate passing specs, red X marks indicate failures

## Example Specs

### UI Spec Example

Here's what a UI spec looks like:

```
Screen "Login"
  VStack spacing: 20
    Image "person.circle.fill" size: 80
    Text "Welcome Back" style: title
    TextField "Email" binding: "email"
    SecureField "Password" binding: "password"
    Button "Sign In" action: "login"
```

The runtime parses this and renders:
- A screen titled "Login"
- A vertical stack with 20pt spacing
- An icon, title text, input fields, and button
- All fully interactive and styled

### Behavior Spec Example

Here's what a behavior spec looks like in code:

```swift
Spec("adds two positive numbers correctly") {
    let result = calculator.add(2, 3)
    return expect(result, toEqual: 5)
}
```

And how it appears in the UI:
- Description: "adds two positive numbers correctly"
- Status icon: ✓ (green) or ✗ (red)
- Result message: "Passed" or detailed failure reason

## Writing Your Own Specs

### UI Spec Syntax

**Supported Elements:**
- `Screen "Title"` - Root element with navigation title
- `VStack` / `HStack` - Vertical/horizontal layouts (optional `spacing: N`)
- `Text "Content"` - Labels (optional `style: title|headline|body|caption`)
- `TextField "Placeholder"` - Text input (requires `binding: "name"`)
- `SecureField "Placeholder"` - Password input (requires `binding: "name"`)
- `Button "Label"` - Buttons (optional `action: "actionName"`)
- `Toggle "Label"` - Switches (requires `binding: "name"`)
- `Image "system-name"` - SF Symbols (optional `size: N`)
- `List` - Scrollable lists
- `Spacer` - Flexible space
- `Divider` - Separator lines

**Example:**
```
Screen "My Screen"
  VStack spacing: 16
    Text "Hello World" style: title
    Button "Click Me" action: "myAction"
```

### Behavior Spec Syntax

**1. Define a Feature:**
```swift
let myFeature = Feature(
    name: "My Feature",
    description: "Description of what this feature does",
    specs: [/* specs here */]
)
```

**2. Write Specs:**
```swift
Spec("describes the expected behavior") {
    let result = systemUnderTest.doSomething()
    return expect(result, toEqual: expectedValue)
}
```

**3. Available Assertions:**
- `expect(_ actual, toEqual expected)` - Equality check
- `expect(_ condition, _ message)` - Boolean condition
- `expectNotNil(_ value)` - Non-nil check
- `expectNil(_ value)` - Nil check
- `expectThrows(_ block)` - Expects error to be thrown
- `expectNoThrow(_ block)` - Expects no error

## Intentional Bugs for Demo

The behavior specs include two intentional bugs to demonstrate failing specs:

1. **Calculator.power()**: Doesn't handle the zero exponent case correctly
2. **UserAuth.changePassword()**: Doesn't verify the old password before changing

Try running the behavior specs to see these failures in action!

## Benefits of Runnable Specs

### UI Specs
1. **Design Without Code**: Describe UIs in plain text, no Swift required
2. **Rapid Prototyping**: Iterate on UI designs with instant feedback
3. **Living Documentation**: UI specs are always accurate - they ARE the UI
4. **Version Control Friendly**: Text-based specs are easy to diff and review
5. **Accessibility**: Non-developers can write and understand UI specs

### Behavior Specs
1. **Self-Documenting Code**: Specs serve as both tests and documentation
2. **Immediate Verification**: Run specs anytime to verify correctness
3. **Behavior-Driven**: Focus on what the code should do, not how
4. **Living Documentation**: Specs that don't match implementation will fail
5. **Better Communication**: Readable specs bridge technical and non-technical stakeholders

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## License

This is a demonstration project for educational purposes.

## Learn More

For more on runnable specifications and related concepts:
- [Specification by Example](https://en.wikipedia.org/wiki/Specification_by_example)
- [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development)
- [Living Documentation](https://www.thoughtworks.com/insights/blog/living-documentation)
- [Declarative UI](https://en.wikipedia.org/wiki/Declarative_programming)
