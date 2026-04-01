#!/bin/sh -e

# SPDX-FileCopyrightText: Copyright 2026 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC1091

ROOTDIR="$PWD"
. "$ROOTDIR/.ci/common/project.sh"
ARTIFACTS_DIR="$ROOTDIR/artifacts"

FJ_HOST="$RELEASE_HOST"
FJ_REPO="$RELEASE_REPO"

sed -i "s|$RELEASE_HOST/$RELEASE_REPO|$FJ_HOST/$FJ_REPO|g" "$ROOTDIR/changelog.md"
git clone --depth 1 https://git.crueter.xyz/scripts/fj.git

echo "-- Creating Release"
"$ROOTDIR/fj/fj.sh" -k "$FJ_TOKEN" -r "$FJ_REPO" -u "$FJ_HOST" release -t "$ARTIFACT_REF" \
	create -b "$ROOTDIR/changelog.md" -n "$GITHUB_TITLE" -d

echo "-- Uploading Assets"

# Cloudflare sucks, so we upload twice just to ensure we don't get blocked.
"$ROOTDIR/fj/fj.sh" -k "$FJ_TOKEN" -r "$FJ_REPO" -u "$FJ_HOST" release -t "$ARTIFACT_REF" \
	upload -g "$ARTIFACTS_DIR"/*

"$ROOTDIR/fj/fj.sh" -k "$FJ_TOKEN" -r "$FJ_REPO" -u "$FJ_HOST" release -t "$ARTIFACT_REF" \
	upload -g "$ARTIFACTS_DIR"/*

export FJ_URL="https://$FJ_HOST/$FJ_REPO/releases/tag/$ARTIFACT_REF"

if [ -n "$GITHUB_STEP_SUMMARY" ]; then
    {
        echo "## Release Summary"
        echo "- View Release on Forgejo: [$GITHUB_TITLE]($FJ_URL)"
    } >> "$GITHUB_STEP_SUMMARY"
fi