# Swift FM Playground

Welcome to the Swift Foundation Model (FM) Playground, an example app to explore how to use **Amazon Bedrock** with the AWS SDK for Swift.

> 🚨 **Important:** This application is for educational purposes and not intended for production use.

## Overview

The Swift FM Playground is a web application that demonstrates how to use Amazon Bedrock foundation models with the AWS SDK for Swift. It consists of:

- A Swift backend that interfaces with Amazon Bedrock
- A React frontend that provides a user-friendly interface for interacting with the models

## Prerequisites

- [Swift 6.0](https://www.swift.org/download/) or later
- [Node.js](https://nodejs.org/) 18 or later
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)
- AWS account with access to Amazon Bedrock
- AWS credentials configured locally

## Running the Application

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Build and run the Swift backend:
   ```bash
   swift build
   swift run
   ```

   The backend server will start on port 8080 by default.

#### Advanced Backend Configuration

You can customize the backend behavior with the following options:

- **Change Log Level**:
  ```bash
  swift run PlaygroundAPI --log-level debug
  ```
  Available log levels: trace, debug, info, notice, warning, error, critical

  You can also use the LOG_LEVEL environment variable.

  ```bash 
  LOG_LEVEL=trace swift run
  ```

- **Use AWS SSO Authentication**:
  ```bash
  swift run PlaygroundAPI --sso
  ```

- **Specify AWS Profile**:
  ```bash
  swift run PlaygroundAPI --profile-name my-profile
  ```

- **Combined Options**:
  ```bash
  swift run PlaygroundAPI --sso --profile-name my-profile --log-level debug
  ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   # or if you use yarn
   yarn install
   ```

3. Start the React development server:
   ```bash
   npm run dev
   # or if you use yarn
   yarn dev
   ```

   The frontend development server will start on port 3000.

## Accessing the Application

To access the application, open `http://localhost:3000` in your web browser.

## Stopping the Application

To halt the application, you will need to stop both the backend and frontend processes.

### Stopping the Frontend

In the terminal where the frontend is running, press `Ctrl + C` to terminate the process.

### Stopping the Backend

Similarly, in the backend terminal, use the `Ctrl + C` shortcut to stop the server.
