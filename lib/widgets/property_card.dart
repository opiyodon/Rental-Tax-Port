import 'package:flutter/material.dart';
import 'package:rental_tax_port/models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(property.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(property.address),
            Text('Type: ${property.type.toString().split('.').last}'),
            Text('Units: ${property.numberOfUnits}'),
            Text(
                'Monthly Rent: KES ${property.monthlyRent.toStringAsFixed(2)}'),
          ],
        ),
        trailing: property.isVacant
            ? const Chip(
          label: Text('Vacant'),
          backgroundColor: Colors.red,
        )
            : const Chip(
          label: Text('Occupied'),
          backgroundColor: Colors.green,
        ),
        onTap: () {
          // TODO: Navigate to property detail screen
        },
      ),
    );
  }
}