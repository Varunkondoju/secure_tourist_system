import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class NavigationMapScreen extends StatefulWidget {
  const NavigationMapScreen({super.key});

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(17.3850, 78.4867); // Default Hyderabad
  bool _isLoading = true;
  bool _isTracking = true;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    // Request permission and get current pos
    LocationPermission permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 16));
      }

      // Track movement LIVE
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
      ).listen((Position position) {
        if (mounted && _isTracking) {
          LatLng newPos = LatLng(position.latitude, position.longitude);
          setState(() => _currentPosition = newPos);
          _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
        }
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 20, left: 20,
            child: FloatingActionButton.extended(
              onPressed: () => setState(() => _isTracking = !_isTracking),
              label: Text(_isTracking ? "Tracking ON" : "Tracking OFF"),
              icon: Icon(_isTracking ? Icons.gps_fixed : Icons.gps_off),
              backgroundColor: _isTracking ? Colors.green : Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
