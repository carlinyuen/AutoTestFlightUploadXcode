AutoTestFlightUploadXcode
=========================

A script for automatically uploading to TestFlight from Xcode once you hit Archive.
Keywords: automation, script, shell, unix, bash, xcode, testflight, beta, testing, upload.

Edited by Carlin Yuen:
 * Took out Growl, which was breaking the open url at the end.
 * Cleaned up and added some comments to better explain how to use and fill out variables.

Taken from Justin Miller's excellent [blog post](http://developmentseed.org/blog/2011/sep/02/automating-development-uploads-testflight-xcode/):

-------------------------------

The basic approach is as follows. Warning! Xcode-isms abound.

 1. Create an Archive step Post-action in your main target’s scheme.
 2. Use some shell trickery to find the latest built archive, since this doesn’t get passed to scripts.
 3. Create an .ipa from the archive.
 4. Re-codesign the .ipa for distribution.
 5. Embed the proper provisioning profile that references your testing team’s devices.
 6. Upload the .ipa to TestFlight using their upload API.
 7. Open the build page in your browser.
 8. Log everything along the way.
 9. Keep in mind that this script will end up in your scheme, which you may or may not include in version control. Mine is located in (project).xcodeproj/xcuserdata/(username).xcuserdatad, and we exclude xcuserdata from version control.

The script ends up in a place like this:
![Xcode Scheme Post-Actions Screenshot](/screenshot.jpg "Xcode Scheme Post-Actions Screenshot")

Adding an Xcode 4 scheme Archive Post-script
You can get your API token from your TestFlight account page and your team token from editing your team page. Aside from your code signing identity and provisioning profile, which could be the same across all members of your team, these are the only dynamic bits that you’d have to change for multiple developers using this script. In all likelihood, even the team token would be the same.

Once you’ve replaced those two values in the script, be sure to set the script shell to /bin/bash from the default of /bin/sh. Also be sure to select your main app target in the Provide build settings from picker so that the product and target environment variables are set properly.

Now, whenever you choose Product > Archive from Xcode, you will get an archive, then a shippable .ipa from it, it will be uploaded to TestFlight, and you will get a web page where you can set the release notes, choose testers to notify, and be on your way to testing the next great version of your app!
