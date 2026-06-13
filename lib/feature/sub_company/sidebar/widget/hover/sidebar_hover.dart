
import 'package:flutter/material.dart';
import 'package:oxdo/core/theme/app_colors.dart';

class HoverSidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isExpandable;
  final List<String>? children;
  final Function(int)? onItemTap;
  final bool isSelected;

  const HoverSidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isExpandable = false,
    this.children,
    this.onItemTap,
    this.isSelected = false,
  });

  @override
  State<HoverSidebarItem> createState() => _HoverSidebarItemState();
}

class _HoverSidebarItemState extends State<HoverSidebarItem> {
  OverlayEntry? _overlayEntry;
  bool _iconHovered = false;
  bool _popupHovered = false;
  int? _hoveredChildIndex;

  // Only called when isExpandable == true
  void _showOverlay() {
    if (_overlayEntry != null) return;

    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final top = position.dy;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 70,
        top: top,
        child: MouseRegion(
          onEnter: (_) => _popupHovered = true,
          onExit: (_) {
            _popupHovered = false;
            _maybeHide();
          },
          child: _buildPopup(),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _maybeHide() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_iconHovered && !_popupHovered) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  Widget _buildPopup() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.children != null)
              ...List.generate(widget.children!.length, (index) {
                return StatefulBuilder(
                  builder: (context, setChildState) {
                    final isHovered = _hoveredChildIndex == index;
                    return MouseRegion(
                      onEnter: (_) {
                        setChildState(() => _hoveredChildIndex = index);
                      },
                      onExit: (_) {
                        setChildState(() => _hoveredChildIndex = null);
                      },
                      child: InkWell(
                        onTap: () {
                          widget.onItemTap?.call(index);
                          _popupHovered = false;
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isHovered
                                ? AppColors.primary.withOpacity(0.08)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isHovered
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.children![index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isHovered
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isHovered
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _iconHovered = true);
        // Only show overlay popup for expandable items
        if (widget.isExpandable) {
          _showOverlay();
        }
      },
      onExit: (_) {
        setState(() => _iconHovered = false);
        // Only attempt to hide overlay for expandable items
        if (widget.isExpandable) {
          _maybeHide();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.12)
                : _iconHovered
                    ? AppColors.primary.withOpacity(0.07)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isSelected
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.25), width: 1)
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: 22,
            color: widget.isSelected
                ? AppColors.primary
                : _iconHovered
                    ? AppColors.primary
                    : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }
}