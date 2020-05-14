#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}/../"
rm -drf docs/*

echo "Creating API Docs for the SDK"

jazzy   --readme ./README.md \
        --github_url https://github.com/LittleGreenViper/Magic8Ball \
        --title Magic8Ball\ Public\ API\ Doumentation \
        --theme fullwidth \
        --exclude=/*/internal* \
        --min_acl public \
        --build-tool-arguments -scheme,"ITCB_SDK_Mac (Framework)"
cp img/*.* docs/img/

cd "${CWD}"
