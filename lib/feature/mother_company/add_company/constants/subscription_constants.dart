import '../models/subscription_plan_model.dart';

class SubscriptionConstants {
  static const String basic = "Basic";
  static const String standard = "Standard";
  static const String enterprise = "Enterprise";

  static const String monthly = "Monthly";
  static const String quarterly = "Quarterly";
  static const String halfYearly = "Half Yearly";
  static const String yearly = "Yearly";

  static const List<String> companyCategories = [
    "Retail",
    "Wholesale",
    "Manufacturing",
    "Construction",
    "Healthcare",
    "Education",
    "IT Services",
    "Finance",
    "Logistics",
    "Real Estate",
    "Other",
  ];

  static const List<SubscriptionPlanModel> plans = [
    SubscriptionPlanModel(
      planName: basic,
      monthlyPrice: 999,
      features: [
        "CRM",
        "Lead Management",
        "Dashboard",
      ],
    ),
    SubscriptionPlanModel(
      planName: standard,
      monthlyPrice: 2499,
      features: [
        "CRM",
        "Lead Management",
        "Dashboard",
        "Sales Pipeline",
        "Reports",
        "Team Management",
      ],
    ),
    SubscriptionPlanModel(
      planName: enterprise,
      monthlyPrice: 5999,
      features: [
        "CRM",
        "Lead Management",
        "Dashboard",
        "Sales Pipeline",
        "Reports",
        "Team Management",
        "Custom Roles",
        "Advanced Analytics",
        "API Access",
        "Priority Support",
      ],
    ),
  ];

  static const Map<String, int> durationMultiplier = {
    monthly: 1,
    quarterly: 3,
    halfYearly: 6,
    yearly: 12,
  };
}