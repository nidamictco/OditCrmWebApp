// import 'package:flutter/material.dart';
// import 'package:login_2_it_solution/core/theme/app_colors.dart';
// import 'package:login_2_it_solution/core/theme/app_text_style.dart';
// import 'package:sizer/sizer.dart';

// // ── Replace with your actual imports ──────────────────────────────────────────
// // import 'package:your_app/core/theme/app_colors.dart';
// // import 'package:your_app/core/theme/app_text_style.dart';
// // import 'package:your_app/widgets/custom_table.dart';

// // ── Paste your AppColors / AppTextStyle / CustomTable from your project ───────
// // The code below references them directly so it compiles without change once
// // you swap the imports above.

// // =============================================================================
// //  CLOUD CALL SETTINGS SCREEN
// // =============================================================================

// class CloudCallSettingsScreen extends StatefulWidget {
//   const CloudCallSettingsScreen({super.key});

//   @override
//   State<CloudCallSettingsScreen> createState() =>
//       _CloudCallSettingsScreenState();
// }

// class _CloudCallSettingsScreenState extends State<CloudCallSettingsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   // ── Sample data (replace with your real data / BLoC / Provider) ───────────
//   final List<_CloudCallEntry> _cloudCallRows = [
//     // Add real entries here; leave empty to show "No Data Found"
//   ];

//   final List<_IvrEntry> _ivrRows = [
//     // Add real entries here; leave empty to show "No Data Found"
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // ── Cloud Call columns ─────────────────────────────────────────────────────
//   List<TableColumn> get _cloudCallColumns => [
//         TableColumn(title: '#', flex: 1),
//         TableColumn(title: 'Provider', flex: 2),
//         TableColumn(title: 'CallerID', flex: 2),
//         TableColumn(title: 'ChannelID', flex: 2),
//         TableColumn(title: 'User', flex: 2),
//         TableColumn(title: 'Lead Category', flex: 2),
//         TableColumn(title: 'Lead Sub category', flex: 3),
//         TableColumn(title: 'Action', flex: 2),
//       ];

//   // ── IVR columns ────────────────────────────────────────────────────────────
//   List<TableColumn> get _ivrColumns => [
//         TableColumn(title: '#', flex: 1),
//         TableColumn(title: 'Provider', flex: 2),
//         TableColumn(title: 'Caller Id', flex: 2),
//         TableColumn(title: 'UID', flex: 2),
//         TableColumn(title: 'PIN', flex: 2),
//         TableColumn(title: 'Ext No', flex: 2),
//         TableColumn(title: 'Staff', flex: 2),
//         TableColumn(title: 'Type', flex: 2),
//         TableColumn(title: 'Action', flex: 2),
//       ];

//   // ── Build row widgets from cloud call data ─────────────────────────────────
//   List<List<Widget>> get _cloudCallTableRows {
//     return List.generate(_cloudCallRows.length, (i) {
//       final e = _cloudCallRows[i];
//       return [
//         _cellText('${i + 1}'),
//         _cellText(e.provider),
//         _cellText(e.callerId),
//         _cellText(e.channelId),
//         _cellText(e.user),
//         _cellText(e.leadCategory),
//         _cellText(e.leadSubCategory),
//         _buildActionButtons(onEdit: e.onEdit, onDelete: e.onDelete),
//       ];
//     });
//   }

//   // ── Build row widgets from IVR data ───────────────────────────────────────
//   List<List<Widget>> get _ivrTableRows {
//     return List.generate(_ivrRows.length, (i) {
//       final e = _ivrRows[i];
//       return [
//         _cellText('${i + 1}'),
//         _cellText(e.provider),
//         _cellText(e.callerId),
//         _cellText(e.uid),
//         _cellText(e.pin),
//         _cellText(e.extNo),
//         _cellText(e.staff),
//         _cellText(e.type),
//         _buildActionButtons(onEdit: e.onEdit, onDelete: e.onDelete),
//       ];
//     });
//   }

//   // ── Helpers ────────────────────────────────────────────────────────────────
//   Widget _cellText(String text) => Text(
//         text,
//         textAlign: TextAlign.center,
//         style: AppTextStyle.body(),
//       );

