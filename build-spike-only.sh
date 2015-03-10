#! /bin/bash
#
# Script to build RISC-V ISA simulator, proxy kernel, and GNU toolchain.
# Tools will be installed to $RISCV.

. build.common

echo "Starting RISC-V Toolchain build process"

build_project riscv-fesvr --prefix=$RISCV

rm -f --preserve-root $RISCV/bin/spike-vanilla
build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV
# copy the spike output executable, then build it again
cp $RISCV/bin/spike $RISCV/bin/spike-vanilla

# build with a specific tag policy
rm -f --preserve-root $RISCV/bin/spike-no-return-copy
CPPFLAGS="-D TAG_POLICY_NO_RETURN_COPY" CFLAGS="-D TAG_POLICY_NO_RETURN_COPY" build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV
# copy the spike output executable, then build it again
cp $RISCV/bin/spike $RISCV/bin/spike-no-return-copy

# build vanilla spike
# because we don't copy libriscv, this nullifies spike-no-return-copy
# TODO(ievans): copy libriscv in installations
# build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV

# don't build riscv-pk if we don't have the correct cross-compiler
# note that this depends on having riscv64-unknown-elf-gcc in your $PATH
if [ ! `which riscv64-unknown-elf-gcc` ]
then
  echo "riscv64-unknown-elf-gcc doesn't appear to be installed; not building riscv-pk"
  exit 1
fi

CC=riscv64-unknown-elf-gcc build_project riscv-pk --prefix=$RISCV/riscv64-unknown-elf --host=riscv

echo -e "\\nRISC-V Toolchain installation completed!"
