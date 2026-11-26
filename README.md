# DebrJournya

*Le job qui s'adapte à ton emploi du temps.*  
*The job that fits your schedule.*

DebrJournya is an Android app, built with Flutter, that connects Algerian students with flexible work: part-time jobs, single shifts, and paid or unpaid events and volunteering. A student sets their weekly availability once, then finds opportunities that fit their timetable. Employers such as cafés, shops, associations and event organisers post what they need and choose from the people who are available.

The app is in Arabic and French, and starts in Algiers.

## Why

Students need extra income and experience around a timetable that changes through the year. Employers need people at short notice. Today this happens in Facebook and Instagram groups, where offers rarely state pay, schedule or location, can't be filtered, and give no recourse when something goes wrong. DebrJournya gives both sides one structured, trustworthy place to find each other.

## What it does

- **For students:** a profile and weekly availability calendar, one place to browse jobs, shifts and volunteering events, simple applications with status tracking, and a CV built from the student's profile.
- **For employers:** post an opening, review applicants and accept the right person.
- **For both:** clear pay and schedule on every post, contact details shared only once an application is accepted, and reporting tools to keep the platform safe.

The app is free for both sides. A Premium plan and advertising are planned for a later stage. Everything is described in the product specification.

## Documentation

| Document | What it covers |
|---|---|
| [Product Specification & Business Plan](docs/DebrJournya_Product_Specification_and_Business_Plan.pdf) | Problem, vision, users, competition, features, business model, marketing, risks, team and milestones |
| [UI/UX designs](docs/design) | 52 screens in light and dark mode, with Arabic right-to-left layouts |
| [Jobby, the mascot](docs/mascot) | The briefcase mascot used across the app |

## Tech stack

- **App:** Flutter (Dart), Android first
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Notifications:** Firebase Cloud Messaging

## Getting started

You need the Flutter SDK, an Android device or emulator, and a Supabase project.

```bash
git clone <repo-url>
cd <repo-folder>
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Never commit your keys.

## Team

- Lydia Ranim BADRI (Team Leader)
- Moussab Abderrahmane KHELAS
- Bachir GUENOUA

Built at the National Higher School of Artificial Intelligence (ENSIA), Algiers.

## License

To be decided.
