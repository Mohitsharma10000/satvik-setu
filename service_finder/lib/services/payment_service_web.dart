// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class PaymentService {
  static const String razorpayKey = 'rzp_live_SyEgfbybUpeZa';

  PaymentService();

  void openCheckout({
    required double amount,
    String? phone,
    String? email,
    required String description,
    required Function(Map<dynamic, dynamic> response) onSuccess,
    required Function(String error) onError,
  }) {
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

      final options = js.JsObject.jsify({
        'key': razorpayKey,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'SATVIKSETU',
        'description': description,
        'handler': (dynamic response) {
          final paymentId = response != null ? response['razorpay_payment_id']?.toString() ?? '' : '';
          final orderId = response != null ? response['razorpay_order_id']?.toString() ?? '' : '';
          final signature = response != null ? response['razorpay_signature']?.toString() ?? '' : '';
          onSuccess({
            'paymentId': paymentId,
            'orderId': orderId,
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
      });

      final razorpayConstructor = js.context['Razorpay'];
      final rzpInstance = js.JsObject(razorpayConstructor, [options]);
      rzpInstance.callMethod('open');
    } catch (e) {
      onError('Failed to open payment gateway: $e');
    }
  }

  void dispose() {}
}
