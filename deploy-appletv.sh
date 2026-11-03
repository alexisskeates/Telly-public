#!/bin/bash
# Build Telly signed with the Fourth Floor team and install it on a paired Apple TV.
# Usage: ./deploy-appletv.sh            (auto-picks the first paired Apple TV)
#        ./deploy-appletv.sh <UDID>     (specific device)
set -euo pipefail
cd "$(dirname "$0")"

UDID="${1:-$(cat .appletv-udid 2>/dev/null || true)}"  # put your Apple TV UDID in .appletv-udid (untracked)
if [ -z "$UDID" ]; then
  echo "No paired Apple TV found. Pair it first: Apple TV Settings > Remotes and Devices > Remote App and Devices, then Xcode > Window > Devices and Simulators > Pair." >&2
  exit 1
fi
echo "Target Apple TV: $UDID"

xcodebuild -project Telly.xcodeproj -scheme Telly -configuration Release \
  -destination "id=$UDID" -derivedDataPath build/signed \
  -allowProvisioningUpdates -allowProvisioningDeviceRegistration build

APP=build/signed/Build/Products/Release-appletvos/Telly.app
xcrun devicectl device install app --device "$UDID" "$APP"
xcrun devicectl device process launch --device "$UDID" com.fourthfloor.Telly
echo "Telly installed and launched."
