import 'package:cloud_firestore/cloud_firestore.dart';

enum MovementStatus { pending, approved, rejected }

class TenantMovement {
  final String? id;
  final String tenantId;
  final String currentLandlordId;
  final String newLandlordId;
  final String currentPropertyId;
  final String newPropertyId;
  final DateTime requestDate;
  final MovementStatus status;

  TenantMovement({
    this.id,
    required this.tenantId,
    required this.currentLandlordId,
    required this.newLandlordId,
    required this.currentPropertyId,
    required this.newPropertyId,
    required this.requestDate,
    this.status = MovementStatus.pending,
  });

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'currentLandlordId': currentLandlordId,
      'newLandlordId': newLandlordId,
      'currentPropertyId': currentPropertyId,
      'newPropertyId': newPropertyId,
      'requestDate': Timestamp.fromDate(requestDate),
      'status': status.toString().split('.').last,
    };
  }

  factory TenantMovement.fromMap(Map<String, dynamic> map, String id) {
    return TenantMovement(
      id: id,
      tenantId: map['tenantId'],
      currentLandlordId: map['currentLandlordId'],
      newLandlordId: map['newLandlordId'],
      currentPropertyId: map['currentPropertyId'],
      newPropertyId: map['newPropertyId'],
      requestDate: (map['requestDate'] as Timestamp).toDate(),
      status: MovementStatus.values.firstWhere((e) => e.toString().split('.').last == map['status']),
    );
  }
}