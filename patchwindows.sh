#!/bin/sh -ex

FORGEJO_LENV="${GITHUB_WORKSPACE}/forgejo.env"
touch "$FORGEJO_LENV"

cd ./eden

# eden nightly
ndname="nightly.patch"
npatchok="0"
for npatch in $(ls -A ../patches/*$ndname | sort -n -r); do
    if patch -p1 < $npatch; then
        npatchok="1"
        break
    fi
done
[ "$npatchok" == "1" ] && echo "FORGEJO_ERROR_UP=" >> "$FORGEJO_LENV" || echo "FORGEJO_ERROR_UP=- Patch Error: !!! *$ndname mismatch !!!" >> "$FORGEJO_LENV"
# translations zh_CN
tdname="translations_zh_CN.patch"
tpatchok="0"
for tpatch in $(ls -A ../patches/*$tdname | sort -n -r); do
    if patch -p1 < $tpatch; then
        tpatchok="1"
        break
    fi
done
[ "$tpatchok" == "1" ] && echo "FORGEJO_ERROR_TP=" >> "$FORGEJO_LENV" || echo "FORGEJO_ERROR_TP=- Patch Error: !!! *$tdname mismatch !!!" >> "$FORGEJO_LENV"
