#!/usr/bin/env python3
"""Patch the freshly generated Android project for true edge-to-edge system bars.

`flutter create` regenerates android/ on every CI build with the default
Flutter theme, which keeps an opaque status-bar background and lets Android
draw a contrast scrim (the grey band / hairline). Two layers fix it:

1. styles.xml (light + dark): transparent system bars, no contrast enforced,
   correct icon brightness before Flutter draws.
2. MainActivity.kt: the same, applied *programmatically* at runtime. OEM skins
   (Xiaomi/MIUI, Samsung One UI, …) frequently ignore the theme-level flags and
   keep a status-bar scrim/divider — forcing it in code is the only reliable fix.
"""
import os

STYLES_TEMPLATE = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/{parent}">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/{parent}">
        <item name="android:windowBackground">?android:colorBackground</item>
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/transparent</item>
        <item name="android:windowDrawsSystemBarBackgrounds">true</item>
        <item name="android:enforceStatusBarContrast">false</item>
        <item name="android:enforceNavigationBarContrast">false</item>
        <item name="android:windowLightStatusBar">{light_icons}</item>
        <item name="android:windowLightNavigationBar">{light_icons}</item>
    </style>
</resources>
"""

BASE = "android/app/src/main/res"
style_targets = {
    f"{BASE}/values/styles.xml": ("Theme.Light.NoTitleBar", "true"),   # light UI -> dark icons
    f"{BASE}/values-night/styles.xml": ("Theme.Black.NoTitleBar", "false"),  # dark UI -> light icons
}

for path, (parent, light_icons) in style_targets.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(STYLES_TEMPLATE.format(parent=parent, light_icons=light_icons))
    print(f"wrote {path} ({parent}, windowLightStatusBar={light_icons})")

# ── Programmatic edge-to-edge (OEM-proof) ───────────────────────────────
# Package/path follow the workflow's `flutter create --org de.schalke04
# --project-name emba_app`, i.e. package de.schalke04.emba_app.
PKG = "de.schalke04.emba_app"
MAIN_ACTIVITY = f"android/app/src/main/kotlin/{PKG.replace('.', '/')}/MainActivity.kt"

MAIN_ACTIVITY_SRC = f"""package {PKG}

import android.graphics.Color
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {{
    override fun onCreate(savedInstanceState: Bundle?) {{
        super.onCreate(savedInstanceState)
        // Keep the system bars fully transparent with no contrast scrim —
        // reinforced here because OEM skins (MIUI, One UI, …) ignore the
        // theme-level flags and keep a status-bar divider otherwise. Flutter's
        // edge-to-edge mode already lays content out behind the bars.
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.TRANSPARENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {{
            window.isStatusBarContrastEnforced = false
            window.isNavigationBarContrastEnforced = false
        }}
    }}
}}
"""

os.makedirs(os.path.dirname(MAIN_ACTIVITY), exist_ok=True)
with open(MAIN_ACTIVITY, "w") as f:
    f.write(MAIN_ACTIVITY_SRC)
print(f"wrote {MAIN_ACTIVITY}")
