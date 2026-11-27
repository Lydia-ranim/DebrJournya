import 'package:debrjournya/core/storage/preferences.dart';
import 'package:debrjournya/features/auth/data/profile_repository.dart';
import 'package:debrjournya/features/role/role_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(resetPrefs);

  screenGoldens('a6_role', () => const RoleScreen());
  robustnessTests('A6', () => const RoleScreen());

  for (final (label, role) in [
    ('Je cherche du travail', UserRole.student),
    ('Je recrute', UserRole.employer),
  ]) {
    testWidgets('"$label" saves the ${role.name} role', (tester) async {
      final repo = FakeProfileRepository();
      UserRole? chosen;
      await tester.pumpWidget(
        harness(
          RoleScreen(onChosen: (r) => chosen = r),
          overrides: [profileRepositoryProvider.overrideWithValue(repo)],
        ),
      );
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(chosen, role);
      expect(repo.role, role);
      expect(testPrefs!.getString(PrefKeys.role), role.name);
    });
  }
}
