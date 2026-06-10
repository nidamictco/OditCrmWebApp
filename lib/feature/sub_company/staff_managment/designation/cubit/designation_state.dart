part of 'designation_cubit.dart';

abstract class DesignationState {}

/// Initial / idle state
class DesignationInitial extends DesignationState {}

/// Saving to Firestore in progress
class DesignationSaving extends DesignationState {}

/// Successfully saved — carries the new document ID
class DesignationSaved extends DesignationState {
  final String docId;
  DesignationSaved(this.docId);
}

/// Error during save
class DesignationError extends DesignationState {
  final String message;
  DesignationError(this.message);
}

/// Loading list of designations
class DesignationLoading extends DesignationState {}

/// List loaded successfully
class DesignationListLoaded extends DesignationState {
  final List<DesignationModel> designations;
  DesignationListLoaded(this.designations);
}