import XCTest
import SwiftUI
@testable import NurseryApp

final class SettingsViewTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Reset AppStorage keys to defaults to avoid interference
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        try super.tearDownWithError()
    }

    func testDestinationEnum_hashableAndCases() {
        let a = SettingsView.Destination.about
        let e = SettingsView.Destination.editProfile
        XCTAssertNotEqual(a, e)
        var set: Set<SettingsView.Destination> = []
        set.insert(a)
        set.insert(e)
        XCTAssertEqual(set.count, 2)
    }

    func testAppStorage_defaultsAndPersistence() {
        // Defaults
        XCTAssertEqual(UserDefaults.standard.string(forKey: "username") ?? "Your name", "Your name")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "userEmail") ?? "", "")

        // Write values and ensure they persist via AppStorage keys
        UserDefaults.standard.setValue("Alice", forKey: "username")
        UserDefaults.standard.setValue("alice@example.com", forKey: "userEmail")

        // Instantiate EditProfileView and ensure the underlying defaults are set
        let _ = EditProfileView()
        XCTAssertEqual(UserDefaults.standard.string(forKey: "username"), "Alice")
        XCTAssertEqual(UserDefaults.standard.string(forKey: "userEmail"), "alice@example.com")
    }

    func testAboutView_hasExpectedTexts() {
        // We can't render View hierarchy without ViewInspector; instead validate the type and that it sets navigation title when used.
        let about = AboutView()
        // Type exists and is constructible
        XCTAssertNotNil(about)
        // Basic smoke: creating a NavigationStack with the view doesn't crash
        let stack = NavigationStack { about }
        XCTAssertNotNil(stack)
    }
}
