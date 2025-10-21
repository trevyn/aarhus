import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            UISpecView()
                .tabItem {
                    Label("UI Specs", systemImage: "rectangle.on.rectangle")
                }
                .tag(0)

            BehaviorSpecView()
                .tabItem {
                    Label("Behavior Specs", systemImage: "checklist")
                }
                .tag(1)
        }
    }
}

// MARK: - UI Spec View (Main Feature)

struct UISpecView: View {
    @State private var selectedExample: UISpecExample?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedExample) {
                Section {
                    ForEach(uiSpecExamples) { example in
                        NavigationLink(value: example) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(example.name)
                                    .font(.headline)
                                Text(example.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("UI Specifications")
                        .font(.headline)
                }
            }
            .navigationTitle("Runnable UI Specs")
        } detail: {
            if let example = selectedExample {
                UISpecDetailView(example: example)
            } else {
                UIWelcomeView()
            }
        }
    }
}

struct UISpecDetailView: View {
    let example: UISpecExample
    @StateObject private var runtime = UISpecRuntime()
    @State private var showingEditor = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(example.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(example.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    showingEditor.toggle()
                }) {
                    Label(showingEditor ? "Hide Spec" : "Show Spec",
                          systemImage: showingEditor ? "chevron.right" : "chevron.left")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))

            // Content
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Rendered UI
                    ScrollView {
                        if let element = runtime.parsedElement {
                            SpecDrivenView(element: element, state: runtime.state)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let error = runtime.parseError {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.orange)
                                Text("Parse Error")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text(error)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    }
                    .frame(width: showingEditor ? geometry.size.width * 0.5 : geometry.size.width)

                    // Spec Editor
                    if showingEditor {
                        Divider()

                        SpecEditorView(runtime: runtime)
                            .frame(width: geometry.size.width * 0.5)
                    }
                }
            }
        }
        .onAppear {
            runtime.load(spec: example.spec)
            setupActions()
        }
    }

    private func setupActions() {
        runtime.registerAction("login") {
            print("Login action triggered")
        }
        runtime.registerAction("signup") {
            print("Sign up action triggered")
        }
        runtime.registerAction("addTodo") {
            print("Add todo action triggered")
        }
        runtime.registerAction("submit") {
            print("Submit action triggered")
        }
        runtime.registerAction("editProfile") {
            print("Edit profile action triggered")
        }
        runtime.registerAction("signOut") {
            print("Sign out action triggered")
        }
        runtime.registerAction("getStarted") {
            print("Get started action triggered")
        }
        runtime.registerAction("changePassword") {
            print("Change password action triggered")
        }
        runtime.registerAction("deleteAccount") {
            print("Delete account action triggered")
        }
    }
}

struct SpecEditorView: View {
    @ObservedObject var runtime: UISpecRuntime
    @State private var editedSpec: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Specification")
                    .font(.headline)
                Spacer()
                Button("Update") {
                    runtime.load(spec: editedSpec)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.gray.opacity(0.1))

            TextEditor(text: $editedSpec)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .padding(8)
                )
        }
        .onAppear {
            editedSpec = runtime.currentSpec
        }
    }
}

struct UIWelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "rectangle.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("Runnable UI Specifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Write UI specs in plain text, run them instantly")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 12) {
                FeatureItem(
                    icon: "doc.plaintext",
                    title: "Human-Readable",
                    description: "Describe UI in natural language"
                )

                FeatureItem(
                    icon: "arrow.triangle.2.circlepath.circle",
                    title: "Live Preview",
                    description: "See UI update as you edit specs"
                )

                FeatureItem(
                    icon: "hammer.fill",
                    title: "Runtime Parsing",
                    description: "Specs are parsed and rendered on-the-fly"
                )

                FeatureItem(
                    icon: "checkmark.seal.fill",
                    title: "Validated",
                    description: "Parse errors are caught immediately"
                )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Text("Select a UI spec from the sidebar to see it in action")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: 600)
    }
}

// MARK: - Behavior Spec View (Original Feature)

struct BehaviorSpecView: View {
    @StateObject private var specSuite = createSpecSuite()
    @State private var selectedFeature: Feature?

