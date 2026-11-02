# IRL

IRL is an iOS dating app built around real places. When you check in at a bar, restaurant, café or club, you can see who else is there and message them. The backend runs on AWS Amplify.

> **Status:** In development. The data model, sign-in and backend resources are set up. Some Lambda functions still return placeholder responses.

## Features

- **Sign up and sign in** with email (Amazon Cognito)
- **Profiles** with a display name, bio, profile photo, gender and who you're interested in
- **Location check-ins**: check in by hand, or automatically through geofencing when you arrive at a venue
- **See who's here**: browse other users checked in at the same location
- **Messaging**: one-to-one conversations with read receipts
- **Privacy controls**: choose whether your location is public, friends-only or private

## Tech stack

| Layer | Technology |
|---|---|
| iOS app | Swift, SwiftUI, Xcode |
| API | AWS AppSync (GraphQL) |
| Auth | Amazon Cognito |
| Database | Amazon DynamoDB |
| Storage | Amazon S3 (profile photos) |
| Serverless logic | AWS Lambda (Node.js) |
| Infrastructure | AWS Amplify CLI |

## Project structure

```
IRL/
├── IRL/                  # iOS app (Xcode project)
│   ├── App/              # App entry point
│   ├── Core/             # Models, networking, services, extensions
│   ├── Features/         # Authentication, CheckIn, Messaging, Profile
│   ├── Views/            # Shared views and UI components
│   └── IRL.xcodeproj
├── amplify/              # Amplify backend configuration
│   └── backend/
│       ├── api/          # GraphQL schema (AppSync)
│       ├── auth/         # Cognito setup
│       ├── function/     # Lambda functions
│       └── storage/      # DynamoDB + S3
└── app/                  # Amplify-generated Android models
```

### Lambda functions

| Function | Purpose |
|---|---|
| `checkInProcessor` | Handles a user checking in at a location |
| `checkOutProcessor` | Handles a user checking out |
| `geofenceEventHandler` | Triggers automatic check-ins and check-outs from geofence events |
| `getNearbyLocations` | Returns venues near the user |
| `getUsersAtLocation` | Returns the users currently checked in at a venue |
| `messageProcessor` | Processes and delivers messages |

## Getting started

### Prerequisites

- macOS with [Xcode](https://developer.apple.com/xcode/)
- [Node.js](https://nodejs.org/) 18 or newer
- An [AWS account](https://aws.amazon.com/)
- The Amplify CLI: `npm install -g @aws-amplify/cli`

### Setup

1. Clone the repo:
   ```bash
   git clone https://github.com/jill-anderson/IRL.git
   cd IRL
   ```

2. Configure Amplify with your AWS account:
   ```bash
   amplify configure
   amplify init
   ```

3. Deploy the backend. This creates the API, auth, database, storage and Lambda functions in AWS:
   ```bash
   amplify push
   ```
   This step also generates `amplifyconfiguration.json`, which the iOS app needs. That file is intentionally left out of the repo.

4. Open `IRL/IRL.xcodeproj` in Xcode, then build and run on a simulator or device.

## License

All rights reserved.
