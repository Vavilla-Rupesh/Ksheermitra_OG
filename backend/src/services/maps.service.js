const axios = require('axios');
const logger = require('../utils/logger');

class MapsService {
  constructor() {
    this.apiKey = process.env.GOOGLE_MAPS_API_KEY;
    this.baseUrl = 'https://maps.googleapis.com/maps/api';
  }

  async geocodeAddress(address) {
    try {
      const response = await axios.get(`${this.baseUrl}/geocode/json`, {
        params: {
          address,
          key: this.apiKey
        }
      });

      if (response.data.status === 'OK' && response.data.results.length > 0) {
        const location = response.data.results[0].geometry.location;
        return {
          latitude: location.lat,
          longitude: location.lng,
          formattedAddress: response.data.results[0].formatted_address
        };
      }

      throw new Error(`Geocoding failed: ${response.data.status}`);
    } catch (error) {
      logger.error('Error geocoding address:', error);
      throw error;
    }
  }

  async reverseGeocode(latitude, longitude) {
    try {
      const response = await axios.get(`${this.baseUrl}/geocode/json`, {
        params: {
          latlng: `${latitude},${longitude}`,
          key: this.apiKey
        }
      });

      if (response.data.status === 'OK' && response.data.results.length > 0) {
        return {
          formattedAddress: response.data.results[0].formatted_address,
          addressComponents: response.data.results[0].address_components
        };
      }

      throw new Error(`Reverse geocoding failed: ${response.data.status}`);
    } catch (error) {
      logger.error('Error reverse geocoding:', error);
      throw error;
    }
  }

  async optimizeRoute(origin, destinations) {
    try {
      if (!destinations || destinations.length === 0) {
        return { optimizedOrder: [], routes: [] };
      }

      const waypoints = destinations.map(dest => 
        `${dest.latitude},${dest.longitude}`
      ).join('|');

      const response = await axios.get(`${this.baseUrl}/directions/json`, {
        params: {
          origin: `${origin.latitude},${origin.longitude}`,
          destination: `${origin.latitude},${origin.longitude}`,
          waypoints: `optimize:true|${waypoints}`,
          key: this.apiKey
        }
      });

      if (response.data.status === 'OK') {
        const route = response.data.routes[0];
        const waypointOrder = route.waypoint_order;
        
        const optimizedDestinations = waypointOrder.map(index => destinations[index]);
        
        const routeDetails = route.legs.map((leg, index) => ({
          startAddress: leg.start_address,
          endAddress: leg.end_address,
          distance: leg.distance.text,
          duration: leg.duration.text,
          distanceMeters: leg.distance.value,
          durationSeconds: leg.duration.value
        }));

        const totalDistance = route.legs.reduce((sum, leg) => sum + leg.distance.value, 0);
        const totalDuration = route.legs.reduce((sum, leg) => sum + leg.duration.value, 0);

        return {
          optimizedOrder: waypointOrder,
          optimizedDestinations,
          routes: routeDetails,
          totalDistance: totalDistance,
          totalDuration: totalDuration,
          polyline: route.overview_polyline.points
        };
      }

      throw new Error(`Route optimization failed: ${response.data.status}`);
    } catch (error) {
      logger.error('Error optimizing route:', error);
      throw error;
    }
  }

  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;
    
    return distance;
  }

  toRad(degrees) {
    return degrees * (Math.PI / 180);
  }
}

module.exports = new MapsService();
