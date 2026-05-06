// ─────────────────────────────────────────────────────────────────────────────
// cubit/call_settings_state.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// No equatable — uses manual == / hashCode via Object.hash.

part of 'call_settings_cubit.dart';

enum CallSettingsStatus { initial, loading, success, failure }

class CallSettingsState {
  const CallSettingsState({
    this.status = CallSettingsStatus.initial,
    this.bonvoiceList = const [],
    this.voxbayList = const [],
    this.isBonvoiceSubmitting = false,
    this.isVoxbaySubmitting = false,
    this.errorMessage,
  });

  final CallSettingsStatus status;
  final List<BonvoiceSettingsModel> bonvoiceList;
  final List<VoxbaySettingsModel> voxbayList;
  final bool isBonvoiceSubmitting;
  final bool isVoxbaySubmitting;
  final String? errorMessage;

  bool get isLoading => status == CallSettingsStatus.loading;

  CallSettingsState copyWith({
    CallSettingsStatus? status,
    List<BonvoiceSettingsModel>? bonvoiceList,
    List<VoxbaySettingsModel>? voxbayList,
    bool? isBonvoiceSubmitting,
    bool? isVoxbaySubmitting,
    String? errorMessage,
  }) {
    return CallSettingsState(
      status: status ?? this.status,
      bonvoiceList: bonvoiceList ?? this.bonvoiceList,
      voxbayList: voxbayList ?? this.voxbayList,
      isBonvoiceSubmitting: isBonvoiceSubmitting ?? this.isBonvoiceSubmitting,
      isVoxbaySubmitting: isVoxbaySubmitting ?? this.isVoxbaySubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CallSettingsState) return false;
    return status == other.status &&
        _listEquals(bonvoiceList, other.bonvoiceList) &&
        _listEquals(voxbayList, other.voxbayList) &&
        isBonvoiceSubmitting == other.isBonvoiceSubmitting &&
        isVoxbaySubmitting == other.isVoxbaySubmitting &&
        errorMessage == other.errorMessage;
  }

  @override
  int get hashCode => Object.hash(
        status,
        Object.hashAll(bonvoiceList),
        Object.hashAll(voxbayList),
        isBonvoiceSubmitting,
        isVoxbaySubmitting,
        errorMessage,
      );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}