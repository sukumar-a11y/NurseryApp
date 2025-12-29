import XCTest
import SwiftUI
@testable import NurseryApp

final class ContentViewTests: XCTestCase {
    func testPlantCard_onToggleFavorite_triggersClosure() {
        var toggled = false
        let plant = Plant(name: "CardTest", emoji: "🌿")
        @Namespace var ns
        let card = PlantCardView(plant: plant, namespace: ns) {
            toggled = true
        }

        // Directly invoke the stored closure to simulate the button action
        card.onToggleFavorite?()
        XCTAssertTrue(toggled, "onToggleFavorite closure should be called when invoked")
    }

    func testPlantCard_reflectsModelValues() {
        let plant = Plant(name: "CardTwo", species: "Specie", emoji: "🌱", isFavorite: true)
        @Namespace var ns
        let card = PlantCardView(plant: plant, namespace: ns)

        // Validate model data used by the view
        XCTAssertEqual(card.plant.name, "CardTwo")
        XCTAssertEqual(card.plant.species, "Specie")
        XCTAssertEqual(card.plant.emoji, "🌱")
        XCTAssertTrue(card.plant.isFavorite)
    }
}
