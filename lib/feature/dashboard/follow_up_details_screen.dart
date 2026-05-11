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


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oxdo/core/utils/dropdown.dart';
import 'package:oxdo/core/utils/dropdown_with_add.dart';
import 'package:oxdo/core/utils/popup_msg.dart';
import 'package:oxdo/feature/lead_managment/leads/model/add_lead_model.dart';
import 'package:sizer/sizer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/top_bread_crumb_bar.dart';
import 'models/follow_up_details_models.dart';
import 'package:oxdo/core/theme/app_text_style.dart';

class FollowUpDetailsScreen extends StatefulWidget {
  const FollowUpDetailsScreen({super.key});

  @override
  State<FollowUpDetailsScreen> createState() => _FollowUpDetailsScreenState();
}

class _FollowUpDetailsScreenState extends State<FollowUpDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;



  final List<FollowupEntry> _followups = const [
    FollowupEntry(
      date: '20-04-2026',
      time: '04:41 AM',
      agent: 'Shahid',
      calledDate: '20-04-2026 04:41 AM',
      callStatus: 'Connected',
      tags: 'Costly',
      remark: 'her husband not allowing to go to pmna to learn something',
      status: 'Rejected',
      products: '',
    ),
    FollowupEntry(
      date: '19-04-2026',
      time: '08:39 PM',
      agent: 'Shahid',
      calledDate: '19-04-2026 08:39 PM',
      callStatus: 'Connected',
      tags: 'Interested',
      remark: 'Will call back tomorrow morning',
      status: 'Follow Up',
      products: '',
    ),
  ];

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
        return _FollowupTabContent(followups: _followups);
      case 1:
        return _ActivitiesTabContent(activities: _activities);
      case 2:
        return const _DetailsTabContent();
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
                  child: const Icon(Icons.person, size: 30, color: Color(0xFF888888)),

                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // shrink-wrap
                  children: [
                    // Name row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                           Text(
                            'Sanidha',
                            style: AppTextStyle.heading(
                                size: 20,
                                weight: FontWeight.w700,
                                color: Color(0xFF222222)),
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
                          _headerIcon(Icons.delete_outline,
                              color: Colors.red.shade300, onTap: () {}),
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
                          _metaItem(Icons.phone, '8086287726'),
                          _divider(),
                          _metaItem(Icons.location_on_outlined, 'Karuvarkund, Malappuram'),
                          _divider(),
                          _metaText('Create Date : 18 Apr, 2026'),
                          _divider(),
                          _metaText('category :'),
                          _divider(),
                          _metaText('Staff : Shahid'),
                          _divider(),
                          _metaText('Cost : 0'),
                          _divider(),
                          const _StatusBadge(label: 'Rejected', color: Color(0xFF2196F3)),
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

  Widget _headerIcon(IconData icon,
      {Color color = const Color(0xFF555555), VoidCallback? onTap}) {
    return GestureDetector(
        onTap: onTap, child: Icon(icon, size: 22, color: color));
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF777777)),
        const SizedBox(width: 3),
        Text(text,
            style: AppTextStyle.small(size: 12, color: Color(0xFF555555))),
      ],
    );
  }

  Widget _metaText(String text) =>
      Text(text, style: AppTextStyle.small(size: 12, color: Color(0xFF555555)));

  Widget _divider() =>
      const Text('|', style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)));
}

// ─────────────────────────────────────────────────────────
// Tab 1 – Followup content (shrink-wraps inside ScrollView)
// ─────────────────────────────────────────────────────────

class _FollowupTabContent extends StatelessWidget {
  final List<FollowupEntry> followups;
  // final AddLeadModel lead;
  const _FollowupTabContent({required this.followups,});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _CalledDateCtrl = TextEditingController();
 final TextEditingController _CallStatusCtrl = TextEditingController();
 final TextEditingController _leadStagetCtrl = TextEditingController();
 final TextEditingController _productCtrl = TextEditingController();
 final TextEditingController _costCtrl = TextEditingController();
 final TextEditingController _WhtsppNoCtrl = TextEditingController();
 final TextEditingController _emailCtrl = TextEditingController();
final TextEditingController  _addressm=TextEditingController();
final TextEditingController _remarksCtrl=TextEditingController();

String? _leadStage;
  String? _leadSource;
  String? _leadCategory;
  String? _leadPriority;

