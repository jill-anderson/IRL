/**
 * Get Nearby Locations Lambda Function
 * Returns locations near a given coordinate using geospatial queries
 */

const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const LOCATIONS_TABLE = process.env.LOCATIONS_TABLE;

/**
 * Calculate distance between two coordinates using Haversine formula
 * Returns distance in meters
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // Earth's radius in meters
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c; // Distance in meters
}

/**
 * Main Lambda handler
 */
exports.handler = async (event) => {
  console.log('GetNearbyLocations invoked:', JSON.stringify(event, null, 2));

  try {
    const { latitude, longitude, radius, limit = 20 } = event.arguments;

    // Scan all locations and calculate distances
    // TODO: For production, implement geohash indexing for efficient spatial queries
    const allLocations = await getAllLocations();

    // Calculate distances and filter by radius
    const locationsWithDistance = allLocations.map(location => ({
      ...location,
      distance: calculateDistance(latitude, longitude, location.latitude, location.longitude)
    }));

    // Filter by radius
    const nearbyLocations = locationsWithDistance.filter(
      location => location.distance <= radius
    );

    // Sort by distance (closest first)
    nearbyLocations.sort((a, b) => a.distance - b.distance);

    // Limit results
    const limitedResults = nearbyLocations.slice(0, limit);

    console.log(`Found ${limitedResults.length} locations within ${radius}m`);

    return limitedResults;
  } catch (error) {
    console.error('Error in getNearbyLocations:', error);
    throw error;
  }
};

/**
 * Get all locations from DynamoDB
 * Note: For production with many locations, implement pagination
 */
async function getAllLocations() {
  const params = {
    TableName: LOCATIONS_TABLE
  };

  const result = await dynamodb.scan(params).promise();
  return result.Items || [];
}
