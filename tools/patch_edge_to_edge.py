#!/usr/bin/env python3
"""Patch the freshly generated Android theme for true edge-to-edge system bars.

`flutter create` regenerates android/ on every CI build with the default
Flutter theme, which keeps an opaque status-bar background and lets Android
draw a contrast scrim (the grey band). This rewrites styles.xml (light + dark)
so both system bars are transparent and no contrast scrim is enforced — the
app background then runs seamlessly under the status and navigation bars.
"""
import os

TEMPLATE = """<?xml version="1.0" encoding="utf-8"?>
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
    </style>
</resources>
"""

BASE = "android/app/src/main/res"
targets = {
    f"{BASE}/values/styles.xml": "Theme.Light.NoTitleBar",
    f"{BASE}/values-night/styles.xml": "Theme.Black.NoTitleBar",
}

for path, parent in targets.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(TEMPLATE.format(parent=parent))
    print(f"wrote {path} ({parent})")
