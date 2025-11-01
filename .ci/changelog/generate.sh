#!/bin/bash -e

# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC1091

case "$1" in
master)
	TAG="v${TIMESTAMP}.${FORGEJO_REF}"
	REF="${FORGEJO_REF}"
	BASE_DOWNLOAD_URL="https://$RELEASE_MASTER_HOST/$RELEASE_MASTER_REPO/releases/download"
	;;
pull_request)
	TAG="${FORGEJO_PR_NUMBER}-${FORGEJO_REF}"
	REF="${FORGEJO_PR_NUMBER}-${FORGEJO_REF}"
	BASE_DOWNLOAD_URL="https://$RELEASE_PR_HOST/$RELEASE_PR_REPO/releases/download"
	;;
tag)
	TAG="${FORGEJO_REF}"
	REF="${FORGEJO_REF}"
	BASE_DOWNLOAD_URL="https://$RELEASE_TAG_HOST/$RELEASE_TAG_REPO/releases/download"
	;;
push | test)
	TAG="v${TIMESTAMP}.${FORGEJO_REF}"
	REF="${FORGEJO_REF}"
	BASE_DOWNLOAD_URL="https://$RELEASE_MASTER_HOST/$RELEASE_MASTER_REPO/releases/download"
	;;
*)
	echo "Type: $1"
	echo "Supported types: master | pull_request | tag | push | test"
	exit 1
	;;
esac

COMPARE_RELEASE_URL="https://$RELEASE_MASTER_HOST/$RELEASE_MASTER_REPO/releases"

linux() {
	ARCH="$1"
	PRETTY_ARCH="$2"
	DESCRIPTION="$3"

	echo -n "| "
	echo -n "[$PRETTY_ARCH ($LABEL)](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Linux-${REF}-${ARCH}-${COMPILER}.AppImage) | "
	if [ "$DEVEL" != "true" ]; then
		echo -n "([zsync](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Linux-${REF}-${ARCH}-${COMPILER}.AppImage.zsync)) | "
	fi
	echo -n "$DESCRIPTION ($LABEL build) |"
	echo
}

linux_builds() {
	LABEL="$1"

	echo "| Build | Description |"
	echo "| ----- | ----------- |"
	linux amd64 "amd64" "For any modern AMD or Intel CPU"
	linux steamdeck "Steam Deck" "For Steam Deck and other >= Zen 2 AMD CPUs"
	[ "$DISABLE_ARM" != "true" ] && linux aarch64 "armv8-a" "For ARM CPUs made in mid-2021 or earlier"

	if [ "$DEVEL" != "true" ]; then
		linux legacy "amd64 (legacy)" "For CPUs older than 2013 or so"
		linux rog-ally "ROG Ally X" "For ROG Ally X and other >= Zen 4 AMD CPUs"
	fi

}

deb() {
	BUILD="$1"
	NAME="${BUILD//-/ }"

	for ARCH in amd64 aarch64; do
		echo -n "| "
		echo -n "[$NAME ($ARCH)](${BASE_DOWNLOAD_URL}/${TAG}/Eden-$BUILD-${REF}-${ARCH}.deb) | "
		echo -n "Pre-packaged \`.deb\` file for $NAME on $ARCH |"
		echo
	done
}

win() {
	ARCH="$1"
	PRETTY_ARCH="$2"
	DESCRIPTION="$3"

	echo -n "| "
	echo -n "[$PRETTY_ARCH](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Windows-${REF}-${ARCH}.zip) | "
	echo -n "$DESCRIPTION |"
	echo
}

android() {
	TYPE="$1"
	FLAVOR="$2"
	DESCRIPTION="$3"

	echo -n "| "
	echo -n "[Android $TYPE](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Android-${REF}-${FLAVOR}.apk) |"
	echo -n "$DESCRIPTION |"
	echo
}

src() {
	EXT="$1"
	DESCRIPTION="$2"

	echo -n "| "
	echo -n "[$EXT](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Source-${REF}.${EXT}) | "
	echo -n "$DESCRIPTION |"
	echo
}

case "$1" in
master)
	echo "Eden's 'master' branch build, commit for reference:"
	echo "- [\`$FORGEJO_REF\`](https://$FORGEJO_HOST/$FORGEJO_REPO/commit/$FORGEJO_REF)"
	echo
	echo "Full changelog: [\`$FORGEJO_BEFORE...$FORGEJO_REF\`](https://$FORGEJO_HOST/$FORGEJO_REPO/compare/$FORGEJO_BEFORE...$FORGEJO_REF)"
	;;
pull_request)
	echo "Eden's Pull Request Number #[$FORGEJO_PR_NUMBER]($FORGEJO_PR_URL)"
	echo
	echo "Commit for reference:"
	echo "- [\`$FORGEJO_REF\`](https://$FORGEJO_HOST/$FORGEJO_REPO/commit/$FORGEJO_REF)"
	echo
	echo "Commit used as the merge base for this Pull Request:"
	echo "- [\`$FORGEJO_PR_MERGE_BASE\`](https://$FORGEJO_HOST/$FORGEJO_REPO/commit/$FORGEJO_PR_MERGE_BASE)"
	echo
	echo "Corresponding 'master' build for reference:"
	echo "- [\`$FORGEJO_REF\`]($COMPARE_RELEASE_URL?q=$FORGEJO_PR_MERGE_BASE&expanded=true)"
	echo
	echo "## Changelog"
	.ci/common/field.py field="body" default_msg="No changelog provided" pull_request_number="$FORGEJO_PR_NUMBER"
	;;
