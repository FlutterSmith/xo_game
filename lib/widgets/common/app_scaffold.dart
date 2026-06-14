import 'package:flutter/material.dart';
import 'app_background.dart';
import 'neon_button.dart';

/// Standard screen shell: transparent Scaffold over the shared [AppBackground],
/// with an optional glassy app bar (title + back + actions). Guarantees a
/// consistent look across every screen.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool blobs;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  final Widget? bottomBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.floatingActionButton,
    this.blobs = true,
    this.safeArea = true,
    this.padding,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    final hasBar =
        title != null || titleWidget != null || showBack || (actions?.isNotEmpty ?? false);

    Widget content = padding != null ? Padding(padding: padding!, child: body) : body;
    if (safeArea) content = SafeArea(child: content);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: hasBar
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: showBack
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: GlassIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                    )
                  : null,
              leadingWidth: showBack ? 68 : null,
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: AppBackground(blobs: blobs, child: content),
    );
  }
}
