import 'package:flutter_riverpod/flutter_riverpod.dart';

// Conditional import: uses mobile version by default,
// switches to web version when running in a browser.
export 'payment_service_mobile.dart'
    if (dart.library.js) 'payment_service_web.dart';

import 'payment_service_mobile.dart'
    if (dart.library.js) 'payment_service_web.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());
