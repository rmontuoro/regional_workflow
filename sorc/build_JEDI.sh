#! /usr/bin/env bash
set -eux

source ./machine-setup.sh > /dev/null 2>&1
cwd=`pwd`

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

cd JEDI

mkdir -p build
cd build

# load modules depending on platform
# and different build commands too
moduledir=$(readlink -f ../../../modulefiles/codes/$target)
if [ "$target" = "hera" ] ; then
  source $moduledir/JEDI
  module list
  ecbuild -DMPIEXEC_EXECUTABLE=`which srun` -DMPIEXEC_NUMPROC_FLAG="-n" ../
  make -j8
elif [ "$target" = "wcoss_dell_p3" ] ; then
  module use $moduledir
  module load JEDI
else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi

# link executables to exec dir
ln -sf $cwd/JEDI/build/bin/fv3jedi* $cwd/../exec/.
