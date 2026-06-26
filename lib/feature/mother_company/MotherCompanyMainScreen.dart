import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shared/enum/mother_company_enum.dart';
import 'shared/widgets/app_sidebar.dart';
import 'Dashboard/screens/dashboard_page.dart';
import 'add_new_company/screens/add_new_company_page.dart';
import 'company_manage/screens/company_manage_page.dart';

class MotherCompanyMainScreen extends StatefulWidget {
  final MotherCompanyPage initialPage;
  const MotherCompanyMainScreen({
    super.key,
    this.initialPage = MotherCompanyPage.dashboard,
  });

  @override
  State<MotherCompanyMainScreen> createState() =>
      _MotherCompanyMainScreenState();
}

class _MotherCompanyMainScreenState extends State<MotherCompanyMainScreen> {
  late MotherCompanyPage selectedPage;
  bool showExitAlert = false;

  @override
  void initState() {
    super.initState();
    selectedPage = widget.initialPage;
  }

  void _navigateToPage(MotherCompanyPage page) {
    if (selectedPage == page) return;
    if (page == MotherCompanyPage.dashboard) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MotherCompanyMainScreen(initialPage: page),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MotherCompanyMainScreen(initialPage: page),
          ),
        );
      }
    }
  }

  Widget get currentPage {
    switch (selectedPage) {
      case MotherCompanyPage.dashboard:
        return DashboardPage(
          onViewAllTap: () {
            _navigateToPage(MotherCompanyPage.companyManage);
          },
        );

      case MotherCompanyPage.companyManage:
        return CompanyManagePage(
          onAddCompanyTap: () {
            _navigateToPage(MotherCompanyPage.addCompany);
          },
        );

      case MotherCompanyPage.addCompany:
        return AddNewCompanyPage(
          onBackTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        );
    }
  }

  Widget _buildExitDialogOverlay() {
    if (!showExitAlert) return const SizedBox.shrink();
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showExitAlert = false;
          });
        },
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside dialog from closing it
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Exit Application',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Are you sure you want to exit from the app?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => showExitAlert = false),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = Stack(
      children: [
        Scaffold(
          body: Row(
            children: [
              AppSidebar(
                selectedPage: selectedPage,
                onPageChanged: (page) {
                  _navigateToPage(page);
                },
              ),
              Expanded(child: currentPage),
            ],
          ),
        ),
        _buildExitDialogOverlay(),
      ],
    );

    if (kIsWeb) {
      return mainContent;
    }

    return PopScope(
      canPop: !showExitAlert && Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (showExitAlert) {
          setState(() {
            showExitAlert = false;
          });
        } else {
          setState(() {
            showExitAlert = true;
          });
        }
      },
      child: mainContent,
    );
  }
}
