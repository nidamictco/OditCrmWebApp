// import 'dart:typed_data';

// import '../../../rightside_menu/common_model/lead_model.dart';
// import '../../../staff_managment/staff/model/staff_model.dart';

// // ── Top-level status enums ────────────────────────────────────────────────────



// // ── State ─────────────────────────────────────────────────────────────────────

// class ImportLeadsState {
//   final ImportLeadsStatus status;

//   // ── Dropdown data ─────────────────────────────────────────────────────────
//   final List<LeadsModel> categories;
//   final List<LeadsModel> sources;
//   final List<StaffModel> staffList;
//   final List<LeadsModel> stages;

//   // ── Form selections ───────────────────────────────────────────────────────
//   final String? selectedCategory;
//   final String? selectedSource;
//   final String? selectedLeadStage;
//   final String? selectedPriority;
//   final String? selectedStaff;
//   final String? selectedState;
//   final String? selectedDistrict;
//   final String dialCode;
//   final String assignedStaffName;
//   final String? assignedStaffId;

//   // ── CSV / field-position ──────────────────────────────────────────────────
//   final Uint8List? csvBytes;
//   final Map<String, int> fieldPositions; // e.g. {'clientName': 0, 'phone': 1}

//   // ── Tab (0 = with country code, 1 = without) ─────────────────────────────
//   final int selectedTab;

//   // ── Feedback ──────────────────────────────────────────────────────────────
//   final String? errorMessage;
//   final String? successMessage;
//   final int importedCount;
//   final int skippedCount;

//   const ImportLeadsState({
//     this.status = ImportLeadsStatus.initial,
//     this.categories = const [],
//     this.sources = const [],
//     this.staffList = const [],
//     this.stages = const [],
//     this.selectedCategory,
//     this.selectedSource,
//     this.selectedLeadStage,
//     this.selectedPriority='Normal',
//     this.selectedStaff,
//     this.assignedStaffName = '',
//     this.assignedStaffId,
//     this.selectedState,
//     this.selectedDistrict,
//     this.dialCode = '+91',
//     this.csvBytes,
//     this.fieldPositions = const {
//       'clientName': 0,
//       'phone': 1,
//       'address': 2,
//     },
//     this.selectedTab = 0,
//     this.errorMessage,
//     this.successMessage,
//     this.importedCount = 0,
//     this.skippedCount = 0,
//   });

//   bool get isLoading   => status == ImportLeadsStatus.loading;
//   bool get isImporting => status == ImportLeadsStatus.importing;
//   bool get isReady     =>
//       status == ImportLeadsStatus.ready ||
//       status == ImportLeadsStatus.success ||
//       status == ImportLeadsStatus.failure;

