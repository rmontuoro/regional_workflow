#
#-----------------------------------------------------------------------
#
# This file defines a function that, given the starting date (date_start, 
# in the form YYYYMMDD), the ending date (date_end, in the form YYYYMMDD), 
# and an array containing the cycle hours for each day (whose elements 
# have the form HH), returns an array of cycle date-hours whose elements
# have the form YYYYMMDD.  Here, YYYY is a four-digit year, MM is a two-
# digit month, DD is a two-digit day of the month, and HH is a two-digit
# hour of the day.
#
#-----------------------------------------------------------------------
#
function set_cycle_dates() {
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
  local scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
  local scrfunc_fn=$( basename "${scrfunc_fp}" )
  local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
  local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
# Specify the set of valid argument names for this script/function.  Then
# process the arguments provided to this script/function (which should
# consist of a set of name-value pairs of the form arg1="value1", etc).
#
#-----------------------------------------------------------------------
#
  local valid_args=( \
"date_start" \
"date_end" \
"cycle_hrs" \
"output_varname_all_cdates" \
"output_varname_cycle_inc" \
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
# Declare local variables.
#
#-----------------------------------------------------------------------
#
  local all_cdates date_crnt 
#
#-----------------------------------------------------------------------
#
# Ensure that the ending date is at or after the starting date.
#
#-----------------------------------------------------------------------
#
  if [ "${date_end}" -lt "${date_start}" ]; then
    print_err_msg_exit "\
End date (date_end) must be at or after start date (date_start):
  date_start = \"${date_start}\"
  date_end = \"${date_end}\""
  fi
#
#-----------------------------------------------------------------------
#
# In the following "while" loop, we begin with the starting date and 
# increment by 1 day each time through the loop until we reach the ending
# date.  For each date, we obtain an intermediate array of cdates (whose
# elements have the format YYYYMMDDHH) by prepending to the elements of 
# cycle_hrs the current date.  (Thus, this array has the same number of
# elements as cycle_hrs.)  We then append this intermediate array to the 
# final array that will contain all cdates (i.e. over all days and cycle
# hours).
#
#-----------------------------------------------------------------------
#
  all_cdates=()
  date_crnt="${date_start}"
  while [ "${date_crnt}" -le "${date_end}" ]; do
    all_cdates+=( $( printf "%s " ${cycle_hrs[@]/#/${date_crnt}} ) )
    date_crnt=$( date -d "${date_crnt} + 1 days" +%Y%m%d )
  done
#
#-----------------------------------------------------------------------
#
# Ensure daily cycles are equally spaced. All dates are converted to the
# number of seconds since 1970-01-01 00:00:00 UTC, then differences are
# computed between consecutive dates and checked to verify they are all
# identical.
#
#-----------------------------------------------------------------------
#
  all_ctime_refs=()
  for (( i=0; i<${#all_cdates[@]}; i++ )); do
    all_ctime_refs+=( $( date -u -d "${all_cdates[i]:0:8} ${all_cdates[i]:8:2}" +%s ) )
  done

  all_ctime_diffs=()
  for (( i=1; i<${#all_ctime_refs[@]}; i++ )); do
    all_ctime_diffs+=( $(( ( ${all_ctime_refs[i]} - ${all_ctime_refs[i-1]} ) / 3600 )) )
  done

  if [ ${#all_ctime_diffs[@]} -eq 0 ]; then
    all_ctime_diffs=( 0 )
  fi

  if [ $( echo "${all_ctime_diffs[@]}" | xargs -n 1 | sort -u | wc -l ) -ne 1 ]; then
    print_err_msg_exit "\
Daily cycles (cycle_hrs) need to be equally spaced:
  cycle_hrs = \"${cycle_hrs[*]}\"
  all_cdates = \"${all_cdates[*]}\""
  fi
#
#-----------------------------------------------------------------------
#
# Set output variables.
#
#-----------------------------------------------------------------------
#
  all_cdates_str="( "$( printf "\"%s\" " "${all_cdates[@]}" )")"     
  eval ${output_varname_all_cdates}=${all_cdates_str}             
  cycle_inc_str="( "$( printf "\"%02d\" " "${all_ctime_diffs[0]}" )")"
  eval ${output_varname_cycle_inc}=${cycle_inc_str}
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
  { restore_shell_opts; } > /dev/null 2>&1

}
