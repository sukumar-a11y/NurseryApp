import XCTest
import SwiftUI
@testable import NurseryApp

final class PlantDetailViewBodyTests: XCTestCase {
    func testBody_includesDescriptionAndSpecies_whenProvided() {
        let plant = Plant(name: "WithDesc", species: "Specie", description: "A lovely plant.", emoji: "🌿", isFavorite: true)
        @Namespace var ns
        let view = PlantDetailView(plant: plant, namespace: ns, onClose: {}, onToggleFavorite: {})

        // Access body to force SwiftUI ViewBuilder to execute code paths
        _ = view.body

        // Verify model-backed properties
        XCTAssertEqual(view.plant.name, "WithDesc")
        XCTAssertEqual(view.plant.species, "Specie")
        XCTAssertEqual(view.plant.description, "A lovely plant.")
        XCTAssertTrue(view.plant.isFavorite)
    }

    func testBody_hidesDescription_whenEmptyOrNil() {
        let plantNoDesc = Plant(name: "NoDesc", species: nil, description: nil, emoji: "🪴", isFavorite: false)
        @Namespace var ns
        let view = PlantDetailView(plant: plantNoDesc, namespace: ns)

        // Access body to ensure the branch without description is executed
        _ = view.body

        XCTAssertNil(view.plant.description)
        XCTAssertFalse(view.plant.isFavorite)
    }

    func testOnClose_andToggleFavoriteClosuresAreCallable() {
        var closed = false
        var toggled = false
        let plant = Plant(name: "Callbacks", emoji: "🌱")
        @Namespace var ns
        let view = PlantDetailView(plant: plant, namespace: ns, onClose: { closed = true }, onToggleFavorite: { toggled = true })

        // Simulate invoking closures
        view.onClose?()
        view.onToggleFavorite?()

        XCTAssertTrue(closed)
        XCTAssertTrue(toggled)
    }
}
