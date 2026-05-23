import 'package:equatable/equatable.dart';
import 'package:oxdo/feature/settings/general_settings/model/general_settings_model.dart';

abstract class GeneralSettingsState extends Equatable {
  const GeneralSettingsState();

  @override
  List<Object?> get props => [];
}

class GeneralSettingsInitial extends GeneralSettingsState {
  const GeneralSettingsInitial();
}

class GeneralSettingsLoading extends GeneralSettingsState {
  const GeneralSettingsLoading();
}

class GeneralSettingsLoaded extends GeneralSettingsState {
  final GeneralSettingsModel settings;
  final DateTime _ts; // ← forces inequality on every emit

  GeneralSettingsLoaded(this.settings) : _ts = DateTime.now();

  @override
  List<Object?> get props => [settings, _ts]; // ← _ts always differs
}

class GeneralSettingsUpdating extends GeneralSettingsState {
  final GeneralSettingsModel settings;
  final DateTime _ts;

  GeneralSettingsUpdating(this.settings) : _ts = DateTime.now();

  @override
  List<Object?> get props => [settings, _ts];
}

// class GeneralSettingsUpdating extends GeneralSettingsState {
//   final GeneralSettingsModel settings;
//   const GeneralSettingsUpdating(this.settings);

//   @override
//   List<Object?> get props => [settings];
// }

class GeneralSettingsError extends GeneralSettingsState {
  final String message;
  const GeneralSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}