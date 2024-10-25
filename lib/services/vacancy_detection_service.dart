import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/models/vacancy_report.dart';

class VacancyDetectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Property>> getVacantProperties() {
    return _firestore
        .collection('properties')
        .where('isVacant', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Property.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> reportVacancy(VacancyReport report) async {
    await _firestore.collection('vacancy_reports').add(report.toMap());
    await _firestore
        .collection('properties')
        .doc(report.propertyId)
        .update({'isVacant': true});
  }

  Future<void> markAsOccupied(String propertyId) async {
    await _firestore
        .collection('properties')
        .doc(propertyId)
        .update({'isVacant': false});
  }

  Stream<List<VacancyReport>> getVacancyReports() {
    return _firestore
        .collection('vacancy_reports')
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => VacancyReport.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> scheduleInspection(
      String reportId, DateTime inspectionDate) async {
    await _firestore.collection('vacancy_reports').doc(reportId).update({
      'inspectionScheduled': true,
      'inspectionDate': Timestamp.fromDate(inspectionDate),
    });
  }

  Future<void> updateInspectionResult(
      String reportId, bool vacancyConfirmed) async {
    await _firestore.collection('vacancy_reports').doc(reportId).update({
      'inspectionComplete': true,
      'vacancyConfirmed': vacancyConfirmed,
    });
  }
}