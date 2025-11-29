package com.{{PACKAGE_NAME}}.data.repository

import com.{{PACKAGE_NAME}}.data.model.User

/**
 * Fake implementation of UserRepository for testing
 */
class FakeUserRepository : UserRepository {

    var shouldFail = false
    var errorMessage = "Network error"
    var currentUser = User.PREVIEW

    override suspend fun getCurrentUser(): Result<User> {
        return if (shouldFail) {
            Result.failure(Exception(errorMessage))
        } else {
            Result.success(currentUser)
        }
    }

    override suspend fun updateUser(user: User): Result<User> {
        return if (shouldFail) {
            Result.failure(Exception(errorMessage))
        } else {
            currentUser = user
            Result.success(user)
        }
    }
}
