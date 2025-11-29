package com.{{PACKAGE_NAME}}.ui.screens.profile

import com.{{PACKAGE_NAME}}.data.model.User
import com.{{PACKAGE_NAME}}.data.repository.FakeUserRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

/**
 * Unit tests for UserProfileViewModel
 */
@OptIn(ExperimentalCoroutinesApi::class)
class UserProfileViewModelTest {

    private val testDispatcher = UnconfinedTestDispatcher()
    private lateinit var fakeRepository: FakeUserRepository
    private lateinit var viewModel: UserProfileViewModel

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
        fakeRepository = FakeUserRepository()
        viewModel = UserProfileViewModel(fakeRepository)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    // MARK: - Initial State

    @Test
    fun `initial state is Idle`() {
        assertEquals(UserProfileUiState.Idle, viewModel.uiState.value)
        assertNull(viewModel.editableUser.value)
        assertTrue(viewModel.validationErrors.value.isEmpty())
    }

    // MARK: - Load Profile

    @Test
    fun `loadProfile emits Success on successful load`() = runTest {
        // Arrange
        val testUser = User(
            id = "test-123",
            name = "Test User",
            email = "test@example.com",
            bio = "Test bio",
            avatarUrl = null,
            createdAt = System.currentTimeMillis()
        )
        fakeRepository.currentUser = testUser

        // Act
        viewModel.loadProfile()
        advanceUntilIdle()

        // Assert
        val state = viewModel.uiState.value
        assertTrue(state is UserProfileUiState.Success)
        assertEquals("Test User", (state as UserProfileUiState.Success).user.name)
    }

    @Test
    fun `loadProfile emits Error on failure`() = runTest {
        // Arrange
        fakeRepository.shouldFail = true
        fakeRepository.errorMessage = "Network error"

        // Act
        viewModel.loadProfile()
        advanceUntilIdle()

        // Assert
        val state = viewModel.uiState.value
        assertTrue(state is UserProfileUiState.Error)
        assertEquals("Network error", (state as UserProfileUiState.Error).message)
    }

    // MARK: - Edit Profile

    @Test
    fun `startEditing copies user to editableUser`() = runTest {
        // Arrange
        viewModel.loadProfile()
        advanceUntilIdle()

        // Act
        viewModel.startEditing()

        // Assert
        assertNotNull(viewModel.editableUser.value)
        assertEquals(fakeRepository.currentUser.id, viewModel.editableUser.value?.id)
    }

    @Test
    fun `cancelEditing clears editableUser`() = runTest {
        // Arrange
        viewModel.loadProfile()
        advanceUntilIdle()
        viewModel.startEditing()

        // Act
        viewModel.cancelEditing()

        // Assert
        assertNull(viewModel.editableUser.value)
        assertTrue(viewModel.validationErrors.value.isEmpty())
    }

    @Test
    fun `updateField updates editableUser correctly`() = runTest {
        // Arrange
        viewModel.loadProfile()
        advanceUntilIdle()
        viewModel.startEditing()

        // Act
        viewModel.updateField("name", "Updated Name")

        // Assert
        assertEquals("Updated Name", viewModel.editableUser.value?.name)
    }

    // MARK: - Validation

    @Test
    fun `saveProfile fails validation with empty name`() = runTest {
        // Arrange
        viewModel.loadProfile()
        advanceUntilIdle()
        viewModel.startEditing()
        viewModel.updateField("name", "")

        // Act
        val result = viewModel.saveProfile()

        // Assert
        assertFalse(result)
        assertTrue(viewModel.validationErrors.value.containsKey("name"))
    }

    @Test
    fun `saveProfile fails validation with invalid email`() = runTest {
        // Arrange
        viewModel.loadProfile()
        advanceUntilIdle()
        viewModel.startEditing()
        viewModel.updateField("email", "invalid-email")

        // Act
        val result = viewModel.saveProfile()

        // Assert
        assertFalse(result)
        assertTrue(viewModel.validationErrors.value.containsKey("email"))
    }

    @Test
    fun `saveProfile fails validation with long bio`() = runTest {
        // Arrange
        viewModel.loadProfile()
        advanceUntilIdle()
        viewModel.startEditing()
        viewModel.updateField("bio", "a".repeat(501))

        // Act
        val result = viewModel.saveProfile()

        // Assert
        assertFalse(result)
        assertTrue(viewModel.validationErrors.value.containsKey("bio"))
    }

    // MARK: - Save Profile

    @Test
    fun `saveProfile succeeds with valid user`() = runTest {
        // Arrange
        viewModel.loadProfile()
        advanceUntilIdle()
        viewModel.startEditing()
        viewModel.updateField("name", "Updated Name")

        // Act
        val result = viewModel.saveProfile()
        advanceUntilIdle()

        // Assert
        assertTrue(result)
        assertNull(viewModel.editableUser.value)
        val state = viewModel.uiState.value
        assertTrue(state is UserProfileUiState.Success)
        assertEquals("Updated Name", (state as UserProfileUiState.Success).user.name)
    }

    @Test
    fun `saveProfile returns false without editableUser`() {
        // Act
        val result = viewModel.saveProfile()

        // Assert
        assertFalse(result)
    }
}
