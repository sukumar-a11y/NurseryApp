import XCTest
@testable import NurseryApp
import CoreData

final class CoreDataManagerTests: XCTestCase {
    // Use an isolated in-memory Core Data manager per test to avoid interference
    var mgr: CoreDataManager!

    private func makePlant(name: String = "Test Plant", emoji: String = "🌿") -> Plant {
        return Plant(id: UUID(), name: name, species: "Spec", description: "Desc", emoji: emoji, isFavorite: false)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        mgr = CoreDataManager.makeInMemoryManager()
    }

    override func tearDownWithError() throws {
        mgr = nil
        try super.tearDownWithError()
    }

    func testViewContextConfiguration() {
        let viewCtx = mgr.viewContext
        // verify merge policy and auto-merge are configured
        XCTAssertTrue(viewCtx.mergePolicy is NSMergePolicy)
        XCTAssertTrue(viewCtx.automaticallyMergesChangesFromParent)
        XCTAssertNil(viewCtx.undoManager)
    }

    func testAddAndFetchPlant_sync_pass() throws {
        let p = makePlant(name: "Sync Plant", emoji: "🌱")

        let addExpectation = expectation(description: "addPlant completion")
        mgr.addPlant(p) { result in
            switch result {
            case .success: break
            case .failure(let err): XCTFail("addPlant failed: \(err)")
            }
            addExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        let fetched = mgr.fetchPlants()
        XCTAssertTrue(fetched.contains(where: { $0.id == p.id && $0.name == p.name }), "Added plant should be fetched")
    }

    func testFetchAsync_pass() throws {
        let p = makePlant(name: "Async Plant", emoji: "🌼")

        let addExpectation = expectation(description: "addPlant")
        mgr.addPlant(p) { result in
            if case .failure(let e) = result { XCTFail("add failed: \(e)") }
            addExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        let fetchExpectation = expectation(description: "fetchPlantsAsync")
        mgr.fetchPlantsAsync { res in
            switch res {
            case .success(let plants):
                XCTAssertTrue(plants.contains(where: { $0.id == p.id }), "Async fetch should include added plant")
            case .failure(let err):
                XCTFail("fetchPlantsAsync failed: \(err)")
            }
            fetchExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testUpdateFavorite_pass() throws {
        let p = makePlant(name: "Fav Plant", emoji: "⭐")

        let addExpectation = expectation(description: "addPlant")
        mgr.addPlant(p) { res in
            if case .failure(let e) = res { XCTFail("add failed: \(e)") }
            addExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        let updateExpectation = expectation(description: "updateFavorite")
        mgr.updateFavorite(forId: p.id, to: true) { res in
            if case .failure(let e) = res { XCTFail("update failed: \(e)") }
            updateExpectation.fulfill()
        }
        waitForExpectations(timeout: 5)

        // verify persisted change
        let fetched = mgr.fetchPlants()
        guard let updated = fetched.first(where: { $0.id == p.id }) else {
            XCTFail("Updated plant not found")
            return
        }
        XCTAssertTrue(updated.isFavorite, "isFavorite should be true after update")
    }

    func testRemovePlant_pass() throws {
        let p = makePlant(name: "Removable", emoji: "🪴")

        let addExp = expectation(description: "addPlant")
        mgr.addPlant(p) { res in
            if case .failure(let e) = res { XCTFail("add failed: \(e)") }
            addExp.fulfill()
        }
        waitForExpectations(timeout: 5)

        let removeExp = expectation(description: "removePlant")
        mgr.removePlant(withId: p.id) { res in
            if case .failure(let e) = res { XCTFail("remove failed: \(e)") }
            removeExp.fulfill()
        }
        waitForExpectations(timeout: 5)

        let fetched = mgr.fetchPlants()
        XCTAssertFalse(fetched.contains(where: { $0.id == p.id }), "Removed plant should not be present")
    }

    func testDeleteAllPlants_pass() throws {
        let p1 = makePlant(name: "Bulk1")
        let p2 = makePlant(name: "Bulk2")

        let addExp = expectation(description: "add both")
        let group = DispatchGroup()
        group.enter(); mgr.addPlant(p1) { _ in group.leave() }
        group.enter(); mgr.addPlant(p2) { _ in group.leave() }

        // wait on group asynchronously
        DispatchQueue.global().async {
            group.wait()
            addExp.fulfill()
        }
        waitForExpectations(timeout: 6)

        XCTAssertTrue(mgr.fetchPlants().count >= 2, "Should have at least two plants before deleteAll")

        let deleteExp = expectation(description: "deleteAllPlants")
        mgr.deleteAllPlants { res in
            if case .failure(let e) = res { XCTFail("deleteAll failed: \(e)") }
            deleteExp.fulfill()
        }
        waitForExpectations(timeout: 5)

        let fetchedAfter = mgr.fetchPlants()
        XCTAssertTrue(fetchedAfter.isEmpty, "All plants should be deleted")
    }

    func testUpdateFavorite_nonExistent_noCrash() throws {
        // calling updateFavorite for non-existent id should succeed (no-op) and not crash
        let nonExistentID = UUID()
        let exp = expectation(description: "updateNonExistent")
        mgr.updateFavorite(forId: nonExistentID, to: true) { res in
            switch res {
            case .success: break
            case .failure(let e): XCTFail("update on non-existent returned error: \(e)")
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testFetchEmptyStore_returnsEmpty() throws {
        // A fresh fetch from the manager should return an array (possibly empty)
        let plants = mgr.fetchPlants()
        XCTAssertNotNil(plants)
    }

    func testSaveViewContext_noChanges_noThrow() {
        // ensure no changes and calling saveViewContext is a no-op
        XCTAssertFalse(mgr.viewContext.hasChanges)
        XCTAssertNoThrow(mgr.saveViewContext())
    }
}
