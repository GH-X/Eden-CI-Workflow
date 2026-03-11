#!/bin/sh -e

FORGEJO_LENV="${GITHUB_WORKSPACE}/forgejo.env"
touch "$FORGEJO_LENV"

cd ./eden

patcherror=""
apply_patch() {
	for patchname in $(ls -A ../patches/$2*$1 | sort -n -r); do
		echo "----------[ $patchname ]----------"
		if patch -p1 < $patchname; then
			echo "patch $patchname OK !!!"
			break
		fi
		if ! patch -Rp1 < $patchname; then
			patcherror="- Patch Error: !!! $1 mismatch !!!"
			echo "patch $patchname mismatch !!!"
		fi
	done
}
# temporary
temppatchs="temporary.patch"
previouspatchs=""
for currentpatchs in $(ls -A ../patches/*$temppatchs | sort -n -r | awk -F\/ '{print $3}' | awk -F\. '{print $1}'); do
	[ "$currentpatchs" != "" ] || break
	[ "$currentpatchs" != "$previouspatchs" ] || continue
	apply_patch $temppatchs $currentpatchs
	previouspatchs="$currentpatchs"
done
echo "FORGEJO_ERROR_TEMP=$patcherror" >> "$FORGEJO_LENV"
# translations zh_CN
patcherror=""
apply_patch 'translations.patch' 'zh_CN'
echo "FORGEJO_ERROR_ZHCN=$patcherror" >> "$FORGEJO_LENV"
