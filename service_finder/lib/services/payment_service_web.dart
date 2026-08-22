// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:http/http.dart' as http;

class PaymentService {
  static const String razorpayKey = 'rzp_live_SyEgfbybUpeZaz';
  static const String razorpaySecret = 'I52KxvhmJK2wsCZDXe0jTgU8';

  PaymentService();

  Future<String?> _createOrderId(double amount) async {
    final amountInPaise = (amount * 100).toInt();
    
    // 1. Try Vercel Serverless API first
    try {
      final vercelRes = await http.post(
        Uri.parse('/api/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      ).timeout(const Duration(seconds: 5));
      
      if (vercelRes.statusCode == 200) {
        final data = jsonDecode(vercelRes.body);
        if (data['id'] != null) {
          return data['id'] as String;
        }
      }
    } catch (_) {}

    // 2. Fallback to direct Razorpay API (or CORS proxy if needed)
    try {
      final auth = base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'));
      final res = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amountInPaise,
          'currency': 'INR',
          'receipt': 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data['id'] as String?;
      }
    } catch (_) {}

    return null;
  }

  void openCheckout({
    required double amount,
    String? phone,
    String? email,
    required String description,
    required Function(Map<dynamic, dynamic> response) onSuccess,
    required Function(String error) onError,
  }) async {
    final amountInPaise = (amount * 100).toInt();
    if (amountInPaise < 100) {
      onError('Amount must be at least ₹1');
      return;
    }

    try {
      if (!js.context.hasProperty('Razorpay')) {
        onError('Razorpay SDK is loading. Please try again in a few seconds or refresh.');
        return;
      }

      // Create Razorpay Order ID for mandatory UPI activation
      final orderId = await _createOrderId(amount);

      final Map<String, dynamic> optionsMap = {
        'key': razorpayKey,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'SATVIKSETU',
        'description': description,
        'handler': (dynamic response) {
          final paymentId = response != null ? response['razorpay_payment_id']?.toString() ?? '' : '';
          final resOrderId = response != null ? response['razorpay_order_id']?.toString() ?? (orderId ?? '') : '';
          final signature = response != null ? response['razorpay_signature']?.toString() ?? '' : '';
          onSuccess({
            'paymentId': paymentId,
            'orderId': resOrderId,
            'signature': signature,
          });
        },
        'modal': {
          'ondismiss': () {
            onError('Payment was cancelled');
          },
        },
        'theme': {
          'color': '#1E88E5',
        },
        'prefill': {
          if (phone != null && phone.isNotEmpty) 'contact': phone,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      };

      if (orderId != null && orderId.isNotEmpty) {
        optionsMap['order_id'] = orderId;
      }

      final options = js.JsObject.jsify(optionsMap);
      final razorpayConstructor = js.context['Razorpay'];
      final rzpInstance = js.JsObject(razorpayConstructor, [options]);
      rzpInstance.callMethod('open');
    } catch (e) {
      onError('Failed to open payment gateway: $e');
    }
  }

  void dispose() {}
}
