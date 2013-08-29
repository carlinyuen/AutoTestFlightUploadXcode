#!/bin/bash
#
# (Above line comes out when placing in Xcode scheme)
# Taken from Justin Miller (http://developmentseed.org/blog/2011/sep/02/automating-development-uploads-testflight-xcode/)
# Place in Xcode Scheme's Archive Post-actions

API_TOKEN=5dec216d496ec840e281ecbd0c1b8db9_MTEzMTU5NTIwMTMtMDYtMjUgMTE6NTQ6MTEuOTk1MTMy
TEAM_TOKEN=aff00c3da85a641e8d712888dec36eb8_MjY1Nzc1MjAxMy0wOC0yOCAyMjoyMjo1Mi4wMzEzOTc
SIGNING_IDENTITY="iPhone Distribution: Development Seed"
PROVISIONING_PROFILE="${HOME}/Library/MobileDevice/Provisioning Profiles/MapBox Ad Hoc.mobileprovision"
#LOG="/tmp/testflight.log"
GROWL="${HOME}/bin/growlnotify -a Xcode -w"

DATE=$( /bin/date +"%Y-%m-%d" )
ARCHIVE=$( /bin/ls -t "${HOME}/Library/Developer/Xcode/Archives/${DATE}" | /usr/bin/grep xcarchive | /usr/bin/sed -n 1p )
DSYM="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/dSYMs/${PRODUCT_NAME}.app.dSYM"
APP="${HOME}/Library/Developer/Xcode/Archives/${DATE}/${ARCHIVE}/Products/Applications/${PRODUCT_NAME}.app"

#/usr/bin/open -a /Applications/Utilities/Console.app $LOG

#echo -n "Creating .ipa for ${PRODUCT_NAME}... " > $LOG
echo "Creating .ipa for ${PRODUCT_NAME}" | ${GROWL}

/bin/rm "/tmp/${PRODUCT_NAME}.ipa"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "/tmp/${PRODUCT_NAME}.ipa" --sign "${SIGNING_IDENTITY}" --embed "${PROVISIONING_PROFILE}"

#echo "done." >> $LOG
echo "Created .ipa for ${PRODUCT_NAME}" | ${GROWL}

#echo -n "Zipping .dSYM for ${PRODUCT_NAME}..." >> $LOG
echo "Zipping .dSYM for ${PRODUCT_NAME}" | ${GROWL}

/bin/rm "/tmp/${PRODUCT_NAME}.dSYM.zip"
/usr/bin/zip -r "/tmp/${PRODUCT_NAME}.dSYM.zip" "${DSYM}"

#echo "done." >> $LOG
echo "Created .dSYM for ${PRODUCT_NAME}" | ${GROWL}

#echo -n "Uploading to TestFlight... " >> $LOG
echo "Uploading to TestFlight" | ${GROWL}

/usr/bin/curl "http://testflightapp.com/api/builds.json" \
  -F file=@"/tmp/${PRODUCT_NAME}.ipa" \
  -F dsym=@"/tmp/${PRODUCT_NAME}.dSYM.zip" \
  -F api_token="${API_TOKEN}" \
  -F team_token="${TEAM_TOKEN}" \
  -F notes="Build uploaded automatically from Xcode."

#echo "done." >> $LOG
echo "Uploaded to TestFlight" | ${GROWL} -s && /usr/bin/open "https://testflightapp.com/dashboard/builds/"
