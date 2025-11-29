package com.{{PACKAGE_NAME}}.data.model

/**
 * User data class representing a user profile
 */
data class User(
    val id: String,
    val name: String,
    val email: String,
    val bio: String,
    val avatarUrl: String?,
    val createdAt: Long
) {
    companion object {
        val EMPTY = User(
            id = "",
            name = "",
            email = "",
            bio = "",
            avatarUrl = null,
            createdAt = 0L
        )

        val PREVIEW = User(
            id = "preview-123",
            name = "Jane Developer",
            email = "jane@example.com",
            bio = "Mobile developer enthusiast building great apps.",
            avatarUrl = "https://example.com/avatar.jpg",
            createdAt = System.currentTimeMillis()
        )
    }
}
