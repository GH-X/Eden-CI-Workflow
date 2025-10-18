#!/bin/sh -ex

FORGEJO_LENV=${FORGEJO_LENV:-"forgejo.env"}
touch "$FORGEJO_LENV"
echo "FORGEJO_ERROR_UP=" >> "$FORGEJO_LENV"
echo "FORGEJO_ERROR_TP=" >> "$FORGEJO_LENV"

cd ./eden

# eden-nightly patch
if ! patch -p1 < ../patches/update.patch; then
	echo "FORGEJO_ERROR_UP=!!! update.patch mismatch !!!" >> "$FORGEJO_LENV"
fi
# translations zh_CN
if ! patch -p1 < ../patches/translations_zh_CN.patch; then
	echo "FORGEJO_ERROR_TP=!!! translations_zh_CN.patch mismatch !!!" >> "$FORGEJO_LENV"
fi
