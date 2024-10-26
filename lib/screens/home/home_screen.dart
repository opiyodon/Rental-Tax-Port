import 'package:flutter/material.dart';
import 'package:rental_tax_port/screens/admin/admin_dashboard.dart';
import 'package:rental_tax_port/screens/agent/agent_dashboard.dart';
import 'package:rental_tax_port/screens/landlord/landlord_dashboard.dart';
import 'package:rental_tax_port/screens/tenant/tenant_dashboard.dart';
import 'package:rental_tax_port/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  String userType = '';

  @override
  void initState() {
    super.initState();
    _getUserType();
  }

  void _getUserType() async {
    // In a real app, you would get the user type from your auth service
    // This is a placeholder implementation
    String? type = await _auth.getUserType();
    setState(() {
      userType = type!;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget dashboard;
    switch (userType) {
      case 'Landlord':
        dashboard = const LandlordDashboard();
        break;
      case 'Tenant':
        dashboard = const TenantDashboard();
        break;
      case 'Agent':
        dashboard = const AgentDashboard();
        break;
      case 'Admin':
        dashboard = const AdminDashboard();
        break;
      default:
        dashboard = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Tax Pot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: dashboard,
    );
  }
}