    // Group entries by date
    final Map<String, List<FollowupEntry>> grouped = {};
    for (final f in followups) {
      grouped.putIfAbsent(f.date, () => []).add(f);
    }
    final dates = grouped.keys.toList();

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
                  )
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: const Row(
                    children: [
                      Icon(Icons.chat, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // _addFollowUpBottom(context, lead);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                  ),
                  child:  Text('Add Follow-up',
                      style: AppTextStyle.small(size: 13, color: AppColors.white)),
                      // TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // ✅ Rendered as plain Column children — no ListView required
          ...dates.map((date) =>
              _DateGroup(date: date, entries: grouped[date]!, time: grouped[date]![0].time, entry: grouped[date]![0],)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
  // void _addFollowUpBottom(BuildContext context, AddLeadModel lead){
  //   showDialog(
  //     context: context,
  //     builder: (context) => AppDialog(
  //       title: 'Add Follow-Up',
  //        body:  Column(
  //         children: [
  //           Row(
  //             children: [
  //                Expanded(
  //                 child: Dropdown(
  //                   showStar: true,
  //                   items: [],
  //                   selectedValue: ,
  //                   onChanged: (v) {

  //                   },
  //                   label: 'Called Status',
  //                   hint: 'Select',
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Row(children: [
  //              Expanded(
  //                 child: Dropdown(
  //                   showHelp: true,
  //                   showStar: true,
  //                   items: [],
  //                   selectedValue: _leadStage,
  //                   onChanged: (v) {
  //                     // setState(() => _leadStage = v);
  //                     // cubit.selectLeadStage(v);
  //                   },
  //                   label: 'Lead Stage',
  //                   hint: 'Select Stages',
  //                 ),
  //               ),
  //                Expanded(child: _field(
  //                   'Product',
  //                   true,
  //                   Icons.person_outline,
  //                   controller: _productCtrl,
  //                 ),
  //                )
  //           ],),
  //           Row(
  //             children: [
  //               Expanded(child: _field(
  //                   'Cost',
  //                   true,
  //                   null,
  //                   // Icons.person_outline,
  //                   controller: ,
  //                 ),
  //                ),
  //                 Expanded(child:DropdownWithAdd(
  //                   label: 'Lead Category',
  //                   icon: Icons.layers_outlined,
  //                   items: [],
  //                   selectedValue: _leadCategory,
  //                   onChanged: (v) {
  //                     // setState(() => _leadCategory = v);
  //                     // cubit.selectCategory(v);
  //                   },
  //                   onTap: _showAddCategoryDialog,
  //                 ),
  //                ),
  //             ],
  //           ),
  //          Row(
  //           children: [

  //           ],
  //          )
  //         ],
  //       ),

  //     ),
  //   );
  // }
  // Widget _field(
  //   String label,
  //   bool required,
  //   IconData? icons, {
  //   TextEditingController? controller,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _label(label, required, icons!),
  //       SizedBox(height: 0.5.h),
  //       Container(
  //         height: 5.h,
  //         decoration: BoxDecoration(
  //     border: Border.all(color: AppColors.divider),
  //     borderRadius: BorderRadius.circular(4),
  //     color: AppColors.greyCard,
  //   ),
  //         child: TextField(
  //           controller: controller,
  //           style: AppTextStyle.body(size: 11.sp),
  //           decoration: InputDecoration(
  //             hintText: label,
  //             hintStyle: AppTextStyle.small(size: 11.sp, color: AppColors.grey),
  //             border: InputBorder.none,
  //             contentPadding: EdgeInsets.all(1.w),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //  Widget _label(String text, bool required, IconData icons) {
  //   return Row(
  //     children: [
  //       Icon(icons, size: 12.sp, color: AppColors.green),
  //       SizedBox(width: 0.5.w),
  //       Text(text, style: AppTextStyle.medium()),
  //       if (required)
  //         Text(
  //           '*',
  //           style: AppTextStyle.small(size: 11.sp, color: AppColors.red),
  //         ),
  //     ],
  //   );
  // }
  // void _showAddCategoryDialog() {
  //   _dialogNameCtrl.clear();
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AppDialog(
  //       title: 'Add Lead Category',
  //       body: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text('Lead Category', style: AppTextStyle.medium(size: 11.sp)),
  //           SizedBox(height: 2.h),
  //           TextField(
  //             controller: _dialogNameCtrl,
  //             decoration: InputDecoration(
  //               hintText: 'Enter Category',
  //               hintStyle: AppTextStyle.medium(
  //                 size: 11.sp,
  //                 color: AppColors.grey,
  //               ),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       onSubmit: () async {
  //         final name = _dialogNameCtrl.text.trim();
  //         if (name.isEmpty) return;
  //         Navigator.pop(ctx);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Category "$name" added.'),
  //             backgroundColor: AppColors.green,
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}

class _DateGroup extends StatelessWidget {
  final String date;
  final String time;
  final List<FollowupEntry> entries;
  final FollowupEntry entry;
  const _DateGroup({required this.date, required this.entries, required this.time, required this.entry});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30,),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline column
            Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFc1c1c1),
                    // borderRadius: BorderRadius.circular(6),
                    shape: BoxShape.circle
                  ),
                  child: Center(
                    child: Text(
                      date,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.heading(size:13 ,color: Color(0xFF555555),weight: FontWeight.w600),
                      // const TextStyle(
                      //     fontSize: 11,
                      //     fontWeight: FontWeight.w600,
                      //     color: Color(0xFF555555)),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 43,
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
                // SizedBox(
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Container(
                //           width: 10,
                //           height: 10,
                //           decoration: const BoxDecoration(
                //             color: Color(0xFF00BCD4),
                //             shape: BoxShape.circle,
                //           ),
                //         ),
                //         const SizedBox(width: 6),
                //         Text(
                //           time,
                //           style: const TextStyle(
                //               fontSize: 12,
                //               fontWeight: FontWeight.w500,
                //               color: Color(0xFF444444)),
                //         ),
                //       ],
                //     ),
                //   ),
                // Center(
                //   child: Row(
                //     children: [
                //       Container(
                //           width: 1, color: const Color(0xFFDDDDDD)),
                //       const SizedBox(width: 6),
                //       _FollowupCard(entry: entry)
                //     ],
                //   ),
                // ),
                Expanded(
                  child: Container(
                      width: 1, color: const Color(0xFFDDDDDD)),
                ),
              ],
            ),
            // Cards
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.map((e) => _FollowupCard(entry: e)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowupCard extends StatelessWidget {
  final FollowupEntry entry;
  const _FollowupCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16,bottom: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100,),
              Text(
                entry.time,
                style: AppTextStyle.medium(color: Color(0xFF444444),size: 12)
                // const TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w500,
                //     color: Color(0xFF444444)),
              ),
          SizedBox(height: 25,),
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
                    offset: const Offset(0, 2))
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
                        child: Icon(Icons.person,
                            size: 16, color: Color(0xFF888888)),
                      ),
                      const SizedBox(width: 8),
                      Text(entry.agent,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF222222))),
                      const Spacer(),
                      Icon(Icons.edit_outlined,
                          size: 18, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Icon(Icons.delete_outline,
                          size: 18, color: Colors.red.shade400),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cardRow('Called Date', entry.calledDate),
                      const SizedBox(height: 6),
                      _cardRow('Call Status', entry.callStatus),
                      const SizedBox(height: 6),
                      _cardRow('Tags', entry.tags),
                      const SizedBox(height: 6),
                      _cardRow('Remark', '-${entry.remark}'),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           SizedBox(
                            width: 90,
                            child: Text('Status',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w500)),
                          ),
                           Text(': ',
                              style: GoogleFonts.poppins(color: Color(0xFF555555))),
                          const SizedBox(width: 4),
                          _StatusChip(label: entry.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _cardRow('Products', entry.products),
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
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(':  $value',
                style: GoogleFonts.poppins(fontSize: 13, color: Color(0xFF333333))),
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
  const _ActivitiesTabContent({required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
        children: [
          const Text('Activities',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222))),
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
              Container(
                  width: 1.5,
                  height: 40,
                  color: const Color(0xFFE0E0E0)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.agent,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF222222))),
                const SizedBox(height: 3),
                Text(entry.description,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        height: 1.5)),
                const SizedBox(height: 4),
                Text(entry.dateTime,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999))),
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
  const _DetailsTabContent();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
        fontSize: 13, color: Color(0xFF888888), fontWeight: FontWeight.w500);
    const valueStyle = TextStyle(fontSize: 13, color: Color(0xFF222222));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ✅ shrink-wrap
        children: [
          const Text('Details',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222))),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 8),
          const _DetailGrid(rows: [
            ['Phone', '+917902207315', 'Address', 'Cheruplasheri'],
            ['State', '', 'District', ''],
            ['Post office', '', 'Pincode', ''],
            ['Whatsapp_number', '+917902207315', 'Email', ''],
            ['Created Date', '25 Apr, 2026', 'Created By', 'Oxdo technologies pvt ltd'],
            ['Lead Category', 'May Visit', 'Assigned Staff', 'Shahid'],
            ['Cost', '0', 'Call Status', 'Follow Up'],
            ['Products', '', '', ''],
          ]),
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
          const Text('Lead handled staffs',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222))),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$left :', style: labelStyle),
              const SizedBox(height: 2),
              Text(leftVal, style: valueStyle),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$right :', style: labelStyle),
              const SizedBox(height: 2),
              Text(rightVal, style: valueStyle),
            ]),
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
              Expanded(child: _DetailCell(label: row[0], value: row[1])),
              const SizedBox(width: 12),
              Expanded(child: _DetailCell(label: row[2], value: row[3])),
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
        Text('$label :',
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF222222))),
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
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222))),
                const SizedBox(height: 2),
                Text(phone,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF777777))),
                const SizedBox(height: 6),
                Text('$activities Activities',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF555555))),
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
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: AppTextStyle.medium(
              color: Colors.white,
              weight: FontWeight.w600)),
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
          color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: AppTextStyle.heading(
              color: Colors.white,
              size: 11,
              weight: FontWeight.w600)),
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
        return const Color(0xFF2196F3);
      case 'connected':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: _color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: AppTextStyle.medium(
              color: Colors.white,
              size: 12,
              weight: FontWeight.w500)),
    );
  }


}