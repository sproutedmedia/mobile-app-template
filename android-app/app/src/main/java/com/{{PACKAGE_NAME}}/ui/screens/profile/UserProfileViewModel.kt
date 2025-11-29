package com.{{PACKAGE_NAME}}.ui.screens.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.{{PACKAGE_NAME}}.data.model.User
import com.{{PACKAGE_NAME}}.data.repository.UserRepository
import com.{{PACKAGE_NAME}}.data.repository.UserRepositoryImpl
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for managing user profile state and operations
 */
class UserProfileViewModel(
    private val userRepository: UserRepository = UserRepositoryImpl()
) : ViewModel() {

    private val _uiState = MutableStateFlow<UserProfileUiState>(UserProfileUiState.Idle)
    val uiState: StateFlow<UserProfileUiState> = _uiState.asStateFlow()

    private val _validationErrors = MutableStateFlow<Map<String, String>>(emptyMap())
    val validationErrors: StateFlow<Map<String, String>> = _validationErrors.asStateFlow()

    private val _editableUser = MutableStateFlow<User?>(null)
    val editableUser: StateFlow<User?> = _editableUser.asStateFlow()

    /**
     * Loads the user profile from the repository
     */
    fun loadProfile() {
        viewModelScope.launch {
            _uiState.value = UserProfileUiState.Loading

            userRepository.getCurrentUser()
                .onSuccess { user ->
                    _uiState.value = UserProfileUiState.Success(user)
                }
                .onFailure { error ->
                    _uiState.value = UserProfileUiState.Error(
                        error.message ?: "Failed to load profile"
                    )
                }
        }
    }

    /**
     * Begins editing the current user profile
     */
    fun startEditing() {
        val currentState = _uiState.value
        if (currentState is UserProfileUiState.Success) {
            _editableUser.value = currentState.user
            _validationErrors.value = emptyMap()
        }
    }

    /**
     * Updates a field in the editable user
     */
    fun updateField(field: String, value: String) {
        _editableUser.value = _editableUser.value?.let { user ->
            when (field) {
                "name" -> user.copy(name = value)
                "email" -> user.copy(email = value)
                "bio" -> user.copy(bio = value)
                else -> user
            }
        }
    }

    /**
     * Cancels editing and discards changes
     */
    fun cancelEditing() {
        _editableUser.value = null
        _validationErrors.value = emptyMap()
    }

    /**
     * Validates and saves the edited profile
     * @return true if validation passed and save was initiated
     */
    fun saveProfile(): Boolean {
        val user = _editableUser.value ?: return false

        if (!validate(user)) {
            return false
        }

        viewModelScope.launch {
            _uiState.value = UserProfileUiState.Loading

            userRepository.updateUser(user)
                .onSuccess { updatedUser ->
                    _uiState.value = UserProfileUiState.Success(updatedUser)
                    _editableUser.value = null
                }
                .onFailure { error ->
                    _uiState.value = UserProfileUiState.Error(
                        error.message ?: "Failed to save profile"
                    )
                }
        }

        return true
    }

    private fun validate(user: User): Boolean {
        val errors = mutableMapOf<String, String>()

        if (user.name.isBlank()) {
            errors["name"] = "Name is required"
        }

        if (!isValidEmail(user.email)) {
            errors["email"] = "Please enter a valid email address"
        }

        if (user.bio.length > 500) {
            errors["bio"] = "Bio must be 500 characters or less"
        }

        _validationErrors.value = errors
        return errors.isEmpty()
    }

    private fun isValidEmail(email: String): Boolean {
        val emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$".toRegex()
        return email.matches(emailRegex)
    }
}
