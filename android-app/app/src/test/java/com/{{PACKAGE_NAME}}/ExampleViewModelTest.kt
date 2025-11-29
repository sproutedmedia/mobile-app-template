package com.{{PACKAGE_NAME}}

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

/**
 * Example unit test for ViewModel
 *
 * Add your ViewModel tests here following this pattern:
 * 1. Arrange - Set up test data and dependencies
 * 2. Act - Execute the method being tested
 * 3. Assert - Verify the expected outcome
 */
class ExampleViewModelTest {

    @Test
    fun `example test - string concatenation`() {
        // Arrange
        val greeting = "Hello"
        val name = "{{PROJECT_NAME}}"

        // Act
        val result = "$greeting, $name!"

        // Assert
        assertEquals("Hello, {{PROJECT_NAME}}!", result)
    }

    @Test
    fun `example test - list operations`() {
        // Arrange
        val items = mutableListOf("iOS", "Android")

        // Act
        items.add("Web")

        // Assert
        assertEquals(3, items.size)
        assertNotNull(items.find { it == "Android" })
    }

    // TODO: Add your ViewModel tests here
    // Example:
    // @Test
    // fun `viewModel emits loading state on init`() {
    //     val viewModel = MainViewModel()
    //     assertEquals(UiState.Loading, viewModel.uiState.value)
    // }
}
