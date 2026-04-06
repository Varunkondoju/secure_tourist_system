import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _myTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    final user = ApiService.currentUserData;
    if (user != null) {
      final trips = await ApiService.fetchTrips(user['email']);
      setState(() {
        _myTrips = trips;
        _isLoading = false;
      });
    }
  }

  void _addNewTrip() {
    String title = "";
    String date = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Destination (e.g. Delhi)'),
              onChanged: (v) => title = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Date (e.g. Apr 10)'),
              onChanged: (v) => date = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (title.isNotEmpty && date.isNotEmpty) {
                final user = ApiService.currentUserData;
                final data = {
                  "userId": user?['email'],
                  "destination": title,
                  "date": date,
                };
                
                final success = await ApiService.addTrip(data);
                if (success) {
                  Navigator.pop(context);
                  _loadTrips(); // Refresh the list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Trip Added Successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to add trip")),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian Trip Itinerary'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildTripList('all'),
              _buildTripList('Upcoming'),
              _buildTripList('Completed'),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTrip,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTripList(String filter) {
    final filteredTrips = _myTrips.where((trip) => filter == 'all' || trip['status'] == filter).toList();

    if (filteredTrips.isEmpty) {
      return const Center(child: Text('No trips found. Tap + to add one.'));
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredTrips.length,
        itemBuilder: (context, index) {
          final trip = filteredTrips[index];
          final isCompleted = trip['status'] == 'Completed';
          return TripCard(
            title: trip['destination'] ?? 'Unknown',
            status: trip['status'] ?? 'Upcoming',
            date: trip['date'] ?? 'N/A',
            icon: isCompleted ? Icons.verified : Icons.calendar_month,
            color: isCompleted ? Colors.green : Colors.blue,
          );
        },
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final String title;
  final String status;
  final String date;
  final IconData icon;
  final Color color;

  const TripCard({
    super.key,
    required this.title,
    required this.status,
    required this.date,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
