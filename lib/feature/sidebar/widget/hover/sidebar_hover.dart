import 'package:flutter/material.dart';

class HoverSidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  final bool isExpandable;
  final List<String>? children;
  final Function(int)? onItemTap;

  const HoverSidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isExpandable = false,
    this.children,
    this.onItemTap,
  });

  @override
  State<HoverSidebarItem> createState() => _HoverSidebarItemState();
}

class _HoverSidebarItemState extends State<HoverSidebarItem> {
  OverlayEntry? overlayEntry;

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 70,
          top: _getPosition(),
          child: _buildPopup(),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  double _getPosition() {
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    return position.dy;
  }

  Widget _buildPopup() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 220,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE BAR
            Container(
              color: Colors.blue.shade700,
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(widget.icon, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            if (widget.isExpandable && widget.children != null)
              ...List.generate(widget.children!.length, (index) {
                return InkWell(
                  onTap: () {
                    widget.onItemTap?.call(index);
                    hideOverlay();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(widget.children![index]),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => showOverlay(),
      onExit: (_) => hideOverlay(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 60,
          alignment: Alignment.center,
          child: Icon(widget.icon, size: 22),
        ),
      ),
    );
  }
}