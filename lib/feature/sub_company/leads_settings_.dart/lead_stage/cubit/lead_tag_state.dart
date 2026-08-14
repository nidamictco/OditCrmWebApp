import 'package:equatable/equatable.dart';
import 'package:Odit_CRM/feature/sub_company/leads_settings_.dart/common_model/lead_model.dart';

enum LeadTagStatus { initial, loading, success, failure }

class LeadTagState extends Equatable {
  final LeadTagStatus status;
  final List<LeadsModel> leadTags;
  final String? errorMessage;

  /// Whether a write operation (add / update / delete) is in progress
  final bool isSubmitting;

  /// ID of the category currently being deleted (for per-row loader)
  final String? deletingId;

  const LeadTagState({
    this.status = LeadTagStatus.initial,
    this.leadTags = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.deletingId,
  });

  bool get isLoading => status == LeadTagStatus.loading;
  bool get isSuccess => status == LeadTagStatus.success;
  bool get isFailure => status == LeadTagStatus.failure;

  LeadTagState copyWith({
    LeadTagStatus? status,
    List<LeadsModel>? leadTags,
    String? errorMessage,
    bool? isSubmitting,
    String? deletingId,
    bool clearError = false,
    bool clearDeletingId = false,
  }) {
    return LeadTagState(
      status: status ?? this.status,
      leadTags: leadTags ?? this.leadTags,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingId: clearDeletingId ? null : (deletingId ?? this.deletingId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        leadTags,
        errorMessage,
        isSubmitting,
        deletingId,
      ];
}
