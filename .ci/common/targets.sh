#!/bin/bash -e

# SPDX-FileCopyrightText: Copyright 2025 Eden Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later

SDL_FLAGS=(-DYUZU_USE_BUNDLED_SDL2=ON)

# only clang and gcc support this
if [ ! -z "$SUPPORTS_TARGETS" ]; then
	case "$TARGET" in
		amd64)
			echo "Making amd64-v3 optimized build of Eden"
			ARCH_FLAGS="-march=x86-64-v3 -mtune=generic"
			ARCH="amd64"
			;;
		steamdeck|zen2)
			echo "Making Steam Deck (Zen 2) optimized build of Eden"
			ARCH_FLAGS="-march=znver2 -mtune=znver2"
			ARCH="steamdeck"
			STEAMDECK=true
			;;
		rog-ally|allyx|zen4)
			echo "Making ROG Ally X (Zen 4) optimized build of Eden"
			ARCH_FLAGS="-march=znver4 -mtune=znver4"
			ARCH="rog-ally-x"
			STEAMDECK=true
			;;
		legacy)
			echo "Making amd64 generic build of Eden"
			ARCH_FLAGS="-march=x86-64 -mtune=generic"
			ARCH=legacy
			;;
		aarch64|arm64)
			echo "Making armv8-a build of Eden"
			ARCH_FLAGS="-march=armv8-a -mtune=generic"
			ARCH=aarch64
			;;
		armv9)
			echo "Making armv9-a build of Eden"
			ARCH_FLAGS="-march=armv9-a -mtune=generic"
			ARCH=armv9
			;;
		native)
			echo "Making native build of Eden"
			ARCH_FLAGS="-march=native -mtune=native"
			FFMPEG=OFF
			OPENSSL=OFF
			;;
		# Special target: package-{amd64,aarch64}
		# In the "package" target we WANT standalone executables
		# and want to target generic architectures
		package-amd64)
			echo "Making package-friendly amd64 build of Eden"
			ARCH_FLAGS="-march=x86-64 -mtune=generic"
			STANDALONE=ON
			PACKAGE=true
			FFMPEG=OFF
			OPENSSL=OFF

			;;
		package-aarch64)
			echo "Making package-friendly aarch64 build of Eden"
			ARCH_FLAGS="-march=armv8-a -mtune=generic"
			STANDALONE=ON
			PACKAGE=true
			FFMPEG=OFF
			OPENSSL=OFF

			# apparently gcc-arm64 on ubuntu dislikes lto
			LTO=OFF
			;;
		*)
			echo "Invalid target $TARGET specified, must be one of: native, amd64, steamdeck, zen2, allyx, rog-ally, zen4, legacy, aarch64, armv9"
			exit 1
			;;
	esac

	ARCH_FLAGS="${ARCH_FLAGS} -O3"
	[ "$PLATFORM" = "linux" ] && ARCH_FLAGS="${ARCH_FLAGS} -pipe"

	# For PGO, we fetch profdata and add it to our flags
	if [ "$PGO_TARGET" = "pgo" ]; then
		echo "Creating PGO build"

		CCACHE=OFF

		PROFDATA="$PWD/eden.profdata"
		[ -f "$PROFDATA" ] && rm -f "$PROFDATA"
		curl -L https://$RELEASE_PGO_HOST/$RELEASE_PGO_REPO/releases/latest/download/eden.profdata > "$PROFDATA"
		[ ! -f "$PROFDATA" ] && (echo "PGO data failed to download" ; exit 1)
		command -v cygpath >/dev/null 2>&1 && PROFDATA="$(cygpath -m "$PROFDATA")"
		ARCH_FLAGS="${ARCH_FLAGS} -fprofile-use=$PROFDATA -Wno-backend-plugin -Wno-profile-instr-unprofiled -Wno-profile-instr-out-of-date"
	fi
fi

# Steamdeck targets need older sdl2
if [ "$STEAMDECK" = "true" ]; then
	SDL_FLAGS=(
		-DYUZU_SYSTEM_PROFILE=steamdeck
		-DYUZU_USE_EXTERNAL_SDL2=ON
	)
fi

# Package targets use system sdl2
if [ "$PACKAGE" = "true" ]; then
	SDL_FLAGS=(-DYUZU_USE_BUNDLED_SDL2=OFF)
fi

[ -n "$ARCH_FLAGS" ] && ARCH_CMAKE=(-DCMAKE_C_FLAGS="${ARCH_FLAGS}" -DCMAKE_CXX_FLAGS="${ARCH_FLAGS}")

export ARCH_CMAKE
export SDL_FLAGS
export STANDALONE
export ARCH
export OPENSSL
export FFMPEG
export LTO
export CCACHE