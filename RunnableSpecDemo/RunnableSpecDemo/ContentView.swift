import SwiftUI

struct ContentView: View {
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
            .navigationTitle("Runnable Specs")
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
                WelcomeView()
            }
        }
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
