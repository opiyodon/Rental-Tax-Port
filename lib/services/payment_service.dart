import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static const String _consumerKey = 'YOUR_MPESA_CONSUMER_KEY';
  static const String _consumerSecret = 'YOUR_MPESA_CONSUMER_SECRET';
  static const String _baseUrl = 'https://sandbox.safaricom.co.ke';

  Future<String> _getAccessToken() async {
    final auth = base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));
    final response = await http.get(
      Uri.parse('$_baseUrl/oauth/v1/generate?grant_type=client_credentials'),
      headers: {'Authorization': 'Basic $auth'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    }
    throw Exception('Failed to get access token');
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String description,
  }) async {
    final accessToken = await _getAccessToken();
    final url = Uri.parse('$_baseUrl/mpesa/stkpush/v1/processrequest');

    final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
    const businessShortCode = 'YOUR_BUSINESS_SHORTCODE';
    const passKey = 'YOUR_PASS_KEY';
    final password = base64Encode(utf8.encode('$businessShortCode$passKey$timestamp'));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'BusinessShortCode': businessShortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toStringAsFixed(2),
        'PartyA': phoneNumber,
        'PartyB': businessShortCode,
        'PhoneNumber': phoneNumber,
        'CallBackURL': 'YOUR_CALLBACK_URL',
        'AccountReference': accountReference,
        'TransactionDesc': description,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to initiate payment');
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String checkoutRequestId) async {
    final accessToken = await _getAccessToken();
    final url = Uri.parse('$_baseUrl/mpesa/stkpushquery/v1/query');

    final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
    const businessShortCode = 'YOUR_BUSINESS_SHORTCODE';
    const passKey = 'YOUR_PASS_KEY';
    final password = base64Encode(utf8.encode('$businessShortCode$passKey$timestamp'));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'BusinessShortCode': businessShortCode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to check payment status');
  }
}