import 'package:flutter/material.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/screens/agent/manage_properties_screen.dart';
import 'package:rental_tax_port/services/database_service.dart';
import 'package:rental_tax_port/widgets/property_card.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  AgentDashboardState createState() => AgentDashboardState();
}

class AgentDashboardState extends State<AgentDashboard> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agent Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Managed Properties'),
              Tab(icon: Icon(Icons.assignment), text: 'Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildManagedPropertiesTab(),
            _buildTasksTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ManagePropertiesScreen()),
            );
          },
          tooltip: 'Manage Properties',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildManagedPropertiesTab() {
    return StreamBuilder<List<Property>>(
      stream: _databaseService
          .getAgentProperties('currentAgentId'), // Replace with actual agent ID
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No properties found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Property property = snapshot.data![index];
            return PropertyCard(property: property);
          },
        );
      },
    );
  }

  Widget _buildTasksTab() {
    // TODO: Implement tasks list for agents
    return const Center(child: Text('Tasks coming soon'));
  }
}