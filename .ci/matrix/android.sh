#!/bin/sh -e

flavor() {
	cat <<-EOF
		{"flavor": "$1"}
	EOF
}

standard=$(flavor standard)
chromeos=$(flavor chromeos)
optimized=$(flavor optimized)
legacy=$(flavor legacy)

# TODO: rename force_pgo to force_tag or something
# and have it build the extras here too
targets="[$standard"

if [ "$DEVEL" = "false" ]; then
	targets="$targets, $legacy, $optimized, $chromeos"
elif [ "$BUILD_ID" = "pull_request" ]; then
	targets="$targets, $chromeos"
fi

targets="$targets]"

echo "Android Targets: $targets"
echo "targets=${targets}" >>"$GITHUB_OUTPUT"
