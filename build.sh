#! /bin/bash
#
# Script to build RISC-V ISA simulator, proxy kernel, and GNU toolchain.
# Tools will be installed to $RISCV.

. build.common

echo "Starting RISC-V Toolchain build process"

# get the absolute path this script is in
SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPT")
$SCRIPTDIR/build-spike-only.sh

build_project riscv-gnu-toolchain --prefix=$RISCV

# build riscv64-unknown-linux-gnu-gcc
#cd riscv-gnu-toolchain/build
#make linux -j
#make install
#cd -

build_project riscv-pk --prefix=$RISCV/riscv64-unknown-elf --host=riscv64-unknown-elf
# ignore translation files from qemu
cd riscv-qemu; git update-index --assume-unchanged po/*; cd ..
build_project riscv-qemu --prefix=$RISCV --target-list=riscv-softmmu
build_tests

echo -e "\\nRISC-V Toolchain installation completed!"
