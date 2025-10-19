#!/bin/sh -ex

FORGEJO_LENV="${GITHUB_WORKSPACE}/forgejo.env"
touch "$FORGEJO_LENV"

upatch="update.patch"
tpatch="translations_zh_CN.patch"
[ -e "${GITHUB_WORKSPACE}/patches/${FORGEJO_REF}.update.patch" ] && upatch="${FORGEJO_REF}.update.patch"
[ -e "${GITHUB_WORKSPACE}/patches/${FORGEJO_REF}.translations_zh_CN.patch" ] && tpatch="${FORGEJO_REF}.translations_zh_CN.patch"

cd ./eden

# eden-nightly patch
if ! patch -p1 < ../patches/$upatch; then
	echo "FORGEJO_ERROR_UP=!!! $upatch mismatch !!!" >> "$FORGEJO_LENV"
else
	echo "FORGEJO_ERROR_UP=" >> "$FORGEJO_LENV"
fi
# translations zh_CN
if ! patch -p1 < ../patches/$tpatch; then
	echo "FORGEJO_ERROR_TP=!!! $tpatch mismatch !!!" >> "$FORGEJO_LENV"
else
	echo "FORGEJO_ERROR_TP=" >> "$FORGEJO_LENV"
fi
