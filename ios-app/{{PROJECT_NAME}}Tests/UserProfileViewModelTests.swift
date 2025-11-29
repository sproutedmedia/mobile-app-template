import XCTest
@testable import {{PROJECT_NAME}}

/// Unit tests for UserProfileViewModel
@MainActor
final class UserProfileViewModelTests: XCTestCase {

    private var mockService: MockUserService!
    private var sut: UserProfileViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockUserService()
        mockService.delay = 0 // No delay for tests
        sut = UserProfileViewModel(userService: mockService)
    }

    override func tearDown() {
        mockService = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialStateIsIdle() {
        XCTAssertEqual(sut.viewState, .idle)
        XCTAssertNil(sut.editableUser)
        XCTAssertTrue(sut.validationErrors.isEmpty)
    }

    // MARK: - Load Profile

    func testLoadProfileSuccess() async {
        // Arrange
        mockService.mockUser = User(
            id: "test-id",
            name: "Test User",
            email: "test@example.com",
            bio: "Test bio",
            avatarURL: nil,
            createdAt: Date()
        )

        // Act
        await sut.loadProfile()

        // Assert
        if case .loaded(let user) = sut.viewState {
            XCTAssertEqual(user.name, "Test User")
            XCTAssertEqual(user.email, "test@example.com")
        } else {
            XCTFail("Expected loaded state, got \(sut.viewState)")
        }
    }

    func testLoadProfileFailure() async {
        // Arrange
        mockService.shouldFail = true

        // Act
        await sut.loadProfile()

        // Assert
        if case .error(let message) = sut.viewState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected error state, got \(sut.viewState)")
        }
    }

    // MARK: - Edit Profile

    func testStartEditingCopiesUser() async {
        // Arrange
        await sut.loadProfile()

        // Act
        sut.startEditing()

        // Assert
        XCTAssertNotNil(sut.editableUser)
        XCTAssertEqual(sut.editableUser?.id, mockService.mockUser.id)
    }

    func testCancelEditingClearsEditableUser() async {
        // Arrange
        await sut.loadProfile()
        sut.startEditing()

        // Act
        sut.cancelEditing()

        // Assert
        XCTAssertNil(sut.editableUser)
        XCTAssertTrue(sut.validationErrors.isEmpty)
    }

    // MARK: - Validation

    func testValidationFailsWithEmptyName() async {
        // Arrange
        await sut.loadProfile()
        sut.startEditing()
        sut.editableUser?.name = ""

        // Act
        let success = await sut.saveProfile()

        // Assert
        XCTAssertFalse(success)
        XCTAssertNotNil(sut.validationErrors["name"])
    }

    func testValidationFailsWithInvalidEmail() async {
        // Arrange
        await sut.loadProfile()
        sut.startEditing()
        sut.editableUser?.email = "invalid-email"

        // Act
        let success = await sut.saveProfile()

        // Assert
        XCTAssertFalse(success)
        XCTAssertNotNil(sut.validationErrors["email"])
    }

    func testValidationFailsWithLongBio() async {
        // Arrange
        await sut.loadProfile()
        sut.startEditing()
        sut.editableUser?.bio = String(repeating: "a", count: 501)

        // Act
        let success = await sut.saveProfile()

        // Assert
        XCTAssertFalse(success)
        XCTAssertNotNil(sut.validationErrors["bio"])
    }

    // MARK: - Save Profile

    func testSaveProfileSuccess() async {
        // Arrange
        await sut.loadProfile()
        sut.startEditing()
        sut.editableUser?.name = "Updated Name"

        // Act
        let success = await sut.saveProfile()

        // Assert
        XCTAssertTrue(success)
        XCTAssertNil(sut.editableUser)
        if case .loaded(let user) = sut.viewState {
            XCTAssertEqual(user.name, "Updated Name")
        } else {
            XCTFail("Expected loaded state after save")
        }
    }

    func testSaveProfileFailure() async {
        // Arrange
        await sut.loadProfile()
        sut.startEditing()
        mockService.shouldFail = true

        // Act
        let success = await sut.saveProfile()

        // Assert
        XCTAssertFalse(success)
        if case .error = sut.viewState {
            // Expected
        } else {
            XCTFail("Expected error state after failed save")
        }
    }

    func testSaveProfileWithoutEditableUserReturnsFalse() async {
        // Arrange - don't start editing

        // Act
        let success = await sut.saveProfile()

        // Assert
        XCTAssertFalse(success)
    }
}
