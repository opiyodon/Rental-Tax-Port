import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/models/property_type.dart';
import 'package:rental_tax_port/services/database_service.dart';
import 'package:rental_tax_port/services/geolocation_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  AddPropertyScreenState createState() => AddPropertyScreenState();
}

class AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final GeolocationService _geolocationService = GeolocationService();

  String name = '';
  String address = '';
  late PropertyType type =
      PropertyType.types.first; // Initialize with first type
  int numberOfUnits = 1;
  double monthlyRent = 0.0;
  GeoPoint? location;
  String selectedUnitType = ''; // Add this for unit type selection

  @override
  void initState() {
    super.initState();
    selectedUnitType = type.unitTypes.first; // Initialize with first unit type
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Property Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a property name';
                  }
                  return null;
                },
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) => address = value!,
              ),
              DropdownButtonFormField<PropertyType>(
                value: type,
                decoration: const InputDecoration(labelText: 'Property Type'),
                items: PropertyType.types.map((PropertyType value) {
                  return DropdownMenuItem<PropertyType>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
                onChanged: (PropertyType? newValue) {
                  setState(() {
                    if (newValue != null) {
                      type = newValue;
                      // Reset unit type when property type changes
                      selectedUnitType = newValue.unitTypes.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedUnitType,
                decoration: const InputDecoration(labelText: 'Unit Type'),
                items: type.unitTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedUnitType = newValue;
                    });
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Units'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of units';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => numberOfUnits = int.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Monthly Rent'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the monthly rent';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => monthlyRent = double.parse(value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Get Current Location'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Property'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    try {
      GeoPoint currentLocation =
          (await _geolocationService.getCurrentLocation()) as GeoPoint;
      setState(() {
        location = currentLocation;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location obtained successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please get the current location')),
        );
        return;
      }

      Property newProperty = Property(
        landlordId: 'currentLandlordId', // Replace with actual landlord ID
        name: name,
        address: address,
        location: location!,
        type: type,
        numberOfUnits: numberOfUnits,
        monthlyRent: monthlyRent,
      );

      try {
        await _databaseService.addProperty(newProperty);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add property')),
        );
      }
    }
  }
}
