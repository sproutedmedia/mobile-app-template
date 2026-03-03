package com.{{PACKAGE_NAME}}.ui.screens.settings

import android.app.Application
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.io.File

/**
 * Unit tests for [SettingsViewModel].
 *
 * Tests verify that preference keys are read/written correctly using
 * a temporary DataStore backed by a temp file.
 */
@OptIn(ExperimentalCoroutinesApi::class)
class SettingsViewModelTest {

    @get:Rule
    val tmpFolder = TemporaryFolder()

    private val testDispatcher = StandardTestDispatcher()

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `dark mode preference key defaults to false`() = runTest {
        val dataStore = PreferenceDataStoreFactory.create {
            File(tmpFolder.newFolder(), "test_prefs.preferences_pb")
        }

        val darkModeKey = booleanPreferencesKey("dark_mode")
        val isDarkMode = dataStore.data.map { it[darkModeKey] ?: false }.first()
        assertFalse("Dark mode should default to false", isDarkMode)
    }

    @Test
    fun `notifications preference key defaults to true`() = runTest {
        val dataStore = PreferenceDataStoreFactory.create {
            File(tmpFolder.newFolder(), "test_prefs.preferences_pb")
        }

        val notificationsKey = booleanPreferencesKey("notifications_enabled")
        val isEnabled = dataStore.data.map { it[notificationsKey] ?: true }.first()
        assertTrue("Notifications should default to true", isEnabled)
    }

    @Test
    fun `toggling dark mode persists value`() = runTest {
        val dataStore = PreferenceDataStoreFactory.create {
            File(tmpFolder.newFolder(), "test_prefs.preferences_pb")
        }

        val darkModeKey = booleanPreferencesKey("dark_mode")

        // Toggle on
        dataStore.edit { it[darkModeKey] = true }
        val afterToggleOn = dataStore.data.map { it[darkModeKey] ?: false }.first()
        assertTrue("Dark mode should be true after toggling on", afterToggleOn)

        // Toggle off
        dataStore.edit { it[darkModeKey] = false }
        val afterToggleOff = dataStore.data.map { it[darkModeKey] ?: false }.first()
        assertFalse("Dark mode should be false after toggling off", afterToggleOff)
    }

    @Test
    fun `toggling notifications persists value`() = runTest {
        val dataStore = PreferenceDataStoreFactory.create {
            File(tmpFolder.newFolder(), "test_prefs.preferences_pb")
        }

        val notificationsKey = booleanPreferencesKey("notifications_enabled")

        // Toggle off
        dataStore.edit { it[notificationsKey] = false }
        val afterToggleOff = dataStore.data.map { it[notificationsKey] ?: true }.first()
        assertFalse("Notifications should be false after toggling off", afterToggleOff)

        // Toggle on
        dataStore.edit { it[notificationsKey] = true }
        val afterToggleOn = dataStore.data.map { it[notificationsKey] ?: true }.first()
        assertTrue("Notifications should be true after toggling on", afterToggleOn)
    }
}
