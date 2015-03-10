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
TAG_POLICIES=( "spike-no-return-copy" "spike-no-fp-arith" )
TAG_DEFINES=( "-D TAG_POLICY_NO_RETURN_COPY" "-D TAG_POLICY_NO_FP_ARITH" )
numPolicies=${#TAG_POLICIES[@]}
# use for loop read all nameservers
for (( i=0; i<${numPolicies}; i++ ));
do
    echo "Building $RISCV/${TAG_POLICIES[$i]}/${TAG_POLICIES[$i]}"
    rm -rf --preserve-root "$RISCV/${TAG_POLICIES[$i]}"
    mkdir -p "$RISCV/${TAG_POLICIES[$i]}"
    CPPFLAGS="${TAG_DEFINES[$i]}" CFLAGS="${TAG_DEFINES[$i]}" build_project riscv-isa-sim --prefix=$RISCV/${TAG_POLICIES[$i]} --with-fesvr=$RISCV
    mv $RISCV/${TAG_POLICIES[$i]}/bin/spike $RISCV/${TAG_POLICIES[$i]}/bin/${TAG_POLICIES[$i]}
    ln -s $RISCV/${TAG_POLICIES[$i]}/bin/${TAG_POLICIES[$i]} $RISCV/bin/${TAG_POLICIES[$i]}
done

# build vanilla spike
build_project riscv-isa-sim --prefix=$RISCV --with-fesvr=$RISCV

# don't build riscv-pk if we don't have the correct cross-compiler
# note that this depends on having riscv64-unknown-elf-gcc in your $PATH
if [ ! `which riscv64-unknown-elf-gcc` ]
then
  echo "riscv64-unknown-elf-gcc doesn't appear to be installed; not building riscv-pk"
  exit 1
fi

CC=riscv64-unknown-elf-gcc build_project riscv-pk --prefix=$RISCV/riscv64-unknown-elf --host=riscv

echo -e "\\nRISC-V Toolchain installation completed!"
