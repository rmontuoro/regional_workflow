#
# define the array of the name of build program
#
 declare -a Build_prg=("Build_libs" "Build_nexus" "Build_forecast" "Build_gsi" \
                       "Build_post" "Build_utils" "Build_chgres" "Build_chgres_cube" \
                       "Build_orog" "Build_sfc_climo_gen" "Build_regional_grid" "Build_nctools" \
                       "Build_mosaic_file" "Build_global_equiv_resol" "Build_JEDI")

#
# function parse_cfg: read config file and retrieve the values
#
 parse_cfg() {
   declare -i n
   declare -i num_args
   declare -i total_args
   declare -a all_prg
   total_args=$#
   num_args=$1
   (( num_args == 0 )) && return 0
   config=$2
   [[ ${config,,} == "--verbose" ]] && config=$3
   all_prg=()
   for (( n = num_args + 2; n <= total_args; n++ )); do
     all_prg+=( ${!n} )
   done

   if [[ ${config^^} == ALL ]]; then
#
# set all values to true
#
     for var in "${Build_prg[@]}"; do
       eval "$var=true"
     done
   elif [[ $config == config=* ]]; then
#
# process config file
#
     cfg_file=${config#config=}
     $verbose && echo "INFO: settings in config file: $cfg_file"
     while read cline; do
#  remove leading white space
       clean_line="${cline#"${cline%%[![:space:]]*}"}"
       ( [[ -z "$clean_line" ]] || [[ "${clean_line:0:1}" == "#" ]] ) || {
         $verbose && echo $clean_line
         first9=${clean_line:0:9}
         [[ ${first9,,} == "building " ]] && {
           short_prg=$(sed -e 's/.*(\(.*\)).*/\1/' <<< "$clean_line")
#  remove trailing white space
           clean_line="${cline%"${cline##*[![:space:]]}"}"
           build_action=true
           last5=${clean_line: -5}
           [[ ${last5,,} == ". yes" ]] && build_action=true
           last4=${clean_line: -4}
           [[ ${last4,,} == ". no" ]] && build_action=false
           found=false
           for prg in ${all_prg[@]}; do
             [[ $prg == "Build_"$short_prg ]] && {
               found=true
               eval "$prg=$build_action"
               break
             }
           done
           $found || {
             echo "*** Unrecognized line in config file \"$cfg_file\":" 2>&1
             echo "$cline" 2>&1
             exit 3
           }
         }
       }
     done < $cfg_file
   elif [[ $config == select=* ]]; then
#
# set all values to (default) false
#
     for var in "${Build_prg[@]}"; do
       eval "$var=false"
     done
#
# read command line partial build setting
#
     del=""
     sel_prg=${config#select=}
     for separator in " " "," ";" ":" "/" "|"; do
       [[ "${sel_prg/$separator}" == "$sel_prg" ]] || {
         del=$separator
         sel_prg=${sel_prg//$del/ }
       }
     done
     [[ $del == "" ]] && {
       short_prg=$sel_prg
       found=false
       for prg in ${all_prg[@]}; do
         [[ $prg == "Build_"$short_prg ]] && {
           found=true
           eval "$prg=true"
           break
         }
       done
       $found || {
         echo "*** Unrecognized program name \"$short_prg\" in command line" 2>&1
         exit 4
       }
     } || {
       for short_prg in $(echo ${sel_prg}); do
         found=false
         for prg in ${all_prg[@]}; do
           [[ $prg == "Build_"$short_prg ]] && {
             found=true
             eval "$prg=true"
             break
           }
         done
         $found || {
           echo "*** Unrecognized program name \"$short_prg\" in command line" 2>&1
           exit 5
         }
       done
     }
   else
     echo "*** Unrecognized command line option \"$config\"" 2>&1
     exit 6
   fi
 }

#
# read command line arguments; processing config file
#
 verbose=false
 num_arg=$#
 (( num_arg > 1 )) && {
   [[ ${1,,} == "--verbose" ]] && {
     verbose=true
   } || {
     echo "Usage: $0 [ALL|config=config_file|[select=][prog1[,prog2[,...]]]" 2>&1
     exit 1
   }
 }
 (( num_arg == 1 )) && {
     ( [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ) && {
       echo "Usage: $0 [ALL|config=config_file|[select=][prog1[,prog2[,...]]]" 2>&1
       exit 2
     }
     ( [[ $1 == "-v" ]] || [[ ${1,,} == "--verbose" ]] ) && {
       verbose=true
       num_arg=0
     } || {
       echo "Usage: $0 [ALL|config=config_file|[select=][prog1[,prog2[,...]]]" 2>&1
       exit 3
     }
 }

 if (( num_arg == 0 )); then
#
# set default values for partial build
#
   parse_cfg 1 "config=regional_build.cfg" ${Build_prg[@]}
 else

#
# call arguments retriever/config parser
#
   parse_cfg $num_arg "$@" ${Build_prg[@]}
 fi

#
# print values of build array
#
 $verbose && {
   echo "INFO: partial build settings:"
   for var in "${Build_prg[@]}"; do
     echo -n "  $var: "
     ${!var} && echo True || echo False
   done
 }

 echo "=== end of partial build setting ===" > /dev/null

