import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'dart:async';

class LocationService {
  static Timer? _updateTimer;

  static Future<void> requestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  static void startLiveTracking() {
    _updateTimer?.cancel();
    // Update backend every 5 minutes with current location
    _updateTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        
        await ApiService.updateActivity(
          position.latitude, 
          position.longitude, 
          "Active"
        );
        print("Backend updated with live location: ${position.latitude}, ${position.longitude}");
      } catch (e) {
        print("Failed to send live location to backend: $e");
      }
    });
  }

  static void stopTracking() {
    _updateTimer?.cancel();
  }
}
