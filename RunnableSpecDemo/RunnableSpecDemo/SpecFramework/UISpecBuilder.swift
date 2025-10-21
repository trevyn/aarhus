import SwiftUI

// MARK: - Spec-Driven UI Builder

public class UISpecState: ObservableObject {
    @Published public var bindings: [String: Any] = [:]
    @Published public var actions: [String: () -> Void] = [:]

    public init() {}

    public func getString(_ key: String) -> Binding<String> {
        Binding(
            get: { (self.bindings[key] as? String) ?? "" },
            set: { self.bindings[key] = $0 }
        )
    }

    public func getBool(_ key: String) -> Binding<Bool> {
        Binding(
            get: { (self.bindings[key] as? Bool) ?? false },
            set: { self.bindings[key] = $0 }
        )
    }

    public func registerAction(_ name: String, action: @escaping () -> Void) {
        actions[name] = action
    }

    public func performAction(_ name: String) {
        actions[name]?()
    }
}

public struct SpecDrivenView: View {
    let element: UIElement
    @ObservedObject var state: UISpecState

    public init(element: UIElement, state: UISpecState = UISpecState()) {
        self.element = element
        self.state = state
    }

    public var body: some View {
        buildView(for: element)
    }

    @ViewBuilder
    private func buildView(for element: UIElement) -> some View {
        switch element {
        case .screen(let title, let elements):
            NavigationView {
                VStack(spacing: 0) {
                    ForEach(elements) { child in
                        buildView(for: child)
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
            }

        case .button(let text, let action):
            Button(action: {
                if let action = action {
                    state.performAction(action)
                }
            }) {
                Text(text)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

        case .text(let content, let style):
            switch style {
            case .title:
                Text(content)
                    .font(.title)
                    .padding()
            case .headline:
                Text(content)
                    .font(.headline)
                    .padding()
            case .body:
                Text(content)
                    .font(.body)
                    .padding()
            case .caption:
                Text(content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }

        case .textField(let placeholder, let binding):
            TextField(placeholder, text: state.getString(binding))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

        case .secureField(let placeholder, let binding):
            SecureField(placeholder, text: state.getString(binding))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

        case .toggle(let label, let binding):
            Toggle(label, isOn: state.getBool(binding))
                .padding(.horizontal)

        case .image(let systemName, let size):
            Image(systemName: systemName)
                .font(.system(size: size ?? 24))
                .padding()

        case .vstack(let spacing, let elements):
            VStack(spacing: spacing ?? 8) {
                ForEach(elements) { child in
                    buildView(for: child)
                }
            }

        case .hstack(let spacing, let elements):
            HStack(spacing: spacing ?? 8) {
                ForEach(elements) { child in
                    buildView(for: child)
                }
            }

        case .spacer:
            Spacer()

        case .divider:
            Divider()
                .padding(.vertical)

        case .list(let elements):
            List {
                ForEach(elements) { child in
                    buildView(for: child)
                }
            }
        }
    }
}

// MARK: - Spec Runtime

public class UISpecRuntime: ObservableObject {
    @Published public var currentSpec: String = ""
    @Published public var parsedElement: UIElement?
    @Published public var parseError: String?
    public let state = UISpecState()

    private let parser = UISpecParser()

    public init() {}

    public func load(spec: String) {
        currentSpec = spec
        parse()
    }

    public func parse() {
        do {
            parsedElement = try parser.parse(currentSpec)
            parseError = nil
        } catch {
            parseError = error.localizedDescription
            parsedElement = nil
        }
    }

    public func registerAction(_ name: String, action: @escaping () -> Void) {
        state.registerAction(name, action: action)
    }
}
