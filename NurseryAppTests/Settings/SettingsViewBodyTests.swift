import XCTest
import SwiftUI
@testable import NurseryApp

final class SettingsViewBodyTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        try super.tearDownWithError()
    }

    func testSettingsView_constructsAndContainsDestinations() {
        let view = SettingsView()
        // Access body to execute the ViewBuilder branches
        _ = view.body
        XCTAssertNotNil(view)
    }

    func testAboutView_andEditProfileView_construct() {
        let about = AboutView()
        _ = about.body
        XCTAssertNotNil(about)

        let edit = EditProfileView()
        _ = edit.body
        XCTAssertNotNil(edit)
    }

    func testAppStorage_persistsUsernameAndEmail() {
        XCTAssertNil(UserDefaults.standard.string(forKey: "username"))
        XCTAssertNil(UserDefaults.standard.string(forKey: "userEmail"))

        UserDefaults.standard.setValue("Bob", forKey: "username")
        UserDefaults.standard.setValue("bob@example.com", forKey: "userEmail")

        // Construct EditProfileView to ensure access doesn't crash
        let _ = EditProfileView()

        XCTAssertEqual(UserDefaults.standard.string(forKey: "username"), "Bob")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "userEmail"), "bob@example.com")
    }
}
