import 'package:cloud_firestore/cloud_firestore.dart';

class TenantMovementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> approveTenantMovement(String tenantId, String newPropertyId) async {
    await _db.collection('tenant_movements').doc(tenantId).set({
      'tenantId': tenantId,
      'newPropertyId': newPropertyId,
      'approved': true,
    });
  }

  Future<List<Object?>> getTenantMovements() async {
    QuerySnapshot snapshot = await _db.collection('tenant_movements').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}