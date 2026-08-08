// lib/core/router/route_paths.dart

class RoutePaths {
  // Unauthenticated
  static const login = '/login';
  static const forgotPassword = '/forgot_password';

  // Mother Company
  static const motherCompanyDashboard = '/mother_company/dashboard';
  static const motherCompanyCompanyManage = '/mother_company/company_manage';
  static const motherCompanyAddCompany = '/mother_company/add_company';

  // Sub Company CRM (Dashboard & New Leads)
  static const dashboard = '/dashboard';
  static const newLeads = '/leads';
  static const addLead = '/add_lead';
  static const editLead = '/leads/edit/:leadId';
  static const leadsReport = '/leads_report';
  static const callHistory = '/call_history';
  static const deletedLeads = '/deleted_leads';
  static const transferLeads = '/transfer_leads';
  static const phoneCallLog = '/phone_call_log';
  static const leadCategory = '/lead_category';
  static const customFields = '/custom_fields';
  static const leadSource = '/lead_source';
  static const leadStages = '/lead_stages';
  static const leadDistribution = '/lead_distribution';
  static const unassignedLeads = '/unassigned_leads';
  static const importLeads = '/import_leads';
  static const addStaff = '/add_staff';
  static const editStaff = '/staff/edit/:staffId';
  static const viewStaff = '/view_staff';
  static const designation = '/designation';
  static const deletedStaff = '/deleted_staff';
  static const fileManager = '/file_manager';
  static const generalSettings = '/general_settings';
  static const facebookSettings = '/facebook_settings';
  static const staffReports = '/staff_reports';
  static const transferReport = '/transfer_report';
  static const scheduledReport = '/scheduled_report';
  static const rejectedReport = '/rejected_report';
  static const outgoingCallHistory = '/outgoing_call_history';
  static const designationPermissions =
      '/designations/:designationId/permissions';
  static const cloudCallSettings = '/cloud_call_settings';
  static const staffProfile = '/staff/:staffId';
  static const timeline = '/timeline';
  static const followUp = '/follow_up/:leadId';
  static const changePassword = '/staff/:staffId/change_password';
  static const personalProfile = '/personal_profile';
  static const notifications = '/notifications';
  static const subCategory = '/sub_category';
  static const leadTag = '/lead_tag';

  // Central map from sidebar index to route path
  static const Map<int, String> sidebarPaths = {
    0: dashboard,
    1: addLead,
    2: leadsReport,
    3: callHistory,
    4: deletedLeads,
    5: transferLeads,
    6: phoneCallLog,
    7: leadCategory,
    8: customFields,
    9: leadSource,
    10: leadStages,
    11: leadDistribution,
    12: newLeads,
    13: unassignedLeads,
    14: importLeads,
    15: addStaff,
    16: viewStaff,
    17: designation,
    18: deletedStaff,
    19: fileManager,
    20: generalSettings,
    21: facebookSettings,
    22: staffReports,
    23: transferReport,
    24: scheduledReport,
    25: rejectedReport,
    26: outgoingCallHistory,
    30: timeline,
    33: personalProfile,
    34: notifications,
  };

  // Helper methods to generate parameterized paths
  static String leadEditPath(
  String leadId, {
  String? fromCard,
  String? fromScreen,
}) {
  final query = <String, String>{
    if (fromCard != null && fromCard.isNotEmpty) 'fromCard': fromCard,
    if (fromScreen != null && fromScreen.isNotEmpty) 'fromScreen': fromScreen,
  };
  return Uri(
    path: '/leads/edit/${Uri.encodeComponent(leadId)}',
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}
  static String staffEditPath(String staffId) =>
      '/staff/edit/${Uri.encodeComponent(staffId)}';
  static String designationPermissionsPath(String designationId) =>
      '/designations/${Uri.encodeComponent(designationId)}/permissions';
 static String staffProfilePath(String staffId, {String? fromScreen}) {
  final query = <String, String>{
    if (fromScreen != null && fromScreen.isNotEmpty) 'fromScreen': fromScreen,
  };
  return Uri(
    path: '/staff/${Uri.encodeComponent(staffId)}',
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}
  static String followUpPath(
  String leadId,
  String fromCard, {
  String? fromScreen,
}) {
  final query = <String, String>{
    'fromCard': fromCard,
    if (fromScreen != null && fromScreen.isNotEmpty) 'fromScreen': fromScreen,
  };
  return Uri(
    path: '/follow_up/${Uri.encodeComponent(leadId)}',
    queryParameters: query,
  ).toString();
}
  static String changePasswordPath(String staffId) =>
      '/staff/${Uri.encodeComponent(staffId)}/change_password';
  static String subCategoryPath(String categoryName, String categoryId) =>
      '/sub_category?categoryName=${Uri.encodeComponent(categoryName)}&categoryId=${Uri.encodeComponent(categoryId)}';
  static String leadTagPath(String leadStageName, String leadStageId, bool tagMandatory) =>
      '/lead_tag?leadStageName=${Uri.encodeComponent(leadStageName)}&leadStageId=${Uri.encodeComponent(leadStageId)}&tagMandatory=${Uri.encodeComponent(tagMandatory.toString())}';
      
}