    var body: some View {
        NavigationSplitView {
            // Sidebar - Feature List
            List(selection: $selectedFeature) {
                Section {
                    ForEach(specSuite.features) { feature in
                        NavigationLink(value: feature) {
                            FeatureRow(feature: feature)
                        }
                    }
                } header: {
                    Text("Features")
                        .font(.headline)
                }

                Section {
                    SummaryView(suite: specSuite)
                } header: {
                    Text("Summary")
                        .font(.headline)
                }
            }
            .navigationTitle("Behavior Specs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        specSuite.runAll()
                    }) {
                        Label("Run All", systemImage: "play.fill")
                    }
                }
            }
        } detail: {
            if let feature = selectedFeature {
                FeatureDetailView(feature: feature)
            } else {
                BehaviorWelcomeView()
            }
        }
    }
}

struct BehaviorWelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("Behavior Specifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Executable tests as living documentation")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                FeatureItem(
                    icon: "doc.richtext",
                    title: "Readable Specs",
                    description: "Specifications written in natural language"
                )

                FeatureItem(
                    icon: "play.circle",
                    title: "Executable",
                    description: "Run specs to verify implementation"
                )

                FeatureItem(
                    icon: "checkmark.circle",
                    title: "Immediate Feedback",
                    description: "See results instantly with pass/fail status"
                )

                FeatureItem(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Living Documentation",
                    description: "Specs stay in sync with code"
                )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Text("Select a feature from the sidebar to get started")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: 600)
    }
}

struct FeatureRow: View {
    @ObservedObject var feature: Feature

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(feature.name)
                .font(.headline)

            Text(feature.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if feature.specs.contains(where: { $0.hasRun }) {
                HStack(spacing: 12) {
                    Label("\(feature.passCount)", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)

                    Label("\(feature.failCount)", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)

                    Spacer()

                    Text("\(feature.totalCount) specs")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FeatureDetailView: View {
    @ObservedObject var feature: Feature

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(feature.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(feature.description)
                    .font(.body)
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.top, 8)
            }
            .padding()

            // Specs List
            List {
                ForEach(feature.specs) { spec in
                    SpecRow(spec: spec)
                }
            }
            .listStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    feature.runAll()
                }) {
                    Label("Run Feature", systemImage: "play.fill")
                }
            }
        }
    }
}

struct SpecRow: View {
    @ObservedObject var spec: Spec

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status Icon
            statusIcon
                .frame(width: 24, height: 24)

            // Spec Description
            VStack(alignment: .leading, spacing: 4) {
                Text(spec.description)
                    .font(.body)

                if spec.hasRun {
                    Text(spec.result.message)
                        .font(.caption)
                        .foregroundColor(resultColor)
                }
            }

            Spacer()

            // Run Button
            Button(action: {
                spec.run()
            }) {
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var statusIcon: some View {
        if !spec.hasRun {
            Image(systemName: "circle")
                .foregroundColor(.gray)
        } else if spec.result.isPassing {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        } else {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        }
    }

    private var resultColor: Color {
        if !spec.hasRun {
            return .secondary
        } else if spec.result.isPassing {
            return .green
        } else {
            return .red
        }
    }
}

struct SummaryView: View {
    @ObservedObject var suite: SpecSuite

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
                Text("\(suite.totalSpecs) Total Specs")
            }

            if suite.totalPassed > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(suite.totalPassed) Passed")
                }
            }

            if suite.totalFailed > 0 {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("\(suite.totalFailed) Failed")
                }
            }

            if suite.totalPassed + suite.totalFailed == suite.totalSpecs {
                Divider()

                let percentage = Double(suite.totalPassed) / Double(suite.totalSpecs) * 100
                Text("Coverage: \(Int(percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .font(.callout)
        .padding(.vertical, 4)
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("Runnable Specifications")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Living documentation that executes")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                FeatureItem(
                    icon: "doc.richtext",
                    title: "Readable Specs",
                    description: "Specifications written in natural language"
                )

                FeatureItem(
                    icon: "play.circle",
                    title: "Executable",
                    description: "Run specs to verify implementation"
                )

                FeatureItem(
                    icon: "checkmark.circle",
                    title: "Immediate Feedback",
                    description: "See results instantly with pass/fail status"
                )

                FeatureItem(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Living Documentation",
                    description: "Specs stay in sync with code"
                )
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Text("Select a feature from the sidebar to get started")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: 600)
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
