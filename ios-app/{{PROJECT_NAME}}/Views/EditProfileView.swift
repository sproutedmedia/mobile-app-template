import SwiftUI

/// View for editing user profile information
struct EditProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Binding var isPresented: Bool
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                if let user = Binding($viewModel.editableUser) {
                    Section("Personal Information") {
                        TextField("Name", text: user.name)
                            .textContentType(.name)
                            .autocorrectionDisabled()

                        if let error = viewModel.validationErrors["name"] {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        TextField("Email", text: user.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                        if let error = viewModel.validationErrors["email"] {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    Section("About") {
                        TextField("Bio", text: user.bio, axis: .vertical)
                            .lineLimit(3...6)

                        if let error = viewModel.validationErrors["bio"] {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        Text("\(user.wrappedValue.bio.count)/500 characters")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelEditing()
                        isPresented = false
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            let success = await viewModel.saveProfile()
                            isSaving = false
                            if success {
                                isPresented = false
                            }
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .interactiveDismissDisabled(isSaving)
        }
    }
}

#Preview {
    EditProfileView(
        viewModel: UserProfileViewModel(),
        isPresented: .constant(true)
    )
}
