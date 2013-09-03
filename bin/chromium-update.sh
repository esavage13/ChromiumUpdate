#!/usr/bin/env bash

# Update Chromium (on OS X) to the latest nightly build. 

base_url='http://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac'
build=$(curl -s -f ${base_url}/LAST_CHANGE)

install_dir=/Applications/Chromium.app
if test -f ${install_dir}/Contents/Info.plist ; then
    # installed=$(/usr/libexec/PlistBuddy -c 'Print :SVNRevision' ${install_dir}/Contents/Info.plist)
    version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" /Applications/Chromium.app/Contents/Info.plist)
    installed=$(/usr/libexec/PlistBuddy -c "Print :SCMRevision" /Applications/Chromium.app/Contents/Info.plist)
else
    version="unknown"
    installed=0
fi
script=$(basename $0)

topdir=$(dirname $0)
snapshots=$topdir/snapshots
temp=$topdir/temp

notice () {
    echo $(tput setaf 7)[$(tput setaf 4)${script}$(tput setaf 7)]$(tput sgr0) $@
}

do_upgrade () {
    zipfile="$snapshots/chrome-${build}.zip"
    if test ! -d $snapshots ; then
        mkdir -p $snapshots
    fi
    curl -# -A "Mozilla/5.0" -L -e ";auto" "${base_url}/${build}/chrome-mac.zip" -o $zipfile

    if test -d $temp ; then
        rm -rf $temp
        mkdir -p $temp
    fi

    unzip -q -x $zipfile -d $temp 
    new_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" $temp/chrome-mac/Chromium.app/Contents/Info.plist)
    new_revision=$(/usr/libexec/PlistBuddy -c "Print :SCMRevision" $temp/chrome-mac/Chromium.app/Contents/Info.plist)

    pid=$(ps aux | grep '[C]hromium' | awk '{print $2}')
    if test ! -z "$pid" ; then
        kill $pid
        sleep 2
    fi
    if test -d ${install_dir} ; then
        rm -rf ${install_dir} &>/dev/null
    fi
    mv $temp/chrome-mac/Chromium.app /Applications
    rm -rf $temp

    notice "Upgraded to $new_version ($new_revision)"
}

if [[ "${installed}" -ge "${build}" ]]; then
    notice "You're running the latest build: $version (${installed})."
    exit 1
else
    notice "Upgrading to ${build}; you have $version (${installed})..."
    do_upgrade
fi

# vim: cindent cinkeys-=0#
