#!/bin/bash
#
# (Above line comes out when placing in Xcode scheme)
# Taken from Justin Miller (http://developmentseed.org/blog/2011/sep/02/automating-development-uploads-testflight-xcode/)
# Place in Xcode Scheme's Archive Post-actions


############################################
# Modify these variables with your own

# Upload API token, from Testflight site (https://testflightapp.com/account/#api)
API_TOKEN="__YOUR_API_TOKEN__"

# Team token, from Testflight site (https://testflightapp.com/dashboard/team/edit/)
TEAM_TOKEN="__YOUR_TEAM_TOKEN__"

# Signing identity name (can be taken from Xcode), usually looks like:
#	iPhone Distribution: Carlin Yuen (ABCDEFG)
SIGNING_IDENTITY="__YOUR_SIGNING_IDENTITY__"

# Path to provisioning profile, recommend putting in this dir, but can be custom
PROVISIONING_PROFILE="${HOME}/Library/MobileDevice/Provisioning Profiles/__YOUR_PROVISIONING_PROFILE__.mobileprovision"

# Url to open in browser after upload is complete
DONE_URL="https://testflightapp.com/dashboard/builds/"

#LOG="/tmp/testflight.log"	# Uncomment to get log file


##############################################
# Generally don't have to modify after here

DATE=$( /bin/date +"%Y-%m-%d" )
ARCHIVE=$( /bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${DATE}" | /usr/bin/grep xcarchive | /usr/bin/sed -n 1p )
DSYM="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/dSYMs/${PRODUCT_NAME}.app.dSYM"
APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PRODUCT_NAME}.app"

if [ -n "$LOG" ]; then
	/usr/bin/open -a /Applications/Utilities/Console.app $LOG
	echo -n "Creating .ipa for ${PRODUCT_NAME}... " > $LOG
fi

/bin/rm "/tmp/${PRODUCT_NAME}.ipa"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "/tmp/${PRODUCT_NAME}.ipa" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE}"

if [ -n "$LOG" ]; then
	echo "done." >> $LOG
	echo -n "Zipping .dSYM for ${PRODUCT_NAME}..." >> $LOG
fi

/bin/rm "/tmp/${PRODUCT_NAME}.dSYM.zip"
/usr/bin/zip -r "/tmp/${PRODUCT_NAME}.dSYM.zip" "${DSYM}"

if [ -n "$LOG" ]; then
	echo "done." >> $LOG
	echo -n "Uploading to TestFlight... " >> $LOG
fi

/usr/bin/curl "http://testflightapp.com/api/builds.json" \
  -F file=@"/tmp/${PRODUCT_NAME}.ipa" \
  -F dsym=@"/tmp/${PRODUCT_NAME}.dSYM.zip" \
  -F api_token="${API_TOKEN}" \
  -F team_token="${TEAM_TOKEN}" \
  -F notes="Build uploaded automatically from Xcode."

if [ -n "$LOG" ]; then
	echo "done." >> $LOG
	echo "Opening browser to $DONE_URL" >> $LOG
fi
/usr/bin/open "$DONE_URL"
