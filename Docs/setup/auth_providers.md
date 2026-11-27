# Sign-in setup (Supabase project DebrJournya)

Project ref: `owqidxoazgcndjlcnano` · Dashboard: https://supabase.com/dashboard/project/owqidxoazgcndjlcnano

Values used below:

| Name | Value |
|---|---|
| Supabase callback URL | `https://owqidxoazgcndjlcnano.supabase.co/auth/v1/callback` |
| App redirect (deep link) | `com.debrjournya.debrjournya://login-callback` |
| Android package name | `com.debrjournya.debrjournya` |

Secrets (client secrets, app secrets) go **only** into the Supabase dashboard. Never in the code, the
repo or a chat.

---

## 1. E-mail + password with a 6-digit code (Supabase only)

1. **Authentication → Sign In / Providers → Email**: Enable Email provider ✅, Confirm email ✅,
   Email OTP length **6**. Save.
2. **Authentication → Emails → Templates → "Confirm signup"**: replace the body with a code
   (the app asks for the code, it doesn't open links):
   ```html
   <h2>Ton code DebrJournya</h2>
   <p>Entre ce code dans l'application pour confirmer ton adresse :</p>
   <p style="font-size:28px;font-weight:700;letter-spacing:6px">{{ .Token }}</p>
   <p>رمز التأكيد الخاص بك: <b>{{ .Token }}</b></p>
   ```
   Subject: `Ton code DebrJournya : {{ .Token }}`
3. Same for **"Reset password"** (subject `Réinitialise ton mot de passe : {{ .Token }}`, body with
   `{{ .Token }}`).
4. **Authentication → URL Configuration → Redirect URLs**: add
   `com.debrjournya.debrjournya://login-callback`.

**Until the templates show `{{ .Token }}`** (custom SMTP needed first), e-mails hold the default
*link*. The app handles it: sign-up / resend / reset pass `redirectTo =
com.debrjournya.debrjournya://login-callback`, so opening the link **on the phone** returns to the app,
which signs the user in (sign-up → A6 or home; reset → "Nouveau mot de passe"). The code screen says so
("Tu as reçu un lien plutôt qu'un code ?"). Opening the link on a computer won't work (the sign-in is
tied to the phone that asked for it).

Note: Supabase's built-in e-mail sender only sends a few e-mails per hour and is meant for testing.
Before the beta, set a custom SMTP (Authentication → Emails → SMTP Settings), e.g. Resend or Brevo
(free tiers).

---

## 2. Google

### a. Google Cloud project
1. Go to https://console.cloud.google.com/ → project picker → **New project** → name `DebrJournya` → Create.
2. **APIs & Services → OAuth consent screen** (also called "Google Auth Platform → Branding"):
   - App name `DebrJournya`, support e-mail = your e-mail, logo optional.
   - Audience: **External**. While "Testing", only the test users you add can sign in → add your
     Gmail and your testers' Gmail under **Audience → Test users**.
   - Authorized domains: add `supabase.co`.
   - Scopes: `openid`, `.../auth/userinfo.email`, `.../auth/userinfo.profile` (defaults).
3. **APIs & Services → Credentials → Create credentials → OAuth client ID**:
   - Application type: **Web application** (yes, Web — the sign-in happens through Supabase's page).
   - Name: `DebrJournya Supabase`.
   - Authorized redirect URIs: `https://owqidxoazgcndjlcnano.supabase.co/auth/v1/callback`
   - Create → copy the **Client ID** and **Client secret**.

### b. Supabase
**Authentication → Sign In / Providers → Google**: Enable ✅, paste Client ID and Client secret, Save.

### c. Going public (later)
In the consent screen, **Publish app**. With only email/profile scopes Google doesn't need a long review.

---

## 3. Facebook (postponed — the button is hidden by `Features.facebookLogin = false` in
`lib/core/config/features.dart`; set it to `true` once the Meta app is set up)

### a. Meta developer app
1. Go to https://developers.facebook.com/ → log in → **My Apps → Create App**.
2. Use case: **Authenticate and request data from users with Facebook Login** → Next.
3. App name `DebrJournya`, contact e-mail → Create (confirm your password).
4. **Use cases → Facebook Login → Customize → Settings**:
   - Valid OAuth Redirect URIs: `https://owqidxoazgcndjlcnano.supabase.co/auth/v1/callback`
   - Save.
5. **Use cases → Facebook Login → Customize → Permissions**: make sure **email** and
   **public_profile** are added (click "Add" next to email).
6. **App settings → Basic**: copy the **App ID** and **App Secret** (click "Show").
   Also fill **Privacy Policy URL** (any page you control for now) and **Category** — needed to go Live.

### b. Supabase
**Authentication → Sign In / Providers → Facebook**: Enable ✅, Client ID = App ID, Secret = App
Secret, Save.

### c. Testers and going Live
- While the app is in **Development** mode, only people with a role on the app can sign in:
  **App roles → Roles → Add People** (as Testers) — they must accept the invite.
- To let everyone sign in: switch the app to **Live** (top of the dashboard). For `email` +
  `public_profile` no App Review is needed, but Meta asks for the privacy policy URL, an app icon and,
  for some accounts, business verification.

---

## 4. Check

From the repo (no secrets needed):
```bash
URL=https://owqidxoazgcndjlcnano.supabase.co
KEY=$(python3 -c "import json;print(json.load(open('env/dev.json'))['SUPABASE_PUBLISHABLE_KEY'])")
curl -s "$URL/auth/v1/settings" -H "apikey: $KEY"   # "external": email / google / facebook → true
```
Google and Facebook sign-in return to the app through the deep link, so test them on the Android
phone (`flutter run --dart-define-from-file=env/dev.json`), not on the Linux preview.
