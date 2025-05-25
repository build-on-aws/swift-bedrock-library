# Amazon Bedrock Swift Library and web playground

This repository contains projects demonstrating how to use Amazon Bedrock with Swift.

## Projects

### 1. Swift Bedrock Library

A tiny layer on top of the [AWS SDK for Swift](https://github.com/awslabs/aws-sdk-swift) for interacting with Amazon Bedrock foundation models. This library provides a convenient way to access Amazon Bedrock's capabilities from Swift applications.

[Go to Swift Bedrock Library →](swift-bedrock-library/README.md)

### 2. Swift FM Playground

An interactive web application that demonstrates the capabilities of Amazon Bedrock foundation models using the Swift Bedrock Library. The playground includes:

- A Swift "backend for frontend" that interfaces with Amazon Bedrock
- A React frontend for interacting with the models through a user-friendly interface

[Go to Swift FM Playground →](swift-fm-playground/web-playground/README.md)

## Getting Started

Each project has its own README with specific setup instructions:

- For the Swift Bedrock Library, see the [library README](swift-bedrock-library/README.md)
- For the Swift FM Playground, see the [playground README](swift-fm-playground/web-playground/README.md)

## Prerequisites

- Swift 6.0 or later
- AWS account with access to Amazon Bedrock
- [AWS credentials configured locally](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) or [SSO configured with AWS Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-accounts.html) configured

## License

These projects are licensed under the Apache License 2.0. See the LICENSE files in each project for details.