//   Widget _buildActionButtons({
//     VoidCallback? onEdit,
//     VoidCallback? onDelete,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _IconBtn(
//           icon: Icons.edit_outlined,
//           color: AppColors.primary,
//           onTap: onEdit ?? () {},
//         ),
//         SizedBox(width: 1.w),
//         _IconBtn(
//           icon: Icons.delete_outline,
//           color: AppColors.red,
//           onTap: onDelete ?? () {},
//         ),
//       ],
//     );
//   }

//   // ── "Add New" button ───────────────────────────────────────────────────────
//   Widget _addNewButton(VoidCallback onTap) {
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       icon: Icon(Icons.add_circle_outline,
//           color: AppColors.green, size: 12.sp),
//       label: Text(
//         'Add New',
//         style: AppTextStyle.body(color: AppColors.green),
//       ),
//       style: OutlinedButton.styleFrom(
//         side: BorderSide(color: AppColors.green, width: 1.2),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(6),
//         ),
//         padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
//       ),
//     );
//   }

//   // ── Section card wrapping header + table ──────────────────────────────────
//   Widget _sectionCard({
//     required String title,
//     required VoidCallback onAddNew,
//     required List<TableColumn> columns,
//     required List<List<Widget>> rows,
//     required String emptyMessage,
//   }) {
//     return Container(
//       margin: EdgeInsets.all(3.w),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.divider),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Header row ────────────────────────────────────────────────────
//           Padding(
//             padding:
//                 EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyle.medium(
//                     weight: FontWeight.w600,
//                     color: AppColors.black,
//                     size: 13.sp,
//                   ),
//                 ),
//                 _addNewButton(onAddNew),
//               ],
//             ),
//           ),

//           Divider(color: AppColors.divider, height: 1, thickness: 1),

//           SizedBox(height: 1.h),

//           // ── Table ─────────────────────────────────────────────────────────
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
//             child: SizedBox(
//               // Give the table enough width on small screens
//               width: columns.fold<double>(
//                   0, (sum, c) => sum + c.flex * 22.0),
//               child: CustomTable(
//                 columns: columns,
//                 rows: rows,
//                 emptyMessage: emptyMessage,
//               ),
//             ),
//           ),

//           SizedBox(height: 1.h),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Tab bar ───────────────────────────────────────────────────────
//           TabBar(
//             controller: _tabController,
//             isScrollable: true,
//             tabAlignment: TabAlignment.start,
//             labelColor: AppColors.primary,
//             unselectedLabelColor: AppColors.grey,
//             labelStyle: AppTextStyle.medium(
//               color: AppColors.primary,
//               weight: FontWeight.w600,
//             ),
//             unselectedLabelStyle: AppTextStyle.medium(color: AppColors.grey),
//             indicatorColor: AppColors.primary,
//             indicatorWeight: 2.5,
//             dividerColor: AppColors.divider,
//             tabs: const [
//               Tab(text: 'Bonvoice'),
//               Tab(text: 'Voxbay'),
//             ],
//           ),

//           // ── Tab views ─────────────────────────────────────────────────────
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // ── Bonvoice → Cloud Call Settings ────────────────────────
//                 SingleChildScrollView(
//                   child: _sectionCard(
//                     title: 'Cloud Call Settings',
//                     onAddNew: () {
//                       // TODO: open add dialog / navigate
//                     },
//                     columns: _cloudCallColumns,
//                     rows: _cloudCallTableRows,
//                     emptyMessage: 'No Data Found',
//                   ),
//                 ),

//                 // ── Voxbay → IVR Settings ─────────────────────────────────
//                 SingleChildScrollView(
//                   child: _sectionCard(
//                     title: 'IVR Settings',
//                     onAddNew: () {
//                       // TODO: open add dialog / navigate
//                     },
//                     columns: _ivrColumns,
//                     rows: _ivrTableRows,
//                     emptyMessage: 'No Data Found',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // =============================================================================
// //  DATA MODELS  (replace with your real models / from API)
// // =============================================================================

// class _CloudCallEntry {
//   final String provider;
//   final String callerId;
//   final String channelId;
//   final String user;
//   final String leadCategory;
//   final String leadSubCategory;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;

//   const _CloudCallEntry({
//     required this.provider,
//     required this.callerId,
//     required this.channelId,
//     required this.user,
//     required this.leadCategory,
//     required this.leadSubCategory,
//     this.onEdit,
//     this.onDelete,
//   });
// }

// class _IvrEntry {
//   final String provider;
//   final String callerId;
//   final String uid;
//   final String pin;
//   final String extNo;
//   final String staff;
//   final String type;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;

//   const _IvrEntry({
//     required this.provider,
//     required this.callerId,
//     required this.uid,
//     required this.pin,
//     required this.extNo,
//     required this.staff,
//     required this.type,
//     this.onEdit,
//     this.onDelete,
//   });
// }

// // =============================================================================
// //  SMALL REUSABLE ICON BUTTON
// // =============================================================================

// class _IconBtn extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _IconBtn({
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(4),
//       child: Container(
//         padding: EdgeInsets.all(1.w),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Icon(icon, color: color, size: 11.sp),
//       ),
//     );
//   }
// }

// // =============================================================================
// //  ── STUB CLASSES (remove once you import your real theme files) ──────────────
// //  Delete everything below this line and add your real imports at the top.
// // =============================================================================

// // class AppColors {
// //   static const primary = Color(0xff2F8FCE);
// //   static const green = Color(0xff1BAA90);
// //   static const orange = Color(0xffF97316);
// //   static const red = Color(0xffE53935);
// //   static const background = Color(0xffF3F4F6);
// //   static const white = Color(0xffffffff);
// //   static const container = Color(0xffFAFAFB);
// //   static const black = Color(0xff111827);
// //   static const grey = Color(0xff6B7280);
// //   static const lightGrey = Color(0xffD1D5DB);
// //   static const greyCard = Color(0xffF3F4F6);
// //   static const divider = Color(0xffE5E7EB);
// // }

// // class AppTextStyle {
// //   static TextStyle body({Color? color, double? size, FontWeight? weight}) =>
// //       TextStyle(
// //         color: color ?? AppColors.black,
// //         fontSize: size ?? 10,
// //         fontWeight: weight ?? FontWeight.w400,
// //       );
// //   static TextStyle medium({Color? color, double? size, FontWeight? weight}) =>
// //       TextStyle(
// //         color: color ?? AppColors.black,
// //         fontSize: size ?? 11,
// //         fontWeight: weight ?? FontWeight.w500,
// //       );
// // }

// class TableColumn {
//   final String title;
//   final int flex;
//   const TableColumn({required this.title, this.flex = 1});
// }

// class CustomTable extends StatelessWidget {
//   final List<TableColumn> columns;
//   final List<List<Widget>> rows;
//   final String emptyMessage;

//   const CustomTable({
//     super.key,
//     required this.columns,
//     required this.rows,
//     this.emptyMessage = 'No data available in table',
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: AppColors.divider),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Column(
//         children: [
//           _buildHeader(),
//           if (rows.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 40),
//               child: Center(
//                 child: Text(emptyMessage,
//                     style: AppTextStyle.medium(color: Colors.grey)),
//               ),
//             )
//           else
//             ..._buildRows(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.lightGrey.withOpacity(0.5),
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
//         border: const Border(bottom: BorderSide(color: AppColors.divider)),
//       ),
//       child: Row(
//         children: List.generate(columns.length, (i) {
//           final col = columns[i];
//           return Expanded(
//             flex: col.flex,
//             child: Container(
//               alignment: Alignment.center,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 border: Border(
//                   right: i == columns.length - 1
//                       ? BorderSide.none
//                       : const BorderSide(color: AppColors.divider),
//                 ),
//               ),
//               child: Text(col.title,
//                   style: AppTextStyle.medium(weight: FontWeight.w600)),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   List<Widget> _buildRows() {
//     return List.generate(rows.length, (rowIndex) {
//       return Container(
//         decoration: BoxDecoration(
//           color: rowIndex.isEven ? AppColors.greyCard : Colors.white,
//           border:
//               const Border(bottom: BorderSide(color: AppColors.divider)),
//         ),
//         child: Row(
//           children: List.generate(rows[rowIndex].length, (colIndex) {
//             return Expanded(
//               flex: columns[colIndex].flex,
//               child: Container(
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     right: colIndex == columns.length - 1
//                         ? BorderSide.none
//                         : const BorderSide(color: AppColors.divider),
//                   ),
//                 ),
//                 child: rows[rowIndex][colIndex],
//               ),
//             );
//           }),
//         ),
//       );
//     });
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Replace the imports below with your real project paths, then delete
//  the stub class at the bottom of this file.
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_text_style.dart';

// =============================================================================
//  SCREEN
// =============================================================================

class CloudCallSettingsScreen extends StatefulWidget {
  const CloudCallSettingsScreen({super.key});

  @override
  State<CloudCallSettingsScreen> createState() =>
      _CloudCallSettingsScreenState();
}

class _CloudCallSettingsScreenState extends State<CloudCallSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Swap with real data from your BLoC / Provider / API ───────────────────
  final List<Map<String, String>> _cloudCallRows = [];
  final List<Map<String, String>> _ivrRows = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Column definitions (fixed pixel widths to match the screenshot) ────────

  static const _cloudCallColumns = [
    _ColDef('#', 45),
    _ColDef('Provider', 120),
    _ColDef('CallerID', 110),
    _ColDef('ChannelID', 120),
    _ColDef('User', 100),
    _ColDef('Lead Category', 140),
    _ColDef('Lead Sub category', 170),
    _ColDef('Action', 100),
  ];

  static const _ivrColumns = [
    _ColDef('#', 55),
    _ColDef('Provider', 140),
    _ColDef('Caller Id', 130),
    _ColDef('UID', 90),
    _ColDef('PIN', 90),
    _ColDef('Ext No', 100),
    _ColDef('Staff', 110),
    _ColDef('Type', 120),
    _ColDef('Action', 100),
  ];

  double _totalWidth(List<_ColDef> cols) =>
      cols.fold(0.0, (s, c) => s + c.width);

  // ── "⊕ Add New" button — teal outlined, light teal fill, circle-plus icon ──
  Widget _addNewButton(VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xff1BAA90), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0),
        minimumSize: Size(0, 4.h),
        backgroundColor: const Color(0xffF0FBF8),
        elevation: 0,
      ),
      icon: const Icon(Icons.add_circle_outline,
          color: Color(0xff1BAA90), size: 16),
      label: Text(
        'Add New',
        style: GoogleFonts.poppins(
          color: const Color(0xff1BAA90),
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Full data table widget ─────────────────────────────────────────────────
  Widget _dataTable({
    required List<_ColDef> columns,
    required List<Map<String, String>> rows,
    required String emptyMessage,
  }) {
    final totalW = _totalWidth(columns);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(3.w, 0, 3.w, 2.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE5E7EB)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalW,
          child: Column(
            children: [
              _tableHeader(columns),
              if (rows.isEmpty)
                _emptyRow(columns: columns, message: emptyMessage)
              else
                ...List.generate(
                  rows.length,
                  (i) => _tableDataRow(
                      columns: columns, rowData: rows[i], isEven: i.isEven),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header row: light blue-grey bg, bold dark text, vertical dividers ──────
  Widget _tableHeader(List<_ColDef> columns) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffEEF2F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(bottom: BorderSide(color: Color(0xffE5E7EB))),
      ),
      child: Row(
        children: List.generate(columns.length, (i) {
          final col = columns[i];
          final isLast = i == columns.length - 1;
          return Container(
            width: col.width,
            padding:
                EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              border: Border(
                right: isLast
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xffE5E7EB)),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              col.title,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xff111827),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── "No Data Found" row — text in left portion, right portion blank,
  //    separated by a vertical border — exactly as the screenshot shows ───────
  Widget _emptyRow({
    required List<_ColDef> columns,
    required String message,
  }) {
    // Left portion: first 4 columns (up to ChannelID / Ext No in screenshots)
    final leftCols = columns.take(4).toList();
    final rightCols = columns.skip(4).toList();
    final leftW = leftCols.fold(0.0, (s, c) => s + c.width);
    final rightW = rightCols.fold(0.0, (s, c) => s + c.width);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left — contains "No Data Found"
          Container(
            width: leftW,
            padding:
                EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.8.h),
            decoration: const BoxDecoration(
              border: Border(
                  right: BorderSide(color: Color(0xffE5E7EB)),
                  bottom: BorderSide(color: Color(0xffE5E7EB))),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                color: const Color(0xff6B7280),
              ),
            ),
          ),
          // Right — blank
          Container(
            width: rightW,
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Color(0xffE5E7EB))),
            ),
          ),
        ],
      ),
    );
  }

  // ── Normal data row ────────────────────────────────────────────────────────
  Widget _tableDataRow({
    required List<_ColDef> columns,
    required Map<String, String> rowData,
    required bool isEven,
  }) {
    return Container(
      color: isEven ? const Color(0xffF9FAFB) : Colors.white,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffE5E7EB))),
      ),
      child: Row(
        children: List.generate(columns.length, (i) {
          final col = columns[i];
          final isLast = i == columns.length - 1;
          return Container(
            width: col.width,
            padding:
                EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              border: Border(
                right: isLast
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xffE5E7EB)),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: isLast
                ? Row(
                    children: [
                      _iconBtn(Icons.edit_outlined, const Color(0xff2F8FCE)),
                      SizedBox(width: 1.5.w),
                      _iconBtn(
                          Icons.delete_outline, const Color(0xffE53935)),
                    ],
                  )
                : Text(
                    rowData[col.title] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: const Color(0xff111827),
                    ),
                  ),
          );
        }),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: color, size: 13.sp),
      ),
    );
  }

  // ── White section card (title row + divider + table) ──────────────────────
  Widget _sectionCard({
    required String title,
    required VoidCallback onAddNew,
    required List<_ColDef> columns,
    required List<Map<String, String>> rows,
    required String emptyMessage,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(3.w, 2.h, 3.w, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Add New
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff111827),
                  ),
                ),
                _addNewButton(onAddNew),
              ],
            ),
          ),
          // Divider
          const Divider(
              color: Color(0xffE5E7EB), height: 1, thickness: 1),
          SizedBox(height: 1.5.h),
          // Table
          _dataTable(
            columns: columns,
            rows: rows,
            emptyMessage: emptyMessage,
          ),
        ],
      ),
    );
  }

  // ── Custom tab label ───────────────────────────────────────────────────────
  Widget _tabLabel(String text, bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          color: isActive
              ? const Color(0xff2D3A8C) // navy-blue — matches screenshot
              : const Color(0xff9CA3AF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = _tabController.index;

    return Scaffold(
      // Warm off-white background — exactly what the screenshot shows
      backgroundColor: const Color(0xffF3F0EC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tab bar ───────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 3.w, right: 3.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _tabController.animateTo(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _tabLabel('Bonvoice', activeIdx == 0),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.5,
                        width: 18.w,
                        decoration: BoxDecoration(
                          color: activeIdx == 0
                              ? const Color(0xff2D3A8C)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: () => _tabController.animateTo(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _tabLabel('Voxbay', activeIdx == 1),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.5,
                        width: 14.w,
                        decoration: BoxDecoration(
                          color: activeIdx == 1
                              ? const Color(0xff2D3A8C)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Tab views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Bonvoice → Cloud Call Settings
                SingleChildScrollView(
                  child: _sectionCard(
                    title: 'Cloud Call Settings',
                    onAddNew: () {
                      // TODO
                    },
                    columns: _cloudCallColumns,
                    rows: _cloudCallRows,
                    emptyMessage: 'No Data Found',
                  ),
                ),

                // Voxbay → IVR Settings
                SingleChildScrollView(
                  child: _sectionCard(
                    title: 'IVR Settings',
                    onAddNew: () {
                      // TODO
                    },
                    columns: _ivrColumns,
                    rows: _ivrRows,
                    emptyMessage: 'No Data Found',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  COLUMN DEFINITION
// =============================================================================

class _ColDef {
  final String title;
  final double width;
  const _ColDef(this.title, this.width);
}

// =============================================================================
//  STUB — delete once you add your real AppColors import
// =============================================================================

// class AppColors {
//   static const primary = Color(0xff2F8FCE);
//   static const green = Color(0xff1BAA90);
//   static const red = Color(0xffE53935);
//   static const background = Color(0xffF3F0EC);
//   static const white = Color(0xffffffff);
//   static const black = Color(0xff111827);
//   static const grey = Color(0xff6B7280);
//   static const divider = Color(0xffE5E7EB);
// }