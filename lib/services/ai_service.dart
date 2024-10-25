import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  static const String _baseUrl = 'YOUR_AI_SERVICE_ENDPOINT';

  Future<bool> detectFraud({
    required String landlordId,
    required String propertyId,
    required double declaredRent,
    required int declaredOccupancy,
  }) async {
    final url = Uri.parse('$_baseUrl/detect_fraud');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'landlord_id': landlordId,
        'property_id': propertyId,
        'declared_rent': declaredRent,
        'declared_occupancy': declaredOccupancy,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['fraud_detected'] as bool;
    }
    throw Exception('Failed to perform fraud detection');
  }

  Future<List<Map<String, dynamic>>> getAnomalies({
    required String landlordId,
    required String propertyId,
  }) async {
    final url = Uri.parse('$_baseUrl/get_anomalies');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'landlord_id': landlordId,
        'property_id': propertyId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['anomalies']);
    }
    throw Exception('Failed to get anomalies');
  }

  Future<double> predictOccupancyRate({
    required String propertyId,
    required List<double> historicalRates,
  }) async {
    final url = Uri.parse('$_baseUrl/predict_occupancy');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'property_id': propertyId,
        'historical_rates': historicalRates,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['predicted_occupancy'] as double;
    }
    throw Exception('Failed to predict occupancy rate');
  }
}