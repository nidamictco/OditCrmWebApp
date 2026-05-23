// import 'package:flutter/material.dart';
// import 'package:oxdo/core/theme/app_text_style.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../../core/utils/top_bread_crumb_bar.dart';
// import 'models/follow_up_details_models.dart';
//
// class FollowUpDetailsScreen extends StatefulWidget {
//   const FollowUpDetailsScreen({super.key});
//
//   @override
//   State<FollowUpDetailsScreen> createState() => _FollowUpDetailsScreenState();
// }
//
// class _FollowUpDetailsScreenState extends State<FollowUpDetailsScreen>  with SingleTickerProviderStateMixin{
//
//   late TabController _tabController;
//
//   /// ── Sample Data ──────────────────────────────────────────
//   final List<FollowupEntry> _followups = const [
//     FollowupEntry(
//       date: '20-04-2026',
//       time: '04:41 AM',
//       agent: 'Shahid',
//       calledDate: '20-04-2026 04:41 AM',
//       callStatus: 'Connected',
//       tags: 'Costly',
//       remark: 'her husband not allowing to go to pmna to learn something',
//       status: 'Rejected',
//       products: '',
//     ),
//     FollowupEntry(
//       date: '19-04-2026',
//       time: '08:39 PM',
//       agent: 'Shahid',
//       calledDate: '19-04-2026 08:39 PM',
//       callStatus: 'Connected',
//       tags: 'Interested',
//       remark: 'Will call back tomorrow morning',
//       status: 'Follow Up',
//       products: '',
//     ),
//   ];
//
//   final List<ActivityEntry> _activities = const [
//     ActivityEntry(
//       agent: 'Shahid',
//       description:
//       'Status changed to Rejected. Cost Updated from to 0\nLead Category Updated from May Visit to',
//       dateTime: '20-04-2026 04:42 PM',
//     ),
//     ActivityEntry(
//       agent: 'Shahid',
//       description:
//       'Status changed to Follow Up. Next followup scheduled to 20-04-2026 10:38\nCost Updated from to 0',
//       dateTime: '19-04-2026 08:39 PM',
//     ),
//     ActivityEntry(
//       agent: 'Shahid',
//       description: 'Lead Created. Assigned to Shahid',
//       dateTime: '18-04-2026 06:30 PM',
//     ),
//   ];
//
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body:SingleChildScrollView(
//         child: Column(
//           children: [
//             TopBreadcrumbBar(
//               subTitle: 'Details',
//               title: 'Dashboard',
//               subTitle2: 'Lead List',
//               show2ndTitle: true,
//               showMenu: true,
//             ),
//             _buildHeader(),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _FollowupTab(followups: _followups),
//                   _ActivitiesTab(activities: _activities),
//                   const _DetailsTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       )
//     );
//   }
//
// // ── Header ───────────────────────────────────────────────
// Widget _buildHeader() {
//   return Container(
//     color: const Color(0xFFFFF3E0),
//     padding: EdgeInsets.symmetric(horizontal: 20),
//     child: Column(
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: AppColors.white,
//               radius: 30,
//               child: const Icon(Icons.person, size: 30, color: Color(0xFF888888)),
//
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Top bar with back button
//                   Padding(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                     child: Row(
//                       children: [
//
//                         const Text(
//                           'Sanidha',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF222222),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         _PriorityBadge(label: 'Lead priority: High'),
//                         const Spacer(),
//                         // Action icons
//                         _headerIcon(Icons.edit_outlined, onTap: () {}),
//                         const SizedBox(width: 4),
//                         _headerIcon(Icons.swap_horiz, onTap: () {}),
//                         const SizedBox(width: 4),
//                         _headerIcon(Icons.add_box_outlined, onTap: () {}),
//                         const SizedBox(width: 4),
//                         _headerIcon(Icons.delete_outline,
//                             color: Colors.red.shade300, onTap: () {}),
//                       ],
//                     ),
//                   ),
//
//                   // Meta row
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Wrap(
//                       spacing: 6,
//                       runSpacing: 4,
//                       crossAxisAlignment: WrapCrossAlignment.center,
//                       children: [
//                         _metaItem(Icons.phone, '8086287726'),
//                         _divider(),
//                         _metaItem(Icons.location_on_outlined, 'Karuvarkund, Malappuram'),
//                         _divider(),
//                         _metaText('Create Date : 18 Apr, 2026'),
//                         _divider(),
//                         _metaText('category :'),
//                         _divider(),
//                         _metaText('Staff : Shahid'),
//                         _divider(),
//                         _metaText('Cost : 0'),
//                         _divider(),
//                         _StatusBadge(label: 'Rejected', color: const Color(0xFF2196F3)),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 6),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: _metaText('Lead Source : Ads'),
//                   ),
//                   const SizedBox(height: 10),
//
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//         // Tabs
//         // _tabs(),
//
//         SizedBox(
//           child: TabBar(
//             isScrollable: true,
//             tabAlignment: TabAlignment.start,
//             controller: _tabController,
//             labelColor: const Color(0xFF1565C0),
//             unselectedLabelColor: const Color(0xFF888888),
//             indicatorColor: const Color(0xFF1565C0),
//             indicatorWeight: 2.5,
//             labelStyle: AppTextStyle.heading(size: 14),
//             unselectedLabelStyle: AppTextStyle.small(size: 14),
//             tabs: const [
//               Tab(text: 'Followup'),
//               Tab(text: 'Activities'),
//               Tab(text: 'Details'),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// Widget _headerIcon(IconData icon,
//     {Color color = const Color(0xFF555555), VoidCallback? onTap}) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Icon(icon, size: 22, color: color),
//   );
// }
//
// Widget _metaItem(IconData icon, String text) {
//   return Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Icon(icon, size: 14, color: const Color(0xFF777777)),
//       const SizedBox(width: 3),
//       Text(
//         text,
//         style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
//       ),
//     ],
//   );
// }
//
// Widget _metaText(String text) {
//   return Text(
//     text,
//     style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
//   );
// }
//
// Widget _divider() {
//   return const Text('|',
//       style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)));
// }
// }
//
// // ─────────────────────────────────────────────────────────
// // Tab 1 – Followup
// // ─────────────────────────────────────────────────────────
//
// class _FollowupTab extends StatelessWidget {
//   final List<FollowupEntry> followups;
//   const _FollowupTab({required this.followups});
//
//   @override
//   Widget build(BuildContext context) {
//     // Group by date
//     final Map<String, List<FollowupEntry>> grouped = {};
//     for (final f in followups) {
//       grouped.putIfAbsent(f.date, () => []).add(f);
//     }
//     final dates = grouped.keys.toList();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Top bar
//           Padding(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 const Text(
//                   'Followup Details',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF222222),
//                   ),
//                 ),
//                 const Spacer(),
//                 // WhatsApp button
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF25D366),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                   child: Row(
//                     children: const [
//                       Icon(Icons.chat, color: Colors.white, size: 16),
//                       SizedBox(width: 4),
//                       Icon(Icons.keyboard_arrow_down,
//                           color: Colors.white, size: 16),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 // Add Follow-up button
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF009688),
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(6)),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 9),
//                   ),
//                   child: const Text(
//                     'Add Follow-up',
//                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               physics: NeverScrollableScrollPhysics(),
//               padding: const EdgeInsets.only(bottom: 20),
//               itemCount: dates.length,
//               itemBuilder: (ctx, i) {
//                 final date = dates[i];
//                 final entries = grouped[date]!;
//                 return _DateGroup(date: date, entries: entries, time: entries[0].time);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DateGroup extends StatelessWidget {
//   final String date;
//   final String time;
//   final List<FollowupEntry> entries;
//
//   const _DateGroup({required this.date, required this.entries, required this.time});
//
//   @override
//   Widget build(BuildContext context) {
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Timeline column
//           SizedBox(
//             width: 80,
//             child: Column(
//               children: [
//                 const SizedBox(height: 8),
//                 // Date bubble
//                 Container(
//                   width: 70,
//                   height: 70,
//                   padding: const EdgeInsets.symmetric(vertical: 6),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE0E0E0),
//                     // borderRadius: BorderRadius.circular(6),
//                     shape: BoxShape.circle
//                   ),
//                   child: Center(
//                     child: Text(
//                       date,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF555555),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     height: 50,
//                     width: 1,
//                     color: const Color(0xFF636363),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Container(
//                       width: 10,
//                       height: 10,
//                       decoration: const BoxDecoration(
//                         color: Color(0xFF00BCD4),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       time,
//                       style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF444444)),
//                     ),
//                   ],
//                 ),
//                 // Vertical line
//                 Expanded(
//                   child: Center(
//                     child: Container(
//                       width: 0.5,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Cards column
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: entries.map((e) => _FollowupCard(entry: e)).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _FollowupCard extends StatelessWidget {
//   final FollowupEntry entry;
//   const _FollowupCard({required this.entry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 16, bottom: 16, top: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Time with dot
//           // Row(
//           //   children: [
//           //     Container(
//           //       width: 10,
//           //       height: 10,
//           //       decoration: const BoxDecoration(
//           //         color: Color(0xFF00BCD4),
//           //         shape: BoxShape.circle,
//           //       ),
//           //     ),
//           //     const SizedBox(width: 6),
//           //     Text(
//           //       entry.time,
//           //       style: const TextStyle(
//           //           fontSize: 12,
//           //           fontWeight: FontWeight.w500,
//           //           color: Color(0xFF444444)),
//           //     ),
//           //   ],
//           // ),
//           const SizedBox(height: 6),
//           // Card
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: const Color(0xFFEEEEEE)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   blurRadius: 6,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Card header
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
//                   child: Row(
//                     children: [
//                       const CircleAvatar(
//                         radius: 14,
//                         backgroundColor: Color(0xFFEEEEEE),
//                         child: Icon(Icons.person,
//                             size: 16, color: Color(0xFF888888)),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         entry.agent,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                           color: Color(0xFF222222),
//                         ),
//                       ),
//                       const Spacer(),
//                       Icon(Icons.edit_outlined,
//                           size: 18, color: Colors.green.shade600),
//                       const SizedBox(width: 8),
//                       Icon(Icons.delete_outline,
//                           size: 18, color: Colors.red.shade400),
//                     ],
//                   ),
//                 ),
//                 const Divider(height: 1, color: Color(0xFFF0F0F0)),
//                 Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     children: [
//                       _cardRow('Called Date', entry.calledDate),
//                       const SizedBox(height: 6),
//                       _cardRow('Call Status', entry.callStatus),
//                       const SizedBox(height: 6),
//                       _cardRow('Tags', entry.tags),
//                       const SizedBox(height: 6),
//                       _cardRow('Remark', ':  -${entry.remark}'),
//                       const SizedBox(height: 6),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             width: 90,
//                             child: Text(
//                               'Status',
//                               style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Color(0xFF555555),
//                                   fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                           const Text(': ',
//                               style: TextStyle(color: Color(0xFF555555))),
//                           const SizedBox(width: 4),
//                           _StatusChip(label: entry.status),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       _cardRow('Products', entry.products),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _cardRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 90,
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF555555),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             ':  $value',
//             style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────
// // Tab 2 – Activities
// // ─────────────────────────────────────────────────────────
//
// class _ActivitiesTab extends StatelessWidget {
//   final List<ActivityEntry> activities;
//   const _ActivitiesTab({required this.activities});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const Text(
//             'Activities',
//             style: TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF222222),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...activities.map((a) => _ActivityItem(entry: a)).toList(),
//         ],
//       ),
//     );
//   }
// }
//
// class _ActivityItem extends StatelessWidget {
//   final ActivityEntry entry;
//   const _ActivityItem({required this.entry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar + vertical line
//           Column(
//             children: [
//               const CircleAvatar(
//                 radius: 18,
//                 backgroundColor: Color(0xFFEEEEEE),
//                 child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
//               ),
//               Container(
//                 width: 1.5,
//                 height: 40,
//                 color: const Color(0xFFE0E0E0),
//               ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   entry.agent,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     color: Color(0xFF222222),
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   entry.description,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF555555),
//                     height: 1.5,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   entry.dateTime,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF999999),
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
//
// // ─────────────────────────────────────────────────────────
// // Tab 3 – Details
// // ─────────────────────────────────────────────────────────
//
// class _DetailsTab extends StatelessWidget {
//   const _DetailsTab();
//
//   @override
//   Widget build(BuildContext context) {
//     const labelStyle = TextStyle(
//       fontSize: 13,
//       color: Color(0xFF888888),
//       fontWeight: FontWeight.w500,
//     );
//     const valueStyle = TextStyle(
//       fontSize: 13,
//       color: Color(0xFF222222),
//     );
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const Text(
//             'Details',
//             style: TextStyle(
//               fontSize: 17,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF222222),
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Divider(color: Color(0xFFEEEEEE)),
//           const SizedBox(height: 8),
//
//           // Two-column grid of details
//           _DetailGrid(rows: const [
//             ['Phone', '+917902207315', 'Address', 'Cheruplasheri'],
//             ['State', '', 'District', ''],
//             ['Post office', '', 'Pincode', ''],
//             ['Whatsapp_number', '+917902207315', 'Email', ''],
//             ['Created Date', '25 Apr, 2026', 'Created By', 'Oxdo technologies pvt ltd'],
//             ['Lead Category', 'May Visit', 'Assigned Staff', 'Shahid'],
//             ['Cost', '0', 'Call Status', 'Follow Up'],
//             ['Products', '', '', ''],
//           ]),
//
//           const SizedBox(height: 8),
//
//           // Lead Method & Remarks
//           _detailRow(
//             labelStyle: labelStyle,
//             valueStyle: valueStyle,
//             left: 'Lead Method',
//             leftVal: 'Direct Entry',
//             right: 'Remarks',
//             rightVal:
//             'planning to visit on 4th may with friends, some friends are in different places. will try to visit before 4th otherwise will come on 4th',
//           ),
//
//           const SizedBox(height: 16),
//           const Divider(color: Color(0xFFEEEEEE)),
//           const SizedBox(height: 12),
//
//           const Text(
//             'Lead handled staffs',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF222222),
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           Row(
//             children: [
//               Expanded(
//                 child: _StaffCard(
//                   name: 'Oxdo technologies pvt ltd',
//                   phone: '9207554433',
//                   activities: 1,
//                   isStarred: false,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _StaffCard(
//                   name: 'Shahid',
//                   phone: '918089131915',
//                   activities: 2,
//                   isStarred: true,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _detailRow({
//     required TextStyle labelStyle,
//     required TextStyle valueStyle,
//     required String left,
//     required String leftVal,
//     required String right,
//     required String rightVal,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('$left :', style: labelStyle),
//                 const SizedBox(height: 2),
//                 Text(leftVal, style: valueStyle),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('$right :', style: labelStyle),
//                 const SizedBox(height: 2),
//                 Text(rightVal, style: valueStyle),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DetailGrid extends StatelessWidget {
//   final List<List<String>> rows;
//   const _DetailGrid({required this.rows});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: rows.map((row) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 7),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(child: _DetailCell(label: row[0], value: row[1])),
//               const SizedBox(width: 12),
//               Expanded(child: _DetailCell(label: row[2], value: row[3])),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// class _DetailCell extends StatelessWidget {
//   final String label;
//   final String value;
//   const _DetailCell({required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     if (label.isEmpty) return const SizedBox();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           '$label :',
//           style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF888888),
//               fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 13, color: Color(0xFF222222)),
//         ),
//       ],
//     );
//   }
// }
//
// class _StaffCard extends StatelessWidget {
//   final String name;
//   final String phone;
//   final int activities;
//   final bool isStarred;
//
//   const _StaffCard({
//     required this.name,
//     required this.phone,
//     required this.activities,
//     required this.isStarred,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFDE7),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: const Color(0xFFEEEECC)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const CircleAvatar(
//             radius: 18,
//             backgroundColor: Color(0xFFE0E0E0),
//             child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF222222),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   phone,
//                   style: const TextStyle(
//                       fontSize: 12, color: Color(0xFF777777)),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   '$activities Activities',
//                   style: const TextStyle(
//                       fontSize: 12, color: Color(0xFF555555)),
//                 ),
//               ],
//             ),
//           ),
//           if (isStarred)
//             const Icon(Icons.star, color: Color(0xFFFFA000), size: 20),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────
// // Shared Widgets
// // ─────────────────────────────────────────────────────────
//
// class _PriorityBadge extends StatelessWidget {
//   final String label;
//   const _PriorityBadge({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFF5722),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _StatusBadge({required this.label, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
//
// class _StatusChip extends StatelessWidget {
//   final String label;
//   const _StatusChip({required this.label});
//
//   Color get _color {
//     switch (label.toLowerCase()) {
//       case 'rejected':
//         return const Color(0xFFFF5722);
//       case 'follow up':
//         return const Color(0xFF2196F3);
//       case 'connected':
//         return const Color(0xFF4CAF50);
//       default:
//         return const Color(0xFF9E9E9E);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//       decoration: BoxDecoration(
//         color: _color,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:oxdo/core/utils/custom_calender.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/dropdown_with_add.dart';
import 'package:oxdo/core/utils/input_date.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_cubit.dart';
import 'package:oxdo/feature/lead_managment/leads/cubit/add_lead_state.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/top_bread_crumb_bar.dart';
import '../lead_managment/leads/model/add_lead_model.dart';
import 'models/follow_up_details_models.dart';
import 'package:oxdo/core/theme/app_text_style.dart';

class FollowUpDetailsScreen extends StatefulWidget {
  AddLeadModel currentLead;
   FollowUpDetailsScreen({super.key, required this.currentLead});
  // final AddLeadModel? lead;
  // const FollowUpDetailsScreen({super.key, this.lead});

  @override
  State<FollowUpDetailsScreen> createState() => _FollowUpDetailsScreenState();
}

class _FollowUpDetailsScreenState extends State<FollowUpDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  final List<ActivityEntry> _activities = const [
    ActivityEntry(
      agent: 'Shahid',
      description:
          'Status changed to Rejected. Cost Updated from to 0\nLead Category Updated from May Visit to',
      dateTime: '20-04-2026 04:42 PM',
    ),
    ActivityEntry(
      agent: 'Shahid',
      description:
          'Status changed to Follow Up. Next followup scheduled to 20-04-2026 10:38\nCost Updated from to 0',
      dateTime: '19-04-2026 08:39 PM',
    ),
    ActivityEntry(
      agent: 'Shahid',
      description: 'Lead Created. Assigned to Shahid',
      dateTime: '18-04-2026 06:30 PM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Keep _selectedTab in sync when user swipes (if you ever re-add TabBarView)
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
      }
    });
    context.read<AddLeadCubit>().initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ SingleChildScrollView is the ONE scroll owner for the whole screen.
      // No Expanded / TabBarView inside — zero conflict.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBreadcrumbBar(
              subTitle: 'Details',
              title: 'Dashboard',
              subTitle2: 'Lead List',
              show2ndTitle: true,
              showMenu: true,
            ),

            // Header + TabBar (no TabBarView)
            _buildHeader(),

            // ✅ Inline tab content — each widget uses mainAxisSize.min so
            // it shrink-wraps naturally inside the SingleChildScrollView.
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  // ── Inline tab content switcher ──────────────────────────
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _FollowupTabContent(
          followups: widget.currentLead.followUp??[],
          leadId: widget.currentLead.id ?? '',
          leadName: widget.currentLead.clientName ?? '',
          lead: widget.currentLead,
        );
      case 1:
        return _ActivitiesTabContent(activities: _activities, lead: widget.currentLead,);
      case 2:
        return _DetailsTabContent(lead: widget.currentLead,);
      default:
        return const SizedBox();
    }
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFFFFF3E0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 30,
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Color(0xFF888888),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // shrink-wrap
                  children: [
                    // Name row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            // 'Sanidha',
                            widget.currentLead.clientName ?? '',
                            style: AppTextStyle.heading(
                              size: 20,
                              weight: FontWeight.w700,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const _PriorityBadge(label: 'Lead priority: High'),
                          const Spacer(),
                          _headerIcon(Icons.edit_outlined, onTap: () {}),
                          const SizedBox(width: 10),
                          _headerIcon(Icons.swap_horiz, onTap: () {}),
                          const SizedBox(width: 10),
                          _headerIcon(Icons.add_box_outlined, onTap: () {}),
                          const SizedBox(width: 10),
                          _headerIcon(
                            Icons.delete_outline,
                            color: Colors.red.shade300,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // Meta row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _metaItem(Icons.phone,
                              // '8086287726'
                              widget.currentLead.contactNumber ?? '',),
                          _divider(),
                          _metaItem(
                            Icons.location_on_outlined,
                            'Karuvarkund, Malappuram',
                          ),
                          _divider(),
                          _metaText('Create Date : 18 Apr, 2026'),
                          _divider(),
                          _metaText('category :'),
                          _divider(),
                          _metaText('Staff : Shahid'),
                          _divider(),
                          _metaText('Cost : 0'),
                          _divider(),
                          const _StatusBadge(
                            label: 'Rejected',
                            color: Color(0xFF2196F3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _metaText('Lead Source : Ads'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
          // ✅ TabBar only — NO TabBarView.
          // onTap drives setState which swaps the inline content below.
          TabBar(
            padding: EdgeInsets.zero,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            controller: _tabController,
            labelColor: const Color(0xFF1565C0),
            unselectedLabelColor: const Color(0xFF888888),
            indicatorColor: const Color(0xFF1565C0),
            indicatorWeight: 2,
            labelStyle: AppTextStyle.heading(size: 12),
            unselectedLabelStyle: AppTextStyle.small(size: 12),
            onTap: (i) => setState(() => _selectedTab = i),
            tabs: const [
              Tab(text: 'Followup'),
              Tab(text: 'Activities'),
              Tab(text: 'Details'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(
    IconData icon, {
    Color color = const Color(0xFF555555),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 22, color: color),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF777777)),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTextStyle.small(size: 12, color: Color(0xFF555555)),
        ),
      ],
    );
  }

  Widget _metaText(String text) =>
      Text(text, style: AppTextStyle.small(size: 12, color: Color(0xFF555555)));

  Widget _divider() => Text(
    '|',
    style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFFBBBBBB)),
  );
}

