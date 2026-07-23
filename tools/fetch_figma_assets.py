#!/usr/bin/env python3
"""Fetch real illustration assets from Figma and save them as PNGs.

Runs at build time (e.g. in CI) where outbound network is available. Uses the
Figma REST API to render specific nodes and downloads them into assets/images/.

Requires the environment variable FIGMA_TOKEN (a Figma personal access token
from an account with at least a Dev seat on the file's team). If the token is
missing the script exits successfully without doing anything, so local/dev
builds still work (the app falls back to branded placeholders via AssetImg).

Config: tools/figma_assets.json
"""
import json
import os
import sys
import urllib.request
import urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CONFIG = os.path.join(HERE, "figma_assets.json")
API = "https://api.figma.com/v1/images/"


def log(msg):
    print(f"[figma-assets] {msg}", flush=True)


def main():
    token = os.environ.get("FIGMA_TOKEN", "").strip()
    if not token:
        log("FIGMA_TOKEN not set — skipping asset fetch (app uses fallbacks).")
        return 0

    cfg = json.load(open(CONFIG))
    file_key = cfg["fileKey"]
    out_dir = os.path.join(ROOT, cfg.get("outDir", "assets/images"))
    os.makedirs(out_dir, exist_ok=True)

    # Figma renders one scale per request, so group nodes by scale.
    by_scale = {}
    for a in cfg["assets"]:
        by_scale.setdefault(a.get("scale", 2), []).append(a)

    ok, fail = 0, 0
    for scale, assets in by_scale.items():
        ids = ",".join(a["node"] for a in assets)
        url = f"{API}{file_key}?ids={urllib.parse.quote(ids)}&format=png&scale={scale}"
        req = urllib.request.Request(url, headers={"X-Figma-Token": token})
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                data = json.load(resp)
        except Exception as e:  # noqa: BLE001
            log(f"ERROR requesting renders (scale {scale}): {e}")
            fail += len(assets)
            continue
        if data.get("err"):
            log(f"ERROR from Figma (scale {scale}): {data['err']}")
            fail += len(assets)
            continue
        images = data.get("images", {})
        for a in assets:
            img_url = images.get(a["node"])
            if not img_url:
                log(f"MISSING render for {a['name']} ({a['node']})")
                fail += 1
                continue
            dest = os.path.join(out_dir, f"{a['name']}.png")
            try:
                with urllib.request.urlopen(img_url, timeout=120) as r:
                    payload = r.read()
                with open(dest, "wb") as f:
                    f.write(payload)
                log(f"saved {a['name']}.png ({len(payload)} bytes, scale {scale})")
                ok += 1
            except Exception as e:  # noqa: BLE001
                log(f"ERROR downloading {a['name']}: {e}")
                fail += 1

    log(f"done — {ok} saved, {fail} failed")
    # Never fail the build over assets; fallbacks cover the gap.
    return 0


if __name__ == "__main__":
    sys.exit(main())
