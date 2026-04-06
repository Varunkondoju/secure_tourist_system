import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _reportType = 'Lost Item';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final user = ApiService.currentUserData;
        final userId = user?['id'] ?? user?['email'] ?? "unknown_user";
        
        // Fetch live location for E-FIR
        Position? pos;
        try {
          pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (e) {
          print("Location fetch failed for E-FIR: $e");
        }

        final reportData = {
          "userId": userId,
          "fullName": ApiService.loggedInUserName,
          "phone": user?['phone'] ?? "N/A",
          "type": _reportType,
          "description": _descriptionController.text,
          "location": pos != null ? "${pos.latitude},${pos.longitude}" : "17.3850,78.4867",
          "timestamp": DateTime.now().toIso8601String(),
        };

        final success = await ApiService.submitEfir(reportData);

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('E-FIR Submitted Successfully.'), backgroundColor: Colors.green),
          );
          _descriptionController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('E-FIR Submission Failed.'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-FIR / Safety Report'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Indian Police Incident Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _reportType,
                isExpanded: true,
                items: ['Theft / Robbery', 'Harassment', 'Lost Item', 'Medical Help', 'Missing Person','Others']
                    .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (newValue) => setState(() => _reportType = newValue!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Incident Details (Please be specific)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  hintText: 'Location, Time, and Description of the issue...',
                ),
                validator: (value) => value!.isEmpty ? 'Please provide details for the E-FIR' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Emergency Note: This report is automatically shared with the nearest Indian Police Station and the Ministry of Tourism.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('SUBMIT SECURE E-FIR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
