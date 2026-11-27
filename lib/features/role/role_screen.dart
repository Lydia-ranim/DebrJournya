import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/storage/preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_banner.dart';
import '../auth/data/profile_repository.dart';

/// A6 · Choix du rôle: student or employer, chosen once (fixed for v1).
/// Saves the role to the profile, caches it on the device, then calls
/// [onChosen].
class RoleScreen extends ConsumerStatefulWidget {
  const RoleScreen({super.key, this.onChosen});

  final ValueChanged<UserRole>? onChosen;

  @override
  ConsumerState<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends ConsumerState<RoleScreen> {
  static const _headerToCards = 26.5;
  static const _tileIcon = 26.0;

  bool _busy = false;
  bool _failed = false;

  Future<void> _choose(UserRole role) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref.read(profileRepositoryProvider).setRole(role);
      await ref
          .read(sharedPreferencesProvider)
          .setString(PrefKeys.role, role.name);
      if (!mounted) return;
      setState(() => _busy = false);
      widget.onChosen?.call(role);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    Widget icon(IconData i) => Icon(i, size: _tileIcon, color: c.textPrimary);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                Space.page,
                Space.pageTop,
                Space.page,
                Space.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    titles: [
                      HeaderLine(l.roleTitle1),
                      HeaderLine(l.roleTitle2),
                    ],
                    lead: l.roleLead,
                  ),
                  const SizedBox(height: _headerToCards),
                  ChoiceCard(
                    tileColor: c.greenTile,
                    tile: icon(LucideIcons.search),
                    title: l.roleStudentTitle,
                    description: l.roleStudentText,
                    onTap: () => _choose(UserRole.student),
                  ),
                  const SizedBox(height: Space.lg),
                  ChoiceCard(
                    tileColor: c.blueTile,
                    tile: icon(LucideIcons.building),
                    title: l.roleEmployerTitle,
                    description: l.roleEmployerText,
                    onTap: () => _choose(UserRole.employer),
                  ),
                ],
              ),
            ),
            if (_failed)
              PositionedDirectional(
                top: Space.lg,
                start: Space.lg,
                end: Space.lg,
                child: StatusBanner(
                  icon: LucideIcons.wifiOff,
                  message: l.commonNoConnection,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
