# iOS Dependencies

This iOS project uses Swift Package Manager (SPM) for dependency management.

## Adding Dependencies

1. Open `{{PROJECT_NAME}}.xcodeproj` in Xcode
2. Select the project in the navigator
3. Go to "Package Dependencies" tab
4. Click the "+" button to add a package
5. Enter the package URL and version rules

## Recommended Packages

### Networking
- **Alamofire**: `https://github.com/Alamofire/Alamofire.git`
  - Modern HTTP networking library

### Image Loading
- **Kingfisher**: `https://github.com/onevcat/Kingfisher.git`
  - Async image downloading and caching

### Async/Combine
- **CombineExt**: `https://github.com/CombineCommunity/CombineExt.git`
  - Additional operators for Combine

### Storage
- **SwiftData**: Built into iOS 17+ (no package needed)
- **KeychainAccess**: `https://github.com/kishikawakatsumi/KeychainAccess.git`
  - Secure keychain wrapper

### UI Components
- **SwiftUI-Introspect**: `https://github.com/siteline/SwiftUI-Introspect.git`
  - Access UIKit components from SwiftUI

### Analytics & Logging
- **swift-log**: `https://github.com/apple/swift-log.git`
  - Apple's logging API

## Example: Adding Alamofire

```swift
// After adding via Xcode, import in your code:
import Alamofire

// Use in your service layer:
func fetchUsers() async throws -> [User] {
    let response = try await AF.request("https://api.example.com/users")
        .serializingDecodable([User].self)
        .value
    return response
}
```

## Version Requirements

- Xcode 15.0+
- iOS 17.0+ deployment target
- Swift 5.9+
