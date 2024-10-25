import 'package:flutter/material.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/screens/landlord/add_property_screen.dart';
import 'package:rental_tax_port/screens/landlord/manage_tenants_screen.dart';
import 'package:rental_tax_port/screens/landlord/vacancy_report_screen.dart';
import 'package:rental_tax_port/services/database_service.dart';
import 'package:rental_tax_port/widgets/property_card.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  LandlordDashboardState createState() => LandlordDashboardState();
}

class LandlordDashboardState extends State<LandlordDashboard> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Landlord Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Properties'),
              Tab(icon: Icon(Icons.people), text: 'Tenants'),
              Tab(icon: Icon(Icons.report), text: 'Vacancies'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPropertiesTab(),
            _buildTenantsTab(),
            _buildVacanciesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
            );
          },
          tooltip: 'Add Property',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    return StreamBuilder<List<Property>>(
      stream: _databaseService.getProperties('currentLandlordId'), // Replace with actual landlord ID
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

  Widget _buildTenantsTab() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageTenantsScreen()),
          );
        },
        child: const Text('Manage Tenants'),
      ),
    );
  }

  Widget _buildVacanciesTab() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VacancyReportScreen()),
          );
        },
        child: const Text('View Vacancy Reports'),
      ),
    );
  }
}