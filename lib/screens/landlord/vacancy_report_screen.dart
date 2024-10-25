import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rental_tax_port/models/vacancy_report.dart';
import 'package:rental_tax_port/services/vacancy_detection_service.dart';

class VacancyReportScreen extends StatelessWidget {
  const VacancyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vacancyService = Provider.of<VacancyDetectionService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vacancy Reports')),
      body: StreamBuilder<List<VacancyReport>>(
        stream: vacancyService.getVacancyReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reports = snapshot.data ?? [];
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text('Property ID: ${report.propertyId ?? 'Unknown'}'),
                subtitle: Text('Reported on: ${report.reportDate?.toString() ?? 'Unknown date'}'),
                trailing: _buildTrailingWidget(report),
                onTap: () => _showReportDetails(context, report, vacancyService),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _reportNewVacancy(context, vacancyService),
      ),
    );
  }

  Widget _buildTrailingWidget(VacancyReport report) {
    if (report.inspectionComplete == true) {
      return Icon(report.vacancyConfirmed == true ? Icons.check : Icons.close);
    } else {
      return const Text('Pending');
    }
  }

  void _showReportDetails(BuildContext context, VacancyReport report, VacancyDetectionService service) {
    // Show detailed report and options to schedule inspection or update results
  }

  void _reportNewVacancy(BuildContext context, VacancyDetectionService service) {
    // Show form to report a new vacancy
  }
}