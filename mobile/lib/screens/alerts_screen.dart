import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Safety & Geo-Alerts'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Resolved'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertList('all'),
          _buildAlertList('active'),
          _buildAlertList('resolved'),
          _buildAlertList('expired'),
        ],
      ),
    );
  }

  Widget _buildAlertList(String filter) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (filter == 'all' || filter == 'active')
          const AlertCard(
            title: 'Geo-Fencing Alert: Meghalaya',
            description: 'You have entered a sensitive border zone near Dawki. Please keep your Digital ID ready for verification.',
            time: '5 mins ago',
            isCritical: true,
            status: 'Active',
          ),
        if (filter == 'all' || filter == 'active')
          const AlertCard(
            title: 'Indian Meteorological Dept',
            description: 'Heavy rain alert in North-East regions. Stay updated on road blockages in Tawang sector.',
            time: '2 hours ago',
            isCritical: false,
            status: 'Active',
          ),
        if (filter == 'all' || filter == 'resolved')
          const AlertCard(
            title: 'Police Assistance',
            description: 'Requested medical help at Shillong market has been provided. Case closed.',
            time: 'Yesterday',
            isCritical: false,
            status: 'Resolved',
          ),
        if (filter == 'all' || filter == 'expired')
          const AlertCard(
            title: 'Check-point Reminder',
            description: 'Please report at Guwahati entry gate within 2 hours.',
            time: '3 days ago',
            isCritical: false,
            status: 'Expired',
          ),
      ],
    );
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final bool isCritical;
  final String status;

  const AlertCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.isCritical,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Active' ? Colors.red : (status == 'Resolved' ? Colors.green : Colors.grey);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          isCritical ? Icons.gpp_maybe : Icons.info_outline,
          color: isCritical ? Colors.orange : Colors.indigo,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
