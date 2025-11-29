package com.{{PACKAGE_NAME}}.data.repository

import com.{{PACKAGE_NAME}}.data.model.User

/**
 * Repository interface for user operations
 */
interface UserRepository {
    suspend fun getCurrentUser(): Result<User>
    suspend fun updateUser(user: User): Result<User>
}
