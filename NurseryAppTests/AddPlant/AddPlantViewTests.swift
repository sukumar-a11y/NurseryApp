import XCTest
import SwiftUI
@testable import NurseryApp

final class AddPlantViewTests: XCTestCase {
    func testPlantFactory_matchesAddViewSaveLogic() {
        // This verifies the trimming/defaulting logic used by AddPlantView.Save
        let name = "  My Plant  "
        let species = "  Fun  "
        let notes = "  Some notes  "
        let emoji = "  "

        let p = Plant.fromInput(name: name, species: species, description: notes, emoji: emoji)
        XCTAssertEqual(p.name, "My Plant")
        XCTAssertEqual(p.species, "Fun")
        XCTAssertEqual(p.description, "Some notes")
        XCTAssertEqual(p.emoji, "🪴")
    }

    func testOnSaveClosure_isCalledWhenInvoked() {
        let exp = expectation(description: "onSave called")
        let sample = Plant(name: "S")
        let view = AddPlantView { plant in
            XCTAssertEqual(plant.name, sample.name)
            exp.fulfill()
        }

        // We cannot programmatically tap the button without UI test frameworks, so call the closure to simulate
        view.onSave(sample)
        waitForExpectations(timeout: 1)
    }
}
