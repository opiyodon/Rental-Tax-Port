import 'package:cloud_firestore/cloud_firestore.dart';

enum PropertyType { commercial, residential, mixed }

class Property {
  final String? id;
  final String landlordId;
  final String name;
  final String address;
  final GeoPoint location;
  final PropertyType type;
  final int numberOfUnits;
  final double monthlyRent;
  final bool isVacant;

  Property({
    this.id,
    required this.landlordId,
    required this.name,
    required this.address,
    required this.location,
    required this.type,
    required this.numberOfUnits,
    required this.monthlyRent,
    this.isVacant = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'landlordId': landlordId,
      'name': name,
      'address': address,
      'location': location,
      'type': type.toString().split('.').last,
      'numberOfUnits': numberOfUnits,
      'monthlyRent': monthlyRent,
      'isVacant': isVacant,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map, String id) {
    return Property(
      id: id,
      landlordId: map['landlordId'],
      name: map['name'],
      address: map['address'],
      location: map['location'],
      type: PropertyType.values.firstWhere((e) => e.toString().split('.').last == map['type']),
      numberOfUnits: map['numberOfUnits'],
      monthlyRent: map['monthlyRent'],
      isVacant: map['isVacant'],
    );
  }
}