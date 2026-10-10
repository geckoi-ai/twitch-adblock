#!/usr/bin/env bash
# Pack the shippable extension zip: manifest.json, src/ (debug popup included), icons/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$ROOT/manifest.json")"
OUT="${1:-$ROOT/twitch-adblock-${VERSION}.zip}"

REQUIRED=(manifest.json src/popup.html src/popup.js src/debug.js src/debug-bridge.js src/vendor/video-swap-new.user.js src/vendor/LICENSE-TwitchAdSolutions src/youtube.js src/rules/general-network.json src/rules/meta.json src/rules/LICENSES.md icons/icon16.png icons/icon48.png icons/icon128.png)
for r in "${REQUIRED[@]}"; do
  [[ -f "$ROOT/$r" ]] || { echo "Missing $r"; exit 1; }
done
if [[ -f "$ROOT/popup.html" || -f "$ROOT/popup.js" ]]; then
  echo "Refuse to pack: the popup lives in src/ (zip holds manifest.json, src/, icons/ only)"
  exit 1
fi

TMP="$(mktemp -d /tmp/adblock-pack.XXXXXX)"
mkdir -p "$TMP/src/vendor" "$TMP/src/rules" "$TMP/icons"
cp "$ROOT/manifest.json" "$TMP/"
cp "$ROOT/src/popup.html" "$ROOT/src/popup.js" "$ROOT/src/debug.js" "$ROOT/src/debug-bridge.js" "$ROOT/src/youtube.js" "$TMP/src/"
cp "$ROOT/src/vendor/video-swap-new.user.js" "$ROOT/src/vendor/LICENSE-TwitchAdSolutions" "$ROOT/src/vendor/README.md" "$TMP/src/vendor/"
cp "$ROOT/src/rules/general-network.json" "$ROOT/src/rules/meta.json" "$ROOT/src/rules/LICENSES.md" "$ROOT/src/rules/README.md" "$TMP/src/rules/"
# Optional cosmetic sample for the cosmetic agent (shipped when present).
if [[ -f "$ROOT/src/rules/cosmetic-sample.json" ]]; then
  cp "$ROOT/src/rules/cosmetic-sample.json" "$TMP/src/rules/"
fi
cp "$ROOT/icons/icon16.png" "$ROOT/icons/icon48.png" "$ROOT/icons/icon128.png" "$TMP/icons/"

rm -f "$OUT"
(cd "$TMP" && zip -qr "$OUT" manifest.json src icons)
rm -rf "$TMP"

echo "Wrote $OUT"
unzip -l "$OUT"
