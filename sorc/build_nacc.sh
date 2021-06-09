#!/bin/sh
set -eux
#
# Check for input argument: this should be the "platform" if it exists.
#
if [ $# -eq 0 ]; then
  echo
  echo "No 'platform' argument supplied"
  echo "Using directory structure to determine machine settings"
  platform=''
else 
  platform=$1
fi
#
source ./machine-setup.sh $platform > /dev/null 2>&1
if [ $platform = "wcoss_cray" ]; then
  platform="cray"
fi

#
# Set the name of the package.  This will also be the name of the execu-
# table that will be built.
#
package_name="arl_nacc"
#
# Make an exec folder if it doesn't already exist.
#
mkdir -p ../exec
#
# Change directory to where the source code is located.
# 
cd ${package_name}/parallel/src
home_dir=`pwd`/../../../..
srcDir=`pwd`
#
# Load modules.
#
set +x
source ../../../../modulefiles/codes/${platform}/global_equiv_resol
module load impi
module list
#module load cmake
#source config/modulefiles.${platform}
#
MPICH_UNEX_BUFFER_SIZE=256m
MPICH_MAX_SHORT_MSG_SIZE=64000
MPICH_PTL_UNEX_EVENTS=160k
KMP_STACKSIZE=2g
F_UFMTENDIAN=big
#
# HDF5, NetCDF, IOAPI, and MPI (for parallel NACC) directories.
#
if [ $platform = "cray" ]; then
  cp Makefile_cray Makefile
  HDF5=${HDF5}
  NETCDF=${NETCDF}
  IOAPI=/gpfs/hps3/emc/naqfc/noscrub/Youhua.Tang/CMAQ/ioapi-3.2/Linux2_x86_64ifort
  MPI=/opt/cray/mpt/7.2.0/gni/mpich2-intel/140
elif [ $platform = "theia" ]; then
 echo "Uncertain libraries for theia..untested"
 echo "Error during '$target' build"
 exit 1
elif [ $platform = "hera" ]; then
  cp Makefile_intel Makefile
  HDF5=${HDF5}
  NETCDF=${NETCDF}
  IOAPI=/scratch2/NCEPDEV/naqfc/Youhua.Tang/CMAQ/ioapi-3.2/Linux2_x86_64ifort
  MPI=/apps/intel/compilers_and_libraries_2018/linux/mpi/intel64
elif [ $platform = "cheyenne" ]; then
  echo "Uncertain libraries for cheyenne..untested"
  echo "Error during '$target' build"
  exit 1
elif [ $platform = "jet" ]; then
  echo "Uncertain libraries for jet..untested"
  echo "Error during '$target' build"
  exit 1
fi

#build the file

export COMPILER=${COMPILER:-intel}
#export CMAKE_Platform=linux.${COMPILER}
#export CMAKE_C_COMPILER=${CMAKE_C_COMPILER:-mpicc}
#export CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER:-mpicxx}
#export CMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER:-mpif90}

#cmake CMakeLists.txt
make clean
#make -j ${BUILD_JOBS:-4} FC=mpiifort IOAPI=${IOAPI} NETCDF=${NETCDF}
make -j FC=mpiifort IOAPI=${IOAPI} NETCDF=${NETCDF} MPI=${MPI}

exit
