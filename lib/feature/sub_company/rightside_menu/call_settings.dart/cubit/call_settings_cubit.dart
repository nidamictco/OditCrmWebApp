// ─────────────────────────────────────────────────────────────────────────────
// cubit/call_settings_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// Packages used: flutter_bloc only.
// ID generation: DateTime.now().microsecondsSinceEpoch.toString()
//                — collision-safe for sequential user taps.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/call_settings.dart/data/call_settings_repo.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/call_settings.dart/model/bonvoice_model.dart';
import 'package:oxdo/feature/sub_company/rightside_menu/call_settings.dart/model/voxbay_model.dart';

part 'call_settings_state.dart';

class CallSettingsCubit extends Cubit<CallSettingsState> {
  CallSettingsCubit({required CallSettingsRepository repository})
      : _repo = repository,
        super(const CallSettingsState());

  final CallSettingsRepository _repo;

  StreamSubscription<List<BonvoiceSettingsModel>>? _bonvoiceSub;
  StreamSubscription<List<VoxbaySettingsModel>>? _voxbaySub;

  /// Generates a simple unique id without any external package.
  static String _genId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void init() {
    emit(state.copyWith(status: CallSettingsStatus.loading));
    _subscribeBonvoice();
    _subscribeVoxbay();
  }

  void _subscribeBonvoice() {
    _bonvoiceSub?.cancel();
    _bonvoiceSub = _repo.bonvoiceStream().listen(
      (list) => emit(
        state.copyWith(
          status: CallSettingsStatus.success,
          bonvoiceList: list,
        ),
      ),
      onError: (Object e) => emit(
        state.copyWith(
          status: CallSettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      ),
    );
  }

  void _subscribeVoxbay() {
    _voxbaySub?.cancel();
    _voxbaySub = _repo.voxbayStream().listen(
      (list) => emit(
        state.copyWith(
          status: CallSettingsStatus.success,
          voxbayList: list,
        ),
      ),
      onError: (Object e) => emit(
        state.copyWith(
          status: CallSettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      ),
    );
  }

  // ── BONVOICE ──────────────────────────────────────────────────────────────

  Future<void> addBonvoice({
    required String providerName,
    required bool isUsingZipCall,
    required String callerId,
    required String channelId,
    required String token,
    required String url,
    required String accessibleUser,
    required String leadCategory,
  }) async {
    emit(state.copyWith(isBonvoiceSubmitting: true));
    try {
      await _repo.addBonvoice(
        BonvoiceSettingsModel(
          id: _genId(),
          providerName: providerName,
          isUsingZipCall: isUsingZipCall,
          callerId: callerId,
          channelId: channelId,
          token: token,
          url: url,
          accessibleUser: accessibleUser,
          leadCategory: leadCategory,
        ),
      );
      emit(state.copyWith(isBonvoiceSubmitting: false));
    } catch (e) {
      emit(state.copyWith(
        isBonvoiceSubmitting: false,
        status: CallSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateBonvoice(BonvoiceSettingsModel model) async {
    emit(state.copyWith(isBonvoiceSubmitting: true));
    try {
      await _repo.updateBonvoice(model);
      emit(state.copyWith(isBonvoiceSubmitting: false));
    } catch (e) {
      emit(state.copyWith(
        isBonvoiceSubmitting: false,
        status: CallSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteBonvoice(String id) async {
    try {
      await _repo.deleteBonvoice(id);
    } catch (e) {
      emit(state.copyWith(
        status: CallSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── VOXBAY ────────────────────────────────────────────────────────────────

  Future<void> addVoxbay({
    required String providerName,
    required String type,
    required String customer,
    required String callerId,
    required String uid,
    required String pin,
    required String extNo,
    required String url,
    required String accessibleUser,
  }) async {
    emit(state.copyWith(isVoxbaySubmitting: true));
    try {
      await _repo.addVoxbay(
        VoxbaySettingsModel(
          id: _genId(),
          providerName: providerName,
          type: type,
          customer: customer,
          callerId: callerId,
          uid: uid,
          pin: pin,
          extNo: extNo,
          url: url,
          accessibleUser: accessibleUser,
        ),
      );
      emit(state.copyWith(isVoxbaySubmitting: false));
    } catch (e) {
      emit(state.copyWith(
        isVoxbaySubmitting: false,
        status: CallSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateVoxbay(VoxbaySettingsModel model) async {
    emit(state.copyWith(isVoxbaySubmitting: true));
    try {
      await _repo.updateVoxbay(model);
      emit(state.copyWith(isVoxbaySubmitting: false));
    } catch (e) {
      emit(state.copyWith(
        isVoxbaySubmitting: false,
        status: CallSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteVoxbay(String id) async {
    try {
      await _repo.deleteVoxbay(id);
    } catch (e) {
      emit(state.copyWith(
        status: CallSettingsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _bonvoiceSub?.cancel();
    _voxbaySub?.cancel();
    return super.close();
  }
}