import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/subscription_feature.dart';
import 'addon_card.dart';
import 'billing_toggle.dart';
import 'pricing_summary_card.dart';
import 'section_card.dart';
import 'subscription_card.dart';

enum SubscriptionPlan { basic, professional, enterprise }

class SubscriptionStep extends StatelessWidget {
  final bool yearlyBilling;

  final SubscriptionPlan selectedPlan;

  final bool analyticsAddon;
  final bool supportAddon;
  final bool storageAddon;

  final ValueChanged<bool> onBillingChanged;

  final ValueChanged<SubscriptionPlan> onPlanSelected;

  final VoidCallback onAnalyticsToggle;
  final VoidCallback onSupportToggle;
  final VoidCallback onStorageToggle;

  final VoidCallback onBack;
  final VoidCallback onNext;

  const SubscriptionStep({
    super.key,
    required this.yearlyBilling,
    required this.selectedPlan,
    required this.analyticsAddon,
    required this.supportAddon,
    required this.storageAddon,
    required this.onBillingChanged,
    required this.onPlanSelected,
    required this.onAnalyticsToggle,
    required this.onSupportToggle,
    required this.onStorageToggle,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final planPrice = _planPrice;
    final addonPrice = _addonPrice;
    final double discount = yearlyBilling ? planPrice * .15 : 0;
    final total = planPrice + addonPrice - discount;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Subscription Plan",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Choose the ideal plan for your organization and add optional enhancements.",
            style: GoogleFonts.poppins(color: const Color(0xff64748B)),
          ),

          const SizedBox(height: 32),

          Center(
            child: BillingToggle(
              yearly: yearlyBilling,
              onChanged: onBillingChanged,
            ),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  SubscriptionCard(
                    category: "Starter",
                    title: "Basic",
                    price: yearlyBilling ? 79 : 99,
                    selected: selectedPlan == SubscriptionPlan.basic,
                    onTap: () {
                      onPlanSelected(SubscriptionPlan.basic);
                    },
                    features: const [
                      SubscriptionFeature(
                        title: "Up to 5 Staff Members",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Lead Management System",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "10GB Cloud Storage",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Email Support",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Advanced Analytics",
                        available: false,
                      ),
                    ],
                  ),

                  const SizedBox(width: 24),

                  SubscriptionCard(
                    category: "Growth",
                    title: "Professional",
                    price: yearlyBilling ? 109 : 129,
                    selected: selectedPlan == SubscriptionPlan.professional,
                    mostPopular: true,
                    onTap: () {
                      onPlanSelected(SubscriptionPlan.professional);
                    },
                    features: const [
                      SubscriptionFeature(
                        title: "Up to 25 Staff Members",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Advanced CRM & Automation",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "50GB Cloud Storage",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Custom Reports",
                        available: true,
                      ),
                      SubscriptionFeature(title: "API Access", available: true),
                    ],
                  ),

                  const SizedBox(width: 24),

                  SubscriptionCard(
                    category: "Scale",
                    title: "Enterprise",
                    price: yearlyBilling ? 249 : 299,
                    selected: selectedPlan == SubscriptionPlan.enterprise,
                    onTap: () {
                      onPlanSelected(SubscriptionPlan.enterprise);
                    },
                    features: const [
                      SubscriptionFeature(
                        title: "Unlimited Staff Members",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Advanced Automation Suite",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Unlimited Storage",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "Dedicated Success Manager",
                        available: true,
                      ),
                      SubscriptionFeature(
                        title: "White Label Support",
                        available: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Text(
            "Enhance Your Experience",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              AddonCard(
                title: "Advanced Analytics",
                description:
                    "Deep business intelligence and forecasting tools.",
                price: 49,
                selected: analyticsAddon,
                onTap: onAnalyticsToggle,
              ),

              AddonCard(
                title: "Priority Support",
                description: "Dedicated support with faster response times.",
                price: 29,
                selected: supportAddon,
                onTap: onSupportToggle,
              ),

              AddonCard(
                title: "Extra Storage",
                description:
                    "Additional cloud storage for documents and files.",
                price: 19,
                selected: storageAddon,
                onTap: onStorageToggle,
              ),
            ],
          ),

          const SizedBox(height: 50),

          Align(
            alignment: Alignment.centerRight,
            child: PricingSummaryCard(
              planPrice: planPrice,
              addonPrice: addonPrice,
              discount: discount,
              total: total,
            ),
          ),

          const SizedBox(height: 32),

          const Divider(),

          const SizedBox(height: 24),

          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: Text("Back", style: GoogleFonts.poppins()),
              ),

              const Spacer(),

              SizedBox(
                width: 180,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onNext,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    "Next Step",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double get _planPrice {
    switch (selectedPlan) {
      case SubscriptionPlan.basic:
        return yearlyBilling ? 79 : 99;

      case SubscriptionPlan.professional:
        return yearlyBilling ? 109 : 129;

      case SubscriptionPlan.enterprise:
        return yearlyBilling ? 249 : 299;
    }
  }

  double get _addonPrice {
    double value = 0;

    if (analyticsAddon) value += 49;
    if (supportAddon) value += 29;
    if (storageAddon) value += 19;

    return value;
  }
}
