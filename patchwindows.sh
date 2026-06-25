#!/bin/sh -e

# Summary
SUMMARY="## Job Summary
- Triggered by: $1
- Clone URL: $2
- Commit: [\`$FORGEJO_REF\`](https://$FORGEJO_HOST/$FORGEJO_REPO/commit/$FORGEJO_REF)

## Custom Build

- Nightly REV: $ARTIFACT_REF
"

cd ./eden

apply_patch() {
	for patchname in $(ls -A ../patches/$2*$1 | sort -n -r); do
		echo "----------[ $patchname ]----------"
		if patch -p1 < $patchname; then
			echo "patch $patchname OK !!!"
			# Summary
			SUMMARY="$SUMMARY
- Patch Successful: $patchname
"
			break
		fi
		if ! patch -Rp1 < $patchname; then
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
# translations zh_CN
apply_patch 'translations.patch' 'zh_CN'
# Summary
echo "$SUMMARY" >>"$GITHUB_STEP_SUMMARY"