//   ImportLeadsState copyWith({
//     ImportLeadsStatus? status,
//     List<LeadsModel>? categories,
//     List<LeadsModel>? sources,
//     List<StaffModel>? staffList,
//     List<LeadsModel>? stages,
//     String? selectedCategory,
//     String? selectedSource,
//     String? selectedLeadStage,
//     String? selectedPriority,
//     String? selectedStaff,
//     String? assignedStaffName,
//     String? assignedStaffId,
//     String? selectedState,
//     String? selectedDistrict,
//     String? dialCode,
//     // ✅ FIX: added csvBytes as a proper named parameter
//     Uint8List? csvBytes,
//     Map<String, int>? fieldPositions,
//     int? selectedTab,
//     String? errorMessage,
//     String? successMessage,
//     int? importedCount,
//     int? skippedCount,
//     // ── clear flags ───────────────────────────────────────────────────────
//     bool clearError     = false,
//     bool clearSuccess   = false,
//     // ✅ FIX: renamed clearCsvFile → clearCsvBytes for consistency
//     bool clearCsvBytes  = false,
//     bool clearDistrict  = false,
//     bool clearCategory  = false,
//     bool clearSource    = false,
//     bool clearLeadStage = false,
//     bool clearPriority  = false,
//     bool clearStaff     = false,
//     bool clearState     = false,
//     // ✅ FIX: kept clearCsvFile as an alias so existing callers don't break
//     bool clearCsvFile   = false,
//   }) {
//     return ImportLeadsState(
//       status:            status           ?? this.status,
//       categories:        categories       ?? this.categories,
//       sources:           sources          ?? this.sources,
//       staffList:         staffList        ?? this.staffList,
//       stages:            stages           ?? this.stages,
//       selectedCategory:  clearCategory    ? null : (selectedCategory  ?? this.selectedCategory),
//       selectedSource:    clearSource      ? null : (selectedSource    ?? this.selectedSource),
//       selectedLeadStage: clearLeadStage   ? null : (selectedLeadStage ?? this.selectedLeadStage),
//       selectedPriority:  clearPriority    ? null : (selectedPriority  ?? this.selectedPriority),
//         assignedStaffName: assignedStaffName ?? this.assignedStaffName,
//       assignedStaffId: assignedStaffId ?? this.assignedStaffId,
//      selectedState:     clearState       ? null : (selectedState     ?? this.selectedState),
//       selectedDistrict:  clearDistrict    ? null : (selectedDistrict  ?? this.selectedDistrict),
//       dialCode:          dialCode         ?? this.dialCode,
//       // ✅ FIX: either clear flag clears the bytes
//       csvBytes:          (clearCsvBytes || clearCsvFile)
//                              ? null
//                              : (csvBytes ?? this.csvBytes),
//       fieldPositions:    fieldPositions   ?? this.fieldPositions,
//       selectedTab:       selectedTab      ?? this.selectedTab,
//       errorMessage:      clearError       ? null : (errorMessage      ?? this.errorMessage),
//       successMessage:    clearSuccess     ? null : (successMessage    ?? this.successMessage),
//       importedCount:     importedCount    ?? this.importedCount,
//       skippedCount:  skippedCount  ?? this.skippedCount,
//     );
//   }
// }

// ── State ─────────────────────────────────────────────────────────────────────

import 'dart:typed_data';

import '../../../rightside_menu/common_model/lead_model.dart';
import '../../../staff_managment/staff/model/staff_model.dart';


enum ImportLeadsStatus {
  initial,
  loading,  
  ready,    
  importing, 
  success,  
  failure, 
}

class ImportLeadsState {
  final ImportLeadsStatus status;

  // ── Dropdown data ─────────────────────────────────────────────────────────
  final List<LeadsModel> categories;
  final List<LeadsModel> sources;
  final List<StaffModel> staffList;
  final List<LeadsModel> stages;

  // ── Logged-in user context ────────────────────────────────────────────────
  final String userRole;        // 'Admin' or 'Staff'
  final String loggedInStaffId; // populated for Staff users

  // ── Form selections ───────────────────────────────────────────────────────
  final String? selectedCategory;
  final String? selectedSource;
  final String? selectedLeadStage;
  final String? selectedPriority;
  final String? selectedStaff;
  final String? selectedState;
  final String? selectedDistrict;
  final String dialCode;
  final String assignedStaffName;
  final String? assignedStaffId;

  // ── CSV / field-position ──────────────────────────────────────────────────
  final Uint8List? csvBytes;
  final Map<String, int> fieldPositions;

  // ── Tab (0 = with country code, 1 = without) ─────────────────────────────
  final int selectedTab;

  // ── Feedback ──────────────────────────────────────────────────────────────
  final String? errorMessage;
  final String? successMessage;
  final int importedCount;
  final int skippedCount;

