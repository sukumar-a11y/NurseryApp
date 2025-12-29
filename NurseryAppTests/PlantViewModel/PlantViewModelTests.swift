import XCTest
@testable import NurseryApp
import CoreData

final class PlantViewModelTests: XCTestCase {
    private var viewModel: PlantViewModel!
    private var coreData: CoreDataManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Use an isolated in-memory Core Data manager for deterministic tests
        coreData = CoreDataManager.makeInMemoryManager()
        viewModel = PlantViewModel(coreDataManager: coreData, sampleData: false)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        coreData = nil
        try super.tearDownWithError()
    }

    func testInit_withNoSampleData_startsEmpty() {
        XCTAssertTrue(viewModel.plants.isEmpty, "ViewModel should start with empty plants when sampleData is false")
    }

    func testAddPlant_updatesPlantsArray() throws {
        let p = Plant(name: "VM Test", emoji: "🌱")
        let exp = expectation(description: "add")
        viewModel.add(p) {
            exp.fulfill()
        }
        waitForExpectations(timeout: 2)

        XCTAssertTrue(viewModel.plants.contains(where: { $0.id == p.id }))
    }

    func testRemovePlant_byPlant_removesFromArray() throws {
        let p = Plant(name: "ToRemove", emoji: "🪴")
        let addExp = expectation(description: "add")
        viewModel.add(p) { addExp.fulfill() }
        waitForExpectations(timeout: 2)

        let removeExp = expectation(description: "remove")
        viewModel.remove(plant: p) { removeExp.fulfill() }
        waitForExpectations(timeout: 2)

        XCTAssertFalse(viewModel.plants.contains(where: { $0.id == p.id }))
    }

    func testToggleFavorite_persistsFavoriteChange() throws {
        let p = Plant(name: "FavToggle", emoji: "⭐")
        let addExp = expectation(description: "add")
        viewModel.add(p) { addExp.fulfill() }
        waitForExpectations(timeout: 2)

        // Ensure present
        guard let before = viewModel.plant(withId: p.id) else { XCTFail("plant missing after add"); return }
        XCTAssertFalse(before.isFavorite)

        let toggleExp = expectation(description: "toggle")
        viewModel.toggleFavorite(plant: before) { toggleExp.fulfill() }
        waitForExpectations(timeout: 2)

        guard let after = viewModel.plant(withId: p.id) else { XCTFail("plant missing after toggle"); return }
        XCTAssertTrue(after.isFavorite)
    }

    func testMove_changesOrderOnly() throws {
        let p1 = Plant(name: "One")
        let p2 = Plant(name: "Two")
        let seedExp = expectation(description: "seed")
        let group = DispatchGroup()
        group.enter(); viewModel.add(p1) { group.leave() }
        group.enter(); viewModel.add(p2) { group.leave() }
        DispatchQueue.global().async {
            group.wait()
            seedExp.fulfill()
        }
        waitForExpectations(timeout: 3)

        // capture order
        let original = viewModel.plants.map { $0.id }
        XCTAssertEqual(original.count, 2)

        viewModel.move(from: IndexSet(integer: 0), to: 2)
        let moved = viewModel.plants.map { $0.id }
        XCTAssertNotEqual(original, moved)
        // ensure the set of ids remains same
        XCTAssertEqual(Set(original), Set(moved))
    }

    func testPlantWithId_returnsCorrectPlantOrNil() throws {
        let p = Plant(name: "Lookup")
        let addExp = expectation(description: "add")
        viewModel.add(p) { addExp.fulfill() }
        waitForExpectations(timeout: 2)

        let found = viewModel.plant(withId: p.id)
        XCTAssertNotNil(found)

        let notFound = viewModel.plant(withId: UUID())
        XCTAssertNil(notFound)
    }
}
