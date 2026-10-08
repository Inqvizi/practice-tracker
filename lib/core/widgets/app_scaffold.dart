import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Master responsive shell scaffold that manages navigation sidebar,
/// top bar, breadcrumbs, drawer on mobile/tablet viewports, and page content.
class AppScaffold extends StatefulWidget {
  final String currentRoute;
  final String breadcrumb;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.currentRoute,
    required this.breadcrumb,
    required this.body,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppSpacing.desktopBreakpoint;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  backgroundColor: AppColors.surface,
                  child: SafeArea(
                    child: Sidebar(currentRoute: widget.currentRoute),
                  ),
                ),
          body: Row(
            children: [
              if (isDesktop) Sidebar(currentRoute: widget.currentRoute),
              Expanded(
                child: Column(
                  children: [
                    TopBar(
                      breadcrumb: widget.breadcrumb,
                      onMenuPressed: isDesktop
                          ? null
                          : () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: widget.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
