import '../models/billing_summary_model.dart';

class BillingCalculator {
  static BillingSummaryModel calculate({
    required double planPrice,
    required int durationMultiplier,
    double discount = 0,
  }) {
    final subtotal =
        planPrice * durationMultiplier;

    final tax =
        subtotal * 0.18;

    final total =
        subtotal + tax - discount;

    return BillingSummaryModel(
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
    );
  }
}