import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;
  static const String razorpayKey = 'rzp_live_SyEgfbybUpeZa';

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

  void openCheckout({
    required double amount,
    String? phone,
    String? email,
    required String description,
    required Function(Map<dynamic, dynamic> response) onSuccess,
    required Function(String error) onError,
  }) {
    _onSuccessCallback = onSuccess;
    _onErrorCallback = onError;

    final amountInPaise = (amount * 100).toInt();
    if (amountInPaise < 100) {
      onError('Amount must be at least ₹1');
      return;
    }

    var options = {
      'key': razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'SATVIKSETU',
      'description': description,
      'theme': {'color': '#1E88E5'},
    };

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
