import Foundation

// Example implementation: User Authentication System
public class UserAuth {
    private var users: [String: User] = [:]
    private var currentUser: User?

    public init() {}

    public func register(username: String, password: String) throws {
        guard username.count >= 3 else {
            throw AuthError.usernameTooShort
        }
        guard password.count >= 8 else {
            throw AuthError.passwordTooShort
        }
        guard users[username] == nil else {
            throw AuthError.userAlreadyExists
        }

        users[username] = User(username: username, password: password)
    }

    public func login(username: String, password: String) -> Bool {
        guard let user = users[username] else { return false }
        guard user.password == password else { return false }

        currentUser = user
        return true
    }

    public func logout() {
        currentUser = nil
    }

    public func isLoggedIn() -> Bool {
        return currentUser != nil
    }

    public func getCurrentUsername() -> String? {
        return currentUser?.username
    }

    // Intentionally buggy method for demonstration
    public func changePassword(oldPassword: String, newPassword: String) throws {
        guard let user = currentUser else {
            throw AuthError.notLoggedIn
        }

        // Bug: Not checking if old password matches
        guard newPassword.count >= 8 else {
            throw AuthError.passwordTooShort
        }

        users[user.username]?.password = newPassword
    }
}

public struct User {
    let username: String
    var password: String
}

public enum AuthError: Error {
    case usernameTooShort
    case passwordTooShort
    case userAlreadyExists
    case notLoggedIn
    case invalidCredentials
}
