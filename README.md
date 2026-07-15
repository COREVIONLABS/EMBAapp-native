# EMBA Fan App — nativer Prototyp (Flutter)

Erster funktionaler Prototyp der Gamification-Schleife (echter Code, keine Bilder):

- **Home** mit hochzählenden Fan-Points und echter Tab-Navigation
- **Daily Spin** — echtes, physikalisch abbremsendes Glücksrad; Gewinn wird gutgeschrieben
- **Scratch Card** — mit dem Finger echt freirubbeln, darunter erscheint der Gewinn
- Punkte-Logik dahinter (Fake-Daten, kein Server)

Wallet, Fan+, Rewards, Profil sind vorerst Platzhalter.

## APK bauen (wie beim Klick-Dummy, über GitHub)
1. Neues, leeres GitHub-Repo anlegen: **EMBAapp-native** (unter COREVIONLABS).
2. Die Datei `push-to-github.command` doppelklicken — sie lädt das Projekt hoch.
3. Auf GitHub: Reiter **Actions** → Lauf „Build APK" abwarten (~5–8 Min, lädt beim
   ersten Mal Flutter + Android-SDK) → unter **Artifacts** `emba-app-apk` herunterladen.
4. APK aufs Handy, installieren.

Der Android-Ordner wird im Build automatisch von Flutter erzeugt (`flutter create`),
muss also nicht im Repo liegen.

## Nächste Ausbaustufen
Predictions, Rewards-Einlösung, Onboarding/Login, danach Backend (Supabase/Firebase)
für echte Konten und Punkte.
