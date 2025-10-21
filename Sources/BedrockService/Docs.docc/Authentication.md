# Authentication

Configure authentication for Amazon Bedrock access

## Overview

BedrockService supports multiple authentication methods to work with Amazon Bedrock. Choose the method that best fits your application's deployment environment and security requirements.

## Default Authentication

Uses the standard AWS credential provider chain:

```swift
let bedrock = try await BedrockService(
    region: .uswest2
    // authentication defaults to .default
)
```

The credential chain checks for credentials in this order:
1. Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`)
2. AWS credentials file (`~/.aws/credentials`)
3. AWS config file (`~/.aws/config`)
4. IAM roles for Amazon EC2 instances
5. IAM roles for tasks (Amazon ECS)
6. IAM roles for Lambda functions

## Profile-based Authentication

Use a specific profile from your AWS credentials file:

```swift
let bedrock = try await BedrockService(
    region: .uswest2,
    authentication: .profile(profileName: "my-profile")
)
```

## SSO Authentication

Use AWS Single Sign-On authentication. Run `aws sso login --profile <profile_name>` first:

```swift
let bedrock = try await BedrockService(
    region: .uswest2,
    authentication: .sso(profileName: "my-sso-profile")
)
```

## Web Identity Token Authentication

Use JWT tokens from external identity providers (ideal for iOS/macOS apps):

```swift
let bedrock = try await BedrockService(
    region: .uswest2,
    authentication: .webIdentity(
        token: jwtToken,
        roleARN: "arn:aws:iam::123456789012:role/MyAppRole",
        region: .uswest2,
        notification: {
            print("AWS credentials updated")
        }
    )
)
```

## API Key Authentication

Use API keys generated in the AWS console:

```swift
let bedrock = try await BedrockService(
    region: .uswest2,
    authentication: .apiKey(key: "your-api-key-here")
)
```

> Important: Never hardcode API keys in your application. Use secure storage or environment variables.

## Static Credentials (Testing Only)

For testing and debugging purposes only:

```swift
let bedrock = try await BedrockService(
    region: .uswest2,
    authentication: .static(
        accessKey: "AKIAIOSFODNN7EXAMPLE",
        secretKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        sessionToken: "optional-session-token"
    )
)
```

> Warning: Never use static credentials in production or commit them to version control.