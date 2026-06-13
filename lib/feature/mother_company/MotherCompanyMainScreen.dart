import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/mother_company/shared/enum/mother_company_enum.dart';
import 'package:oxdo/feature/mother_company/shared/widgets/app_sidebar.dart';
import 'Dashboard/screens/dashboard_page.dart';
import 'add_company/cubit/add_company_cubit.dart';
import 'add_company/repository/add_company_repo.dart';
import 'add_company/screens/add_company_page.dart';
import 'add_company/services/firebase_add_company_service.dart';
import 'company_manage/screens/company_manage_page.dart';

class MotherCompanyMainScreen extends StatefulWidget {
  const MotherCompanyMainScreen({super.key});

  @override
  State<MotherCompanyMainScreen> createState() =>
      _MotherCompanyMainScreenState();
}

class _MotherCompanyMainScreenState
    extends State<MotherCompanyMainScreen> {
  MotherCompanyPage selectedPage =
      MotherCompanyPage.dashboard;

  Widget get currentPage {
    switch (selectedPage) {
      case MotherCompanyPage.dashboard:
        return DashboardPage(
          onViewAllTap: () {
            setState(() {
              selectedPage = MotherCompanyPage.companyManage;
            });
          },
        );

      case MotherCompanyPage.companyManage:
        return CompanyManagePage(
          onAddCompanyTap: () {
            setState(() {
              selectedPage = MotherCompanyPage.addCompany;
            });
          },
        );

      case MotherCompanyPage.addCompany:
        return const AddCompanyPage();


      // case MotherCompanyPage.systemSetting:
      //   return const Center(
      //     child: Text('System Settings'),
      //   );
      //
      // case MotherCompanyPage.activeLogs:
      //   return const Center(
      //     child: Text('Active Logs'),
      //   );
      //
      // case MotherCompanyPage.supportTickets:
      //   return const Center(
      //     child: Text('Support Tickets'),
      //   );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedPage: selectedPage,
            onPageChanged: (page) {
              setState(() {
                selectedPage = page;
              });
            },
          ),

          Expanded(
            child: currentPage,
          ),
        ],
      ),
    );
  }
}