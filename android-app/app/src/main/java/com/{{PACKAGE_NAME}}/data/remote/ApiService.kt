package com.{{PACKAGE_NAME}}.data.remote

import com.{{PACKAGE_NAME}}.data.model.User
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.PUT
import retrofit2.http.Path

/**
 * Retrofit API service interface.
 *
 * Add your API endpoints here. Each method maps to an HTTP request.
 * Retrofit handles JSON serialization/deserialization via Gson.
 */
interface ApiService {

    @GET("users")
    suspend fun getUsers(): List<User>

    @GET("users/{id}")
    suspend fun getUser(@Path("id") id: String): User

    @PUT("users/{id}")
    suspend fun updateUser(@Path("id") id: String, @Body user: User): User

    // Add your endpoints here:
    // @GET("posts")
    // suspend fun getPosts(): List<Post>
}
