import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'trip_screen.dart';
import 'navigation_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "Tourist";
  String? _digitalId;
  dynamic _currentScore = "98";
  bool _isScoreLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateScore();
  }

  void _loadUserData() {
    setState(() {
      final user = ApiService.currentUserData;
      _userName = user?['fullName'] ?? user?['preferredName'] ?? user?['name'] ?? "Tourist";
      _digitalId = user?['digitalId'] ?? ApiService.loggedInDigitalId;
    });
  }

  Future<void> _updateScore() async {
    setState(() => _isScoreLoading = true);
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
      int? newScore = await ApiService.getSafetyScore(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _currentScore = newScore ?? 98;
          _isScoreLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _currentScore = 98; _isScoreLoading = false; });
    }
  }

  void _showEmergencyContacts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'EMERGENCY CONTACTS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 16),
              _buildContactTile(Icons.local_police, 'Police', '100'),
              _buildContactTile(Icons.medical_services, 'Ambulance', '102'),
              _buildContactTile(Icons.fire_truck, 'Fire Brigade', '101'),
              _buildContactTile(Icons.woman, 'Women Helpline', '1091'),
              _buildContactTile(Icons.emergency, 'National Emergency', '112'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTile(IconData icon, String label, String number) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(number, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: _buildIndianDrawer(context),
      body: RefreshIndicator(
        onRefresh: _updateScore,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $_userName! (Namaste)',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (_digitalId != null && _digitalId != "N/A")
                    Text(
                      'Digital ID: $_digitalId',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSafetyScoreCard(),
              const SizedBox(height: 32),
              _buildPanicButton(context),
              const SizedBox(height: 24),
              const Text(
                'Quick Action',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildIndianQuickActions(context),
              const SizedBox(height: 32),
              const Text(
                'Safety Tips for Tourists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSafetyTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndianQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickActionButton(
          icon: Icons.navigation,
          label: 'Navigate',
          color: Colors.blue,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationMapScreen())),
        ),
        _QuickActionButton(
          icon: Icons.travel_explore,
          label: 'My Trip',
          color: Colors.orange,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TripScreen())),
        ),
        _QuickActionButton(
          icon: Icons.contact_phone,
          label: 'Contacts',
          color: Colors.green,
          onTap: () => _showEmergencyContacts(context),
        ),
      ],
    );
  }

  Widget _buildSafetyTips() {
    final tips = [
      {'icon': Icons.security, 'text': 'Always keep your Digital ID handy for quick verification.'},
      {'icon': Icons.map, 'text': 'Check the Safety Score of a new area before visiting.'},
      {'icon': Icons.phone_android, 'text': 'Ensure your phone is charged and location sharing is ON.'},
      {'icon': Icons.people, 'text': 'Share your trip itinerary with your emergency contacts.'},
      {'icon': Icons.emergency, 'text': 'In any doubt, use the SOS button or call 112 immediately.'},
    ];

    return Column(
      children: tips.map((tip) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(tip['icon'] as IconData, color: Colors.indigo, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip['text'] as String,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildIndianDrawer(BuildContext context) {
    final user = ApiService.currentUserData;
    final relation = user?['emergencyContactRelation'] ?? user?['relation'] ?? 'Not Set';

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text('Relation: $relation'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.indigo),
            ),
            decoration: const BoxDecoration(color: Colors.indigo),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.indigo),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ApiService.currentUserData = null;
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyScoreCard() {
    Color scoreColor = Colors.indigo;
    if (!_isScoreLoading) {
      int score = _currentScore is int ? _currentScore : int.tryParse(_currentScore.toString()) ?? 98;
      if (score >= 90) scoreColor = Colors.green.shade700;
      else if (score >= 70) scoreColor = Colors.orange.shade700;
      else scoreColor = Colors.red.shade700;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.white, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text('Smart Safety Score', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isScoreLoading 
              ? const SizedBox(height: 48, width: 48, child: CircularProgressIndicator(strokeWidth: 3))
              : Text('$_currentScore', style: TextStyle(color: scoreColor, fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPanicButton(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final user = ApiService.currentUserData;
        final userId = user?['id'] ?? user?['_id'] ?? user?['email'] ?? "Unknown";
        final fullName = user?['fullName'] ?? user?['preferredName'] ?? user?['name'] ?? "Tourist";
        final phone = user?['phone'] ?? user?['phoneNumber'] ?? "N/A";
        
        // Get Live Location
        Position? pos;
        try {
          pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 5));
        } catch (e) {
          print("Location fetch failed for SOS: $e");
        }

        final data = {
          "userId": userId,
          "fullName": fullName,
          "phone": phone,
          "digitalId": user?['digitalId'] ?? _digitalId ?? "N/A",
          "location": pos != null ? "${pos.latitude},${pos.longitude}" : "17.3850,78.4867"
        };

        final success = await ApiService.sendSOS(data);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '🚨 SOS Sent Successfully!'
                :'SOS Failed to Send'),
            backgroundColor: success ? Colors.red : Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 44),
              const SizedBox(height: 8),
              Text(
                'EMERGENCY SOS\n(Long Press for 3s)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