  const ImportLeadsState({
    this.status = ImportLeadsStatus.initial,
    this.categories = const [],
    this.sources = const [],
    this.staffList = const [],
    this.stages = const [],
    this.userRole = '',
    this.loggedInStaffId = '',
    this.selectedCategory,
    this.selectedSource,
    this.selectedLeadStage,
    this.selectedPriority = 'Normal',
    this.selectedStaff,
    this.assignedStaffName = '',
    this.assignedStaffId,
    this.selectedState,
    this.selectedDistrict,
    this.dialCode = '+91',
    this.csvBytes,
    this.fieldPositions = const {
      'clientName': 0,
      'phone': 1,
      'address': 2,
    },
    this.selectedTab = 0,
    this.errorMessage,
    this.successMessage,
    this.importedCount = 0,
    this.skippedCount = 0,
  });

  /// True when the logged-in user is an Admin.
  bool get isAdmin => userRole.toLowerCase() == 'admin';

  bool get isLoading   => status == ImportLeadsStatus.loading;
  bool get isImporting => status == ImportLeadsStatus.importing;
  bool get isReady =>
      status == ImportLeadsStatus.ready ||
      status == ImportLeadsStatus.success ||
      status == ImportLeadsStatus.failure;

  ImportLeadsState copyWith({
    ImportLeadsStatus? status,
    List<LeadsModel>? categories,
    List<LeadsModel>? sources,
    List<StaffModel>? staffList,
    List<LeadsModel>? stages,
    String? userRole,
    String? loggedInStaffId,
    String? selectedCategory,
    String? selectedSource,
    String? selectedLeadStage,
    String? selectedPriority,
    String? selectedStaff,
    String? assignedStaffName,
    String? assignedStaffId,
    String? selectedState,
    String? selectedDistrict,
    String? dialCode,
    Uint8List? csvBytes,
    Map<String, int>? fieldPositions,
    int? selectedTab,
    String? errorMessage,
    String? successMessage,
    int? importedCount,
    int? skippedCount,
    // ── clear flags ───────────────────────────────────────────────────────
    bool clearError     = false,
    bool clearSuccess   = false,
    bool clearCsvBytes  = false,
    bool clearDistrict  = false,
    bool clearCategory  = false,
    bool clearSource    = false,
    bool clearLeadStage = false,
    bool clearPriority  = false,
    bool clearStaff     = false,
    bool clearState     = false,
    bool clearCsvFile   = false, // legacy alias
  }) {
    return ImportLeadsState(
      status:            status            ?? this.status,
      categories:        categories        ?? this.categories,
      sources:           sources           ?? this.sources,
      staffList:         staffList         ?? this.staffList,
      stages:            stages            ?? this.stages,
      userRole:          userRole          ?? this.userRole,
      loggedInStaffId:   loggedInStaffId   ?? this.loggedInStaffId,
      selectedCategory:  clearCategory     ? null : (selectedCategory  ?? this.selectedCategory),
      selectedSource:    clearSource       ? null : (selectedSource    ?? this.selectedSource),
      selectedLeadStage: clearLeadStage    ? null : (selectedLeadStage ?? this.selectedLeadStage),
      selectedPriority:  clearPriority     ? null : (selectedPriority  ?? this.selectedPriority),
      selectedStaff:     clearStaff        ? null : (selectedStaff     ?? this.selectedStaff),
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      assignedStaffId:   assignedStaffId   ?? this.assignedStaffId,
      selectedState:     clearState        ? null : (selectedState     ?? this.selectedState),
      selectedDistrict:  clearDistrict     ? null : (selectedDistrict  ?? this.selectedDistrict),
      dialCode:          dialCode          ?? this.dialCode,
      csvBytes:          (clearCsvBytes || clearCsvFile)
                             ? null
                             : (csvBytes ?? this.csvBytes),
      fieldPositions:    fieldPositions    ?? this.fieldPositions,
      selectedTab:       selectedTab       ?? this.selectedTab,
      errorMessage:      clearError        ? null : (errorMessage      ?? this.errorMessage),
      successMessage:    clearSuccess      ? null : (successMessage    ?? this.successMessage),
      importedCount:     importedCount     ?? this.importedCount,
      skippedCount:      skippedCount      ?? this.skippedCount,
    );
  }
}