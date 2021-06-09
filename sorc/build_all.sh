#!/bin/sh
set -eux
#------------------------------------
# USER DEFINED STUFF:
#
# USE_PREINST_LIBS: set to "true" to use preinstalled libraries.
#                   Anything other than "true"  will use libraries locally.
#------------------------------------

export USE_PREINST_LIBS="true"

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

#------------------------------------
# END USER DEFINED STUFF
#------------------------------------

build_dir=`pwd`
logs_dir=$build_dir/logs
if [ ! -d $logs_dir  ]; then
  echo "Creating logs folder"
  mkdir $logs_dir
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  echo "Creating ../exec folder"
  mkdir ../exec
fi

#------------------------------------
# INCLUDE PARTIAL BUILD 
#------------------------------------

. ./partial_build.sh

#------------------------------------
# build libraries first
#------------------------------------
$Build_libs && {
echo " .... Library build not currently supported .... "
#echo " .... Building libraries .... "
#./build_libs.sh > $logs_dir/build_libs.log 2>&1
}

#------------------------------------
# Check and build nexus
#------------------------------------
if [ -d "./arl_nexus" ]
then
    $Build_nexus && {
echo " .... Building nexus .... "
./build_nexus.sh > $logs_dir/build_nexus.log 2>&1
}
fi

#------------------------------------
# Check and build nacc
#------------------------------------
if [ -d "./arl_nacc" ]
then
    $Build_nacc && {
echo " .... Building nacc .... "
./build_nacc.sh $platform > $logs_dir/build_nacc.log 2>&1
}
fi

#------------------------------------
# build forecast
#------------------------------------
$Build_forecast && {
echo " .... Building forecast .... "
./build_forecast.sh > $logs_dir/build_forecast.log 2>&1
}

#------------------------------------
# build post
#------------------------------------
$Build_post && {
echo " .... Building post .... "
./build_post.sh > $logs_dir/build_post.log 2>&1
}

#------------------------------------
# build utils
#------------------------------------
$Build_utils && {
echo " .... Building utils .... "
./build_utils.sh > $logs_dir/build_utils.log 2>&1
}

#------------------------------------
# build gsi
#------------------------------------
$Build_gsi && {
echo " .... GSI build not currently supported .... "
#echo " .... Building gsi .... "
#./build_gsi.sh > $logs_dir/build_gsi.log 2>&1
}

echo;echo " .... Build system finished .... "
echo;echo " .... Installing executables .... "

./install_all.sh

echo;echo " .... Installation finished .... "
echo;echo " .... Linking fix files .... "

./link_fix.sh

echo;echo " .... Linking fix files finished .... "

exit 0