// ─────────────────────────────────────────────────────────
// Tab 1 – Followup content (shrink-wraps inside ScrollView)
// ─────────────────────────────────────────────────────────

class _FollowupTabContent extends StatefulWidget {
  final List<FollowUpModel> followups;
  final String leadId;
  final String leadName;
  final String? leadWhatsappNo;
  final String? leadWhatsappDialCode;
  final AddLeadModel lead;
  const _FollowupTabContent({
    required this.followups,
    required this.leadId,
    required this.leadName,
    this.leadWhatsappNo,
    this.leadWhatsappDialCode,
    required this.lead,
  });

  @override
  State<_FollowupTabContent> createState() => _FollowupTabContentState();
}

class _FollowupTabContentState extends State<_FollowupTabContent> {
  final TextEditingController _calledDateCtrl = TextEditingController();
  final TextEditingController _callStatusCtrl = TextEditingController();
  // final TextEditingController _leadStagetCtrl = TextEditingController();
  final TextEditingController _productCtrl = TextEditingController();
  final TextEditingController _costCtrl = TextEditingController();
  final TextEditingController _WhtsppNoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addressm = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();

  final List<String> _leadStages = ['New', 'Follow Up', 'Closed', 'Rejected'];
  final List<String> _callStatuses = [
    'Connected',
    'Not Connected',
    'Busy',
    "No Status Updated",
    "Not Attended",
    "Out of coverge Area",
    "Rejected",
    "Switched Off",
    "Number Changed",
    "Not Switched On",
  ];

