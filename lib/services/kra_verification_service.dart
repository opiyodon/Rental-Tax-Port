import 'package:http/http.dart' as http;
import 'dart:convert';

class KRAVerificationService {
  static const String _baseUrl = 'https://api.kra.go.ke'; // Replace with actual KRA API endpoint
  static const String _apiKey = 'YOUR_KRA_API_KEY'; // Replace with your actual API key

  Future<bool> verifyKRAPin(String pin) async {
    try {
      final url = Uri.parse('$_baseUrl/verify_pin');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_valid'] as bool;
      } else {
        throw Exception('Failed to verify KRA PIN: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verifying KRA PIN: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLandlordDetails(String pin) async {
    try {
      final url = Uri.parse('$_baseUrl/landlord_details');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get landlord details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting landlord details: $e');
      rethrow;
    }
  }

  Future<bool> isNonResidentLandlord(String pin) async {
    try {
      final landlordDetails = await getLandlordDetails(pin);
      return landlordDetails['is_non_resident'] as bool;
    } catch (e) {
      print('Error checking landlord residency status: $e');
      rethrow;
    }
  }

  Future<void> updateLandlordDetails(String pin, Map<String, dynamic> updates) async {
    try {
      final url = Uri.parse('$_baseUrl/update_landlord');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'pin': pin,
          'updates': updates,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update landlord details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating landlord details: $e');
      rethrow;
    }
  }
}