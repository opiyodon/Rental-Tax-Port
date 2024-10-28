import 'package:flutter/material.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/screens/tenant/change_landlord_screen.dart';
import 'package:rental_tax_port/screens/tenant/search_properties_screen.dart';
import 'package:rental_tax_port/services/auth_service.dart';
import 'package:rental_tax_port/services/database_service.dart';
import 'package:rental_tax_port/widgets/custom_sidebar.dart';
import 'package:rental_tax_port/widgets/property_card.dart';
import 'package:rental_tax_port/widgets/custom_app_bar.dart';
import 'package:rental_tax_port/theme.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  TenantDashboardState createState() => TenantDashboardState();
}

class TenantDashboardState extends State<TenantDashboard> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tenant Dashboard',
        showMenu: true,
      ),
      endDrawer: CustomSidebar(
        authService: AuthService(),
      ),
      body: Container(
        color: AppColors.backgroundWhite,
        child: _buildMyPropertyContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChangeLandlordScreen(),
            ),
          );
        },
        backgroundColor: AppColors.secondaryOrange,
        tooltip: 'Change Landlord',
        elevation: 4,
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }

  Widget _buildMyPropertyContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FutureBuilder<Property?>(
        future: _databaseService.getTenantProperty(
            'currentTenantId'), // Replace with actual tenant ID
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {}); // Refresh the page
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.home_outlined,
                    size: 64,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No property found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search for properties to rent',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPropertiesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search Properties'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return PropertyCard(property: snapshot.data!);
        },
      ),
    );
  }
}
