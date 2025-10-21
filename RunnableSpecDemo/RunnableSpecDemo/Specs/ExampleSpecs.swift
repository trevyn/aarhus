import Foundation

// MARK: - Calculator Specs

func createCalculatorSpecs() -> Feature {
    let calculator = Calculator()

    return Feature(
        name: "Calculator",
        description: "A simple calculator that performs basic arithmetic operations",
        specs: [
            Spec("adds two positive numbers correctly") {
                let result = calculator.add(2, 3)
                return expect(result, toEqual: 5)
            },

            Spec("adds negative numbers correctly") {
                let result = calculator.add(-5, -3)
                return expect(result, toEqual: -8)
            },

            Spec("subtracts numbers correctly") {
                let result = calculator.subtract(10, 3)
                return expect(result, toEqual: 7)
            },

            Spec("multiplies numbers correctly") {
                let result = calculator.multiply(4, 5)
                return expect(result, toEqual: 20)
            },

            Spec("divides numbers correctly") {
                let result = try? calculator.divide(20, 4)
                return expect(result, toEqual: 5)
            },

            Spec("throws error when dividing by zero") {
                return expectThrows {
                    try calculator.divide(10, 0)
                }
            },

            Spec("calculates power correctly for positive exponent") {
                let result = calculator.power(2, 3)
                return expect(result, toEqual: 8)
            },

            // This spec will fail due to the bug in power()
            Spec("handles zero exponent correctly") {
                let result = calculator.power(5, 0)
                return expect(result, toEqual: 1)
            }
        ]
    )
}

// MARK: - User Authentication Specs

func createUserAuthSpecs() -> Feature {
    let auth = UserAuth()

    return Feature(
        name: "User Authentication",
        description: "User registration, login, and session management",
        specs: [
            Spec("allows registration with valid credentials") {
                return expectNoThrow {
                    try auth.register(username: "alice", password: "password123")
                }
            },

            Spec("rejects username shorter than 3 characters") {
                return expectThrows {
                    try auth.register(username: "ab", password: "password123")
                }
            },

            Spec("rejects password shorter than 8 characters") {
                return expectThrows {
                    try auth.register(username: "bob", password: "pass")
                }
            },

            Spec("prevents duplicate username registration") {
                _ = try? auth.register(username: "charlie", password: "password123")
                return expectThrows {
                    try auth.register(username: "charlie", password: "different456")
                }
            },

            Spec("allows login with correct credentials") {
                _ = try? auth.register(username: "david", password: "password123")
                let result = auth.login(username: "david", password: "password123")
                return expect(result, "Login should succeed")
            },

            Spec("rejects login with incorrect password") {
                _ = try? auth.register(username: "eve", password: "password123")
                let result = auth.login(username: "eve", password: "wrongpass")
                return expect(!result, "Login should fail with wrong password")
            },

            Spec("tracks logged in status correctly") {
                _ = try? auth.register(username: "frank", password: "password123")
                _ = auth.login(username: "frank", password: "password123")
                return expect(auth.isLoggedIn(), "Should be logged in")
            },

            Spec("clears session on logout") {
                _ = try? auth.register(username: "grace", password: "password123")
                _ = auth.login(username: "grace", password: "password123")
                auth.logout()
                return expect(!auth.isLoggedIn(), "Should be logged out")
            },

            // This spec will fail due to the bug in changePassword()
            Spec("requires old password to change password") {
                let auth2 = UserAuth()
                _ = try? auth2.register(username: "henry", password: "password123")
                _ = auth2.login(username: "henry", password: "password123")

                // This should fail but won't due to the bug
                do {
                    try auth2.changePassword(oldPassword: "wrongoldpass", newPassword: "newpassword456")
                    return .failed("Should have rejected wrong old password")
                } catch {
                    return .passed
                }
            }
        ]
    )
}

// MARK: - Additional Feature Specs

func createStringUtilsSpecs() -> Feature {
    return Feature(
        name: "String Utilities",
        description: "Helper functions for string manipulation",
        specs: [
            Spec("reverses a string correctly") {
                let result = String("hello".reversed())
                return expect(result, toEqual: "olleh")
            },

            Spec("counts vowels in a string") {
                let vowels = "hello world".filter { "aeiouAEIOU".contains($0) }
                return expect(vowels.count, toEqual: 3)
            },

            Spec("checks if string is palindrome") {
                let str = "racecar"
                let isPalindrome = str == String(str.reversed())
                return expect(isPalindrome, "Should be a palindrome")
            },

            Spec("detects non-palindrome") {
                let str = "hello"
                let isPalindrome = str == String(str.reversed())
                return expect(!isPalindrome, "Should not be a palindrome")
            }
        ]
    )
}

// MARK: - Suite Builder

func createSpecSuite() -> SpecSuite {
    return SpecSuite(features: [
        createCalculatorSpecs(),
        createUserAuthSpecs(),
        createStringUtilsSpecs()
    ])
}
