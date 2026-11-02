/**
 * Message Processor Lambda Function
 * Handles message sending and conversation management
 */

const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const { v4: uuidv4 } = require('uuid');
const { ulid } = require('ulid');

const USERS_TABLE = process.env.USERS_TABLE;
const CONVERSATIONS_TABLE = process.env.CONVERSATIONS_TABLE;
const MESSAGES_TABLE = process.env.MESSAGES_TABLE;

/**
 * Main Lambda handler
 */
exports.handler = async (event) => {
  console.log('MessageProcessor invoked:', JSON.stringify(event, null, 2));

  try {
    const { recipientId, content } = event.arguments;
    const senderId = event.identity.sub; // Cognito user ID

    // Validate users exist
    const [sender, recipient] = await Promise.all([
      getUser(senderId),
      getUser(recipientId)
    ]);

    if (!sender || !recipient) {
      throw new Error('User not found');
    }

    // Find or create conversation
    const conversation = await findOrCreateConversation(sender, recipient);

    // Create message
    const message = await createMessage(conversation.id, senderId, recipientId, content);

    // Update conversation metadata
    const updatedConversation = await updateConversation(
      conversation.id,
      senderId,
      recipientId,
      content,
      message.timestamp
    );

    console.log('Message sent successfully:', message.id);

    return {
      message,
      conversation: updatedConversation
    };
  } catch (error) {
    console.error('Error in messageProcessor:', error);
    throw error;
  }
};

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
 * Find existing conversation or create new one
 */
async function findOrCreateConversation(sender, recipient) {
  // Try to find existing conversation
  const existing = await findConversation(sender.id, recipient.id);
  if (existing) {
    return existing;
  }

  // Create new conversation
  const now = new Date().toISOString();
  const conversation = {
    id: uuidv4(),
    participant1Id: sender.id,
    participant2Id: recipient.id,
    participant1Name: sender.displayName,
    participant2Name: recipient.displayName,
    participant1Photo: sender.profilePhotoUrl || null,
    participant2Photo: recipient.profilePhotoUrl || null,
    lastMessageText: null,
    lastMessageTime: null,
    lastMessageSender: null,
    unreadCount1: 0,
    unreadCount2: 0,
    createdAt: now,
    updatedAt: now
  };

  const params = {
    TableName: CONVERSATIONS_TABLE,
    Item: conversation
  };

  await dynamodb.put(params).promise();

  return conversation;
}

/**
 * Find conversation between two users
 */
async function findConversation(user1Id, user2Id) {
  // Query by participant1
  const params1 = {
    TableName: CONVERSATIONS_TABLE,
    IndexName: 'byParticipant1',
    KeyConditionExpression: 'participant1Id = :userId',
    FilterExpression: 'participant2Id = :otherUserId',
    ExpressionAttributeValues: {
      ':userId': user1Id,
      ':otherUserId': user2Id
    },
    Limit: 1
  };

  const result1 = await dynamodb.query(params1).promise();
  if (result1.Items && result1.Items.length > 0) {
    return result1.Items[0];
  }

  // Query by participant2
  const params2 = {
    TableName: CONVERSATIONS_TABLE,
    IndexName: 'byParticipant2',
    KeyConditionExpression: 'participant2Id = :userId',
    FilterExpression: 'participant1Id = :otherUserId',
    ExpressionAttributeValues: {
      ':userId': user1Id,
      ':otherUserId': user2Id
    },
    Limit: 1
  };

  const result2 = await dynamodb.query(params2).promise();
  return result2.Items && result2.Items.length > 0 ? result2.Items[0] : null;
}

/**
 * Create new message
 */
async function createMessage(conversationId, senderId, recipientId, content) {
  const now = new Date().toISOString();
  const ttl = Math.floor(Date.now() / 1000) + (90 * 24 * 60 * 60); // 90 days from now

  const message = {
    id: ulid(), // ULID for time-ordered IDs
    conversationId,
    senderId,
    recipientId,
    content,
    timestamp: now,
    status: 'SENT',
    ttl,
    createdAt: now,
    updatedAt: now
  };

  const params = {
    TableName: MESSAGES_TABLE,
    Item: message
  };

  await dynamodb.put(params).promise();

  return message;
}

/**
 * Update conversation metadata
 */
async function updateConversation(conversationId, senderId, recipientId, lastMessageText, lastMessageTime) {
  const now = new Date().toISOString();

  // Determine which unread count to increment
  const params = {
    TableName: CONVERSATIONS_TABLE,
    Key: { id: conversationId },
    ReturnValues: 'ALL_NEW'
  };

  // Get current conversation to determine which participant is which
  const getResult = await dynamodb.get(params).promise();
  const conversation = getResult.Item;

  // Increment unread count for recipient
  const unreadCountField = conversation.participant1Id === recipientId ? 'unreadCount1' : 'unreadCount2';

  const updateParams = {
    TableName: CONVERSATIONS_TABLE,
    Key: { id: conversationId },
    UpdateExpression: `SET lastMessageText = :text, lastMessageTime = :time, lastMessageSender = :sender, ${unreadCountField} = ${unreadCountField} + :inc, updatedAt = :updatedAt`,
    ExpressionAttributeValues: {
      ':text': lastMessageText.substring(0, 100), // Truncate to 100 chars
      ':time': lastMessageTime,
      ':sender': senderId,
      ':inc': 1,
      ':updatedAt': now
    },
    ReturnValues: 'ALL_NEW'
  };

  const result = await dynamodb.update(updateParams).promise();
  return result.Attributes;
}
