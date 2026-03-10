#!/bin/sh -e

FORGEJO_LENV="${GITHUB_WORKSPACE}/forgejo.env"
touch "$FORGEJO_LENV"

cd ./eden

temppatcherror=""
zhcnpatcherror=""
temppatch="temporary.patch"
zhcnpatch="translations_zh_CN.patch"
apply_patch() {
	for patchname in $(ls -A ../patches/*$2$1 | sort -n -r); do
		if patch -p1 < $patchname; then
			echo "patch $patchname OK !!!"
			break
		fi
		if ! patch -Rp1 < $patchname; then
			if [ "$1" = "$temppatch" ]; then
				temppatcherror="- Patch Error: !!! $1 mismatch !!!"
			fi
			if [ "$1" = "$zhcnpatch" ]; then
				zhcnpatcherror="- Patch Error: !!! $1 mismatch !!!"
			fi
			echo "patch $patchname mismatch !!!"
		fi
	done
}
# temporary
apply_patch $temppatch '#settings.'
apply_patch $temppatch '#FramePacingMode.'
apply_patch $temppatch '#lowmemorydevice.'
apply_patch $temppatch '-28162#5edcdea78f#3074.'
apply_patch $temppatch '-28093#363d861011#3156.'
echo "FORGEJO_ERROR_TEMP=$temppatcherror" >> "$FORGEJO_LENV"
# translations zh_CN
apply_patch $zhcnpatch '.'
echo "FORGEJO_ERROR_ZHCN=$zhcnpatcherror" >> "$FORGEJO_LENV"
