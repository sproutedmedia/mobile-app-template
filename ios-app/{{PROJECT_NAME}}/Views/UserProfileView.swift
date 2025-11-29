import SwiftUI

/// View displaying the user profile with edit functionality
struct UserProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel
    @State private var showingEditSheet = false

    init(viewModel: UserProfileViewModel = UserProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .idle:
                    Color.clear
                        .onAppear {
                            Task {
                                await viewModel.loadProfile()
                            }
                        }

                case .loading:
                    ProgressView("Loading profile...")

                case .loaded(let user):
                    profileContent(user)

                case .error(let message):
                    errorView(message)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                if case .loaded = viewModel.viewState {
                    Button("Edit") {
                        viewModel.startEditing()
                        showingEditSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditProfileView(viewModel: viewModel, isPresented: $showingEditSheet)
            }
        }
    }

    @ViewBuilder
    private func profileContent(_ user: User) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar
                AsyncImage(url: user.avatarURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())

                // Name
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)

                // Email
                Text(user.email)
                    .foregroundStyle(.secondary)

                // Bio
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Member since
                Text("Member since \(user.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadProfile()
        }
    }

    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.red)

            Text("Something went wrong")
                .font(.headline)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Try Again") {
                Task {
                    await viewModel.loadProfile()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    UserProfileView()
}
