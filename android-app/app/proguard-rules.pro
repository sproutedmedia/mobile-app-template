# =============================================================================
# ProGuard Rules for {{PROJECT_NAME}}
# =============================================================================
#
# This file contains baseline rules for a Jetpack Compose app.
# Add library-specific rules as you add dependencies (see examples at bottom).
#
# For more details, see:
#   https://developer.android.com/build/shrink-code
# =============================================================================

# -----------------------------------------------------------------------------
# Crash Reporting — keep line numbers in stack traces
# -----------------------------------------------------------------------------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# -----------------------------------------------------------------------------
# Kotlin
# -----------------------------------------------------------------------------
-dontwarn kotlin.**
-keep class kotlin.Metadata { *; }

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}

# -----------------------------------------------------------------------------
# Jetpack Compose
# -----------------------------------------------------------------------------
# Compose compiler generates classes that R8 handles well by default.
# These rules are a safety net for edge cases.
-keep class androidx.compose.runtime.** { *; }
-keep class androidx.compose.ui.** { *; }

# Keep @Composable functions from being removed
-keepclassmembers class * {
    @androidx.compose.runtime.Composable <methods>;
}

# =============================================================================
# Library-Specific Rules — uncomment or add as needed
# =============================================================================

# --- Retrofit / OkHttp ---
# -dontwarn okhttp3.**
# -dontwarn okio.**
# -dontwarn retrofit2.**
# -keep class retrofit2.** { *; }
# -keepclassmembers,allowshrinking,allowobfuscation interface * {
#     @retrofit2.http.* <methods>;
# }

# --- Gson ---
# -keepattributes Signature
# -keepclassmembers class * {
#     @com.google.gson.annotations.SerializedName <fields>;
# }

# --- Moshi ---
# -keep class com.squareup.moshi.** { *; }
# -keepclassmembers @com.squareup.moshi.JsonClass class * { *; }

# --- Kotlin Serialization ---
# -keepattributes *Annotation*, InnerClasses
# -keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
# -keepclasseswithmembers class * {
#     kotlinx.serialization.KSerializer serializer(...);
# }

# --- Room ---
# -keep class * extends androidx.room.RoomDatabase
# -keep @androidx.room.Entity class *

# --- Firebase ---
# -keep class com.google.firebase.** { *; }
# -dontwarn com.google.firebase.**
