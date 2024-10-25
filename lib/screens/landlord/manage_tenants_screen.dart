import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rental_tax_port/models/tenant.dart';
import 'package:rental_tax_port/services/database_service.dart';
import 'package:rental_tax_port/services/kra_verification_service.dart';
import 'package:rental_tax_port/services/tax_calculation_service.dart';

class ManageTenantsScreen extends StatelessWidget {
  const ManageTenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context);
    final kraVerificationService = Provider.of<KRAVerificationService>(context);
    final taxCalculationService = Provider.of<TaxCalculationService>(context);
    const String landlordId = 'current_landlord_id'; // Replace with actual landlord ID

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tenants')),
      body: FutureBuilder<List<Tenant>>(
        future: databaseService.getTenants(landlordId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final tenants = snapshot.data ?? [];
          return ListView.builder(
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return ListTile(
                title: Text(tenant.name!),
                subtitle: Text(tenant.email!),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTenant(context, tenant, kraVerificationService, taxCalculationService),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addTenant(context, kraVerificationService, taxCalculationService),
      ),
    );
  }

  void _editTenant(BuildContext context, Tenant tenant, KRAVerificationService kraService, TaxCalculationService taxService) async {
    // Implement edit tenant logic
    // Use kraService to verify KRA PIN if changed
    // Use taxService to recalculate tax if rent changed
  }

  void _addTenant(BuildContext context, KRAVerificationService kraService, TaxCalculationService taxService) async {
    // Implement add tenant logic
    // Use kraService to verify KRA PIN
    // Use taxService to calculate initial tax
  }
}