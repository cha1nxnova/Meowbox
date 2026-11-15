#!/bin/sh
# Packs the channel into dist/Meowbox.zip, ready to upload on the Roku's
# Development Application Installer page.
set -e
cd "$(dirname "$0")"
mkdir -p dist
rm -f dist/Meowbox.zip
(cd roku && zip -q -r -X -9 ../dist/Meowbox.zip manifest source components images fonts)
echo "Built dist/Meowbox.zip"
