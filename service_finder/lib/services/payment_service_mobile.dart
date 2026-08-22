import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;
  static const String razorpayKey = 'rzp_live_SyEgfbybUpeZaz';
  static const String razorpaySecret = 'I52KxvhmJK2wsCZDXe0jTgU8';

  Function(Map<dynamic, dynamic> response)? _onSuccessCallback;
  Function(String error)? _onErrorCallback;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_onSuccessCallback != null) {
      _onSuccessCallback!({
        'paymentId': response.paymentId ?? '',
        'orderId': response.orderId ?? '',
        'signature': response.signature ?? '',
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_onErrorCallback != null) {
      final code = response.code ?? -1;
      final msg = response.message ?? 'Payment failed';
      _onErrorCallback!('Payment Failed (Code: $code): $msg');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<String?> _createOrderId(double amount) async {
    final amountInPaise = (amount * 100).toInt();
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
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data['id'] as String?;
      }
    } catch (e) {
      print('Razorpay Order API Error: $e');
    }
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
    _onSuccessCallback = onSuccess;
    _onErrorCallback = onError;

    final amountInPaise = (amount * 100).toInt();
    if (amountInPaise < 100) {
      onError('Amount must be at least ₹1');
      return;
    }

    final orderId = await _createOrderId(amount);

    var options = <String, dynamic>{
      'key': razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'SATVIKSETU',
      'description': description,
      'theme': {'color': '#1E88E5'},
    };

    if (orderId != null && orderId.isNotEmpty) {
      options['order_id'] = orderId;
    }

    final prefill = <String, String>{};
    if (phone != null && phone.isNotEmpty) prefill['contact'] = phone;
    if (email != null && email.isNotEmpty) prefill['email'] = email;
    if (prefill.isNotEmpty) options['prefill'] = prefill;

    try {
      _razorpay.open(options);
    } catch (e) {
      onError('Failed to open payment gateway: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
