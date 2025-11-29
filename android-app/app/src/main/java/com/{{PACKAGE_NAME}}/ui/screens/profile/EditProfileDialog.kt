package com.{{PACKAGE_NAME}}.ui.screens.profile

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.{{PACKAGE_NAME}}.ui.theme.{{THEME_NAME}}Theme

/**
 * Dialog for editing user profile information
 */
@Composable
fun EditProfileDialog(
    viewModel: UserProfileViewModel,
    onDismiss: () -> Unit,
    onSaved: () -> Unit,
    modifier: Modifier = Modifier
) {
    val editableUser by viewModel.editableUser.collectAsState()
    val validationErrors by viewModel.validationErrors.collectAsState()

    val user = editableUser ?: return

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Edit Profile") },
        text = {
            Column(modifier = Modifier.fillMaxWidth()) {
                // Name field
                OutlinedTextField(
                    value = user.name,
                    onValueChange = { viewModel.updateField("name", it) },
                    label = { Text("Name") },
                    isError = validationErrors.containsKey("name"),
                    supportingText = validationErrors["name"]?.let { { Text(it) } },
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Email field
                OutlinedTextField(
                    value = user.email,
                    onValueChange = { viewModel.updateField("email", it) },
                    label = { Text("Email") },
                    isError = validationErrors.containsKey("email"),
                    supportingText = validationErrors["email"]?.let { { Text(it) } },
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Bio field
                OutlinedTextField(
                    value = user.bio,
                    onValueChange = { viewModel.updateField("bio", it) },
                    label = { Text("Bio") },
                    isError = validationErrors.containsKey("bio"),
                    supportingText = {
                        Column {
                            validationErrors["bio"]?.let {
                                Text(
                                    text = it,
                                    color = MaterialTheme.colorScheme.error
                                )
                            }
                            Text("${user.bio.length}/500 characters")
                        }
                    },
                    minLines = 3,
                    maxLines = 5,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    if (viewModel.saveProfile()) {
                        onSaved()
                    }
                }
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
        modifier = modifier
    )
}

@Preview
@Composable
private fun EditProfileDialogPreview() {
    {{THEME_NAME}}Theme {
        // Preview would need a ViewModel instance
    }
}
