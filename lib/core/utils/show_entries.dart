import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'package:sizer/sizer.dart';

class ShowEntries extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onEntriesChanged;
  final String initialSearch;
  final String initialEntries;
  final Widget? middleWidget;
  final Widget? exportWidget;

  const ShowEntries({
    super.key,
    this.onSearchChanged,
    this.onEntriesChanged,
    this.initialSearch = '',
    this.initialEntries = '1',
    this.middleWidget,
    this.exportWidget,
  });

  @override
  State<ShowEntries> createState() => _ShowEntriesState();
}

class _ShowEntriesState extends State<ShowEntries> {
  late String selectedValue;
  final List<String> dropdownItems = ['1', '10', '50', '100', '500'];
  late final TextEditingController _searchController;

  // ── Overlay state ──────────────────────────────────────────────────
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialEntries;
    _searchController = TextEditingController(text: widget.initialSearch);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _overlayEntry
        ?.remove(); // ← if you have an OverlayEntry, remove it directly
    _overlayEntry = null;
    super.dispose();
  }

  // ── Overlay helpers ────────────────────────────────────────────────

  void _toggleDropdown() {
    _isOpen ? _closeDropdown() : _openDropdown();
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (!mounted) return; // ← guard before setState
    setState(() {
      _isOpen = false;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: const Color(0x14000000), // #00000014 (8% opacity)
        //     offset: const Offset(0, 1),
        //     blurRadius: 8,
        //     spreadRadius: 0,
        //   ),
        // ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Show N entries ────────────────────────────────────────
            Row(
              children: [
                Text("Show ", style: AppTextStyle.medium(size: 12)),
                _smallDropdown(),

                Text(" entries", style: AppTextStyle.medium(size: 12)),
                if (widget.middleWidget != null) ...[
                  SizedBox(width: 25),
                  widget.middleWidget!,
                ],
              ],
            ),

            // ── Search ────────────────────────────────────────────────
            Row(
              children: [
                Text("Search:", style: AppTextStyle.medium(size: 12)),
                SizedBox(width: 1.w),
                // Container(
                //   width: 12.w,
                //   height: 4.h,
                //   decoration: _box(),
                //   child: TextField(
                //     controller: _searchController,
                //     onChanged: (v) => widget.onSearchChanged?.call(v),
                //     style: AppTextStyle.small(size: 10.sp, color: AppColors.black),
                //     decoration: const InputDecoration(
                //       isDense: true,
                //       contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                //       border: InputBorder.none,
                //     ),
                //   ),
                // ),
                Container(
                  width: 12.w,
                  height: 5.h,
                  decoration: _box(),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => widget.onSearchChanged?.call(v),
                    style: AppTextStyle.small(
                      size: 10.sp,
                      color: AppColors.black,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Enter...",
                      hintStyle: AppTextStyle.small(
                        size: 11.sp,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      border: InputBorder.none,
                      // ✅ Show X only when text is non-empty
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                widget.onSearchChanged?.call('');
                              },
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.grey,
                              ),
                            )
                          : Icon(Icons.search, color: Colors.grey),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight:
                            24, // ✅ prevents the suffix from expanding the row height
                      ),
                    ),
                  ),
                ),
                if (widget.exportWidget != null) ...[
                  SizedBox(width: 1.w),
                  widget.exportWidget!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallDropdown() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: 4.2.w,
          height: 4.h,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: _box(),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(selectedValue, style: AppTextStyle.small(size: 11.sp)),
              AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.arrow_drop_down, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      border: Border.all(color: AppColors.lightGrey),
      borderRadius: BorderRadius.circular(6),
      color: AppColors.white,
    );
  }

  void _openDropdown() {
    final itemHeight = 36.0;
    final totalHeight = (dropdownItems.length * itemHeight).clamp(0.0, 200.0);

    // ── Get the button's position on screen ──────────────────────────
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final buttonOffset = renderBox.localToGlobal(Offset.zero);
    final buttonHeight = renderBox.size.height;
    final screenHeight = MediaQuery.of(context).size.height;

    // ── Calculate space below and above ──────────────────────────────
    final spaceBelow = screenHeight - (buttonOffset.dy + buttonHeight);
    final spaceAbove = buttonOffset.dy;

    // ── Open above if not enough space below ─────────────────────────
    final openAbove = spaceBelow < totalHeight && spaceAbove > spaceBelow;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeDropdown,
                child: const SizedBox.shrink(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,

              // ✅ Dynamically switch anchor based on available space
              targetAnchor: openAbove
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              followerAnchor: openAbove
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,

              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                color: AppColors.white,
                child: SizedBox(
                  width: 80,
                  height: totalHeight,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: dropdownItems.map((value) {
                      final isSelected = value == selectedValue;
                      return InkWell(
                        onTap: () {
                          setState(() => selectedValue = value);
                          widget.onEntriesChanged?.call(value);
                          _closeDropdown();
                        },
                        child: Container(
                          height: itemHeight,
                          color: isSelected
                              ? AppColors.lightGrey.withOpacity(0.4)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: AppTextStyle.small(size: 11.sp),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }
}
