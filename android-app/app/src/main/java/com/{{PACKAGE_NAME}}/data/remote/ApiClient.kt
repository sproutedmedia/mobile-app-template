package com.{{PACKAGE_NAME}}.data.remote

import com.{{PACKAGE_NAME}}.BuildConfig
import com.{{PACKAGE_NAME}}.utilities.AppLogger
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

/**
 * Singleton API client configured with Retrofit, OkHttp, and Gson.
 *
 * Usage:
 * ```kotlin
 * val users = ApiClient.service.getUsers()
 * val user = ApiClient.service.getUser("123")
 * ```
 *
 * Update [BASE_URL] to point to your API.
 */
object ApiClient {

    private const val BASE_URL = "https://api.example.com/v1/"
    private const val TIMEOUT_SECONDS = 30L

    private val loggingInterceptor = HttpLoggingInterceptor { message ->
        AppLogger.d("OkHttp", message)
    }.apply {
        level = if (BuildConfig.DEBUG) {
            HttpLoggingInterceptor.Level.BODY
        } else {
            HttpLoggingInterceptor.Level.NONE
        }
    }

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .connectTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .readTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .writeTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .build()

    private val retrofit: Retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    val service: ApiService = retrofit.create(ApiService::class.java)
}
