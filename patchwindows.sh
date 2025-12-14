#!/bin/sh -e

FORGEJO_LENV="${GITHUB_WORKSPACE}/forgejo.env"
touch "$FORGEJO_LENV"

cd ./eden

# temporary
temporarypatchname="temporary.patch"
for temporarypatch in $(ls -A ../patches/*$temporarypatchname | sort -n -r); do
    if patch -p1 < $temporarypatch; then
        echo "patch $temporarypatch OK !!!"
    fi
done
# translations zh_CN
tdname="translations_zh_CN.patch"
tperror="- Patch Error: !!! *$tdname mismatch !!!"
for tpatch in $(ls -A ../patches/*$tdname | sort -n -r); do
    if patch -p1 < $tpatch; then
        tperror=""
        break
    fi
done
echo "FORGEJO_ERROR_TP=$tperror" >> "$FORGEJO_LENV"
