# CLAUDE.md — DebrJournya

Working notes for Claude (and humans) developing this app. Read this first. Keep it current: when a
decision is made or an open question is answered, update the relevant section in the same change.

## 1. What the app is

DebrJournya (*« Le job qui s'adapte à ton emploi du temps »*) is an **Android-first Flutter app** that
matches **Algerian university students** with flexible work around their timetable:

- **Job** — recurring part-time work (e.g. tutoring Tue/Thu 18–20h)
- **Mission** — a single shift or short series of shifts (the spec calls these "shifts")
- **Événement** — an event, paid or **unpaid volunteering** (unpaid = "Non rémunéré · Bénévolat")

Two roles: **student (seeker)** and **employer** (cafés, shops, associations, event organisers).
Students set availability once, get a match score per post, apply in two taps with an auto-built CV.
Employers post, review applicants ranked by fit, accept. **Phone numbers are revealed only after
acceptance**, then both sides continue by call/WhatsApp. No in-app chat, no in-app payment, the app
never handles wages.

Languages: **French and Arabic (RTL)**, both first-class from the first screen. Launch: Algiers.

Source documents (authoritative, read them when a detail matters):
- `Docs/spec/DebrJournya_spec.md` — product spec & business plan (features F1–F15 in §5.2, screens §6)
- `Docs/design/light/*.png`, `Docs/design/dark/* · sombre.png` — 52 screens × 2 themes (French only)
- `Docs/design/mascot/pro (2).jsx` — the animated mascot / logo "Jobby" (see §8)

## 2. Repo layout & commands

```
/                       Flutter project root (package name: debrjournya, Android only)
├─ lib/                 app code (see §4 for target structure)
├─ test/                unit/widget tests
├─ android/             applicationId com.debrjournya.debrjournya
├─ Docs/                spec, designs, mascot (note capital D; README links say docs/ — outdated)
└─ CLAUDE.md
```

Toolchain at creation: Flutter 3.47.8 stable, Dart 3.13.7.

```bash
flutter pub get
flutter analyze                     # must be clean before committing
flutter test
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
flutter gen-l10n                    # once l10n is set up (§6)
```

Secrets are passed with `--dart-define` only. **Never commit keys**, `.env` files or `google-services.json`
with real values.

## 3. Hard product rules (enforce in code, mostly server-side)

The **server (Supabase/Postgres) is the source of truth**; the app is a cache + UI. Anything that is a
business rule must be enforced by RLS / database functions, not only in Dart.

| Rule | Value | Where |
|---|---|---|
| Sign-in | Phone (+213) + 6-digit SMS code. Valid mobile starts with 5, 6 or 7 | A4/A5 |
| OTP errors | "Code incorrect, il te reste N essais", "Code expiré". Resend countdown. Rate-limit per number & device | A5, server |
| Contact reveal | Phone returned by the API **only** for an `accepted` application. Block phone numbers & links in all free text before acceptance | D3, server |
| Paid posts | Pay amount mandatory. Unpaid posts show "Non rémunéré" everywhere | C3, all cards |
| Unpaid events | Employer must be **verified** (free) to post them | C2 |
| Free employer limit | Max **3 active posts** (unpaid included) | C3/C4, server |
| Skills | Max **10** per student, from list or custom | B2 |
| Bio | Max **160** chars | B1 |
| Application status | `sent → viewed → accepted / declined` (UI: Envoyée, Vue, Acceptée, Refusée). Notify student at each change. Unanswered ones expire after a deadline (employers reminded at 48h) | B10, C6/C7 |
| Post status | Ouverte / Pourvue (filled) / Fermée. Shows "x/y pourvues" | C4/C5 |
| Shift completion | After end time, employer marks **completed** or **no-show**. Completed → student work history + CV | C10 (not designed), B12 |
| No-shows | 2 no-shows → student applications suspended 30 days. No-show rate visible to employers | server |
| Reports | 3 reports from different users hide the item until review | D4, server |
| Ratings | Two-way 1–5 stars + tags + optional comment, only after a completed shift | B13, C9 |
| Reminder | Local notification before an accepted shift (spec: 2h; design D2 says "la veille et 2 h avant") — must work offline | D1/D2 |
| Location | Students: **commune level only**, never exact position, never shown to employers. Employer addresses are exact | B6, F permission |
| CV | PDF generated **on the phone**; no CV data sent to a server just to build it | E3/E4 |
| Ads | None inside the apply flow or after acceptance. No third-party ad SDK collecting personal data | F15 |
| Analytics | Counts and timings only; never names, phones, CV content | — |
| Account deletion | Must exist (Law 18-07 / ANPDP) | D2 |

**Match score** (computed server-side, per query, no ML):
`match = 0.5 × availabilityFit + 0.3 × skillsFit + 0.2 × distanceFit`, each in [0,1].
- availabilityFit = share of the post's hours inside the student's free slots
- skillsFit = share of required skills the student has
- distanceFit = linear from 1 at 0 km to 0 at 15 km
- "Pour toi" (Recommended) tab never shows posts with zero availability overlap. Shown as a % pill.

**Non-functional budgets:** installed size < 40 MB; must run well on a 2 GB RAM Android 10 phone on 3G.
Feed and the student's own applications must open offline from cache.

## 4. Architecture (defaults — change here if we decide otherwise)

- **Client:** Flutter, Material 3, Android only. Feature-first folders:
  ```
  lib/
    main.dart, app.dart          # MaterialApp.router, theme, locale
    core/                        # theme/, l10n/, router/, widgets/ (shared UI kit), utils/, supabase/
    features/<feature>/          # auth, onboarding, profile, availability, feed, post, applications,
                                 # employer, cv, notifications, settings, report, mascot
      data/ domain/ presentation/
  ```
- **State / routing / packages:** not added yet. Proposed defaults: `flutter_riverpod`, `go_router`,
  `supabase_flutter`, `firebase_messaging`, `flutter_local_notifications`, `pdf` + `printing`/`share_plus`,
  `flutter_map` (or Google Maps) for B6, `intl` + `flutter_localizations`. Check size budget before adding
  anything heavy. Record here when chosen.
- **Backend:** Supabase (Postgres + PostGIS for distance, Auth with phone OTP, Storage for logos/photos/
  verification docs, RLS on every table). Notifications via FCM; shift reminders are local.
- **Premium/ads:** server-side entitlement flags only; D6 is a "Bientôt" placeholder in v1.

## 5. Screens & navigation

IDs match the design file names. ✱ = exists in design but spec had merged/omitted it (we follow the design).

**Getting started:** A1 Splash (animated Jobby) → A3 Langue → A2 Onboarding ×3 (Passer / Suivant /
Commencer) → A4 Téléphone (+ CGU checkbox, error + offline-banner states) → A5 Code SMS → A6 Choix du rôle
(*« Tu pourras ajouter l'autre rôle plus tard »*).
- Student setup: B1 Profil (1/3: photo, nom, université, filière, année, ville, langues, bio) → B2 Compétences
  (2/3) → B3 Préférences (3/3: type de travail, moments préférés) → permissions → student shell.
- Employer setup: C1 Ton entreprise (1/2: logo, nom, type d'activité, wilaya, commune, adresse, téléphone,
  description) → step 2 (probably C2 Vérification) → employer shell.

**Student shell — bottom nav:** Accueil · Candidatures · Mon CV · Profil
- B4 Accueil: greeting, search, filter button, Jobs/Missions/Événements segmented control, Pour toi/Tout tabs,
  Carte link, category chips (Tout, Service, Événements, Tutorat, Vente), post cards (logo, title, employer +
  verified + rating, match %, description, tags, schedule, place, pay, save, Voir), bell → D1.
- B5 Filtres (bottom sheet) · B6 Vue carte (price pins, bottom card, "Liste") · B7 Détail offre · B8 Détail
  événement bénévolat ("Ce que tu y gagnes") · B9 Confirmer (profil, dispos correspondantes, CV joint, petit
  mot) → B9 Candidature envoyée.
- B10 Mes candidatures (Actives / Passées; accepted card → "Voir le contact" → D3) · B11 Enregistrées ✱ ·
  B12 Historique · B13 Noter l'employeur · B14 Aperçu du profil public ✱.
- E1 Mon CV (completeness %, auto-filled sections) → E2 Choix du modèle (Moderne/Classique, FR/AR) → E3 Aperçu
  & édition (tap a section to edit; "via DebrJournya" tags; bottom: template, photo, reorder, Exporter) → E4
  Export & partage (download, share, "CV par défaut" toggle).

**Employer shell — bottom nav:** Annonces · Candidats · Alertes · Entreprise
- C4 Mes annonces (filters Toutes/Ouvertes/Pourvues/Fermées, FAB "+ Publier") → C3 Nouvelle annonce (type,
  titre, catégorie, payé/non rémunéré, montant + "par" unit, date unique/récurrent + days, début/fin, adresse
  prefilled, nombre de personnes, compétences, langues, description, Brouillon) → C3 Aperçu (feed card preview,
  récap, "N étudiants à moins de 10 km disponibles") → F Succès → C5 Détail de l'annonce ✱ (stats, Voir les
  candidats, Candidats suggérés, Modifier, Clôturer).
- C6 Candidats (Meilleure correspondance / Plus récents) → C7 Détail du candidat (message, skills, CV joint,
  avis, Signaler ou bloquer, Refuser / Accepter) · C8 Suggestions ("Inviter à postuler") · C9 Noter le candidat ✱.
- C2 Vérification (steps, upload "justificatif d'activité", badge preview).

**Shared:** D1 Notifications · D2 Réglages (langue, profil, disponibilités, notification toggles, aide,
confidentialité, CGU, déconnexion, supprimer le compte) · D3 Contact révélé · D4 Signaler / bloquer (bottom
sheet, anonymous, reasons, block toggle) · D5 Aide / Confidentialité / CGU ✱ (tabs, FAQ, contact form) ·
D6 DebrJournya Plus (placeholder).

**Reusable states (F):** Aucun résultat · Fil vide · Chargement (skeleton) · Erreur avec réessai · Pas de
connexion · Succès · Autorisation notifications · Autorisation position. Build these once as shared widgets.

**Not designed yet (must be designed in the existing style before/while building):** C10 mark shift
completed/no-show · student "Profil" tab hub · employer "Candidats", "Alertes", "Entreprise" tabs · employer
onboarding step 2 · public employer page (tap employer card in B7) · edit post · weekly availability grid
(see §9) · sponsored feed card.

## 6. Localisation (FR + AR)

- Use `flutter_localizations` + ARB files (`lib/core/l10n/app_fr.arb`, `app_ar.arb`), French as template.
  **No hard-coded user-facing strings** in widgets.
- **All designs are in French; Claude writes the Arabic strings.** Use Modern Standard Arabic, natural and
  short (not word-for-word), consistent terminology. Keep a glossary in `app_ar.arb` descriptions for key
  terms: Job → وظيفة, Mission → مهمة, Événement → فعالية, Bénévolat → تطوع, Candidature → طلب / ترشّح,
  Postuler → قدّم طلبك, Match % → نسبة التوافق, Non rémunéré → غير مدفوع. Revise the glossary here if changed.
- Arabic is RTL: rely on `Directionality`; use `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `start/end` — never `left/right` for layout. Mirror directional icons (back/chevrons), not logos/media.
  Numbers: Western digits (0–9) in both languages; currency "DA" (FR) / "دج" (AR).
- The A3 Arabic card already shows target style: «العربية» / «التطبيق كاملاً بالعربية، من اليمين إلى اليسار.»
- French copy uses informal "tu". Design copy is feminine for the sample user ("acceptée", "Ponctuelle") —
  gender handling is an open question (§9); until decided, prefer neutral phrasing.

## 7. Design system (tokens measured from the mockups and the mascot file)

Mockups are 390 pt wide (exported @2x = 780 px). Style: calm, rounded, flat cards with thin borders, pill chips.

| Token | Light | Dark |
|---|---|---|
| background | `#FAF8F2` | `#0E1412` |
| surface / card | `#FFFFFF` | `#161E1B` |
| border / line | `#E9E5DA` | subtle lighter-than-card line |
| text primary (ink) | `#111414` | `#E8E4D8` (approx.) |
| text secondary (ink2) | `#3E4544` | muted grey-green |
| primary button bg | `#2D3536` (soot) | `#A3B8A9` (sage) with dark text |
| moss (brand "Journya", progress) | `#697C70` | — |
| eucalyptus (match pill, active nav, FR tile) | `#98AA9D` | darker green tint |
| mist (blue accents, unpaid tag, AR tile) | `#B3C9D6` | slate blue `#3A4A5A`-ish |
| plaster (chips/neutral fills) | `#F2EFE2` / `#EFECE3` | — |
| danger / urgent / report | `#B5533C` | `#B5533C` |
| danger soft bg (Refusée, error box) | `#F6E4DE` | dark red tint |
| info soft bg (Envoyée, info banners) | `#E7EFF3` | dark blue tint |
| mascot body | `#5F8069` | same |

- Radii ≈ cards 24, inputs/buttons 16–20, chips fully rounded, icon tiles 16–20. Buttons ~52 pt tall, full width.
- Typography: geometric sans; looks like **Manrope** (Latin). Arabic font not specified — pick a matching one
  (e.g. IBM Plex Sans Arabic / Noto Sans Arabic); bundle only needed weights (size budget). Confirm and record here.
- Brand wordmark: "Debr" in ink + "Journya" in moss, bold.
- Dark mode is a faithful mirror of light; primary action colour flips from soot to sage.
- Note mock glitch to ignore: D2 toggles render on their own rows — put them trailing on each tile.

## 8. Mascot "Jobby" (animated logo)

`Docs/design/mascot/pro (2).jsx` is a React canvas prototype of the animated logo, variant **"Jobby Pro"**:
a green briefcase (`#5F8069`, plastic shading) with a handle, dashed stitching (`rgba(255,255,255,.35)`), round
glasses, a smile, a soot bow tie, and a notepad (soot top strip, mist ruled lines) with a pen that scribbles.
No metal parts. Pad on the left.

- Geometry (0–100 box): body `M14 34 H86 Q95 34 95 43 V77 Q95 86 86 86 H14 Q5 86 5 77 V43 Q5 34 14 34 Z`;
  handle `M37 37 V27 Q37 19 45 19 H55 Q63 19 63 27 V37 H57.5 V28.5 Q57.5 25 54 25 H46 Q42.5 25 42.5 28.5 V37 Z`
  (drawn behind the body); stitching rect (10,39,80,42) r6; face centre (50,55) scale 0.95; notepad at
  (50−36, 78) rotated +0.22 rad, 25×30.
- States: `default` (au repos, idle bob/blink), `working` (prend des notes — pen writes, line grows),
  `sleeping` (endormi). Tap = "poke" → jump. Supports light/dark theme.
- **Body, face, glasses, bow tie and the pose simulation come from an external `bot-avatars` library that
  is NOT in the repo** (`BotAvatarSim`, `drawBotAvatarFrame`, `autoInk`). The Flutter port must re-create
  them: implement as a `CustomPainter` + `AnimationController` (`features/mascot/jobby.dart`), driving a
  small pose model (x/y offset, squash sx/sy, roll, yaw/pitch, blink, writing weight). Approximate the look
  from A1 Splash; keep it lightweight (no Rive/Lottie unless we decide to).
- Usage: A1 splash (large, `working` or `default`), onboarding header & A4 (small static), possibly empty states.

## 9. Decisions log & open questions

**Decided (2026-11-27):**
- Flutter project lives at the repo root; Android only; package `debrjournya`, org `com.debrjournya`.
- `pro (2).jsx` is the animated logo/mascot → port to Flutter (§8).
- Arabic: Claude writes all Arabic strings (§6).
- Where design and spec differ on merged screens, follow the **design** (B11, B14, C5, C9, D5 are separate) —
  *proposed, confirm.*
- Order: language choice (A3) **before** onboarding (A2) — *proposed, confirm.*

**Open (ask / confirm before building the affected part):**
1. **Availability calendar (F3):** spec requires a 7 days × 4 slots grid (matin 8–12, après-midi 12–17,
   soir 17–22, nuit 22–6) + date exceptions (exams/holidays). Design B3 only has 4 preferred moments.
   Matching needs per-day slots. Add a grid screen (onboarding step and/or D2 "Mes disponibilités")?
2. **CV contact leak:** E3 CV shows phone + email and is attached to applications before acceptance —
   conflicts with contact-reveal rule. Proposed: omit contact details from the attached CV.
3. **Geography:** mockups use Batna + city list; spec says Algiers (+ Koléa) with commune-level location.
4. **Missing screens** listed in §5 — who designs them?
5. **CV templates:** spec says one template; design has Moderne + Classique, FR/AR, multiple saved CVs.
6. **Premium / Boost / ads (F13, F15):** out of v1 except server flags and D6 placeholder?
7. **Roles:** one account with both roles + switcher, or locked at sign-up for v1?
8. **Gendered French copy:** ask gender in profile, or neutral wording?
9. Minor: "Urgent" tag has no field in C3; is "Temps plein / Avec contrat" a real filter; reminder timing
   (2h vs veille + 2h); Arabic font choice; state-management/routing packages (§4).
10. **Milestone target:** Sprint 1 due Thu 10 Dec 2026 (private beta, F10 notifications, F11 report/block);
    final submission Fri 8 Jan 2027 (all Must features F1–F11).

## 10. Working conventions

- Run `flutter analyze` and `flutter test` before saying something is done; report failures honestly.
- Build shared UI components (buttons, chips, cards, inputs, status pills, empty states, bottom nav) in
  `lib/core/widgets/` first and reuse them; match the mockups pixel-close in both themes and both directions.
- Every screen must work in FR + AR and light + dark; check RTL on each new screen.
- Prefer small, focused commits. Don't commit secrets. Branch off `main` for features.
- When the spec and the design disagree, don't silently pick one: check §9, and ask if it isn't decided.
