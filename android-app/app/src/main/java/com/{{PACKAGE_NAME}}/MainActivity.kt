package com.{{PACKAGE_NAME}}

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.{{PACKAGE_NAME}}.ui.theme.{{PROJECT_NAME}}Theme
import com.{{PACKAGE_NAME}}.ui.screens.MainScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            {{PROJECT_NAME}}Theme {
                MainScreen()
            }
        }
    }
}
