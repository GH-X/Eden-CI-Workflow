#!/bin/bash -x

echo $PAYLOAD_JSON

echo "FORGEJO_CLONE_URL=https://git.eden-emu.dev/eden-emu/eden.git" >> $GITHUB_ENV
FORGEJO_REF="$1"
FORGEJO_BRANCH=Nightly

echo "FORGEJO_REF=$FORGEJO_REF" >> $GITHUB_ENV
echo "FORGEJO_BRANCH=$FORGEJO_BRANCH" >> $GITHUB_ENV
