#!/bin/sh -ex

FORGEJO_LENV="${GITHUB_WORKSPACE}/forgejo.env"
touch "$FORGEJO_LENV"

udname="update.patch"
tdname="translations_zh_CN.patch"
upatch="$udname"
tpatch="$tdname"
[ -e "${GITHUB_WORKSPACE}/patches/${FORGEJO_REF}.$udname" ] && upatch="${FORGEJO_REF}.$udname"
[ -e "${GITHUB_WORKSPACE}/patches/${FORGEJO_REF}.$tdname" ] && tpatch="${FORGEJO_REF}.$tdname"
[ -e "${GITHUB_WORKSPACE}/patches/${FORGEJO_NREV}.$udname" ] && upatch="${FORGEJO_NREV}.$udname"
[ -e "${GITHUB_WORKSPACE}/patches/${FORGEJO_NREV}.$tdname" ] && tpatch="${FORGEJO_NREV}.$tdname"

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
