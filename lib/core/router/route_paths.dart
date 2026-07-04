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

  // Helper methods to generate parameterized paths
  static String leadEditPath(String leadId) =>
      '/leads/edit/${Uri.encodeComponent(leadId)}';
  static String staffEditPath(String staffId) =>
      '/staff/edit/${Uri.encodeComponent(staffId)}';
  static String designationPermissionsPath(String designationId) =>
      '/designations/${Uri.encodeComponent(designationId)}/permissions';
  static String staffProfilePath(String staffId) =>
      '/staff/${Uri.encodeComponent(staffId)}';
  static String followUpPath(String leadId) =>
      '/follow_up/${Uri.encodeComponent(leadId)}';
  static String changePasswordPath(String staffId) =>
      '/staff/${Uri.encodeComponent(staffId)}/change_password';
}
