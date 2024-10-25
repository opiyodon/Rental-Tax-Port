import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental_tax_port/models/landlord.dart';
import 'package:rental_tax_port/models/payment.dart';
import 'package:rental_tax_port/models/property.dart';
import 'package:rental_tax_port/models/vacancy_report.dart';
import 'package:rental_tax_port/services/tax_calculation_service.dart';

class KRAReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TaxCalculationService _taxCalculationService = TaxCalculationService();

  Future<Map<String, dynamic>> generateMonthlyTaxReport(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final landlords = await _fetchLandlords();
    final properties = await _fetchProperties();
    final payments = await _fetchPayments(startDate, endDate);

    double totalTaxCollected = 0.0;
    List<Map<String, dynamic>> landlordReports = [];

    for (var landlord in landlords) {
      final landlordProperties = properties.where((p) => p.landlordId == landlord.id).toList();
      final landlordPayments = payments.where((p) => p?.landlordId == landlord.id).toList();

      double taxDue = _taxCalculationService.calculateTax(landlord, landlordProperties);
      double taxCollected = landlordPayments.fold(0.0, (summ, payment) => summ + (payment?.taxAmount ?? 0.0));

      totalTaxCollected += taxCollected;

      landlordReports.add({
        'landlordId': landlord.id,
        'name': landlord.name,
        'isResident': landlord.isResident,
        'propertiesCount': landlordProperties.length,
        'taxDue': taxDue,
        'taxCollected': taxCollected,
      });
    }

    return {
      'year': year,
      'month': month,
      'totalTaxCollected': totalTaxCollected,
      'landlordReports': landlordReports,
    };
  }

  Future<Map<String, dynamic>> generateAnnualTaxReport(int year) async {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year + 1, 1, 1);

    final landlords = await _fetchLandlords();
    final properties = await _fetchProperties();
    final payments = await _fetchPayments(startDate, endDate);

    double totalTaxCollected = 0.0;
    List<Map<String, dynamic>> landlordReports = [];

    for (var landlord in landlords) {
      final landlordProperties = properties.where((p) => p.landlordId == landlord.id).toList();
      final landlordPayments = payments.where((p) => p?.landlordId == landlord.id).toList();

      double taxDue = _taxCalculationService.calculateTax(landlord, landlordProperties);
      double taxCollected = landlordPayments.fold(0.0, (summ, payment) => summ + (payment?.taxAmount ?? 0.0));

      totalTaxCollected += taxCollected;

      landlordReports.add({
        'landlordId': landlord.id,
        'name': landlord.name,
        'isResident': landlord.isResident,
        'propertiesCount': landlordProperties.length,
        'taxDue': taxDue,
        'taxCollected': taxCollected,
      });
    }

    return {
      'year': year,
      'totalTaxCollected': totalTaxCollected,
      'landlordReports': landlordReports,
    };
  }

  Future<Map<String, dynamic>> generateVacancyReport(DateTime startDate, DateTime endDate) async {
    final vacancyReports = await _fetchVacancyReports(startDate, endDate);
    final properties = await _fetchProperties();

    int totalVacancies = vacancyReports.length;
    int confirmedVacancies = vacancyReports.where((r) => r.vacancyConfirmed == true).length;
    double vacancyRate = properties.isEmpty ? 0 : totalVacancies / properties.length;

    return {
      'startDate': startDate,
      'endDate': endDate,
      'totalProperties': properties.length,
      'totalVacancies': totalVacancies,
      'confirmedVacancies': confirmedVacancies,
      'vacancyRate': vacancyRate,
      'vacancyReports': vacancyReports.map((r) => r.toMap()).toList(),
    };
  }

  Future<List> _fetchLandlords() async {
    final snapshot = await _firestore.collection('landlords').get();
    return snapshot.docs.map((doc) => Landlord.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<Property>> _fetchProperties() async {
    final snapshot = await _firestore.collection('properties').get();
    return snapshot.docs.map((doc) => Property.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List> _fetchPayments(DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore.collection('payments')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .get();
    return snapshot.docs.map((doc) => Payment.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<VacancyReport>> _fetchVacancyReports(DateTime startDate, DateTime endDate) async {
    final snapshot = await _firestore.collection('vacancy_reports')
        .where('reportDate', isGreaterThanOrEqualTo: startDate)
        .where('reportDate', isLessThan: endDate)
        .get();
    return snapshot.docs.map((doc) => VacancyReport.fromMap(doc.data(), doc.id)).toList();
  }
}