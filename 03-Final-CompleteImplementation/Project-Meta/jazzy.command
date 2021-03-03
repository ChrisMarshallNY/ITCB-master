#!/bin/sh
if command -v jazzy; then
    CWD="$(pwd)"
    MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
    cd "${MY_SCRIPT_PATH}/../SDK-src"

    echo "Creating Public API Docs for the SDK"

    rm -drf ../docs/api
    rm -drf ../docs/app
    rm -drf ../docs/img
    mkdir ../docs/img

    jazzy   --readme ./README.md \
            --github_url https://github.com/LittleGreenViper/ITCB \
            --title Magic8Ball\ Public\ API\ Doumentation \
            --theme fullwidth \
            --exclude=/*/internal* \
            --min_acl public \
            --output ../docs/api \
            --build-tool-arguments -scheme,"Final-ITCB_SDK_Mac (Framework)"

    echo "Creating Internal Docs for the App"

    cd "${MY_SCRIPT_PATH}/../Apps-src"

    echo "Mac App"

    jazzy   --readme ./README.md \
            --github_url https://github.com/LittleGreenViper/ITCB \
            --title Magic8Ball\ Internal\ App\ Doumentation \(Mac\) \
            --theme fullwidth \
            --min_acl private \
            --output ../docs/app \
            --build-tool-arguments -scheme,"Final-Bluetooth 8-Ball On Mac (App)"
    cp ../img/*.* ../docs/img/

    cd "${CWD}"
else
    echo "\nERROR: Jazzy is Not Installed.\n\nTo install Jazzy, make sure that you have Ruby installed, then run:\n"
    echo "[sudo] gem install jazzy\n"
fi