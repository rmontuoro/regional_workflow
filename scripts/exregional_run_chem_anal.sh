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

This is the ex-script for the task that runs a chemical analysis with
JEDI for the specified cycle.
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
valid_args=( "CYCLE_DIR" )
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
# Load modules.
#
#-----------------------------------------------------------------------
#
case $MACHINE in
#
"WCOSS_DELL_P3")
  ulimit -s unlimited
  ulimit -a
  APRUN="mpirun -l -np ${PE_MEMBER01}"
  ;;
#
"HERA")
  ulimit -s unlimited
  ulimit -a
  APRUN="srun -n ${PE_MEMBER01}"
  source $MODULES_DIR/codes/hera/JEDI
  ;;
esac
#
#-----------------------------------------------------------------------
#
# Create JEDI subdirectory
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Creating JEDI subdirectory..."

mkdir_vrfy -p ${CYCLE_DIR}/JEDI/Data
#
#-----------------------------------------------------------------------
#
# Create links to fix files and  executables
#
#-----------------------------------------------------------------------
#
# executables
ln_vrfy -sf $EXECDIR/fv3jedi_parameters.x ${CYCLE_DIR}/JEDI/.
ln_vrfy -sf $EXECDIR/fv3jedi_var.x ${CYCLE_DIR}/JEDI/.
# FV3-JEDI fix files
ln_vrfy -sf $JEDI_DIR/build/fv3-jedi/test/Data/fieldsets ${CYCLE_DIR}/JEDI/Data/fieldsets
ln_vrfy -sf $JEDI_DIR/build/fv3-jedi/test/Data/fv3files ${CYCLE_DIR}/JEDI/Data/fv3files
# TODO FV3 namelist
# TODO FV3 input dir (grid info, etc.)
#
#-----------------------------------------------------------------------
#
# create output directories for the analysis and hofx files
#
#-----------------------------------------------------------------------
#
mkdir_vrfy -p ${CYCLE_DIR}/JEDI/Data/hofx
mkdir_vrfy -p ${CYCLE_DIR}/JEDI/Data/analysis
#
#-----------------------------------------------------------------------
#
# link model forecast file location to bkg/ directory
#
#-----------------------------------------------------------------------
#
rst_dir=${PREV_CYCLE_DIR}/RESTART
rst_file=fv_tracer.res.tile1.nc
fv_tracer_file=${rst_dir}/${CDATE:0:8}.${CDATE:8:2}0000.${rst_file}
print_info_msg "
  Looking for tracer restart file: \"${fv_tracer_file}\""
if [ ! -r ${fv_tracer_file} ]; then
  if [ -r ${rst_dir}/coupler.res ]; then
    rst_info=( $( tail -n 1 ${rst_dir}/coupler.res ) )
    rst_date=$( printf "%04d%02d%02d%02d" ${rst_info[@]:0:4} )
    print_info_msg "
  Tracer file not found. Checking available restart date:
    requested date: \"${CDATE}\"
    available date: \"${rst_date}\""
    if [ "${rst_date}" == "${CDATE}" ] ; then
      fv_tracer_file=${rst_dir}/${rst_file}
      if [ -r ${fv_tracer_file} ]; then
        print_info_msg "
  Tracer file found: \"${fv_tracer_file}\""
      else
        print_err_msg_exit "\
  No suitable tracer restart file found."
      fi
    fi
  fi
fi

ln_vrfy -sf $rst_dir ${CYCLE_DIR}/JEDI/Data/bkg

#
#-----------------------------------------------------------------------
#
# Run Python script to create YAML
#-----------------------------------------------------------------------
#
YAMLS='jedi_no2_3dvar.yaml jedi_no2_bump.yaml'
TEMPLATEDIR=${USHDIR}/templates
${USHDIR}/gen_JEDI_yaml.py -i $TEMPLATEDIR -o ${CYCLE_DIR}/JEDI/ -c ${CDATE} -y $YAMLS
#
#-----------------------------------------------------------------------
#
# Set and export variables.
#
#-----------------------------------------------------------------------
#
export OMP_NUM_THREADS=1
export OMP_STACKSIZE=1024m
#
#-----------------------------------------------------------------------
#
# Run BUMP first
#
#-----------------------------------------------------------------------
#
$APRUN ./fv3jedi_parameters.x || print_err_msg_exit "\
Call to executable to run fv3jedi_parameters.x returned with nonzero exit
code."
#
#-----------------------------------------------------------------------
#
# Run JEDI var now
#
#-----------------------------------------------------------------------
#
$APRUN ./fv3jedi_var.x || print_err_msg_exit "\
Call to executable to run fv3jedi_var.x returned with nonzero exit
code."
#
#-----------------------------------------------------------------------
#
# Use nco tools to take variables in analysis and put in RESTART/
#
#-----------------------------------------------------------------------
#
echo "TO DO; add nco tools to grab analysis no2 (can it be smart to get all vars?)"
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
chemical data assimilation completed successfully!!!

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
