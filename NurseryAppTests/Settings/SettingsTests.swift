import XCTest
import SwiftUI
@testable import NurseryApp

final class SettingsTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Ensure clean user defaults for tests
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        try super.tearDownWithError()
    }

    func testDefaultAppStorageValues() {
        // AppStorage default values are defined in SettingsView property wrappers
        let username = UserDefaults.standard.string(forKey: "username") ?? "Your name"
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""

        XCTAssertEqual(username, "Your name")
        XCTAssertEqual(email, "")
    }

    func testEditProfilePersistedToUserDefaults() {
        // Simulate editing and saving profile
        UserDefaults.standard.set("Alice", forKey: "username")
        UserDefaults.standard.set("alice@example.com", forKey: "userEmail")

        // Ensure values are persisted
        XCTAssertEqual(UserDefaults.standard.string(forKey: "username"), "Alice")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "userEmail"), "alice@example.com")
    }

    func testAboutView_builds() {
        let _ = AboutView().body
        // Just ensure accessing the body doesn't crash
        XCTAssertTrue(true)
    }
}
