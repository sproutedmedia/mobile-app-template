package com.{{PACKAGE_NAME}}.ui.screens.profile

import com.{{PACKAGE_NAME}}.data.model.User

/**
 * Sealed interface representing the UI state for the user profile screen
 */
sealed interface UserProfileUiState {
    data object Idle : UserProfileUiState
    data object Loading : UserProfileUiState
    data class Success(val user: User) : UserProfileUiState
    data class Error(val message: String) : UserProfileUiState
}
