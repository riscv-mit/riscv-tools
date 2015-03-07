#! /bin/bash
#
# Script to build RISC-V ISA simulator, proxy kernel, and GNU toolchain.
# Tools will be installed to $RISCV.

. build.common

if [ ! `which riscv64-unknown-elf-gcc` ]
then
  echo "riscv64-unknown-elf-gcc doesn't appear to be installed; use the full-on build.sh"
  exit 1
fi

echo "Starting RISC-V Toolchain build process"

build_project riscv-fesvr --prefix=$RISCV


build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV
# copy the spike output executable, then build it again
cp $RISCV/bin/spike $RISCV/bin/spike-vanilla

# build with a specific tag policy
CPPFLAGS="-D TAG_POLICY_NO_RETURN_COPY" CFLAGS="-D TAG_POLICY_NO_RETURN_COPY" build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV
# copy the spike output executable, then build it again
cp $RISCV/bin/spike $RISCV/bin/spike-no-return-copy

# build vanilla spike
build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV

CC=riscv64-unknown-elf-gcc build_project riscv-pk --prefix=$RISCV/riscv64-unknown-elf --host=riscv

echo -e "\\nRISC-V Toolchain installation completed!"
