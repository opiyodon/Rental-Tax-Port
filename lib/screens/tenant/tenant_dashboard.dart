import 'package:flutter/material.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/screens/tenant/change_landlord_screen.dart';
import 'package:rental_tax_port/screens/tenant/search_properties_screen.dart';
import 'package:rental_tax_port/services/database_service.dart';
import 'package:rental_tax_port/widgets/property_card.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  TenantDashboardState createState() => TenantDashboardState();
}

class TenantDashboardState extends State<TenantDashboard> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tenant Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'My Property'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyPropertyTab(),
            _buildSearchTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangeLandlordScreen()),
            );
          },
          tooltip: 'Change Landlord',
          child: const Icon(Icons.swap_horiz),
        ),
      ),
    );
  }

  Widget _buildMyPropertyTab() {
    return FutureBuilder<Property?>(
      future: _databaseService.getTenantProperty(
          'currentTenantId'), // Replace with actual tenant ID
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No property found'));
        }

        return PropertyCard(property: snapshot.data!);
      },
    );
  }

  Widget _buildSearchTab() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SearchPropertiesScreen()),
          );
        },
        child: const Text('Search Properties'),
      ),
    );
  }
}