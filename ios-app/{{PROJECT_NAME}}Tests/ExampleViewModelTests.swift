import XCTest
@testable import {{PROJECT_NAME}}

/// Example unit tests for ViewModels
///
/// Add your ViewModel tests here following this pattern:
/// 1. Arrange - Set up test data and dependencies
/// 2. Act - Execute the method being tested
/// 3. Assert - Verify the expected outcome
final class ExampleViewModelTests: XCTestCase {

    func testExampleStringConcatenation() throws {
        // Arrange
        let greeting = "Hello"
        let name = "{{PROJECT_NAME}}"

        // Act
        let result = "\(greeting), \(name)!"

        // Assert
        XCTAssertEqual(result, "Hello, {{PROJECT_NAME}}!")
    }

    func testExampleArrayOperations() throws {
        // Arrange
        var items = ["iOS", "Android"]

        // Act
        items.append("Web")

        // Assert
        XCTAssertEqual(items.count, 3)
        XCTAssertTrue(items.contains("Android"))
    }

    // TODO: Add your ViewModel tests here
    // Example:
    // func testViewModelInitialState() async throws {
    //     let viewModel = MainViewModel()
    //     XCTAssertEqual(viewModel.state, .loading)
    // }
}