tag)
	echo "## Changelog"
	;;
push | test)
	echo "Eden's Continuous Integration Test Build"
	;;
esac
echo

echo "## Packages"
echo
echo "Desktop builds will automatically put data in \`~/.local/share/eden\` on Linux, or "
echo "\`%APPDATA%/eden\` on Windows. You may optionally create a \`user\` directory in the "
echo "same directory as the executable/AppImage to store data there instead."
echo

if [ "$DEVEL" = "true" ]; then
	echo ">[!WARNING]"
	echo ">These builds are provided **as-is**. They are intended for testers and developers ONLY."
	echo ">They are made available to the public in the interest of maximizing user freedom, but you"
	echo ">**will NOT receive support** while using these builds, *unless* you have useful debug/testing"
	echo ">info to share."
	echo "> "
	echo ">Furthermore, sharing these builds and claiming they are the \"official\" or \"release\""
	echo ">builds is **STRICTLY FORBIDDEN** and may result in further action from the Eden development team."
fi
echo

# TODO(crueter): let's make this all one table
echo "### Linux"
echo
echo "Linux packages are distributed via AppImage. Each build is optimized for a specific architecture."
echo "See the *Description* column for more info. Note that legacy builds will always work on newer systems."
echo

COMPILER=gcc-standard
linux_builds "GCC"

if [ "$DEVEL" != "true" ]; then
	echo
	echo "We are additionally providing experimental packages built with Clang, rather than GCC. These builds should be identical, if not faster,"
	echo "but how it affects the overall experience is currently unknown. In the future, these builds will be made with PGO to increase speed."
	echo

	COMPILER=clang-standard
	linux_builds "Clang"

	echo
	echo "We are additionally providing experimental PGO packages. These should have improved performance, but may be unstable or have bugs."
	echo
	echo "| Build | Description |"
	echo "| ----- | ----------- |"

	COMPILER=clang-pgo
	linux_builds "PGO"
fi
echo

echo "### Debian/Ubuntu"
echo
echo "These are prebuilt \`.deb\` packages for Ubuntu and Debian. To install them, run \`sudo dpkg -i Eden-<platform>-<version>.deb\`."
echo "Note that these use system drivers, and so you may have some graphical bugs with these builds as opposed to the appimage."
echo
echo "| Build | Description |"
echo "| ----- | ----------- |"
deb Ubuntu-24.04
deb Debian-12
deb Debian-13
echo

echo "### Windows"
echo
echo "Windows packages are in-place zip files."
echo
echo "| Build | Description |"
echo "| ----- | ----------- |"
win amd64-msvc-standard amd64 "For any Windows machine running an AMD or Intel CPU"
win arm64-msvc-standard aarch64 "For any Windows machine running a Qualcomm or other ARM-based SoC"
echo

echo "We are additionally providing experimental packages built with Clang, rather than MSVC. These builds should be identical, if not faster,"
echo "but how it affects the overall experience is currently unknown."
echo
echo "| Build | Description |"
echo "| ----- | ----------- |"
win amd64-clang-standard "amd64 (clang)" "For any Windows machine running an AMD or Intel CPU (clang-cl build)"
win arm64-clang-standard "aarch64 (clang)" "For any Windows machine running a Qualcomm or other ARM-based SoC (clang-cl build)"
echo

if [ "$DEVEL" != "true" ]; then
	echo "We are additionally providing experimental PGO packages. These should have improved performance, but may be unstable or have bugs."
	echo
	echo "| Build | Description |"
	echo "| ----- | ----------- |"
	win amd64-clang-pgo "amd64 (PGO)" "For any Windows machine running an AMD or Intel CPU (PGO build)"
	win arm64-clang-pgo "aarch64 (PGO)" "For any Windows machine running a Qualcomm or other ARM-based SoC (PGO build)"
	echo
fi

echo "### Android"
echo
echo "| Build  | Description |"
echo "|--------|-------------|"
android Standard "standard" "Single APK for all supported Android devices (most users should use this)"
if [ "$DEVEL" != true ]; then
	android Optimized "optimized" "For any Android device that has Frame Generation or any other per-device feature"
	android Legacy "legacy" "For Adreno A6xx and other older GPUs"
fi
echo

echo "### macOS"
echo
echo "macOS comes in a tarballed app. These builds are currently experimental, and you should expect major graphical glitches and crashes."
echo "In order to run the app, you *may* need to go to System Settings -> Privacy & Security -> Security -> Allow untrusted app."
echo "| File | Description |"
echo "| ---- | ----------- |"
echo "| [macOS](${BASE_DOWNLOAD_URL}/${TAG}/Eden-macOS-${REF}.tar.gz) | For Apple Silicon (M1, M2, etc) computers running macOS"
echo
echo "### Source"
echo
echo "Contains all source code, submodules, and CPM cache at the time of release."
echo
echo "| File | Description |"
echo "| ---- | ----------- |"
src "tar.zst" "Source as a zstd-compressed tarball (Windows requires 7zip)"
echo
