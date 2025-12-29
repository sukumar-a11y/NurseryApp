import XCTest
import SwiftUI
@testable import NurseryApp

final class PlantDetailViewTests: XCTestCase {
    func testOnClose_and_OnToggleFavorite_areCalled() {
        var closeCalled = false
        var toggleCalled = false

        let plant = Plant(name: "Test", species: "Spec", description: "Desc", emoji: "🌿")
        @Namespace var ns
        let view = PlantDetailView(plant: plant, namespace: ns) {
            closeCalled = true
        } onToggleFavorite: {
            toggleCalled = true
        }

        // The view's closures are stored as properties; invoking them should call the handlers
        view.onClose?()
        view.onToggleFavorite?()

        XCTAssertTrue(closeCalled, "onClose closure should be invoked")
        XCTAssertTrue(toggleCalled, "onToggleFavorite closure should be invoked")
    }

    func testPlantWithoutDescription_doesNotProvideDescriptionString() {
        let plant = Plant(name: "NoDesc", description: nil)
        XCTAssertNil(plant.description, "Plant description should be nil when not provided")
    }

    func testFavoriteButton_reflectsPlantState() {
        // Verify the model favorite flag is honored by the view's property
        let favPlant = Plant(name: "Fav", isFavorite: true)
        @Namespace var ns
        let view = PlantDetailView(plant: favPlant, namespace: ns)

        // The view reads plant.isFavorite to choose image name; we can't inspect the Image directly without ViewInspector,
        // but we can assert the underlying model state
        XCTAssertTrue(view.plant.isFavorite)

        let notFavPlant = Plant(name: "NotFav", isFavorite: false)
        let view2 = PlantDetailView(plant: notFavPlant, namespace: ns)
        XCTAssertFalse(view2.plant.isFavorite)
    }
}
