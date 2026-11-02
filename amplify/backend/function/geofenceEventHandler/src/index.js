/**
 * Geofence Event Handler Lambda Function
 * Processes geofence ENTER/EXIT events from Amazon Location Service via EventBridge
 */

const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const appsync = new AWS.AppSync();

const USERS_TABLE = process.env.USERS_TABLE;
const CHECKINS_TABLE = process.env.CHECKINS_TABLE;
const LOCATIONS_TABLE = process.env.LOCATIONS_TABLE;

/**
 * Main Lambda handler
 * Receives events from EventBridge triggered by Amazon Location Service
 */
exports.handler = async (event) => {
  console.log('GeofenceEventHandler invoked:', JSON.stringify(event, null, 2));

  try {
    // Parse EventBridge event
    const detail = event.detail;
    const eventType = detail.EventType; // ENTER or EXIT
    const geofenceId = detail.GeofenceId;
    const deviceId = detail.DeviceId; // This should be the userId
    const position = detail.Position; // [longitude, latitude]

    console.log(`Geofence ${eventType} event for device ${deviceId} at geofence ${geofenceId}`);

    // Get location by geofenceId
    const location = await getLocationByGeofenceId(geofenceId);
    if (!location) {
      console.warn(`Location not found for geofence ${geofenceId}`);
      return { statusCode: 404, body: 'Location not found' };
    }

    // Get user to check privacy settings
    const user = await getUser(deviceId);
    if (!user) {
      console.warn(`User not found: ${deviceId}`);
      return { statusCode: 404, body: 'User not found' };
    }

    if (eventType === 'ENTER') {
      await handleEnterEvent(deviceId, location, user);
    } else if (eventType === 'EXIT') {
      await handleExitEvent(deviceId, location);
    }

    console.log(`Successfully processed ${eventType} event`);

    return { statusCode: 200, body: 'Event processed successfully' };
  } catch (error) {
    console.error('Error in geofenceEventHandler:', error);
    throw error;
  }
};

/**
 * Handle geofence ENTER event
 */
async function handleEnterEvent(userId, location, user) {
  console.log(`Processing ENTER event for user ${userId} at ${location.name}`);

  // Check if user has auto check-in enabled (based on privacy settings)
  if (user.locationPrivacy === 'PRIVATE') {
    console.log('User has location privacy set to PRIVATE, skipping auto check-in');
    return;
  }

  // Check if user already has an active check-in
  const existingCheckIn = await getActiveCheckIn(userId);
  if (existingCheckIn) {
    // Auto check-out from previous location
    await checkOutUser(existingCheckIn.id);
  }

  // Create new check-in
  await createCheckIn(userId, location.id, true);
}

/**
 * Handle geofence EXIT event
 */
async function handleExitEvent(userId, location) {
  console.log(`Processing EXIT event for user ${userId} at ${location.name}`);

  // Find active check-in at this location
  const activeCheckIn = await getActiveCheckInAtLocation(userId, location.id);

  if (!activeCheckIn) {
    console.log('No active check-in found for EXIT event');
    return;
  }

  // Check minimum duration (5 minutes) to avoid false positives from GPS drift
  const checkInTime = new Date(activeCheckIn.checkInTime);
  const now = new Date();
  const durationMinutes = (now - checkInTime) / (1000 * 60);

  if (durationMinutes < 5) {
    console.log('Check-in duration too short, ignoring EXIT event');
    return;
  }

  // Perform check-out
  await checkOutUser(activeCheckIn.id);
}

/**
 * Get location by geofence ID
 */
async function getLocationByGeofenceId(geofenceId) {
  const params = {
    TableName: LOCATIONS_TABLE,
    IndexName: 'byGeofenceId',
    KeyConditionExpression: 'geofenceId = :geofenceId',
    ExpressionAttributeValues: {
      ':geofenceId': geofenceId
    },
    Limit: 1
  };

  const result = await dynamodb.query(params).promise();
  return result.Items && result.Items.length > 0 ? result.Items[0] : null;
}

/**
 * Get user by ID
 */
async function getUser(userId) {
  const params = {
    TableName: USERS_TABLE,
    Key: { id: userId }
  };

  const result = await dynamodb.get(params).promise();
  return result.Item;
}

/**
 * Get user's active check-in
 */
async function getActiveCheckIn(userId) {
  const params = {
    TableName: CHECKINS_TABLE,
    IndexName: 'byUser',
    KeyConditionExpression: 'userId = :userId',
    FilterExpression: '#status = :status',
    ExpressionAttributeNames: {
      '#status': 'status'
    },
    ExpressionAttributeValues: {
      ':userId': userId,
      ':status': 'ACTIVE'
    },
    Limit: 1
  };

  const result = await dynamodb.query(params).promise();
  return result.Items && result.Items.length > 0 ? result.Items[0] : null;
}

/**
 * Get active check-in at specific location
 */
async function getActiveCheckInAtLocation(userId, locationId) {
  const params = {
    TableName: CHECKINS_TABLE,
    IndexName: 'byUser',
    KeyConditionExpression: 'userId = :userId',
    FilterExpression: '#status = :status AND locationId = :locationId',
    ExpressionAttributeNames: {
      '#status': 'status'
    },
    ExpressionAttributeValues: {
      ':userId': userId,
      ':status': 'ACTIVE',
      ':locationId': locationId
    },
    Limit: 1
  };

  const result = await dynamodb.query(params).promise();
  return result.Items && result.Items.length > 0 ? result.Items[0] : null;
}

/**
 * Create new check-in
 */
async function createCheckIn(userId, locationId, autoCheckIn) {
  const { v4: uuidv4 } = require('uuid');
  const now = new Date().toISOString();
  const ttl = Math.floor(Date.now() / 1000) + (30 * 24 * 60 * 60); // 30 days

  const checkIn = {
    id: uuidv4(),
    userId,
    locationId,
    checkInTime: now,
    checkOutTime: null,
    status: 'ACTIVE',
    autoCheckIn,
    ttl,
    createdAt: now,
    updatedAt: now
  };

  const params = {
    TableName: CHECKINS_TABLE,
    Item: checkIn
  };

  await dynamodb.put(params).promise();

  // Update user's last active timestamp
  await updateUserLastActive(userId);

  console.log('Check-in created:', checkIn.id);
}

/**
 * Check out user
 */
async function checkOutUser(checkInId) {
  const now = new Date().toISOString();

  const params = {
    TableName: CHECKINS_TABLE,
    Key: { id: checkInId },
    UpdateExpression: 'SET checkOutTime = :checkOutTime, #status = :status, updatedAt = :updatedAt',
    ExpressionAttributeNames: {
      '#status': 'status'
    },
    ExpressionAttributeValues: {
      ':checkOutTime': now,
      ':status': 'CHECKED_OUT',
      ':updatedAt': now
    }
  };

  await dynamodb.update(params).promise();
  console.log('Checked out:', checkInId);
}

/**
 * Update user's last active timestamp
 */
async function updateUserLastActive(userId) {
  const now = new Date().toISOString();

  const params = {
    TableName: USERS_TABLE,
    Key: { id: userId },
    UpdateExpression: 'SET lastActiveAt = :lastActiveAt, updatedAt = :updatedAt',
    ExpressionAttributeValues: {
      ':lastActiveAt': now,
      ':updatedAt': now
    }
  };

  await dynamodb.update(params).promise();
}
