/**
 * Get Users At Location Lambda Function
 * Returns list of users currently checked in at a specific location
 */

const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const USERS_TABLE = process.env.USERS_TABLE;
const CHECKINS_TABLE = process.env.CHECKINS_TABLE;

/**
 * Main Lambda handler
 */
exports.handler = async (event) => {
  console.log('GetUsersAtLocation invoked:', JSON.stringify(event, null, 2));

  try {
    const { locationId, limit = 50 } = event.arguments;

    // Get all active check-ins at this location
    const checkIns = await getActiveCheckInsAtLocation(locationId, limit);

    if (!checkIns || checkIns.length === 0) {
      return [];
    }

    // Get user details for each check-in
    const userIds = checkIns.map(checkIn => checkIn.userId);
    const users = await getUsers(userIds);

    // Filter based on privacy settings
    const visibleUsers = users.filter(user => {
      return user.locationPrivacy === 'PUBLIC';
      // TODO: Add FRIENDS logic when friend system is implemented
    });

    // Sort by check-in time (most recent first)
    const usersWithCheckInTime = visibleUsers.map(user => {
      const checkIn = checkIns.find(ci => ci.userId === user.id);
      return {
        ...user,
        checkInTime: checkIn ? checkIn.checkInTime : null
      };
    });

    usersWithCheckInTime.sort((a, b) => {
      return new Date(b.checkInTime) - new Date(a.checkInTime);
    });

    console.log(`Returning ${usersWithCheckInTime.length} users at location ${locationId}`);

    return usersWithCheckInTime;
  } catch (error) {
    console.error('Error in getUsersAtLocation:', error);
    throw error;
  }
};

/**
 * Get all active check-ins at a location
 */
async function getActiveCheckInsAtLocation(locationId, limit) {
  const params = {
    TableName: CHECKINS_TABLE,
    IndexName: 'byLocation',
    KeyConditionExpression: 'locationId = :locationId',
    FilterExpression: '#status = :status',
    ExpressionAttributeNames: {
      '#status': 'status'
    },
    ExpressionAttributeValues: {
      ':locationId': locationId,
      ':status': 'ACTIVE'
    },
    Limit: limit,
    ScanIndexForward: false // Most recent first
  };

  const result = await dynamodb.query(params).promise();
  return result.Items || [];
}

/**
 * Get multiple users by IDs
 */
async function getUsers(userIds) {
  if (!userIds || userIds.length === 0) {
    return [];
  }

  // Batch get users (max 100 at a time)
  const keys = userIds.map(id => ({ id }));

  const params = {
    RequestItems: {
      [USERS_TABLE]: {
        Keys: keys
      }
    }
  };

  const result = await dynamodb.batchGet(params).promise();
  return result.Responses[USERS_TABLE] || [];
}
