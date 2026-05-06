class BonvoiceSettingsModel {
  final String id;
  final String providerName;
  final bool isUsingZipCall;
  final String callerId;
  final String channelId;
  final String token;
  final String url;
  final String accessibleUser;
  final String leadCategory;

  const BonvoiceSettingsModel({
    required this.id,
    required this.providerName,
    required this.isUsingZipCall,
    required this.callerId,
    required this.channelId,
    required this.token,
    required this.url,
    required this.accessibleUser,
    required this.leadCategory,
  });

  factory BonvoiceSettingsModel.fromMap(Map<String, dynamic> map) {
    return BonvoiceSettingsModel(
      id: map['id'] as String? ?? '',
      providerName: map['providerName'] as String? ?? '',
      isUsingZipCall: map['isUsingZipCall'] as bool? ?? false,
      callerId: map['callerId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      token: map['token'] as String? ?? '',
      url: map['url'] as String? ?? '',
      accessibleUser: map['accessibleUser'] as String? ?? '',
      leadCategory: map['leadCategory'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'providerName': providerName,
        'isUsingZipCall': isUsingZipCall,
        'callerId': callerId,
        'channelId': channelId,
        'token': token,
        'url': url,
        'accessibleUser': accessibleUser,
        'leadCategory': leadCategory,
      };

  BonvoiceSettingsModel copyWith({
    String? id,
    String? providerName,
    bool? isUsingZipCall,
    String? callerId,
    String? channelId,
    String? token,
    String? url,
    String? accessibleUser,
    String? leadCategory,
  }) {
    return BonvoiceSettingsModel(
      id: id ?? this.id,
      providerName: providerName ?? this.providerName,
      isUsingZipCall: isUsingZipCall ?? this.isUsingZipCall,
      callerId: callerId ?? this.callerId,
      channelId: channelId ?? this.channelId,
      token: token ?? this.token,
      url: url ?? this.url,
      accessibleUser: accessibleUser ?? this.accessibleUser,
      leadCategory: leadCategory ?? this.leadCategory,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BonvoiceSettingsModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
