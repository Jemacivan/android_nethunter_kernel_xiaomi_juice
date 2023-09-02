#!/usr/bin/env bash

set -e

while [ $# -ge 1 ]; do
    case $1 in
    -d) shift && DEVICE=$1 ;;
    esac

    shift
done

case $DEVICE in
citrus) TARGET=citrus ;;
lime) TARGET=lime ;;
*) exit 1 ;;
esac

ROOT=$(pwd)
ZIPNAME=Nbr-kernel-4.19-$TARGET-$(date +"%F")
JOBS=$(nproc --all)

export PATH=$ROOT/arm64-gcc/bin:$ROOT/arm-gcc/bin:$PATH
export KBUILD_BUILD_USER=mamles

clone() {
    if ! [ -a AnyKernel3 ]; then
        git clone --depth=1 https://github.com/osm0sis/AnyKernel3 AnyKernel3
    fi
    if ! [ -a arm64-gcc ]; then
        git clone --depth=1 https://github.com/MiBengal-Development/arm64-gcc -b master arm64-gcc
    fi
    if ! [ -a arm-gcc ]; then
        git clone --depth=1 https://github.com/MiBengal-Development/arm32-gcc -b master arm-gcc
    fi
}

compile() {
    if [ -a out ]; then
        rm -rf out
    fi
    make O=out ARCH=arm64 vendor/${TARGET}-perf_defconfig -j"$JOBS" \
        CROSS_COMPILE=aarch64-elf- \
        CROSS_COMPILE_ARM32=arm-eabi-
    make O=out ARCH=arm64 -j"$JOBS" \
        CROSS_COMPILE=aarch64-elf- \
        CROSS_COMPILE_ARM32=arm-eabi-
}

repack() {
    cp out/arch/arm64/boot/Image.gz AnyKernel3
    cp out/arch/arm64/boot/dtb.img AnyKernel3
    cp out/arch/arm64/boot/dtbo.img AnyKernel3
    cd AnyKernel3
    if [ -a "${ZIPNAME}".zip ]; then
        rm -rf "${ZIPNAME}".zip
    fi
    if [ -a "${ZIPNAME}"-signed.zip ]; then
        rm -rf "${ZIPNAME}"-signed.zip
    fi
    zip -r9 "${ZIPNAME}".zip ./* -x .git README.md ./*placeholder zipsigner-3.0.jar ./*.zip
    java -jar zipsigner-3.0.jar "${ZIPNAME}".zip "${ZIPNAME}"-signed.zip
    rm -rf Image.gz dtb.img dtbo.img
    cd "$ROOT"
}

clone
compile
repack
