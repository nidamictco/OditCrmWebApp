class BillingSummaryModel {
  final double subtotal;

  final double tax;

  final double discount;

  final double total;

  const BillingSummaryModel({
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
  });
}