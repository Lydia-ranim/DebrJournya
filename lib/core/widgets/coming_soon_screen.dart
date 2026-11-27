import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../../features/mascot/jobby.dart';

/// Stand-in for a route whose screen is not built yet, so navigation can be
/// wired end to end while screens are delivered one at a time. Shows the
/// route name to make it obvious during reviews.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Jobby(size: 120, state: JobbyState.sleeping),
            const SizedBox(height: Space.lg),
            Text(l.commonComingSoon, style: context.type.cardTitle),
            const SizedBox(height: Space.xs),
            Text(routeName, style: context.type.body),
          ],
        ),
      ),
    );
  }
}
