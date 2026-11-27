import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/choice_card.dart';
import '../../core/widgets/page_header.dart';

/// A3 · Langue. First choice after the splash. The title is shown in both
/// languages, and each card is written in — and laid out in the direction
/// of — its own language, whatever language the app is currently in.
/// Picking a card saves the language and calls [onChosen].
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key, this.onChosen});

  final VoidCallback? onChosen;

  static const _fr = Locale('fr');
  static const _ar = Locale('ar');
  static const _headerToCards = 26.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final fr = lookupAppLocalizations(_fr);
    final ar = lookupAppLocalizations(_ar);

    Future<void> choose(Locale locale) async {
      await ref.read(localeProvider.notifier).choose(locale);
      onChosen?.call();
    }

    Widget card(AppLocalizations l, Color tileColor, Locale locale) {
      return Directionality(
        textDirection: locale == _ar ? TextDirection.rtl : TextDirection.ltr,
        child: ChoiceCard(
          tileColor: tileColor,
          tile: Text(l.languageTileLabel, style: context.type.tileLabel),
          title: l.languageName,
          description: l.languageDescription,
          onTap: () => choose(locale),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  HeaderLine(fr.languageTitle, direction: TextDirection.ltr),
                  HeaderLine(ar.languageTitle, direction: TextDirection.rtl),
                ],
                lead: AppLocalizations.of(context).languageLead,
              ),
              const SizedBox(height: _headerToCards),
              card(fr, c.greenTile, _fr),
              const SizedBox(height: Space.lg),
              card(ar, c.blueTile, _ar),
            ],
          ),
        ),
      ),
    );
  }
}
