# IRL Dating App - GraphQL API Documentation

## Overview

This GraphQL API powers the IRL dating app, providing real-time location-based check-ins, user profiles, and messaging functionality.

## Core Features

### 1. User Management
- User profiles with photos, bio, and preferences
- Gender and interest preferences
- Location privacy controls (PUBLIC, FRIENDS, PRIVATE)
- Notification preferences

### 2. Location & Check-ins
- Automatic check-in via geofencing
- Manual check-in option
- Real-time location tracking
- Check-in history
- User count at locations

### 3. Messaging
- One-on-one conversations
- Real-time message delivery
- Read receipts
- Unread message counts
- Message history

## Authentication & Authorization

### User Pools (Cognito)
- Used for authenticated user operations
- Users can only read/update their own data
- Public read access for viewing other users at locations

### IAM
- Used for Lambda function invocations
- Backend services can create/update locations
- Geofence event processing

## Data Models

### User
```graphql
{
  id: ID!
  email: AWSEmail!
  username: String!
  displayName: String!
  bio: String
  profilePhotoUrl: AWSURL
  birthDate: AWSDate!
  gender: Gender!
  locationPrivacy: LocationPrivacy!
}
```

### Location
```graphql
{
  id: ID!
  name: String!
  type: LocationType! # BAR, RESTAURANT, CAFE, CLUB
  address: String!
  latitude: Float!
  longitude: Float!
  geofenceId: String!
  radius: Float!
}
```

### CheckIn
```graphql
{
  id: ID!
  userId: ID!
  locationId: ID!
  checkInTime: AWSDateTime!
  checkOutTime: AWSDateTime
  status: CheckInStatus! # ACTIVE, CHECKED_OUT, EXPIRED
  autoCheckIn: Boolean!
}
```

### Message
```graphql
{
  id: ID!
  conversationId: ID!
  senderId: ID!
  recipientId: ID!
  content: String!
  timestamp: AWSDateTime!
  status: MessageStatus! # SENT, DELIVERED, READ
}
```

## Custom Queries

### getUsersAtLocation
Get all users currently checked in at a specific location.

```graphql
query GetUsersAtBar {
  getUsersAtLocation(locationId: "location-123", limit: 50) {
    id
    displayName
    profilePhotoUrl
    bio
  }
}
```

**Respects Location Privacy:**
- PUBLIC: Visible to all
- FRIENDS: Only visible to connected users (future feature)
- PRIVATE: Not visible

### getNearbyLocations
Get nearby bars/restaurants based on user's coordinates.

```graphql
query GetNearby {
  getNearbyLocations(
    latitude: 37.7749
    longitude: -122.4194
    radius: 5000 # meters
    limit: 20
  ) {
    id
    name
    type
    distance # calculated field
  }
}
```

### getMyActiveCheckIn
Get the current user's active check-in if any.

```graphql
query GetMyCheckIn {
  getMyActiveCheckIn {
    id
    location {
      name
      type
    }
    checkInTime
  }
}
```

## Custom Mutations

### autoCheckIn
Triggered when user enters a geofence.

```graphql
mutation CheckIn {
  autoCheckIn(locationId: "location-123") {
    id
    checkInTime
    location {
      name
    }
  }
}
```

**Business Logic:**
- Only one active check-in per user
- Updates `lastActiveAt` timestamp
- Triggers `onCheckInAtLocation` subscription
- Creates notification for nearby users (if enabled)

### sendMessage
Send a message to another user.

```graphql
mutation Send {
  sendMessage(
    recipientId: "user-456"
    content: "Hey! Great meeting you at the bar!"
  ) {
    message {
      id
      timestamp
      status
    }
    conversation {
      id
      unreadCount1
      unreadCount2
    }
  }
}
```

**Business Logic:**
- Creates conversation if it doesn't exist
- Updates conversation `lastMessage` fields
- Increments unread count for recipient
- Triggers `onNewMessage` subscription
- Sends push notification (if enabled)

### checkOut
Check out from current location.

```graphql
mutation CheckOut {
  checkOut {
    id
    checkOutTime
    status
  }
}
```

**Business Logic:**
- Sets `checkOutTime` to current timestamp
- Changes status to `CHECKED_OUT`
- Triggers `onCheckOutAtLocation` subscription

## Real-time Subscriptions

### onCheckInAtLocation
Receive updates when users check in at a location.

```graphql
subscription WatchLocation {
  onCheckInAtLocation(locationId: "location-123") {
    id
    user {
      displayName
      profilePhotoUrl
    }
    checkInTime
  }
}
```

**Use Case:** Update the "Users Here" list in real-time

### onNewMessage
Receive new messages in a conversation.

```graphql
subscription WatchMessages {
  onNewMessage(conversationId: "conv-789") {
    id
    senderId
    content
    timestamp
    status
  }
}
```

**Use Case:** Real-time chat interface

