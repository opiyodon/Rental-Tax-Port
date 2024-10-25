import 'package:flutter/material.dart';
import 'package:rental_tax_port/screens/admin/fraud_detection_screen.dart';
import 'package:rental_tax_port/screens/admin/tax_collection_report_screen.dart';
import 'package:rental_tax_port/screens/admin/vacancy_inspection_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.security), text: 'Fraud Detection'),
              Tab(icon: Icon(Icons.home_work), text: 'Vacancy Inspection'),
              Tab(icon: Icon(Icons.monetization_on), text: 'Tax Collection'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFraudDetectionTab(context),
            _buildVacancyInspectionTab(context),
            _buildTaxCollectionTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFraudDetectionTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FraudDetectionScreen()),
          );
        },
        child: const Text('Go to Fraud Detection'),
      ),
    );
  }

  Widget _buildVacancyInspectionTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VacancyInspectionScreen()),
          );
        },
        child: const Text('Go to Vacancy Inspection'),
      ),
    );
  }

  Widget _buildTaxCollectionTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaxCollectionReportScreen()),
          );
        },
        child: const Text('View Tax Collection Report'),
      ),
    );
  }
}