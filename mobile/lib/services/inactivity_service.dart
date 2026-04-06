import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';

class InactivityService {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  Timer? _inactivityTimer;
  Timer? _responseTimer;
  bool _isPromptOpen = false;

  // Track the E-FIR status to show in the UI
  bool efirFiled = false;

  void startMonitoring(BuildContext context) {
    _resetTimer(context);
  }

  void _resetTimer(BuildContext context) {
    _inactivityTimer?.cancel();
    // Safety check duration set to 2 minutes of inactivity as requested
    _inactivityTimer = Timer(const Duration(minutes: 2), () {
      if (!efirFiled) {
        _showSafetyPrompt(context);
      }
    });
  }

  void userActivityDetected(BuildContext context) {
    if (!_isPromptOpen) {
      _resetTimer(context);
    }
  }

  void _showSafetyPrompt(BuildContext context) {
    _isPromptOpen = true;
    _startResponseCountdown(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.indigo),
            SizedBox(width: 10),
            Text('Safety Check'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Our system detects no activity for several hours.'),
            SizedBox(height: 16),
            Text('Are you safe?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.indigo)),
            SizedBox(height: 12),
            Text('URGENT: If you do not respond within 3 minutes, an automated E-FIR will be filed with the Indian Police for your safety.', 
              style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                _responseTimer?.cancel();
                _isPromptOpen = false;

                // Tell backend "I am active now"
                final user = ApiService.currentUserData;
                if (user != null) {
                  final userId = user['id'] ?? user['email'];
                  await ApiService.updateProfile(userId, {
                    "lastActiveAt": DateTime.now().toIso8601String(),
                    "emergencyActive": false
                  });
                }

                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                _resetTimer(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Safety confirmed. Monitoring resumed.'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("YES, I'M SAFE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _startResponseCountdown(BuildContext context) {
    _responseTimer?.cancel();
    // Countdown set to 3 minutes as per requirement
    _responseTimer = Timer(const Duration(minutes: 3), () {
      if (_isPromptOpen) {
        _triggerAutomatedEFIR(context);
      }
    });
  }

  void _triggerAutomatedEFIR(BuildContext context) {
    _isPromptOpen = false;
    efirFiled = true;
    
    // Logic to file the E-FIR via API
    final user = ApiService.currentUserData;
    if (user != null) {
      final reportData = {
        "userId": user['id'] ?? user['email'],
        "type": "Automated Missing Person",
        "description": "User failed to respond to safety check prompt after inactivity.",
        "location": "Automated Check",
        "timestamp": DateTime.now().toIso8601String(),
      };
      ApiService.submitEfir(reportData);
    }

    // Close the safety prompt dialog
    Navigator.of(context, rootNavigator: true).pop();
    
    // Notify the user/tourist that the report has been sent
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: const Row(
          children: [
            Icon(Icons.gavel, color: Colors.red),
            SizedBox(width: 10),
            Text('E-FIR FILED', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
          'Because you did not respond to the safety check, an automated Missing Person E-FIR has been filed with the nearest Police Station.\n\nPlease contact 100 immediately if this is a mistake.',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DISMISS'),
          ),
          ElevatedButton(
            onPressed: () {}, // Trigger call to 100
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CALL POLICE (100)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
