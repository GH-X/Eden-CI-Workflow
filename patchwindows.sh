#!/bin/sh -e

FORGEJO_LENV="${GITHUB_WORKSPACE}/forgejo.env"
touch "$FORGEJO_LENV"

cd ./eden

# temporary
temppatcherror=""
temppatchname="temporary.patch"
for temppatch in $(ls -A ../patches/*$temppatchname | sort -n); do
    if patch -p1 < $temppatch; then
        echo "patch $temppatch OK !!!"
        continue
    fi
    if ! patch -Rp1 < $temppatch; then
        temppatcherror="- Patch Error: !!! $temppatchname mismatch !!!"
        echo "patch $temppatch mismatch !!!"
    fi
done
echo "FORGEJO_ERROR_TEMP=$temppatcherror" >> "$FORGEJO_LENV"
# translations zh_CN
zhcnpatcherror=""
zhcnpatchname="translations_zh_CN.patch"
for zhcnpatch in $(ls -A ../patches/*$zhcnpatchname | sort -n -r); do
    if patch -p1 < $zhcnpatch; then
        echo "patch $zhcnpatch OK !!!"
        break
    fi
    if ! patch -Rp1 < $zhcnpatch; then
        zhcnpatcherror="- Patch Error: !!! $zhcnpatchname mismatch !!!"
        echo "patch $zhcnpatch mismatch !!!"
    fi
done
echo "FORGEJO_ERROR_ZHCN=$zhcnpatcherror" >> "$FORGEJO_LENV"
