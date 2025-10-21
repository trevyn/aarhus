import Foundation

// MARK: - Example UI Specifications

public let loginScreenSpec = """
Screen "Login"
  VStack spacing: 20
    Image "person.circle.fill" size: 80
    Text "Welcome Back" style: title
    Text "Sign in to continue" style: caption
    TextField "Email" binding: "email"
    SecureField "Password" binding: "password"
    Button "Sign In" action: "login"
    Divider
    HStack spacing: 8
      Text "Don't have an account?" style: caption
      Button "Sign Up" action: "signup"
"""

public let todoListSpec = """
Screen "Todo List"
  VStack spacing: 16
    HStack spacing: 12
      TextField "New todo..." binding: "newTodo"
      Button "Add" action: "addTodo"
    Divider
    List
      HStack spacing: 12
        Toggle "Buy groceries" binding: "todo1"
        Spacer
      HStack spacing: 12
        Toggle "Finish project" binding: "todo2"
        Spacer
      HStack spacing: 12
        Toggle "Call mom" binding: "todo3"
        Spacer
"""

public let settingsScreenSpec = """
Screen "Settings"
  VStack spacing: 24
    VStack spacing: 12
      Text "Notifications" style: headline
      Toggle "Push Notifications" binding: "pushEnabled"
      Toggle "Email Notifications" binding: "emailEnabled"
      Toggle "SMS Notifications" binding: "smsEnabled"
    Divider
    VStack spacing: 12
      Text "Appearance" style: headline
      Toggle "Dark Mode" binding: "darkMode"
      Toggle "Compact Mode" binding: "compactMode"
    Divider
    VStack spacing: 12
      Text "Account" style: headline
      Button "Change Password" action: "changePassword"
      Button "Delete Account" action: "deleteAccount"
    Spacer
"""

public let profileScreenSpec = """
Screen "Profile"
  VStack spacing: 20
    Image "person.crop.circle.fill" size: 100
    Text "John Doe" style: title
    Text "john.doe@example.com" style: caption
    Divider
    VStack spacing: 16
      HStack spacing: 8
        Image "envelope.fill" size: 20
        Text "Email" style: body
        Spacer
        Text "john.doe@example.com" style: caption
      HStack spacing: 8
        Image "phone.fill" size: 20
        Text "Phone" style: body
        Spacer
        Text "+1 (555) 123-4567" style: caption
      HStack spacing: 8
        Image "location.fill" size: 20
        Text "Location" style: body
        Spacer
        Text "San Francisco, CA" style: caption
    Divider
    Button "Edit Profile" action: "editProfile"
    Button "Sign Out" action: "signOut"
    Spacer
"""

public let onboardingScreenSpec = """
Screen "Welcome"
  VStack spacing: 30
    Spacer
    Image "star.fill" size: 80
    Text "Welcome to SpecUI" style: title
    Text "Build interfaces from specifications" style: headline
    VStack spacing: 16
      HStack spacing: 12
        Image "doc.text.fill" size: 24
        VStack spacing: 4
          Text "Declarative" style: headline
          Text "Describe UI in plain text" style: caption
      HStack spacing: 12
        Image "bolt.fill" size: 24
        VStack spacing: 4
          Text "Fast" style: headline
          Text "Real-time updates" style: caption
      HStack spacing: 12
        Image "checkmark.circle.fill" size: 24
        VStack spacing: 4
          Text "Validated" style: headline
          Text "Specs are verified at runtime" style: caption
    Spacer
    Button "Get Started" action: "getStarted"
"""

public let formScreenSpec = """
Screen "Contact Form"
  VStack spacing: 16
    Text "Get in Touch" style: title
    Divider
    TextField "Full Name" binding: "fullName"
    TextField "Email Address" binding: "email"
    TextField "Phone Number" binding: "phone"
    VStack spacing: 8
      Text "Message" style: headline
      TextField "Your message..." binding: "message"
    Divider
    Toggle "Subscribe to newsletter" binding: "subscribe"
    Button "Submit" action: "submit"
    Spacer
"""

// MARK: - Spec Catalog

public struct UISpecExample: Identifiable {
    public let id = UUID()
    public let name: String
    public let description: String
    public let spec: String

    public init(name: String, description: String, spec: String) {
        self.name = name
        self.description = description
        self.spec = spec
    }
}

public let uiSpecExamples: [UISpecExample] = [
    UISpecExample(
        name: "Login Screen",
        description: "User authentication interface with email and password fields",
        spec: loginScreenSpec
    ),
    UISpecExample(
        name: "Todo List",
        description: "Task management interface with toggleable items",
        spec: todoListSpec
    ),
    UISpecExample(
        name: "Settings",
        description: "Application settings with toggles and action buttons",
        spec: settingsScreenSpec
    ),
    UISpecExample(
        name: "Profile",
        description: "User profile display with contact information",
        spec: profileScreenSpec
    ),
    UISpecExample(
        name: "Onboarding",
        description: "Welcome screen with feature highlights",
        spec: onboardingScreenSpec
    ),
    UISpecExample(
        name: "Contact Form",
        description: "Data collection form with validation",
        spec: formScreenSpec
    )
]
