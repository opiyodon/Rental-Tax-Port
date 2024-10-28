import 'package:flutter/material.dart';
import 'package:rental_tax_port/screens/admin/fraud_detection_screen.dart';
import 'package:rental_tax_port/screens/admin/tax_collection_report_screen.dart';
import 'package:rental_tax_port/screens/admin/vacancy_inspection_screen.dart';
import 'package:rental_tax_port/services/auth_service.dart';
import 'package:rental_tax_port/theme.dart';
import 'package:rental_tax_port/widgets/custom_app_bar.dart';
import 'package:rental_tax_port/widgets/custom_sidebar.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: const CustomAppBar(
            title: 'Agent Dashboard',
            showMenu: true,
          ),
          endDrawer: CustomSidebar(
            authService: AuthService(),
          ),
          body: SingleChildScrollView(
            child: Container(
              color: AppColors.backgroundWhite,
              child: Column(
                children: [
                  _buildFraudDetectionTab(context),
                  _buildVacancyInspectionTab(context),
                  _buildTaxCollectionTab(context),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildFraudDetectionTab(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const FraudDetectionScreen()),
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
            MaterialPageRoute(
                builder: (context) => const VacancyInspectionScreen()),
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
            MaterialPageRoute(
                builder: (context) => const TaxCollectionReportScreen()),
          );
        },
        child: const Text('View Tax Collection Report'),
      ),
    );
  }
}
