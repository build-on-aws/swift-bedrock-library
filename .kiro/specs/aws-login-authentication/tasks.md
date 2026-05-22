# Tasks: `aws login` Authentication Support

## Task 1: Determine minimum SDK version
- [ ] Check which version of `aws-sdk-swift` first includes `LoginAWSCredentialIdentityResolver`
- [ ] Verify it compiles with the new resolver on that version

## Task 2: Update Package.swift
- [ ] Bump `aws-sdk-swift` minimum version to support `LoginAWSCredentialIdentityResolver`
- [ ] Run `swift package resolve` to verify dependency resolution

## Task 3: Add `.login` case to BedrockAuthentication enum
- [ ] Add `case login(profileName: String = "default")` to the enum
- [ ] Add `description` for the new case
- [ ] Add doc comment explaining the case (matching style of other cases)

## Task 4: Implement credential resolution
- [ ] Add `case .login` handling in `getAWSCredentialIdentityResolver()`
- [ ] Use `LoginAWSCredentialIdentityResolver(profileName:configFilePath:credentialsFilePath:)`
- [ ] Handle errors consistently with other cases (wrap in `BedrockLibraryError.authenticationFailed`)

## Task 5: Update documentation
- [ ] Add "Console Login Authentication" section to `Authentication.md`
- [ ] Note that `.default` also picks up `aws login` credentials automatically
- [ ] Add prerequisites (AWS CLI v2.32.0+, run `aws login` first)
- [ ] Note platform limitations (non-sandboxed apps only)

## Task 6: Test
- [ ] Verify the project compiles with `swift build`
- [ ] Run existing tests to ensure no regressions
- [ ] Manually test with `aws login` on local machine
