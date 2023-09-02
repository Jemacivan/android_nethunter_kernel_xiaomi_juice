export ROOT=$(pwd) export 
PATH=$ROOT/arm64-gcc/bin:$ROOT/arm-gcc/bin:$PATH 
make O=out ARCH=arm64 -j$(nproc --all) \
        CROSS_COMPILE=aarch64-elf- \
        CROSS_COMPILE_ARM32=arm-eabi- $@
