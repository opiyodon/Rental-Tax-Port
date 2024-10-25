import 'package:flutter/material.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body: Center(
        child: Text('Details for property: $propertyId'),
      ),
    );
  }
}