# Runnable Spec Demo - iOS

A demonstration iOS app showcasing the concept of "runnable specifications" - living documentation that can be executed to verify implementation correctness.

## What are Runnable Specs?

Runnable specifications are a form of executable documentation where:
- Specifications are written in human-readable language
- Each spec can be executed to verify the implementation
- Results provide immediate feedback (pass/fail)
- Documentation stays in sync with code through continuous verification

This approach combines the clarity of documentation with the reliability of automated testing, creating "living documentation" that evolves with your codebase.

## Features

### Spec Framework
The app includes a lightweight BDD-style specification framework with:
- **Readable DSL**: Write specs in natural language
- **Multiple Assertion Types**: `expect()`, `expectNotNil()`, `expectThrows()`, etc.
- **Feature Grouping**: Organize specs by feature
- **Real-time Results**: See pass/fail status immediately

### Demo Implementations

The demo includes three example features:

1. **Calculator** - Basic arithmetic operations
   - Addition, subtraction, multiplication, division
   - Error handling (division by zero)
   - Includes one intentional bug (power function) to demonstrate failing specs

2. **User Authentication** - Session management system
   - User registration with validation
   - Login/logout functionality
   - Password change
   - Includes one intentional bug (password change validation) to demonstrate failing specs

3. **String Utilities** - String manipulation helpers
   - String reversal
   - Vowel counting
   - Palindrome detection

### Interactive UI

Built with SwiftUI, the app provides:
- **Sidebar Navigation**: Browse all features and specs
- **Individual Spec Execution**: Run specs one at a time
- **Batch Execution**: Run all specs in a feature or entire suite
- **Visual Feedback**: Color-coded pass/fail indicators
- **Summary Statistics**: Track overall test coverage and results

## Project Structure

```
RunnableSpecDemo/
├── RunnableSpecDemo.xcodeproj/    # Xcode project file
└── RunnableSpecDemo/
    ├── RunnableSpecDemoApp.swift   # App entry point
    ├── ContentView.swift           # Main UI
    ├── SpecFramework/
    │   └── SpecFramework.swift     # Core spec framework
    ├── Examples/
    │   ├── Calculator.swift        # Example: Calculator implementation
    │   └── UserAuth.swift          # Example: User auth implementation
    ├── Specs/
    │   └── ExampleSpecs.swift      # Runnable specifications
    └── Assets.xcassets/            # App assets
```

## How to Use

### Running the App

1. Open `RunnableSpecDemo.xcodeproj` in Xcode
2. Select a simulator or device (iOS 17.0+)
3. Build and run (Cmd+R)

### Navigating the Interface

1. **Browse Features**: Select features from the sidebar
2. **Run Specs**:
   - Click the play button next to individual specs
   - Use "Run Feature" to run all specs in a feature
   - Use "Run All" to execute the entire suite
3. **View Results**: Green checkmarks indicate passing specs, red X marks indicate failures
4. **Read Failure Messages**: Failed specs show detailed error messages

## Example Spec

Here's what a spec looks like in code:

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

### 1. Define a Feature

```swift
let myFeature = Feature(
    name: "My Feature",
    description: "Description of what this feature does",
    specs: [
        // specs go here
    ]
)
```

### 2. Write Specs

```swift
Spec("describes the expected behavior") {
    // Arrange: Set up test conditions
    let sut = SystemUnderTest()

    // Act: Perform the action
    let result = sut.doSomething()

    // Assert: Verify the result
    return expect(result, toEqual: expectedValue)
}
```

### 3. Available Assertions

- `expect(_ actual, toEqual expected)` - Equality check
- `expect(_ condition, _ message)` - Boolean condition
- `expectNotNil(_ value)` - Non-nil check
- `expectNil(_ value)` - Nil check
- `expectThrows(_ block)` - Expects error to be thrown
- `expectNoThrow(_ block)` - Expects no error

### 4. Add to Suite

```swift
func createSpecSuite() -> SpecSuite {
    return SpecSuite(features: [
        myFeature,
        // ... other features
    ])
}
```

## Intentional Bugs for Demo

The demo includes two intentional bugs to demonstrate failing specs:

1. **Calculator.power()**: Doesn't handle the zero exponent case correctly
2. **UserAuth.changePassword()**: Doesn't verify the old password before changing

Try running the specs to see these failures in action!

## Benefits of Runnable Specs

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

For more on runnable specifications and behavior-driven development:
- [Specification by Example](https://en.wikipedia.org/wiki/Specification_by_example)
- [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development)
- [Living Documentation](https://www.thoughtworks.com/insights/blog/living-documentation)
