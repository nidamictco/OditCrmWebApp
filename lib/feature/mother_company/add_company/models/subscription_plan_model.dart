enum SubscriptionPlan {
  basic,
  professional,
  enterprise,
}

class SubscriptionPlanModel {
  final String planName;

  final double monthlyPrice;

  final List<String> features;

  const SubscriptionPlanModel({
    required this.planName,
    required this.monthlyPrice,
    required this.features,
  });
}