package com.{{PACKAGE_NAME}}.utilities

import com.{{PACKAGE_NAME}}.BuildConfig
import timber.log.Timber

/**
 * Structured logging utility wrapping Timber.
 *
 * Initialize once in your Application class:
 * ```kotlin
 * class MyApp : Application() {
 *     override fun onCreate() {
 *         super.onCreate()
 *         AppLogger.init()
 *     }
 * }
 * ```
 *
 * Usage:
 * ```kotlin
 * AppLogger.d("Network", "Request started: GET /users")
 * AppLogger.i("Auth", "User logged in")
 * AppLogger.w("Cache", "Cache miss for key: user_profile")
 * AppLogger.e("Database", "Failed to write", exception)
 * ```
 */
object AppLogger {

    fun init() {
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
        // For release builds, add a crash-reporting tree:
        // Timber.plant(CrashlyticsTree())
    }

    fun d(tag: String, message: String) = Timber.tag(tag).d(message)

    fun i(tag: String, message: String) = Timber.tag(tag).i(message)

    fun w(tag: String, message: String) = Timber.tag(tag).w(message)

    fun e(tag: String, message: String, throwable: Throwable? = null) {
        if (throwable != null) {
            Timber.tag(tag).e(throwable, message)
        } else {
            Timber.tag(tag).e(message)
        }
    }
}
