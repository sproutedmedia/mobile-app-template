package com.{{PACKAGE_NAME}}

import android.app.Application
import com.{{PACKAGE_NAME}}.utilities.AppLogger

class {{THEME_NAME}}Application : Application() {
    override fun onCreate() {
        super.onCreate()
        AppLogger.init()
    }
}
