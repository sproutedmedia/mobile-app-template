import Foundation

/// ViewModel for managing user profile state and operations
@MainActor
final class UserProfileViewModel: ObservableObject {
    /// Represents the current state of the view
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(User)
        case error(String)

        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading):
                return true
            case (.loaded(let lhsUser), .loaded(let rhsUser)):
                return lhsUser == rhsUser
            case (.error(let lhsMsg), .error(let rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }

    @Published private(set) var viewState: ViewState = .idle
    @Published var editableUser: User?
    @Published var validationErrors: [String: String] = [:]

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol = MockUserService()) {
        self.userService = userService
    }

    /// Loads the user profile from the service
    func loadProfile() async {
        viewState = .loading

        do {
            let user = try await userService.fetchCurrentUser()
            viewState = .loaded(user)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    /// Begins editing the current user profile
    func startEditing() {
        if case .loaded(let user) = viewState {
            editableUser = user
            validationErrors = [:]
        }
    }

    /// Cancels editing and discards changes
    func cancelEditing() {
        editableUser = nil
        validationErrors = [:]
    }

    /// Validates and saves the edited profile
    /// - Returns: true if save was successful, false otherwise
    func saveProfile() async -> Bool {
        guard let user = editableUser else { return false }

        guard validate(user) else { return false }

        viewState = .loading

        do {
            let updatedUser = try await userService.updateUser(user)
            viewState = .loaded(updatedUser)
            editableUser = nil
            return true
        } catch {
            viewState = .error(error.localizedDescription)
            return false
        }
    }

    /// Validates the user data
    private func validate(_ user: User) -> Bool {
        validationErrors = [:]

        if !ValidationHelpers.isNotEmpty(user.name) {
            validationErrors["name"] = "Name is required"
        }

        if !ValidationHelpers.isValidEmail(user.email) {
            validationErrors["email"] = "Please enter a valid email address"
        }

        if user.bio.count > 500 {
            validationErrors["bio"] = "Bio must be 500 characters or less"
        }

        return validationErrors.isEmpty
    }
}
