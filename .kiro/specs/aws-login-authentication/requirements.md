# Requirements: Add `aws login` Authentication Support

## Overview

Add support for the new `aws login` authentication method (released November 2025) to the BedrockService library. This allows developers to authenticate using their AWS Management Console sign-in credentials for programmatic access, without managing long-term access keys.

## Background

- AWS CLI v2.32.0+ introduced `aws login`, which opens a browser-based sign-in flow and caches temporary credentials in `~/.aws/login/cache`.
- The AWS SDK for Swift provides `LoginAWSCredentialIdentityResolver` in `AWSSDKIdentity` to consume these cached credentials.
- Credentials auto-refresh every 15 minutes, valid up to 12 hours.
- Reference: https://aws.amazon.com/blogs/security/simplified-developer-access-to-aws-with-aws-login/
- SDK docs: https://docs.aws.amazon.com/sdk-for-swift/latest/developer-guide/credential-providers.html

## Requirements

1. **REQ-1**: Add a `.login(profileName:)` case to the `BedrockAuthentication` enum that explicitly uses `LoginAWSCredentialIdentityResolver`.
2. **REQ-2**: The `.login` case must accept an optional profile name (defaulting to `"default"`), matching the pattern of `.sso(profileName:)`.
3. **REQ-3**: The credential resolver must be created using `LoginAWSCredentialIdentityResolver(profileName:configFilePath:credentialsFilePath:)` with `nil` for file paths (use SDK defaults).
4. **REQ-4**: Update the `description` computed property to include the new case.
5. **REQ-5**: Update the minimum `aws-sdk-swift` dependency version in `Package.swift` to a version that includes `LoginAWSCredentialIdentityResolver` support.
6. **REQ-6**: Document the new authentication method in `Sources/BedrockService/Docs.docc/Authentication.md`.
7. **REQ-7**: The `.default` credential chain already picks up `aws login` tokens — document this behavior as well.
