import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://secure-tourist-backend.onrender.com/api';

  static Map<String, dynamic>? currentUserData;

  // Robust name getter
  static String get loggedInUserName {
    try {
      if (currentUserData == null) return 'Tourist';
      return currentUserData?['fullName'] ?? 
             currentUserData?['preferredName'] ?? 
             currentUserData?['name'] ?? 
             currentUserData?['username'] ?? 
             'Tourist';
    } catch (e) {
      return 'Tourist';
    }
  }

  static String get loggedInDigitalId {
    try {
      return currentUserData?['digitalId']?.toString() ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  static Future<bool> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': identifier, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        Map<String, dynamic> tempUser = {};
        if (data['user'] != null && data['user'] is Map) {
          tempUser = Map<String, dynamic>.from(data['user']);
        }
        
        data.forEach((key, value) {
          if (key != 'user' && value != null) tempUser[key] = value;
        });

        // Backend returns userId separately, map it to 'id' for Flutter usage
        if (data['userId'] != null) tempUser['id'] = data['userId'];
        
        currentUserData = tempUser;
        print("DEBUG: Final User Data Map -> $currentUserData");
        return true;
      }
      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }

  static Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/update/$userId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendSOS(Map<String, dynamic> data) async {
    try {
      print("🚨 Sending SOS...");
      final response = await http.post(
        Uri.parse("https://secure-tourist-backend.onrender.com/api/emergency/sos"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<int?> getSafetyScore(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.5:8000/predict?lat=$lat&lon=$lon"),
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data["safety_score"] as num?)?.toInt();
      }

      return null;
    } catch (e) {
      print("Safety Score API Error: $e");
      return null;
    }
  }

  static Future<bool> submitEfir(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/efir/create'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("E-FIR Error: $e");
      return false;
    }
  }

  // Added back updateActivity
  static Future<void> updateActivity(double lat, double lng, String status) async {
    try {
      final userId = currentUserData?['id'] ?? currentUserData?['email'] ?? 'unknown';
      await http.post(
        Uri.parse('$baseUrl/users/activity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'latitude': lat,
          'longitude': lng,
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('Activity update failed: $e');
    }
  }

  static Future<List<dynamic>> fetchTrips(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trips/user/$userId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addTrip(Map<String, dynamic> data) async {
    try {
      final response = await http.post( Uri.parse('$baseUrl/trips/add'), headers: {"Content-Type": "application/json"}, body: jsonEncode(data));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post( Uri.parse("$baseUrl/users/forgot-password"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"email": email}));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      final response = await http.post( Uri.parse("$baseUrl/users/reset-password"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"userId": userId, "newPassword": newPassword}));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
