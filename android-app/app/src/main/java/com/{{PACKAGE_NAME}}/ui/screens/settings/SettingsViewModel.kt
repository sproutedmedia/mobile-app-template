package com.{{PACKAGE_NAME}}.ui.screens.settings

import android.app.Application
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.preferencesDataStore
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

private val android.content.Context.settingsDataStore by preferencesDataStore(name = "settings")

class SettingsViewModel(application: Application) : AndroidViewModel(application) {

    private val dataStore = application.settingsDataStore

    val isDarkMode: StateFlow<Boolean> = dataStore.data
        .map { prefs -> prefs[PreferenceKeys.DARK_MODE] ?: false }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

    val notificationsEnabled: StateFlow<Boolean> = dataStore.data
        .map { prefs -> prefs[PreferenceKeys.NOTIFICATIONS] ?: true }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), true)

    fun toggleDarkMode() {
        viewModelScope.launch {
            dataStore.edit { prefs ->
                prefs[PreferenceKeys.DARK_MODE] = !(prefs[PreferenceKeys.DARK_MODE] ?: false)
            }
        }
    }

    fun toggleNotifications() {
        viewModelScope.launch {
            dataStore.edit { prefs ->
                prefs[PreferenceKeys.NOTIFICATIONS] = !(prefs[PreferenceKeys.NOTIFICATIONS] ?: true)
            }
        }
    }

    private object PreferenceKeys {
        val DARK_MODE = booleanPreferencesKey("dark_mode")
        val NOTIFICATIONS = booleanPreferencesKey("notifications_enabled")
    }
}