  String? _leadStage;
  String? _leadCategory;
  String? _leadPriority;

  @override
  void initState() {
    super.initState();
    log("widget.followups.isEmpty");
    _calledDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final Widget divider = SizedBox(width: 1.w);

    FollowUpModel createLeadFollowup() {
      return FollowUpModel(
        leadId: widget.leadId,
        leadName: widget.leadName,
        leadWhatsappNo: widget.leadWhatsappNo ?? "",
        leadWhatsappDialCode: widget.leadWhatsappDialCode ?? "",
        nextFollowUpDate: widget.lead.followUpDate ?? DateTime.now(),
        calledStatus: widget.lead.callResult ?? "",
        calledDate: widget.lead.calledDate ?? widget.lead.createdAt ?? DateTime.now(),
        leadStage: widget.lead.leadStage,
        leadCategory: widget.lead.leadCategory,
        priority: widget.lead.priority,
        remarks: widget.lead.remarks,
        createdById: widget.lead.createdById,
      );
    }
    // Group entries by date
    final Map<String, List<FollowUpModel>> grouped = {};

    final Map<String, FollowUpModel> followupGroup = {};

    followupGroup[DateFormat('dd-MM-yyyy').format(widget.lead.followUpDate!)] = createLeadFollowup();

    for (final f in widget.followups) {
      followupGroup[DateFormat('dd-MM-yyyy').format(f.calledDate)] = f;
    }

    if(widget.followups.isEmpty) {
      followupGroup[DateFormat('dd-MM-yyyy').format(widget.lead.createdAt!)] = createLeadFollowup();
    }

    ///---------------------------------------------------------------
    grouped.putIfAbsent(DateFormat('dd-MM-yyyy').format(widget.lead.followUpDate!), () => []).add(FollowUpModel(
        leadId: widget.leadId,
        leadName: widget.leadName,
        leadWhatsappNo: widget.leadWhatsappNo ?? "",
        leadWhatsappDialCode: widget.leadWhatsappDialCode ?? "",
        nextFollowUpDate: widget.lead.followUpDate ?? DateTime.now(),
        calledStatus: widget.lead.callResult ?? "",
        calledDate: widget.lead.calledDate ?? widget.lead.createdAt ?? DateTime.now(),
        leadStage: widget.lead.leadStage, leadCategory: widget.lead.leadCategory,
        priority: widget.lead.priority, remarks: widget.lead.remarks, createdById: widget.lead.createdById

    ));

    for (final f in widget.followups) {
      grouped.putIfAbsent(DateFormat('dd-MM-yyyy').format(f.calledDate), () => []).add(f);
    }


    if(widget.followups.isEmpty) {
      grouped.putIfAbsent(DateFormat('dd-MM-yyyy').format(widget.lead.createdAt!), () => []).add(FollowUpModel(
          leadId: widget.leadId,
          leadName: widget.leadName,
          leadWhatsappNo: widget.leadWhatsappNo ?? "",
          leadWhatsappDialCode: widget.leadWhatsappDialCode ?? "",
          nextFollowUpDate: widget.lead.followUpDate ?? DateTime.now(),
          calledStatus: widget.lead.callResult ?? "",
          calledDate: widget.lead.calledDate ?? widget.lead.createdAt ?? DateTime.now(),
          leadStage: widget.lead.leadStage, leadCategory: widget.lead.leadCategory,
          priority: widget.lead.priority, remarks: widget.lead.remarks, createdById: widget.lead.createdById

      ));
    }

    // final dates = grouped.keys.toList();

    ///--------------------------------------------------------------------------

    final dates = followupGroup.keys.toList();
    // log(dates.length.toString());

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
        children: [
          // Action bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              children: [
                Text(
                  'Followup Details',
                  style: AppTextStyle.heading(
                    size: 18,
                    // weight: FontWeight.w700,
                    color: Color(0xFF495057),
                  ),
                  // TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.w700,
                  //     color: Color(0xFF222222)),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _addFollowUpBottom(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                  ),
                  child: Text(
                    'Add Follow-up',
                    style: AppTextStyle.small(size: 13, color: AppColors.white),
                  ),
                  // TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // ✅ Rendered as plain Column children — no ListView required
          ...dates.map(
                (date) => _DateGroup(
              date: date,
              entry: followupGroup[date]!,
              time: DateFormat('hh:mm a').format(followupGroup[date]!.calledDate),
              lead: widget.lead,
                  index: dates.indexOf(date)
            ),
          ),

          // ...dates.map(
          //   (date) => _DateGroup(
          //     date: date,
          //     entries: grouped[date]!,
          //     time: DateFormat('hh:mm a').format(grouped[date]![0].calledDate),
          //     // entry: grouped[date]![0],
          //     lead: widget.lead,
          //   ),
          // ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // void _addFollowUpBottom(BuildContext context) {
  //   final cubit = context.read<AddLeadCubit>();

  // cubit.selectLeadStage(null);
  // cubit.selectCategory(null);
  // cubit.selectPriority(null);

  // final TextEditingController nextFollowUpCtrl = TextEditingController(
  //   text: DateFormat('dd-MM-yyyy').format(
  //     DateTime.now().add(const Duration(days: 1)),
  //   ),
  // );
  // DateTime _nextFollowUpDate = DateTime.now().add(const Duration(days: 1));
  // DateTime _calledDateValue = DateTime.now();
  //   showDialog(
  //     context: context,
  //     builder: (context) => BlocProvider.value(
  //       value: cubit,
  //       child: AppDialog(
  //         title: 'Add Follow-Up',
  //         width: 60.w,
  //         body: Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
  //           child: BlocBuilder<AddLeadCubit, AddLeadState>(
  //             builder: (context, state) {
  //               final categoryNames = state.categories
  //                   .map((e) => e.name)
  //                   .toList();
  //               final stagesNames = state.stages.map((e) => e.name).toList();
  //               final List<String> priority = [
  //                 'High',
  //                 'Low',
  //                 'Negative',
  //                 'Normal',
  //               ];

  //               return Column(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Row(
  //                               children: [
  //                                 Text(
  //                                   'Called Date',
  //                                   style: AppTextStyle.medium(),
  //                                 ),
  //                                 // SizedBox(width: 0.5.w),
  //                                 Text(
  //                                   '*',
  //                                   style: AppTextStyle.medium(
  //                                     size: 13,
  //                                     color: Colors.red,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             GestureDetector(
  //                               onTap: () {
  //                                 showDialog(
  //                                   context: context,
  //                                   barrierColor: Colors.transparent,
  //                                   builder: (context) {
  //                                     return Stack(
  //                                       children: [
  //                                         Positioned(
  //                                           top: 33.h,
  //                                           left: 27.w,
  //                                           child: CustomCalendar(
  //                                             onDateSelected: (date) {
  //                                               _calledDateCtrl.text =
  //                                                   DateFormat(
  //                                                     'dd-MM-yyyy',
  //                                                   ).format(date);
  //                                               Navigator.pop(context);
  //                                             },
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     );
  //                                   },
  //                                 );
  //                               },
  //                               child: Container(
  //                                 // width: 15.w,
  //                                 height: 5.2.h,
  //                                 padding: EdgeInsets.symmetric(
  //                                   horizontal: 10,
  //                                   vertical: 5,
  //                                 ),
  //                                 decoration: BoxDecoration(
  //                                   color: AppColors.greyCard,
  //                                   border: Border.all(
  //                                     color: AppColors.divider,
  //                                     width: 1,
  //                                   ),
  //                                   borderRadius: BorderRadius.circular(4),
  //                                 ),
  //                                 child: IgnorePointer(
  //                                   child: TextField(
  //                                     textAlignVertical:
  //                                         TextAlignVertical.center,
  //                                     textAlign: TextAlign.start,
  //                                     controller: _calledDateCtrl,
  //                                     readOnly: true,
  //                                     style: AppTextStyle.small(
  //                                       size: 11.sp,
  //                                       color: AppColors.black,
  //                                     ),
  //                                     decoration: InputDecoration(
  //                                       border: InputBorder.none,
  //                                       hintText: _calledDateCtrl.text,
  //                                       hintStyle: AppTextStyle.small(
  //                                         size: 11.sp,
  //                                         color: AppColors.black,
  //                                       ),
  //                                       isCollapsed: true,
  //                                       contentPadding: EdgeInsets.zero,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       SizedBox(width: 1.w),
  //                       Expanded(
  //                         child: Dropdown(
  //                           showStar: true,
  //                           items: [
  //                             'Connected',
  //                             'Not Connected',
  //                             'Busy',
  //                             "No Status Updated",
  //                             "Not Attended",
  //                             "Out of coverge Area",
  //                             "Rejected",
  //                             "Switched Off",
  //                             "Number Changed",
  //                             "Not Switched On",
  //                           ],
  //                           selectedValue: _callStatusCtrl.text,
  //                           onChanged: (v) {
  //                             setState(() {
  //                               _callStatusCtrl.text = v ?? '';
  //                             });
  //                           },
  //                           label: 'Called Status',
  //                           hint: 'Select Call Status',
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 1.h),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Dropdown(
  //                           showHelp: true,
  //                           showStar: true,
  //                           items: stagesNames,
  //                           selectedValue: _leadStage,
  //                           onChanged: (v) {
  //                             setState(() => _leadStage = v);
  //                             cubit.selectLeadStage(v);
  //                           },
  //                           label: 'Lead Stage',
  //                           hint: 'Select',
  //                         ),
  //                       ),
  //                       SizedBox(width: 1.w),
  //                       Expanded(
  //                         child: DropdownWithAdd(
  //                           label: 'Lead Category',
  //                           icon: Icons.layers_outlined,
  //                           items: categoryNames,
  //                           selectedValue: _leadCategory,
  //                           onChanged: (v) {
  //                             setState(() => _leadCategory = v);
  //                             cubit.selectCategory(v);
  //                           },
  //                           // onTap: _showAddCategoryDialog,
  //                           onTap: () {},
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 1.h),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Dropdown(
  //                           icon: Icons.flag_outlined,
  //                           showIcon: true,
  //                           showHelp: true,
  //                           items: priority,
  //                           selectedValue: _leadPriority,
  //                           onChanged: (v) {
  //                             setState(() => _leadPriority = v);
  //                             cubit.selectPriority(v);
  //                           },
  //                           label: 'Priority',
  //                           hint: 'Select Priority',
  //                         ),
  //                       ),
  //                       SizedBox(width: 1.w),
  //                       Expanded(
  //                         child: _phoneField(
  //                           'Whatsapp Number',
  //                           false,
  //                           Icons.call_outlined,
  //                           controller: _WhtsppNoCtrl,
  //                           onDialCodeChanged: (c) =>
  //                               setState(() => _WhtsppNoCtrl.text = c),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 1.h),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: _field(
  //                           'Email',
  //                           true,
  //                           null,
  //                           // Icons.person_outline,
  //                           controller: _emailCtrl,
  //                         ),
  //                       ),
  //                       SizedBox(width: 1.w),
  //                       Expanded(
  //                         child: _field(
  //                           'Address',
  //                           true,
  //                           null,
  //                           // Icons.person_outline,
  //                           controller: _addressm,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 1.h),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: _field(
  //                           'Remark',
  //                           true,
  //                           null,
  //                           // Icons.person_outline,
  //                           controller: _addressm,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _addFollowUpBottom(BuildContext context) {
    final cubit = context.read<AddLeadCubit>();

    // Reset selections before opening dialog
    cubit.selectLeadStage(null);
    cubit.selectCategory(null);
    cubit.selectPriority(null);

    final TextEditingController nextFollowUpCtrl = TextEditingController(
      text: DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now().add(const Duration(days: 1))),
    );
    DateTime nextFollowUpDate = DateTime.now().add(const Duration(days: 1));
    DateTime calledDateValue = DateTime.now();

    // ✅ Reset called date to today each time dialog opens
    _calledDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _callStatusCtrl.text = '';
    _remarksCtrl.text = '';
    _emailCtrl.text = '';
    _addressm.text = '';

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: BlocConsumer<AddLeadCubit, AddLeadState>(
          // ✅ BlocConsumer at the TOP — wraps everything so the
          //    entire dialog rebuilds on every state change
          listener: (ctx, state) {
            if (state.status == AddLeadStatus.success &&
                state.successMessage == 'Follow-up added successfully.') {
              // ✅ Capture messenger BEFORE popping — context is still alive here
              final messenger = ScaffoldMessenger.of(context);

              Navigator.pop(dialogContext);

              // ✅ Now safe to use — messenger was captured before pop
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Follow-up added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state.errorMessage != null) {
              // ✅ Guard: only show if context is still mounted
              if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          builder: (ctx, state) {
            // ✅ Data comes from cubit state — guaranteed non-null if
            //    initialize() was called before opening this screen
            final categoryNames = state.categories.map((e) => e.name).toList();
            final stagesNames = state.stages.map((e) => e.name).toList();
            const priority = ['High', 'Low', 'Negative', 'Normal'];

            return StatefulBuilder(
              // ✅ StatefulBuilder is INSIDE BlocConsumer so local UI
              //    state (date pickers etc.) still works
              builder: (sbContext, sbSetState) {
                return AppDialog(
                  title: 'Add Follow-Up',
                  width: 60.w,
                  onSubmit: state.isSubmitting
                      ? null
                      : () {
                          if (_callStatusCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a call status.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          cubit.submitFollowUp(
                            leadId: widget.leadId,
                            leadName: widget.leadName,
                            leadWhatsappNo: _WhtsppNoCtrl.text.trim(),
                            leadWhatsappDialCode: '+91',
                            calledDate: calledDateValue,
                            nextFollowUpDate: nextFollowUpDate,
                            calledStatus: _callStatusCtrl.text,
                            remarks: _remarksCtrl.text.trim(),
                          );
                        },
                  body: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.w,
                      vertical: 1.h,
                    ),
                    child: Column(
                      children: [
                        // ── Row 1: Called Date + Call Status ──────────────
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Called Date',
                                        style: AppTextStyle.medium(),
                                      ),
                                      Text(
                                        '*',
                                        style: AppTextStyle.medium(
                                          size: 13,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.5.h),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: sbContext,
                                        barrierColor: Colors.transparent,
                                        builder: (_) => Stack(
                                          children: [
                                            Positioned(
                                              top: 33.h,
                                              left: 26.w,
                                              child: CustomCalendar(
                                                onDateSelected: (date) {
                                                  // ✅ sbSetState for local date
                                                  sbSetState(() {
                                                    calledDateValue = date;
                                                    _calledDateCtrl.text =
                                                        DateFormat(
                                                          'dd-MM-yyyy',
                                                        ).format(date);
                                                  });
                                                  Navigator.pop(sbContext);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 5.2.h,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.greyCard,
                                        border: Border.all(
                                          color: AppColors.divider,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: IgnorePointer(
                                        child: TextField(
                                          controller: _calledDateCtrl,
                                          readOnly: true,
                                          style: AppTextStyle.small(
                                            size: 11.sp,
                                            color: AppColors.black,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: _calledDateCtrl.text,
                                            hintStyle: AppTextStyle.small(
                                              size: 11.sp,
                                              color: AppColors.black,
                                            ),
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Dropdown(
                                showStar: true,
                                items: _callStatuses,
                                // ✅ Use local controller text, not state
                                selectedValue: _callStatusCtrl.text.isEmpty
                                    ? null
                                    : _callStatusCtrl.text,
                                onChanged: (v) {
                                  // ✅ sbSetState so the conditional
                                  //    Next Follow-Up row shows/hides
                                  sbSetState(
                                    () => _callStatusCtrl.text = v ?? '',
                                  );
                                },
                                label: 'Called Status',
                                hint: 'Select Call Status',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // ── Row 2: Lead Stage + Lead Category ─────────────
                        Row(
                          children: [
                            Expanded(
                              child: Dropdown(
                                showHelp: true,
                                showStar: true,
                                items: stagesNames,
                                selectedValue: state.selectedLeadStage,
                                onChanged: (v) => cubit.selectLeadStage(v),
                                label: 'Lead Stage',
                                hint: stagesNames.isEmpty
                                    ? 'Loading...'
                                    : 'Select',
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: DropdownWithAdd(
                                label: 'Lead Category',
                                icon: Icons.layers_outlined,
                                items: categoryNames,
                                selectedValue: state.selectedCategory,
                                onChanged: (v) => cubit.selectCategory(v),
                                onTap: () {},
                                //  categoryNames.isEmpty ? 'Loading...' : null,
                              ),
                            ),
                          ],
                        ),

                        // ── Conditional: Next Follow-Up Date ──────────────
                        // ✅ Only shows when call status is 'Follow Up'
                        if (state.selectedLeadStage == 'FOLLOWUP') ...[
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next Follow-Up Date',
                                      style: AppTextStyle.medium(),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: sbContext,
                                          barrierColor: Colors.transparent,
                                          builder: (_) => Stack(
                                            children: [
                                              Positioned(
                                                top: 38.h,
                                                left: 27.w,
                                                child: CustomCalendar(
                                                  onDateSelected: (date) {
                                                    sbSetState(() {
                                                      nextFollowUpDate = date;
                                                      nextFollowUpCtrl.text =
                                                          DateFormat(
                                                            'dd-MM-yyyy',
                                                          ).format(date);
                                                    });
                                                    // ✅ pop sbContext not context
                                                    Navigator.pop(sbContext);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 5.2.h,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.greyCard,
                                          border: Border.all(
                                            color: AppColors.divider,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: IgnorePointer(
                                          child: TextField(
                                            controller: nextFollowUpCtrl,
                                            readOnly: true,
                                            style: AppTextStyle.small(
                                              size: 11.sp,
                                              color: AppColors.black,
                                            ),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: nextFollowUpCtrl.text,
                                              hintStyle: AppTextStyle.small(
                                                size: 11.sp,
                                                color: AppColors.black,
                                              ),
                                              isCollapsed: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 1.w),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                        SizedBox(height: 1.h),

                        // ── Row 4: Priority + WhatsApp ────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Dropdown(
                                icon: Icons.flag_outlined,
                                showIcon: true,
                                showHelp: true,
                                items: priority,
                                selectedValue: state.selectedPriority,
                                onChanged: (v) => cubit.selectPriority(v),
                                label: 'Priority',
                                hint: 'Select Priority',
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: _phoneField(
                                'Whatsapp Number',
                                false,
                                Icons.call_outlined,
                                controller: _WhtsppNoCtrl,
                                onDialCodeChanged: (c) =>
                                    sbSetState(() => _WhtsppNoCtrl.text = c),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // ── Row 5: Email + Address ────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                'Email',
                                false,
                                null,
                                controller: _emailCtrl,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: _field(
                                'Address',
                                false,
                                null,
                                controller: _addressm,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // ── Row 6: Remarks ────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                'Remark',
                                false,
                                null,
                                controller: _remarksCtrl,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),

                        // ── Loading indicator when submitting ─────────────
                        if (state.isSubmitting)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _field(
    String label,
    bool required,
    IconData? icons, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),
        Container(
          height: 5.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(4),
            color: AppColors.greyCard,
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyle.body(size: 11.sp),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(1.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, bool required, IconData? icons) {
    return Row(
      children: [
        Icon(icons, size: 12.sp, color: AppColors.green),
        SizedBox(width: 0.5.w),
        Text(text, style: AppTextStyle.medium()),
        if (required)
          Text(
            '*',
            style: AppTextStyle.small(size: 11.sp, color: AppColors.red),
          ),
      ],
    );
  }

  Widget _phoneField(
    String label,
    bool required,
    IconData icons, {
    TextEditingController? controller,
    void Function(String)? onDialCodeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required, icons),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            SizedBox(
              height: 5.h,
              width: 7.5.w,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
                child: CountryCodePicker(
                  onChanged: (country) =>
                      onDialCodeChanged?.call(country.dialCode ?? '+91'),
                  initialSelection: 'IN',
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: true,
                  padding: EdgeInsets.zero,
                  textStyle: AppTextStyle.body(size: 11.sp),
                  flagWidth: 16,
                  dialogBackgroundColor: AppColors.white,
                  dialogSize: Size(30.w, 80.h),
                  dialogTextStyle: AppTextStyle.body(size: 11.sp),
                  searchStyle: AppTextStyle.body(size: 11.sp),
                  searchDecoration: InputDecoration(
                    hintText: 'Search country',
                    hintStyle: AppTextStyle.small(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: EdgeInsets.all(1.w),
                  ),
                ),
              ),
            ),
            SizedBox(width: 0.25.w),
            Expanded(
              child: Container(
                height: 5.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.greyCard,
                ),
                child: TextField(
                  controller: controller,
                  style: AppTextStyle.body(size: 11.sp),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter number',
                    hintStyle: AppTextStyle.small(
                      size: 11.sp,
                      color: AppColors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(1.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateGroup extends StatelessWidget {
  final int index;
  final String date;
  final String time;
  // final List<FollowUpModel> entries;
  final FollowUpModel entry;
  final AddLeadModel lead;
  const _DateGroup({
    required this.date,
    // required this.entries,
    required this.time,
    required this.entry,
    required this.lead,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column
            Column(
              // mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFc1c1c1),
                    // borderRadius: BorderRadius.circular(6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "$date",
                      textAlign: TextAlign.center,
                      style: AppTextStyle.heading(
                        size: 13,
                        color: Color(0xFF555555),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 25,
                    width: 1,
                    color: const Color(0xFFDDDDDD),
                  ),
                ),
                Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Container(width: 1, height: 100, color: const Color(0xFFDDDDDD)),
                Expanded(
                  child: Container(width: 1, color: const Color(0xFFDDDDDD)),
                ),
              ],
            ),
            // Cards

            Flexible(
              fit: FlexFit.loose,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  // Text("count of entries are ${entries.length}"),
                  index == 0 ?
                  _LastFollowupCard(lead: lead,) :
                  lead.followUp!.isEmpty?
                  _FirstFollowupCard(lead: lead,) :
                  _FollowupCard(entry: entry, lead: lead, index: index,),

                // SizedBox(height: 20),
                //   _LastFollowupCard(lead: lead,),
                // ...entries.map((e) =>
                //     _FollowupCard(entry: e, lead: lead, entries : entries)),
                    ],

              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _FollowupCard extends StatelessWidget {
  final FollowUpModel entry;
  final AddLeadModel lead;
  final int index;
  // final List<FollowUpModel> entries;
  const _FollowupCard({required this.entry, required this.lead, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 0, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Text(
            // entry.time,
            DateFormat('hh:mm a').format(entry.calledDate),
            style: AppTextStyle.medium(color: Color(0xFF444444), size: 12),
            // const TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w500,
            //     color: Color(0xFF444444)),
          ),
          SizedBox(height: 10),
          Container(
            width: 550,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCDCDC)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFEEEEEE),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lead.assignedStaff,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const Spacer(),
                      if(index == 1)
                      Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.green.shade600,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.shade400,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardRow('Scheduled Date', DateFormat('dd-MM-yyyy hh:mm a').format(entry.nextFollowUpDate)),
                      const SizedBox(height: 4),
                      _cardRow('Called Date', DateFormat('dd-MM-yyyy hh:mm a').format(entry.calledDate)),
                      const SizedBox(height: 4),
                      _cardRow('Call Status', entry.calledStatus),
                      const SizedBox(height: 4),
                      if(entry.leadStage.toLowerCase() == 'rejected')
                      _cardRow('Tags', lead.leadTag!),
                      if(entry.leadStage.toLowerCase() == 'rejected')
                      const SizedBox(height: 4),
                      _cardRow('Remark', '-${entry.remarks}'),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ': ',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _StatusChip(label: entry.leadStage),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // _cardRow('Products', entry.products),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _cardRow(String label, String value) {
    return SizedBox(
      // width: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ':  $value',
              maxLines: 4,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstFollowupCard extends StatelessWidget {

  final AddLeadModel lead;
  const _FirstFollowupCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Text(
            // entry.time,
            DateFormat('hh:mm a').format(lead.createdAt!),
            style: AppTextStyle.medium(color: Color(0xFF444444), size: 12),
            // const TextStyle(
            //     fontSize: 12,
            //     fontWeight: FontWeight.w500,
            //     color: Color(0xFF444444)),
          ),
          SizedBox(height: 25),
          Container(
            width: 550,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFEEEEEE),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lead.assignedStaff,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.shade400,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardRow('Created Date', DateFormat('dd-MM-yyyy hh:mm a').format(lead.createdAt!)),
                      const SizedBox(height: 6),
                      _cardRow('Remark', '-${lead.remarks}'),

                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ': ',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _StatusChip(label: lead.leadStage),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // _cardRow('Products', entry.products),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRow(String label, String value) {
    return SizedBox(
      // width: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ':  $value',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastFollowupCard extends StatelessWidget {

  final AddLeadModel lead;
  const _LastFollowupCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Text(
            // entry.time,
            DateFormat('hh:mm a').format(lead.calledDate?? lead.createdAt!),
            style: AppTextStyle.medium(color: Color(0xFF444444), size: 12),
          ),
          SizedBox(height: 25),
          Container(
            width: 550,
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFEEEEEE),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lead.assignedStaff,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF222222),
                        ),
                      ),
                      // const Spacer(),
                      // Icon(
                      //   Icons.edit_outlined,
                      //   size: 18,
                      //   color: Colors.green.shade600,
                      // ),
                      // const SizedBox(width: 8),
                      // Icon(
                      //   Icons.delete_outline,
                      //   size: 18,
                      //   color: Colors.red.shade400,
                      // ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardRow('Scheduled Date', DateFormat('dd-MM-yyyy hh:mm a').format(lead.followUpDate!)),
                      const SizedBox(height: 6),
                      _cardRow('Remark', '-${lead.remarks}'),

                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ': ',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Row(
                            children: [
                              _StatusChip(label: lead.leadStage),
                              Text("(Pending)",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color(0xFF555555),
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // _cardRow('Products', entry.products),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardRow(String label, String value) {
    return SizedBox(
      // width: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              ':  $value',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 2 – Activities content (shrink-wraps inside ScrollView)
// ─────────────────────────────────────────────────────────

class _ActivitiesTabContent extends StatelessWidget {
  final List<ActivityEntry> activities;
  final AddLeadModel lead;
  const _ActivitiesTabContent({required this.activities, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
        children: [
          Text(
            'Activities',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 16),
          // ✅ Spread entries as Column children — no ListView
          ...activities.map((a) => _ActivityItem(entry: a)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityEntry entry;
  const _ActivityItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEEEEEE),
                child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
              ),
              Container(width: 1.5, height: 40, color: const Color(0xFFE0E0E0)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.agent,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.dateTime,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF999999),
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

// ─────────────────────────────────────────────────────────
// Tab 3 – Details content (shrink-wraps inside ScrollView)
// ─────────────────────────────────────────────────────────

class _DetailsTabContent extends StatelessWidget {
  final AddLeadModel lead;
  const _DetailsTabContent({required this.lead});

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: Color(0xFF888888),
      fontWeight: FontWeight.w500,
    );
    TextStyle valueStyle = GoogleFonts.poppins(
      fontSize: 13,
      color: Color(0xFF222222),
    );

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
        children: [
          Text(
            'Details',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          const _DetailGrid(
            rows: [
              ['Phone', '+917902207315', 'Address', 'Cheruplasheri'],
              ['State', '', 'District', ''],
              ['Post office', '', 'Pincode', ''],
              ['Whatsapp_number', '+917902207315', 'Email', ''],
              [
                'Created Date',
                '25 Apr, 2026',
                'Created By',
                'Oxdo technologies pvt ltd',
              ],
              ['Lead Category', 'May Visit', 'Assigned Staff', 'Shahid'],
              ['Cost', '0', 'Call Status', 'Follow Up'],
              ['Products', '', '', ''],
            ],
          ),
          const SizedBox(height: 8),
          _detailRow(
            labelStyle: labelStyle,
            valueStyle: valueStyle,
            left: 'Lead Method',
            leftVal: 'Direct Entry',
            right: 'Remarks',
            rightVal:
                'planning to visit on 4th may with friends, some friends are in different places. will try to visit before 4th otherwise will come on 4th',
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Text(
            'Lead handled staffs',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StaffCard(
                  name: 'Oxdo technologies pvt ltd',
                  phone: '9207554433',
                  activities: 1,
                  isStarred: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StaffCard(
                  name: 'Shahid',
                  phone: '918089131915',
                  activities: 2,
                  isStarred: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _detailRow({
    required TextStyle labelStyle,
    required TextStyle valueStyle,
    required String left,
    required String leftVal,
    required String right,
    required String rightVal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$left :', style: labelStyle),
                const SizedBox(height: 2),
                Text(leftVal, style: valueStyle),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$right :', style: labelStyle),
                const SizedBox(height: 2),
                Text(rightVal, style: valueStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<List<String>> rows;
  const _DetailGrid({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailCell(label: row[0], value: row[1]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailCell(label: row[2], value: row[3]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final String label;
  final String value;
  const _DetailCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label :',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, color: Color(0xFF222222)),
        ),
      ],
    );
  }
}

class _StaffCard extends StatelessWidget {
  final String name;
  final String phone;
  final int activities;
  final bool isStarred;

  const _StaffCard({
    required this.name,
    required this.phone,
    required this.activities,
    required this.isStarred,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEECC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, size: 20, color: Color(0xFF888888)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$activities Activities',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
          if (isStarred)
            const Icon(Icons.star, color: Color(0xFFFFA000), size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  final String label;
  const _PriorityBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5722),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.medium(
          color: Colors.white,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.heading(
          color: Colors.white,
          size: 11,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  Color get _color {
    switch (label.toLowerCase()) {
      case 'rejected':
        return const Color(0xFFFF5722);
      case 'follow up':
        return const Color(0xFFF59E0B);
      case 'followup':
        return const Color(0xFFF59E0B);
      case 'connected':
        return const Color(0xFF4CAF50);
      case 'new':
        return const Color(0xFF10B981);
      case 'transferred':
        return const Color(0xFF3B82F6);
      case 'missed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Row(
        children: [
          Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _color.withOpacity(0.3)),
          ),
          child: Text(
            label,
            style: AppTextStyle.medium(
              color: _color,
              size: 12,
              weight: FontWeight.w500,
            ),
          ),
              ),
          if(label == "new")
          Text(
            "(Pending)",
            style: AppTextStyle.medium(
              color: Colors.red,
              size: 12,
              weight: FontWeight.w500,
            ),
          ),
        ],
      );
  }
}
