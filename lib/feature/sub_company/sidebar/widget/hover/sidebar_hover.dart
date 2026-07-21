import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/router/browser_aware_link.dart';

class HoverSidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isExpandable;
  final List<String>? children;
  final Function(int)? onItemTap;
  final bool isSelected;
  final String? destination;
  final List<String>? destinations;

  const HoverSidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isExpandable = false,
    this.children,
    this.onItemTap,
    this.isSelected = false,
    this.destination,
    this.destinations,
  });

  @override
  State<HoverSidebarItem> createState() => _HoverSidebarItemState();
}

class _HoverSidebarItemState extends State<HoverSidebarItem> {
  OverlayEntry? _overlayEntry;
  bool _iconHovered = false;
  bool _popupHovered = false;
  int? _hoveredChildIndex;

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
                color: Color(0xff002b66),
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
                    style: GoogleFonts.poppins(
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
                    final childDest =
                        widget.destinations != null &&
                            index < widget.destinations!.length
                        ? widget.destinations![index]
                        : '';
                    return MouseRegion(
                      onEnter: (_) {
                        setChildState(() => _hoveredChildIndex = index);
                      },
                      onExit: (_) {
                        setChildState(() => _hoveredChildIndex = null);
                      },
                      child: BrowserAwareLink(
                        destination: childDest,
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
                                ? const Color(0xff002b66).withOpacity(0.08)
                                : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isHovered
                                    ? const Color(0xff002b66)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.children![index],
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isHovered
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isHovered
                                  ? const Color(0xff002b66)
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
    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 44,
      width: 44,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? const Color(0xff002b66)
            : _iconHovered
            ? const Color(0xff002b66).withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(
        widget.icon,
        size: 20,
        color: widget.isSelected
            ? Colors.white
            : _iconHovered
            ? const Color(0xff002b66)
            : Colors.grey[600],
      ),
    );

    return MouseRegion(
      onEnter: (_) {
        setState(() => _iconHovered = true);
        if (widget.isExpandable) {
          _showOverlay();
        }
      },
      onExit: (_) {
        setState(() => _iconHovered = false);
        if (widget.isExpandable) {
          _maybeHide();
        }
      },
      child: widget.isExpandable
          ? GestureDetector(onTap: widget.onTap, child: container)
          : BrowserAwareLink(
              destination: widget.destination ?? '',
              onTap: widget.onTap,
              enableInkWell: false,
              child: container,
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
