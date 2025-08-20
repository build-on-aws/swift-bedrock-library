# Math Problem Solver

An iOS application that uses AWS Bedrock and Claude to solve math and physics problems from images.

## TODO: add your AWS account detail 

Before compiling or running this app, you must 

- Configure SignIn With Apple on your Apple developer account.
- Configure an IAM Identity Provider for SignIn With Apple and this application bundle.
- Create an AWS IAM role that has the necessary permissions to access AWS Bedrock.
- Replace the placeholder values in `changeme.swift` with your actual AWS account detail and IAM role name.
- Enable the access to Amazon Bedrock models in the Bedrock console.

See [AWS Documentation](https://docs.aws.amazon.com/sdk-for-swift/latest/developer-guide/apple-integration.html#apple-sign-in) for more information.

## Features

- Take a photo or select an image from your photo library
- Analyze math and physics problems using Claude AI
- Get step-by-step solutions with explanations
- Secure authentication using Sign in with Apple (SIWA) and AWS STS

## Screenshot

![Math Problem Solver App Screenshot](screenshot.png)

## Technology Stack

- Swift bedrock Library for AI image analysis and problem solving
- Swift and SwiftUI for the iOS app
- Claude 3 Sonnet model for high-quality responses
- Sign in with Apple (SIWA) for authentication
- Streaming responses for real-time feedback

## How It Works

1. The app captures or selects an image containing a math or physics problem
2. The image is processed and sent to AWS Bedrock
3. Claude analyzes the problem and generates a step-by-step solution
4. The solution is streamed back to the app in real-time
5. The app displays the formatted solution with mathematical notation

## Requirements

- iOS 16.0+
- Xcode 15.0+
- AWS account with Bedrock configured
- Sign in with Apple enabled in your Apple Developer account

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.
