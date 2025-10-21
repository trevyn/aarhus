import SwiftUI

// MARK: - UI Element Types

public enum UIElement: Equatable, Identifiable {
    case screen(title: String, elements: [UIElement])
    case button(text: String, action: String?)
    case text(content: String, style: TextStyle)
    case textField(placeholder: String, binding: String)
    case secureField(placeholder: String, binding: String)
    case toggle(label: String, binding: String)
    case image(systemName: String, size: CGFloat?)
    case vstack(spacing: CGFloat?, elements: [UIElement])
    case hstack(spacing: CGFloat?, elements: [UIElement])
    case spacer
    case divider
    case list(elements: [UIElement])

    public var id: String {
        switch self {
        case .screen(let title, _): return "screen_\(title)"
        case .button(let text, _): return "button_\(text)"
        case .text(let content, _): return "text_\(content)"
        case .textField(let placeholder, _): return "textfield_\(placeholder)"
        case .secureField(let placeholder, _): return "securefield_\(placeholder)"
        case .toggle(let label, _): return "toggle_\(label)"
        case .image(let name, _): return "image_\(name)"
        case .vstack: return "vstack_\(UUID().uuidString)"
        case .hstack: return "hstack_\(UUID().uuidString)"
        case .spacer: return "spacer_\(UUID().uuidString)"
        case .divider: return "divider_\(UUID().uuidString)"
        case .list: return "list_\(UUID().uuidString)"
        }
    }
}

public enum TextStyle: String, Equatable {
    case title, headline, body, caption
}

// MARK: - UI Spec Parser

public class UISpecParser {
    public init() {}

    public func parse(_ spec: String) throws -> UIElement {
        let lines = spec.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.hasPrefix("//") }

        guard !lines.isEmpty else {
            throw ParseError.emptySpec
        }

