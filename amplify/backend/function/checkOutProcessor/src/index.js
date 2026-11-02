/**
 * Check-Out Processor Lambda Function
 * Handles check-outs for users leaving locations
 */

const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const CHECKINS_TABLE = process.env.CHECKINS_TABLE;

/**
 * Main Lambda handler
 */
exports.handler = async (event) => {
  console.log('CheckOutProcessor invoked:', JSON.stringify(event, null, 2));

  try {
    const userId = event.identity.sub; // Cognito user ID

    // Find user's active check-in
    const activeCheckIn = await getActiveCheckIn(userId);

    if (!activeCheckIn) {
      throw new Error('No active check-in found');
    }

    // Check minimum duration (5 minutes) to avoid false positives from GPS drift
    const checkInTime = new Date(activeCheckIn.checkInTime);
    const now = new Date();
    const durationMinutes = (now - checkInTime) / (1000 * 60);

    if (durationMinutes < 5) {
      console.log('Check-in duration too short, ignoring check-out');
      throw new Error('Check-in duration must be at least 5 minutes');
    }

    // Perform check-out
    const updatedCheckIn = await checkOutUser(activeCheckIn.id);

    console.log('Check-out successful:', updatedCheckIn.id);

    return updatedCheckIn;
  } catch (error) {
    console.error('Error in checkOutProcessor:', error);
    throw error;
  }
};

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
    },
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(params).promise();
  return result.Attributes;
}
