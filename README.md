# EMBA / FC Schalke 04 — Fan App (Flutter)

Native Flutter fan app implementing the **FC Schalke Club App** Figma design
1:1 (`figma.com/design/l3xCU8r7RoR8l9EBmeZCWR`). Builds on the original EMBA
gamification prototype (real spin wheel + finger-scratch card) and extends it
into the full app.

## Design system

- **Font:** Urbanist (the design font), bundled as font files in
  `assets/fonts/` (weights 400/500/600/700/800) — no runtime download.
- **Tokens** in `lib/theme/app_theme.dart`: Schalke blue `#004B9C`, gold accent
  gradient, Urbanist type scale, radii — extracted from the Figma variables.
- **Real assets** exported from Figma into `assets/icons/` (SVG): S04 crest,
  bell, arrows, 5 bottom-nav icons. `lib/widgets/asset_img.dart` renders raster
  illustrations from `assets/images/<name>.png` when present, with a branded
  fallback otherwise.

## Screens (`lib/screens/`)

- **Auth / onboarding:** Splash, Onboarding (Earn Points / Redeem Rewards /
  Exclusive Experiences), Log In, Sign Up.
- **Home — Matchday** (pixel-accurate 1:1).
- **Tabs:** Wallet, Points (History / Missions), Fan+ (subscription tiers),
  Profile (+ settings menu). Floating bottom-nav shell in `lib/main_shell.dart`.
- **Feature screens:** Redeem / Rewards, Daily Spin, Scratch Card (real
  finger-scratch), Predictions (predict score + past results), Notifications.
- **Detail:** Edit Profile, Notification Preferences, Language, Data Sharing,
  Marketing Consent, Device Management, Biometric, Privacy Policy, Manage Cards,
  Bank Account, Upgrade Plan.

## Run

```bash
flutter pub get
flutter run -d chrome        # web
flutter run -d <device>      # android device
```

## Build the APK (GitHub Actions)

Every push triggers `.github/workflows/build-apk.yml`, which runs
`flutter build apk --release` on a GitHub runner (org `de.schalke04`, project
`emba_app`) and uploads the artifact.

1. Push to GitHub (this branch, or via `push-to-github.command`).
2. **Actions** tab → run **“Build APK”** → wait ~5–8 min.
3. Download the **`emba-app-apk`** artifact → install on device.

The `android/` folder is generated during the build (`flutter create`), so it is
not committed.

## Pending

Some pure state-variants (Home Non-Matchday, reward states) and the raster 3D
illustrations (Daily Spin/Scratch/Rewards/trophy art, player photos) are a
follow-up Figma-export pass; the code already consumes them via `AssetImg`.
