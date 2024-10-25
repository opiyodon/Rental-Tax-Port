import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/models/tenant_movement.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProperty(Property property) async {
    await _firestore.collection('properties').add(property.toMap());
  }

  Future<void> updateProperty(String id, Property property) async {
    await _firestore.collection('properties').doc(id).update(property.toMap());
  }

  Future<void> deleteProperty(String id) async {
    await _firestore.collection('properties').doc(id).delete();
  }

  Stream<List<Property>> getProperties(String landlordId) {
    return _firestore
        .collection('properties')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Property.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> requestTenantMovement(TenantMovement movement) async {
    await _firestore.collection('tenant_movements').add(movement.toMap());
  }

  Future<void> approveTenantMovement(String movementId) async {
    await _firestore.collection('tenant_movements').doc(movementId).update({'status': 'approved'});
  }

  Stream<List<TenantMovement>> getTenantMovements(String landlordId) {
    return _firestore
        .collection('tenant_movements')
        .where('landlordId', isEqualTo: landlordId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TenantMovement.fromMap(doc.data(), doc.id)).toList());
  }

  getTenantProperty(String s) {}

  getTenants(String landlordId) {}

  getAgentProperties(String s) {}
}