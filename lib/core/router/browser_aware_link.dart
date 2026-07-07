// lib/core/router/browser_aware_link.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_html/html.dart' as html;

class OpenInNewTabIntent extends Intent {
  const OpenInNewTabIntent();
}

class ActivateLinkIntent extends Intent {
  const ActivateLinkIntent();
}

class BrowserAwareLink extends StatefulWidget {
  final String destination;
  final Widget child;
  final VoidCallback? onTap;
  final bool usePush;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final bool enableInkWell;
  final Color? hoverColor;
  final Color? focusColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onNewTabOpened;

  const BrowserAwareLink({
    super.key,
    required this.destination,
    required this.child,
    this.onTap,
    this.usePush = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.enableInkWell = true,
    this.hoverColor,
    this.focusColor,
    this.borderRadius,
    this.onNewTabOpened,
  });

  @override
  State<BrowserAwareLink> createState() => _BrowserAwareLinkState();
}

class _BrowserAwareLinkState extends State<BrowserAwareLink> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _openInNewTab() {
    final url = resolveUrl(widget.destination);
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      debugPrint('Opening in new tab: $url');
    }
    widget.onNewTabOpened?.call();
  }

  void _openInCurrentTab() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      if (widget.usePush) {
        context.push(widget.destination);
      } else {
        context.go(widget.destination);
      }
    }
  }

  static String resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (!kIsWeb) return path;

    final baseElement = html.document.querySelector('base');
    var baseHref = baseElement?.getAttribute('href') ?? '/';

    if (!baseHref.startsWith('/')) {
      baseHref = '/$baseHref';
    }
    if (!baseHref.endsWith('/')) {
      baseHref = '$baseHref/';
    }

    var cleanPath = path;
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final origin = html.window.location.origin;
    final fullUrl = '$origin$baseHref$cleanPath';
    return Uri.parse(fullUrl).normalizePath().toString();
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.enter, control: true): const OpenInNewTabIntent(),
      const SingleActivator(LogicalKeyboardKey.enter, meta: true): const OpenInNewTabIntent(),
      const SingleActivator(LogicalKeyboardKey.enter): const ActivateLinkIntent(),
    };

    final actions = <Type, Action<Intent>>{
      OpenInNewTabIntent: CallbackAction<OpenInNewTabIntent>(
        onInvoke: (intent) {
          _openInNewTab();
          return null;
        },
      ),
      ActivateLinkIntent: CallbackAction<ActivateLinkIntent>(
        onInvoke: (intent) {
          _openInCurrentTab();
          return null;
        },
      ),
    };

    Widget mainWidget;

    if (widget.enableInkWell) {
      mainWidget = InkWell(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        hoverColor: widget.hoverColor,
        focusColor: widget.focusColor,
        borderRadius: widget.borderRadius,
        onTap: () {
          final isCtrl = HardwareKeyboard.instance.isControlPressed;
          final isMeta = HardwareKeyboard.instance.isMetaPressed;
          if (isCtrl || isMeta) {
            _openInNewTab();
          } else {
            _openInCurrentTab();
          }
        },
        child: widget.child,
      );
    } else {
      mainWidget = Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final isCtrl = HardwareKeyboard.instance.isControlPressed;
              final isMeta = HardwareKeyboard.instance.isMetaPressed;
              if (isCtrl || isMeta) {
                _openInNewTab();
              } else {
                _openInCurrentTab();
              }
            },
            child: widget.child,
          ),
        ),
      );
    }

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Listener(
          onPointerDown: (event) {
            if (event.buttons == kMiddleMouseButton) {
              _openInNewTab();
            }
          },
          child: Semantics(
            label: widget.semanticLabel,
            link: true,
            child: mainWidget,
          ),
        ),
      ),
    );
  }
}
