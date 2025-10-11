#!/bin/sh -x

cd ./eden

# eden-nightly patch
patch -p1 < ../patches/update.patch
# translations zh_CN
patch -p1 < ../patches/translations_zh_CN.patch
