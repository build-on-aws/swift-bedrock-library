# Design: `aws login` Authentication Support

## Architecture

The implementation follows the existing authentication pattern in the library. Each auth method is a case in the `BedrockAuthentication` enum, with credential resolution handled in `getAWSCredentialIdentityResolver()`.

## Changes

### 1. `BedrockAuthentication` enum (BedrockAuthentication.swift)

Add a new case:

```swift
case login(profileName: String = "default")
```

### 2. Credential resolution (BedrockAuthentication.swift)

In `getAWSCredentialIdentityResolver()`, add:

```swift
case .login(let profileName):
    return try LoginAWSCredentialIdentityResolver(
        profileName: profileName,
        configFilePath: nil,
        credentialsFilePath: nil
    )
```

### 3. Description (BedrockAuthentication.swift)

```swift
case .login(let profileName):
    return "login: \(profileName)"
```

### 4. Package.swift

Bump `aws-sdk-swift` minimum version to one that includes `LoginAWSCredentialIdentityResolver`. Need to verify the exact version — likely `1.7.x` or later.

### 5. Documentation (Authentication.md)

Add a new section:

```markdown
## Console Login Authentication

Use credentials from `aws login` (AWS CLI v2.32.0+). Run `aws login` first:

\```swift
let bedrock = try await BedrockService(
    region: .uswest2,
    authentication: .login(profileName: "default")
)
\```

> Note: The `.default` authentication also picks up `aws login` credentials
> automatically through the credential provider chain.
```

## Dependencies

- `AWSSDKIdentity` module (already imported in the project)
- `LoginAWSCredentialIdentityResolver` class from `AWSSDKIdentity`

## Compatibility Notes

- This feature only works on non-sandboxed apps (macOS CLI tools, server apps) since it reads from `~/.aws/login/cache`
- iOS/tvOS apps cannot use this method — they should continue using `.webIdentity` or `.apiKey`
- Requires AWS CLI v2.32.0+ to be installed and `aws login` to have been run
