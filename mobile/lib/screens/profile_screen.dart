import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _relationController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final user = ApiService.currentUserData;
    _nameController = TextEditingController(text: ApiService.loggedInUserName == 'Tourist' ? '' : ApiService.loggedInUserName);
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
    _emergencyContactController = TextEditingController(text: user?['emergencyContact'] ?? '');
    _relationController = TextEditingController(text: user?['emergencyContactRelation'] ?? user?['relation'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final user = ApiService.currentUserData;
    if (user == null) return;

    final userId = user['id'] ?? user['_id'] ?? user['email'];
    
    final data = {
      "fullName": _nameController.text,
      "preferredName": _nameController.text,
      "phone": _phoneController.text,
      "emergencyContact": _emergencyContactController.text,
      "emergencyContactRelation": _relationController.text,
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await ApiService.updateProfile(userId, data);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      if (success) {
        setState(() {
          // Update local session data immediately
          ApiService.currentUserData?['fullName'] = _nameController.text;
          ApiService.currentUserData?['preferredName'] = _nameController.text;
          ApiService.currentUserData?['phone'] = _phoneController.text;
          ApiService.currentUserData?['emergencyContact'] = _emergencyContactController.text;
          ApiService.currentUserData?['emergencyContactRelation'] = _relationController.text;
        });
        Navigator.pop(context); // Close edit dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Display Name')),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
              TextField(controller: _emergencyContactController, decoration: const InputDecoration(labelText: 'Emergency Contact Phone')),
              TextField(controller: _relationController, decoration: const InputDecoration(labelText: 'Relation')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _handleUpdate, child: const Text('Save Changes')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUserData;
    final String digitalId = ApiService.loggedInDigitalId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Digital ID'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // THE DIGITAL ID CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, Colors.indigo.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOURIST IDENTITY', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const Icon(Icons.verified, color: Colors.greenAccent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    ApiService.loggedInUserName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Digital ID: $digitalId', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 10),
                  Text('AADHAAR: ${user?['aadhaar'] ?? 'N/A'}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  Text('EMAIL: ${user?['email'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _buildDetailRow(Icons.phone, "Phone", user?['phone'] ?? 'N/A'),
            _buildDetailRow(Icons.contact_phone, "Emergency Contact", user?['emergencyContact'] ?? 'N/A'),
            _buildDetailRow(Icons.people, "Relation", user?['emergencyContactRelation'] ?? user?['relation'] ?? 'Not Set'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ApiService.currentUserData = null;
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50, 
                foregroundColor: Colors.red, 
                minimumSize: const Size(double.infinity, 50)
              ),
              child: const Text('Logout Session'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEditDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 28),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
