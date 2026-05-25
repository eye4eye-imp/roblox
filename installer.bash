#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

DYLIB_URL="https://x099xkycxe.ufs.sh/f/ar75CUBjeUn9cydHFnEjAvpstXiKRe5u2TVDgxGFfJ3N07Wd"
MODULES_URL="https://x099xkycxe.ufs.sh/f/ar75CUBjeUn9xXaWrFvIpMwWQxsnHTt2V4BR3zyoFfE0AGjZ"

VERSION="$(sw_vers -productVersion | awk -F. '{print $1}')"

run_step() {
    shift
    if ! "$@"; then
        exit 1
    fi
}

main() {
    if [ -w "/Applications" ]; then
        APP_DIR="/Applications"
    else
        APP_DIR="$HOME/Applications"
        mkdir -p "$APP_DIR"
    fi

    TEMP="$(mktemp -d)"

    run_step "" bash -c "killall -9 RobloxPlayer Opiumware 2>/dev/null || true"

    for target in "$APP_DIR/Roblox.app" "$APP_DIR/Opiumware.app"; do
        [ -e "$target" ] || continue

        rm -rf "$target" 2>/dev/null || true

        if [ -e "$target" ]; then
            sudo rm -rf "$target" 2>/dev/null || true
        fi

        if [ -e "$target" ]; then
            exit 1
        fi
    done
    rm -rf ~/Opiumware/modules/LuauLSP ~/Opiumware/modules/decompiler
    rm -f ~/Opiumware/modules/update.json 2>/dev/null || true

    version="version-2f00787ab023453e"

    run_step "" bash -c "
        curl -s -L 'https://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip' -o '$TEMP/RobloxPlayer.zip' &&
        unzip -oq '$TEMP/RobloxPlayer.zip' -d '$TEMP' &&
        mv '$TEMP/RobloxPlayer.app' '$APP_DIR/Roblox.app' &&
        xattr -cr '$APP_DIR/Roblox.app' &&
        codesign --remove-signature '$APP_DIR/Roblox.app/Contents/MacOS/RobloxPlayer'
    "

    run_step "" bash -c "
        curl -s -L '$DYLIB_URL' -o '$TEMP/lib.zip' &&
        unzip -oq '$TEMP/lib.zip' -d '$TEMP' &&
        mv '$TEMP/libOpiumware.dylib' '$APP_DIR/Roblox.app/Contents/Resources/libOpiumware.dylib' &&

        curl -s -L '$MODULES_URL' -o '$TEMP/modules.zip' &&
        unzip -oq '$TEMP/modules.zip' -d '$TEMP' &&

        '$TEMP/Resources/Injector' \
            '$APP_DIR/Roblox.app/Contents/Resources/libOpiumware.dylib' \
            '$APP_DIR/Roblox.app/Contents/MacOS/libmimalloc.3.dylib' \
            --strip-codesig --all-yes >/dev/null 2>&1 &&

        mv '$APP_DIR/Roblox.app/Contents/MacOS/libmimalloc.3.dylib_patched' \
           '$APP_DIR/Roblox.app/Contents/MacOS/libmimalloc.3.dylib' &&
        rm -rf '$APP_DIR/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app' &&
        codesign --force --deep --sign - '$APP_DIR/Roblox.app' &&

        mkdir -p ~/Opiumware/{workspace,autoexec,themes,modules} &&
        mkdir -p ~/Opiumware/modules/{decompiler,LuauLSP} &&
        mv -f '$TEMP/Resources/Decompiler' ~/Opiumware/modules/decompiler/Decompiler &&
        mv -f '$TEMP/Resources/LuauLSP' ~/Opiumware/modules/LuauLSP/LuauLSP
    "

    open "$APP_DIR/Roblox.app"
    rm -rf '$TEMP'
}

main
