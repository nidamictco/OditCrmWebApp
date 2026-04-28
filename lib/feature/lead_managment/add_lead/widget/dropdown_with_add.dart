// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:login_2_it_solution/core/theme/app_colors.dart';
// import 'package:login_2_it_solution/core/theme/app_text_style.dart';
// import 'package:sizer/sizer.dart';

// class DropdownWithAdd extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final List<String> items;
//   final String? selectedValue;
//   final Function(String?) onChanged;

//   const DropdownWithAdd({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.items,
//     required this.selectedValue,
//     required this.onChanged,
//   });

//   @override
//   State<DropdownWithAdd> createState() => _DropdownWithAddState();
// }

// class _DropdownWithAddState extends State<DropdownWithAdd> {
//   late List<String> localItems;

//   @override
//   void initState() {
//     super.initState();
//     localItems = List.from(widget.items);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// 🔹 LABEL
//         Row(
//           children: [
//             Icon(widget.icon, size: 16, color: AppColors.green),
//             const SizedBox(width: 6),
//             Text(widget.label),
//           ],
//         ),

//         const SizedBox(height: 6),

//         /// 🔹 FIELD
//         Container(
//           height: 5.5.h,
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.divider),
//             borderRadius: BorderRadius.circular(6),
//             color: AppColors.greyCard,
//           ),
//           child: Row(
//             children: [
//               /// ➕ ADD BUTTON
//               GestureDetector(
//                 onTap: () => _showAddDialog(),
//                 child: Container(
//                   width: 50,
//                   height: double.infinity,
//                   decoration: const BoxDecoration(
//                     color: Colors.blue,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(6),
//                       bottomLeft: Radius.circular(6),
//                     ),
//                   ),
//                   child: const Icon(Icons.add, color: Colors.white),
//                 ),
//               ),

//               /// 🔽 DROPDOWN
//               Expanded(
//                 child: DropdownSearch<String>(
//                   items: localItems,
//                   selectedItem: widget.selectedValue,

//                   popupProps: const PopupProps.menu(showSearchBox: true),

//                   dropdownDecoratorProps: DropDownDecoratorProps(
//                     baseStyle: AppTextStyle.medium(
//                       size: 11.sp,
//                       weight: FontWeight.w400,
//                     ),
//                     dropdownSearchDecoration: InputDecoration(
//                       constraints: BoxConstraints(maxHeight: 50),
//                       hintText: "Select ${widget.label}",
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 1.w,
//                         vertical: 1.h,
//                       ),
//                     ),
//                   ),

//                   onChanged: widget.onChanged,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// 🔥 ADD NEW ITEM DIALOG
//   void _showAddDialog() {
//     final TextEditingController controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Add ${widget.label}"),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(hintText: "Enter new ${widget.label}"),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (controller.text.isNotEmpty) {
//                   setState(() {
//                     localItems.add(controller.text);
//                   });
//                   Navigator.pop(context);
//                 }
//               },
//               child: const Text("Add"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:login_2_it_solution/core/theme/app_colors.dart';
import 'package:login_2_it_solution/core/theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class DropdownWithAdd extends StatefulWidget {
  final String label;
  final IconData? icon;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;

  const DropdownWithAdd({
    super.key,
    required this.label,
     this.icon,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<DropdownWithAdd> createState() => _DropdownWithAddState();
}

class _DropdownWithAddState extends State<DropdownWithAdd> {
  late List<String> localItems;

  @override
  void initState() {
    super.initState();
    localItems = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 LABEL
        Row(
          children: [
            Icon(widget.icon, size: 16, color: AppColors.green),
            const SizedBox(width: 6),
            Text(widget.label,style: AppTextStyle.medium(size: 11.sp),),
          ],
        ),

        const SizedBox(height: 6),

        /// 🔹 FIELD
        Container(
          height: 5.5.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(6),
            color: AppColors.greyCard,
          ),
          child: Row(
            children: [
              /// ➕ ADD BUTTON
              GestureDetector(
                onTap: () => _showAddDialog(),
                child: Container(
                  width: 50,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),

              /// 🔽 DROPDOWN
              Expanded(
                child: DropdownSearch<String>(
                  items: localItems,
                  selectedItem: widget.selectedValue,

                  /// 🔥 POPUP STYLE (THIS IS THE MAIN CHANGE)
                  popupProps: PopupProps.menu(
                    showSearchBox: true,

                    constraints: BoxConstraints(
                      maxHeight: 300, // 🔥 fixed dropdown height
                    ),

                    itemBuilder: (context, item, isSelected) {
                      return Container(
                        height: 45, // 🔥 fixed item height
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        color: isSelected
                            ? const Color(0xff4A5D9E) // blue highlight like image
                            : Colors.white,
                        child: Text(
                          item,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.black87,
                            fontSize: 12.sp,
                          ),
                        ),
                      );
                    },

                    menuProps: MenuProps(
                      backgroundColor: Colors.white,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(6),
                    ),

                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),

                  /// 🔹 FIELD STYLE
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    baseStyle: AppTextStyle.medium(
                      size: 11.sp,
                      weight: FontWeight.w400,
                    ),
                    dropdownSearchDecoration: InputDecoration(
                      hintText: "Select ${widget.label}",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 1.w,
                        vertical: 1.h,
                      ),
                    ),
                  ),

                  onChanged: widget.onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔥 ADD NEW ITEM DIALOG
  void _showAddDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add ${widget.label}"),
          content: TextField(
            controller: controller,
            decoration:
                InputDecoration(hintText: "Enter new ${widget.label}"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    localItems.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}