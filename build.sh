#!/bin/sh
# Packs the channel, ready to upload on the Roku's Development Application
# Installer page.
#
#   ./build.sh        dist/Meowbox.zip          the television alone (tiny; needs only zip)
#   ./build.sh all    dist/Meowbox-Playlet.zip  the television and the Playlet fork behind one
#                                               front door (needs Node 22; run "npm ci" in playlet/ once)
set -e
cd "$(dirname "$0")"
mkdir -p dist

if [ "$1" != "all" ]; then
    rm -f dist/Meowbox.zip
    (cd roku && zip -q -r -X -9 ../dist/Meowbox.zip manifest source components images fonts)
    echo "Built dist/Meowbox.zip"
    exit 0
fi

# 1. Playlet: the web app it serves, its library, then the shell that loads the library
#    (REPACK=1 skips this and reuses the last build: handy after changing only Meowbox)
if [ -z "$REPACK" ]; then
    (cd playlet && npm run build:web)
    (cd playlet/playlet-lib && node ../tools/rm.js ../build/playlet-lib && npx bsc --create-package --sourceMap=false --lintConfig ../config/bslint.jsonc)
    mkdir -p playlet/playlet-app/src/lib
    cp playlet/dist/playlet-lib.zip playlet/playlet-app/src/lib/playlet-lib.zip
    (cd playlet/playlet-app && node ../tools/rm.js ../build/playlet-app && npx bsc --create-package --sourceMap=false --lintConfig ../config/bslint.jsonc)
fi

# 2. Meowbox moves in beside it. Its code is plain BrightScript and is copied as
#    it stands; Playlet's shell finds the front door (MeowHub) by name at start-up.
stage=playlet/build/playlet-app
cp roku/source/broadcast.brs roku/source/captions.brs roku/source/engine.brs roku/source/logo.brs roku/source/net.brs "$stage/source/"
for c in BroadcastTask CaptionTask MeowRow MeowTV PixelLogo; do
    cp "roku/components/$c.xml" "roku/components/$c.brs" "$stage/components/"
done
mkdir -p "$stage/components/meowbox" "$stage/fonts"
cp roku/hub/MeowHub.xml roku/hub/MeowHub.brs "$stage/components/meowbox/"
sed -i "s|@BUILD@|built $(date -u '+%b %-d, %H:%M') UTC|" "$stage/components/meowbox/MeowHub.xml"
cp roku/fonts/* "$stage/fonts/"
cp roku/images/*.png "$stage/images/"

# 3. One name, one tile, one splash on the home screen
sed -i \
    -e 's|^title=.*|title=Meowbox|' \
    -e 's|^mm_icon_focus_fhd=.*|mm_icon_focus_fhd=pkg:/images/icon_focus_fhd.png|' \
    -e 's|^mm_icon_focus_hd=.*|mm_icon_focus_hd=pkg:/images/icon_focus_hd.png|' \
    -e '/^mm_icon_focus_sd=/d' \
    -e 's|^splash_screen_fhd=.*|splash_screen_fhd=pkg:/images/splash_fhd.png|' \
    -e 's|^splash_screen_hd=.*|splash_screen_hd=pkg:/images/splash_hd.png|' \
    -e '/^splash_screen_sd=/d' \
    -e 's|^splash_color=.*|splash_color=#120E1F|' \
    -e 's|^splash_min_time=.*|splash_min_time=800|' \
    "$stage/manifest"
rm -f "$stage"/images/channel-poster_*.png "$stage"/images/splash-screen_*.jpg

rm -f dist/Meowbox-Playlet.zip
(cd "$stage" && zip -q -r -X -9 "$OLDPWD/dist/Meowbox-Playlet.zip" manifest source components images fonts lib)
echo "Built dist/Meowbox-Playlet.zip"
