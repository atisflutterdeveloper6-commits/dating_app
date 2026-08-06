import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();
  
  final RxString currentLocation = ''.obs;
  final RxString currentCoordinates = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool locationFetched = false.obs;
  
  // Full address components
  final RxString street = ''.obs;
  final RxString city = ''.obs;
  final RxString state = ''.obs;
  final RxString country = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString fullAddress = ''.obs;

  // ==================== LOCATION METHODS ====================

  Future<bool> getCurrentLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📍 Fetching current location...');

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled. Please enable them.';
        print('❌ Location services disabled');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'Location permission denied. Please allow location access.';
          print('❌ Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permissions are permanently denied. Please enable them in settings.';
        print('❌ Location permissions permanently denied');
        return false;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      currentCoordinates.value = '${latitude.value},${longitude.value}';

      print('✅ Location fetched!');
      print('📍 Latitude: ${latitude.value}');
      print('📍 Longitude: ${longitude.value}');

      await _getAddressFromCoordinates(position.latitude, position.longitude);

      locationFetched.value = true;
      
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to get location: $e';
      print('❌ Error getting location: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Only set city and state - keep others empty
        city.value = place.locality ?? '';
        state.value = place.administrativeArea ?? '';
        
        // Don't set these - keep them empty
        street.value = '';
        country.value = '';
        postalCode.value = '';
        
        // Build currentLocation with only city and state
        List<String> locationParts = [];
        
        if (city.value.isNotEmpty) {
          locationParts.add(city.value);
        }
        
        if (state.value.isNotEmpty) {
          locationParts.add(state.value);
        }
        
        if (locationParts.isNotEmpty) {
          currentLocation.value = locationParts.join(', ');
          fullAddress.value = currentLocation.value;
        } else {
          // If no city/state found, use coordinates
          String coordString = '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
          currentLocation.value = coordString;
          fullAddress.value = coordString;
        }
        
        print('📍 City: ${city.value}');
        print('📍 State: ${state.value}');
        print('📍 Location: ${currentLocation.value}');
      } else {
        String coordString = '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
        fullAddress.value = coordString;
        currentLocation.value = coordString;
        print('⚠️ No address found, using coordinates');
      }
    } catch (e) {
      print('❌ Error getting address: $e');
      String coordString = '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
      fullAddress.value = coordString;
      currentLocation.value = coordString;
    }
  }

  // ==================== 🔥🔥🔥 NEW DISTANCE METHODS ====================

  /// Calculate real distance between two coordinates in kilometers
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    try {
      // Using Geolocator's built-in distance method
      double distanceInMeters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      return distanceInMeters / 1000; // Convert to kilometers
    } catch (e) {
      print('❌ Error calculating distance: $e');
      return 999.0; // Return large number if error
    }
  }

  /// Get distance between user and a profile
  double getDistanceToProfile(double profileLat, double profileLon) {
    if (!locationFetched.value || latitude.value == 0.0 || longitude.value == 0.0) {
      print('⚠️ User location not available');
      return 999.0;
    }
    
    return calculateDistance(
      latitude.value, 
      longitude.value, 
      profileLat, 
      profileLon
    );
  }

  /// Format distance for display
  String formatDistance(double distanceInKm) {
    if (distanceInKm >= 999.0) {
      return 'Unknown';
    } else if (distanceInKm < 1.0) {
      // Less than 1 km - show in meters
      int meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else if (distanceInKm < 10.0) {
      // Less than 10 km - show with 1 decimal
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      // More than 10 km - show without decimal
      return '${distanceInKm.round()} km';
    }
  }

  /// Get distance with display string
  String getDistanceDisplay(double profileLat, double profileLon) {
    double distance = getDistanceToProfile(profileLat, profileLon);
    return formatDistance(distance);
  }

  /// Get approximate coordinates from city name (backup)
  Future<Map<String, double>> getCoordinatesFromCity(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        return {
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        };
      }
    } catch (e) {
      print('❌ Error getting coordinates for $cityName: $e');
    }
    return {'latitude': 0.0, 'longitude': 0.0};
  }
String getLocationAsGeoJson() {
  if (latitude.value != 0.0 && longitude.value != 0.0) {
    return jsonEncode({
      'type': 'Point',
      'coordinates': [longitude.value, latitude.value]
    });
  }
  return jsonEncode({
    'type': 'Point',
    'coordinates': [0, 0]
  });
}

// Also add this to get location as string for display:
String getLocationForDisplay() {
  return currentLocation.value.isNotEmpty 
      ? currentLocation.value 
      : '${latitude.value}, ${longitude.value}';
}
  // ==================== EXISTING METHODS ====================

  String getLocationString() {
    if (fullAddress.value.isNotEmpty) {
      return fullAddress.value;
    } else if (currentLocation.value.isNotEmpty) {
      return currentLocation.value;
    } else {
      return currentCoordinates.value;
    }
  }

  String getShortLocation() {
    if (city.value.isNotEmpty && state.value.isNotEmpty) {
      return '${city.value}, ${state.value}';
    } else if (city.value.isNotEmpty) {
      return city.value;
    } else if (fullAddress.value.isNotEmpty) {
      if (fullAddress.value.length > 30) {
        return '${fullAddress.value.substring(0, 30)}...';
      }
      return fullAddress.value;
    } else {
      return currentCoordinates.value;
    }
  }

  String getCity() => city.value;
  String getState() => state.value;
  String getCountry() => country.value;
  String getFullAddress() => fullAddress.value;

  void resetLocation() {
    currentLocation.value = '';
    currentCoordinates.value = '';
    latitude.value = 0.0;
    longitude.value = 0.0;
    locationFetched.value = false;
    street.value = '';
    city.value = '';
    state.value = '';
    country.value = '';
    postalCode.value = '';
    fullAddress.value = '';
  }

  // 🔥 NEW: Update location manually (for city selection)
  void updateLocation(double lat, double lon) {
    latitude.value = lat;
    longitude.value = lon;
    currentCoordinates.value = '$lat,$lon';
    locationFetched.value = true;
    print('📍 Location updated to: $lat, $lon');
  }
}