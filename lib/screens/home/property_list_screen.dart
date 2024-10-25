import 'package:flutter/material.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/services/database_service.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatelessWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Property>>(
      stream: DatabaseService().getProperties('some_parameter'), // Add the required parameter here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No properties available.'));
        }

        List<Property> properties = snapshot.data!;

        return ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            Property property = properties[index];
            return ListTile(
              title: Text(property.name), // Handle possible null value
              onTap: () {
                if (property.id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailScreen(propertyId: property.id!),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}