### onConversationUpdate
Receive updates to conversation metadata (unread counts, last message).

```graphql
subscription WatchConversations {
  onConversationUpdate(userId: "user-123") {
    id
    lastMessageText
    lastMessageTime
    unreadCount1
    unreadCount2
  }
}
```

**Use Case:** Update conversations list

## Lambda Functions

### checkInProcessor
**Triggered by:** `autoCheckIn`, `manualCheckIn` mutations

**Responsibilities:**
- Validate user can check in (not already checked in elsewhere)
- Create CheckIn record
- Update user's `lastActiveAt`
- Trigger AppSync subscription

### checkOutProcessor
**Triggered by:** `checkOut` mutation, EXIT geofence event

**Responsibilities:**
- Find active check-in for user
- Set `checkOutTime`
- Update status to `CHECKED_OUT`
- Trigger AppSync subscription

### messageProcessor
**Triggered by:** `sendMessage` mutation

**Responsibilities:**
- Find or create Conversation
- Create Message record
- Update Conversation metadata
- Increment unread count
- Trigger AppSync subscriptions
- Send push notification via SNS

### getUsersAtLocation
**Triggered by:** `getUsersAtLocation` query

**Responsibilities:**
- Query CheckIns table by locationId
- Filter by status = ACTIVE
- Fetch user details
- Respect privacy settings
- Return sorted list

### getNearbyLocations
**Triggered by:** `getNearbyLocations` query

**Responsibilities:**
- Query Locations table
- Calculate distances from user position
- Filter by radius
- Sort by distance
- Return limited results

### geofenceEventHandler
**Triggered by:** EventBridge (Amazon Location Service)

**Responsibilities:**
- Parse geofence ENTER/EXIT events
- Trigger appropriate check-in/check-out logic
- Handle duplicate events
- Log event for analytics

## Indexes

### User Table
- `byEmail` - Look up user by email
- `byUsername` - Look up user by username

### CheckIn Table
- `byUser` - Get all check-ins for a user (sorted by time)
- `byLocation` - Get all check-ins at a location (sorted by time)
- `byStatus` - Get all active check-ins

### Message Table
- `byConversation` - Get messages in a conversation (sorted by time)
- `bySender` - Get messages sent by a user
- `byRecipient` - Get messages received by a user

### Conversation Table
- `byParticipant1` - Get conversations for user (sorted by updated time)
- `byParticipant2` - Get conversations for user (sorted by updated time)

## TTL (Time To Live)

### CheckIns
- Auto-delete after 30 days
- Keeps database clean
- Historical data can be archived to S3

### Messages (Optional)
- Auto-delete after 90 days
- Configurable per user preference
- Important messages can be marked for retention

## Error Handling

### Common Errors
- `UserAlreadyCheckedIn` - User has active check-in elsewhere
- `LocationNotFound` - Invalid location ID
- `ConversationNotFound` - Invalid conversation ID
- `Unauthorized` - User doesn't have permission
- `RateLimitExceeded` - Too many requests

## Performance Considerations

### Caching
- AppSync has built-in caching (1 hour TTL)
- Location queries are cached
- User profiles are cached

### Pagination
- Use `limit` and `nextToken` for large result sets
- Default limit: 50 items
- Maximum limit: 100 items

### Subscriptions
- Limit subscriptions to active screens only
- Unsubscribe when component unmounts
- Use connection pooling in AppSync client

## Security Best Practices

1. **Never expose sensitive data**
   - Email addresses only visible to owner
   - Phone numbers only visible to owner
   - Location data respects privacy settings

2. **Validate all inputs**
   - Lambda functions validate all parameters
   - GraphQL validates types automatically

3. **Rate limiting**
   - Implement per-user rate limits in Lambda
   - Monitor for abuse via CloudWatch

4. **Data encryption**
   - All data encrypted at rest (DynamoDB)
   - All data encrypted in transit (HTTPS/WSS)

## Monitoring & Logging

### CloudWatch Metrics
- Lambda invocation count
- Lambda duration
- Lambda errors
- AppSync request count
- AppSync latency

### CloudWatch Logs
- All Lambda functions log to CloudWatch
- Log levels: INFO, WARN, ERROR
- Include request ID for tracing

## Testing

### Unit Tests
```bash
cd amplify/backend/function/checkInProcessor
npm test
```

### Integration Tests
```bash
amplify mock api
```

### Load Tests
- Use AWS AppSync console
- Simulate 100+ concurrent users
- Monitor CloudWatch metrics

## Deployment

```bash
# Push schema to AWS
amplify push

# Deploy Lambda functions
amplify publish
```

## Next Steps

1. Implement Lambda functions
2. Set up DynamoDB tables
3. Configure Amazon Location Service
4. Set up EventBridge rules
5. Configure S3 for profile photos
6. Set up CloudFront CDN
7. Configure SNS for push notifications
