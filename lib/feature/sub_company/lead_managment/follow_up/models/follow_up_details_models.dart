class FollowupEntry {
  final String date;
  final String time;
  final String agent;
  final String calledDate;
  final String callStatus;
  final String tags;
  final String remark;
  final String status;
  final String products;

  const FollowupEntry({
    required this.date,
    required this.time,
    required this.agent,
    required this.calledDate,
    required this.callStatus,
    required this.tags,
    required this.remark,
    required this.status,
    required this.products,
  });
}

class ActivityEntry {
  final String agent;
  final String description;
  final String dateTime;

  const ActivityEntry({
    required this.agent,
    required this.description,
    required this.dateTime,
  });
}