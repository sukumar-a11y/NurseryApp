import XCTest
@testable import NurseryApp

final class PlantTests: XCTestCase {
    func testFromInput_trimsAndDefaults() {
        let p = Plant.fromInput(name: "  Alice  ", species: "  MySpecies  ", description: "  Notes  ", emoji: "")
        XCTAssertEqual(p.name, "Alice")
        XCTAssertEqual(p.species, "MySpecies")
        XCTAssertEqual(p.description, "Notes")
        XCTAssertEqual(p.emoji, "🪴")
    }

    func testFromInput_emptySpeciesAndDescriptionBecomesNil() {
        let p = Plant.fromInput(name: "Bob", species: "  ", description: "  ", emoji: "🌿")
        XCTAssertEqual(p.name, "Bob")
        XCTAssertNil(p.species)
        XCTAssertNil(p.description)
        XCTAssertEqual(p.emoji, "🌿")
    }

    func testInit_defaultsFavoriteFalse() {
        let p = Plant(name: "Test")
        XCTAssertFalse(p.isFavorite)
    }
}
