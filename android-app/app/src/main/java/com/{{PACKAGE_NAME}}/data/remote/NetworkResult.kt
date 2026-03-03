package com.{{PACKAGE_NAME}}.data.remote

/**
 * Wrapper for network responses that represents loading, success, and error states.
 *
 * Usage in a ViewModel:
 * ```kotlin
 * val result = apiClient.getUsers()
 * when (result) {
 *     is NetworkResult.Success -> updateUi(result.data)
 *     is NetworkResult.Error -> showError(result.message)
 *     is NetworkResult.Loading -> showLoading()
 * }
 * ```
 */
sealed class NetworkResult<out T> {
    data class Success<T>(val data: T) : NetworkResult<T>()
    data class Error(val message: String, val exception: Throwable? = null) : NetworkResult<Nothing>()
    data object Loading : NetworkResult<Nothing>()
}
