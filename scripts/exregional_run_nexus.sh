#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHDIR/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that generates initial condition 
(IC), surface, and zeroth hour lateral boundary condition (LBC0) files 
for FV3 (in NetCDF format).
========================================================================"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  
# Then process the arguments provided to this script/function (which 
# should consist of a set of name-value pairs of the form arg1="value1",
# etc).
#
#-----------------------------------------------------------------------
#
valid_args=( \
"EXTRN_MDL_FNS" \
"EXTRN_MDL_FILES_DIR" \
"EXTRN_MDL_CDATE" \
"WGRIB2_DIR" \
"APRUN" \
"ICS_DIR" \
)
process_args valid_args "$@"
#
#-----------------------------------------------------------------------
#
# For debugging purposes, print out values of arguments passed to this
# script.  Note that these will be printed out only if VERBOSE is set to
# TRUE.
#
#-----------------------------------------------------------------------
#
print_input_args valid_args
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
workdir="${ICS_DIR}/tmp_ICS"
mkdir_vrfy -p "$workdir"
cd_vrfy $workdir
#
#-----------------------------------------------------------------------
#
# Copy the NEXUS config files to the tmp directory  


#
#-----------------------------------------------------------------------
#
# Get the starting year, month, day, and hour of the the external model
# run.
#
#-----------------------------------------------------------------------
#
cyc="${EXTRN_MDL_CDATE:8:2}"
yyyymmdd="${EXTRN_MDL_CDATE:0:8}"
start_date=$(date -d "$yyyymmdd" +"%Y-%m-%d")
# assume ending date is +24 hours for now
end_date=$(date -d "$yyyymmdd + $FCST_LEN_HRS hours" +"%Y-%m-%d")


#
#----------------------------------------------------------------------
#
#  Copy the config files and executables to the working directory
cp ${EXECDIR}/hemco_standalone ${workdir}
cp ${EXECDIR}/../sorc/arl_nexus/config/cmaq/*.rc ${workdir}

#
#----------------------------------------------------------------------
# 
# modify time configuration file
#
time_parser=${EXECDIR}/../sorc/arl_nexus/utils/hemco_time_parser.py
./${time_parser} -f HEMCO_sa_Time.rc -s $start_date -d $end_date -c $cyc

#
#---------------------------------------------------------------------
#
# set the root directory to the temporary directory
# 
root_parser=${EXECDIR}/../sorc/arl_nexus/utils/hemco_root_parser.py
./root_parser -f HEMCO_Config.rc -d ${workdir}/nexus_inputs

#
#----------------------------------------------------------------------
# 
# Retrieve files from HPSS for input to NEXUS
#
# call script to parse needed files 
# create htar file list 
mkdir_vrfy -p nexus_inputs
cd_vrfy nexus_inputs
#temporarily just copy these here
cp /scratch2/NAGAPE/arl/Patrick.C.Campbell/NEXUS_Emissions/CAM-CMAQ_nrt_emissions/NEI2016v1_rc/input/* .
cd_vrfy ${workdir}

#
#----------------------------------------------------------------------
#
# Execute NEXUS
#
${APRUN} ${EXECDIR}/hemco_standalone || \
print_err_msg_exit "\
Call to execute nexus standalone for the FV3SAR failed
"

#mv files (ummm ok) 
#
#mv_vrfy out.atm.tile${TILE_RGNL}.nc \
#        ${ICS_DIR}/gfs_data.tile${TILE_RGNL}.halo${NH0}.nc

#mv_vrfy out.sfc.tile${TILE_RGNL}.nc \
#        ${ICS_DIR}/sfc_data.tile${TILE_RGNL}.halo${NH0}.nc

#mv_vrfy gfs_ctrl.nc ${ICS_DIR}

#mv_vrfy gfs_bndy.nc ${ICS_DIR}/gfs_bndy.tile${TILE_RGNL}.000.nc
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
NEXUS has successfully generated emissions files in netcdf format!!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
