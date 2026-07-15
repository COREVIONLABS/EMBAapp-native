#!/bin/bash
cd "$(dirname "$0")" || exit 1
echo "Ordner: $(pwd)"
rm -f .git/*.lock .git/refs/heads/*.lock 2>/dev/null
if [ ! -d .git ]; then git init -q; git branch -M main; fi
git remote remove origin 2>/dev/null
git remote add origin git@github.com:COREVIONLABS/EMBAapp-native.git
git add -A
git commit -q -m "Flutter gamification prototype: Home + Daily Spin + Scratch Card" || echo "(nichts Neues)"
echo "Lade zu GitHub hoch..."
git push -u origin main --force
echo ""
echo "==== Wenn oben KEIN Fehler steht, ist der Upload durch. ===="
echo "Danach: github.com/COREVIONLABS/EMBAapp-native -> 'Actions' -> APK herunterladen."
echo "Fenster kann geschlossen werden."
read -n 1 -s
