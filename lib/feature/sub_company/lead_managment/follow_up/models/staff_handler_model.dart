class LeadStaffHandler {
  final String staffId;
  final String staffName;
  final String phone; // from STAFF collection lookup
  final int activityCount; // number of FOLLOWUPs they created
  final bool isCurrentAssignee;

  const LeadStaffHandler({
    required this.staffId,
    required this.staffName,
    required this.phone,
    required this.activityCount,
    required this.isCurrentAssignee,
  });
}
