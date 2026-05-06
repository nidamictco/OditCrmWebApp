
class VoxbaySettingsModel {
  final String id;
  final String providerName;
  final String type;
  final String customer;
  final String callerId;
  final String uid;
  final String pin;
  final String extNo;
  final String url;
  final String accessibleUser;

  const VoxbaySettingsModel({
    required this.id,
    required this.providerName,
    required this.type,
    required this.customer,
    required this.callerId,
    required this.uid,
    required this.pin,
    required this.extNo,
    required this.url,
    required this.accessibleUser,
  });

  factory VoxbaySettingsModel.fromMap(Map<String, dynamic> map) {
    return VoxbaySettingsModel(
      id: map['id'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      type: map['type'] as String? ?? '',
      customer: map['customer'] as String? ?? '',
      callerId: map['callerId'] as String? ?? '',
      uid: map['uid'] as String? ?? '',
      pin: map['pin'] as String? ?? '',
      extNo: map['extNo'] as String? ?? '',
      url: map['url'] as String? ?? '',
      accessibleUser: map['accessibleUser'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'providerName': providerName,
        'type': type,
        'customer': customer,
        'callerId': callerId,
        'uid': uid,
        'pin': pin,
        'extNo': extNo,
        'url': url,
        'accessibleUser': accessibleUser,
      };

  VoxbaySettingsModel copyWith({
    String? id,
    String? providerName,
    String? type,
    String? customer,
    String? callerId,
    String? uid,
    String? pin,
    String? extNo,
    String? url,
    String? accessibleUser,
  }) {
    return VoxbaySettingsModel(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      type: type ?? this.type,
      customer: customer ?? this.customer,
      callerId: callerId ?? this.callerId,
      uid: uid ?? this.uid,
      pin: pin ?? this.pin,
      extNo: extNo ?? this.extNo,
      url: url ?? this.url,
      accessibleUser: accessibleUser ?? this.accessibleUser,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoxbaySettingsModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}