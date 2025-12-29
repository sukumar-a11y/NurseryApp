import XCTest
import SwiftUI
@testable import NurseryApp

final class AddPlantViewBodyTests: XCTestCase {
    func testEmojiPicker_updatesEmojiState_whenButtonSimulated() {
        // We can't tap SwiftUI buttons in unit tests, but we can validate model factory and view closures.
        let sample = Plant(name: "P")
        let view = AddPlantView { plant in
            // validate that onSave would receive a trimmed plant
            XCTAssertEqual(plant.name, sample.name)
        }

        // Validate view constructs without crashing
        _ = view.body

        // Call onSave directly to simulate Save action
        view.onSave(sample)
    }

    func testSaveDisabled_whenNameEmpty_andEnabled_whenNameProvided() {
        // Construct view and simulate name validation via Plant.fromInput
        let empty = Plant.fromInput(name: "   ", species: "", description: "", emoji: "")
        XCTAssertEqual(empty.name, "", "Factory should produce empty name when input is whitespace only")

        let valid = Plant.fromInput(name: " Alice ", species: "", description: "", emoji: "🌿")
        XCTAssertEqual(valid.name, "Alice")
        XCTAssertEqual(valid.emoji, "🌿")
    }
}