        var index = 0
        return try parseElement(lines, index: &index, indentLevel: 0)
    }

    private func parseElement(_ lines: [String], index: inout Int, indentLevel: Int) throws -> UIElement {
        guard index < lines.count else {
            throw ParseError.unexpectedEnd
        }

        let line = lines[index]
        let currentIndent = countIndent(line)

        if currentIndent < indentLevel {
            throw ParseError.invalidIndent
        }

        let trimmed = line.trimmingCharacters(in: .whitespaces)
        index += 1

        // Parse screen
        if trimmed.hasPrefix("Screen") {
            let title = extractQuoted(from: trimmed, after: "Screen") ?? "Untitled"
            var children: [UIElement] = []

            while index < lines.count {
                let nextIndent = countIndent(lines[index])
                if nextIndent <= currentIndent { break }
                let child = try parseElement(lines, index: &index, indentLevel: currentIndent + 2)
                children.append(child)
            }

            return .screen(title: title, elements: children)
        }

        // Parse button
        if trimmed.hasPrefix("Button") {
            let text = extractQuoted(from: trimmed, after: "Button") ?? "Button"
            let action = extractAction(from: trimmed)
            return .button(text: text, action: action)
        }

        // Parse text
        if trimmed.hasPrefix("Text") {
            let content = extractQuoted(from: trimmed, after: "Text") ?? ""
            let style = extractStyle(from: trimmed)
            return .text(content: content, style: style)
        }

        // Parse text field
        if trimmed.hasPrefix("TextField") {
            let placeholder = extractQuoted(from: trimmed, after: "TextField") ?? "Enter text"
            let binding = extractBinding(from: trimmed) ?? "text"
            return .textField(placeholder: placeholder, binding: binding)
        }

        // Parse secure field
        if trimmed.hasPrefix("SecureField") {
            let placeholder = extractQuoted(from: trimmed, after: "SecureField") ?? "Enter password"
            let binding = extractBinding(from: trimmed) ?? "password"
            return .secureField(placeholder: placeholder, binding: binding)
        }

        // Parse toggle
        if trimmed.hasPrefix("Toggle") {
            let label = extractQuoted(from: trimmed, after: "Toggle") ?? "Toggle"
            let binding = extractBinding(from: trimmed) ?? "isOn"
            return .toggle(label: label, binding: binding)
        }

        // Parse image
        if trimmed.hasPrefix("Image") {
            let systemName = extractQuoted(from: trimmed, after: "Image") ?? "photo"
            let size = extractSize(from: trimmed)
            return .image(systemName: systemName, size: size)
        }

        // Parse VStack
        if trimmed.hasPrefix("VStack") {
            let spacing = extractSpacing(from: trimmed)
            var children: [UIElement] = []

            while index < lines.count {
                let nextIndent = countIndent(lines[index])
                if nextIndent <= currentIndent { break }
                let child = try parseElement(lines, index: &index, indentLevel: currentIndent + 2)
                children.append(child)
            }

            return .vstack(spacing: spacing, elements: children)
        }

        // Parse HStack
        if trimmed.hasPrefix("HStack") {
            let spacing = extractSpacing(from: trimmed)
            var children: [UIElement] = []

            while index < lines.count {
                let nextIndent = countIndent(lines[index])
                if nextIndent <= currentIndent { break }
                let child = try parseElement(lines, index: &index, indentLevel: currentIndent + 2)
                children.append(child)
            }

            return .hstack(spacing: spacing, elements: children)
        }

        // Parse List
        if trimmed.hasPrefix("List") {
            var children: [UIElement] = []

            while index < lines.count {
                let nextIndent = countIndent(lines[index])
                if nextIndent <= currentIndent { break }
                let child = try parseElement(lines, index: &index, indentLevel: currentIndent + 2)
                children.append(child)
            }

            return .list(elements: children)
        }

        // Parse Spacer
        if trimmed.hasPrefix("Spacer") {
            return .spacer
        }

        // Parse Divider
        if trimmed.hasPrefix("Divider") {
            return .divider
        }

        throw ParseError.unknownElement(trimmed)
    }

    private func countIndent(_ line: String) -> Int {
        var count = 0
        for char in line {
            if char == " " { count += 1 }
            else if char == "\t" { count += 4 }
            else { break }
        }
        return count
    }

    private func extractQuoted(from line: String, after prefix: String) -> String? {
        let pattern = "\(prefix)\\s+\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else {
            return nil
        }
        return String(line[range])
    }

    private func extractAction(from line: String) -> String? {
        let pattern = "action:\\s*\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else {
            return nil
        }
        return String(line[range])
    }

    private func extractBinding(from line: String) -> String? {
        let pattern = "binding:\\s*\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else {
            return nil
        }
        return String(line[range])
    }

    private func extractStyle(from line: String) -> TextStyle {
        if line.contains("style: title") { return .title }
        if line.contains("style: headline") { return .headline }
        if line.contains("style: caption") { return .caption }
        return .body
    }

    private func extractSpacing(from line: String) -> CGFloat? {
        let pattern = "spacing:\\s*(\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line),
              let spacing = Double(line[range]) else {
            return nil
        }
        return CGFloat(spacing)
    }

    private func extractSize(from line: String) -> CGFloat? {
        let pattern = "size:\\s*(\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line),
              let size = Double(line[range]) else {
            return nil
        }
        return CGFloat(size)
    }
}

public enum ParseError: Error, LocalizedError {
    case emptySpec
    case unexpectedEnd
    case invalidIndent
    case unknownElement(String)

    public var errorDescription: String? {
        switch self {
        case .emptySpec: return "Specification is empty"
        case .unexpectedEnd: return "Unexpected end of specification"
        case .invalidIndent: return "Invalid indentation"
        case .unknownElement(let element): return "Unknown element: \(element)"
        }
    }
}

// MARK: - UI Spec Validator

public class UISpecValidator {
    public static func validate(element: UIElement, spec: String) -> ValidationResult {
        do {
            let parser = UISpecParser()
            let parsedElement = try parser.parse(spec)
            return compare(actual: element, expected: parsedElement)
        } catch {
            return .failed("Failed to parse spec: \(error.localizedDescription)")
        }
    }

    private static func compare(actual: UIElement, expected: UIElement) -> ValidationResult {
        if actual == expected {
            return .passed
        } else {
            return .failed("UI does not match spec. Expected: \(expected), Actual: \(actual)")
        }
    }
}

public enum ValidationResult {
    case passed
    case failed(String)

    public var isPassing: Bool {
        if case .passed = self { return true }
        return false
    }

    public var message: String {
        switch self {
        case .passed: return "UI matches specification"
        case .failed(let reason): return reason
        }
    }
}
