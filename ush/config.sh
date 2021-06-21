MACHINE="hera"
ACCOUNT="naqfc"
EXPT_SUBDIR="test_AOD_PM25"

QUEUE_DEFAULT="batch"
QUEUE_HPSS="service"
QUEUE_FCST="batch"

VERBOSE="TRUE"

RUN_ENVIR="community"
PREEXISTING_DIR_METHOD="rename"

# Set forecast model
FCST_MODEL="fv3gfs_aqm"

PREDEF_GRID_NAME="GSD_HRRR25km"
GRID_GEN_METHOD="JPgrid"
QUILTING="TRUE"
FCST_LEN_HRS="12"
LBC_UPDATE_INTVL_HRS="6"

DATE_FIRST_CYCL="20190801"
DATE_LAST_CYCL="20190814"
CYCL_HRS=( "00" "06" "12" "18" )

EXTRN_MDL_NAME_ICS="FV3GFS"
EXTRN_MDL_NAME_LBCS="FV3GFS"

RUN_TASK_MAKE_GRID="TRUE"
RUN_TASK_MAKE_OROG="TRUE"
RUN_TASK_MAKE_SFC_CLIMO="TRUE"

# Perform chemical (NO2, PM2.5, AOD) analysis task
# set RUN_TASK_CHEM_ANAL TRUE to generate NO2 tasks 
RUN_TASK_CHEM_ANAL="FALSE" 
USE_CHEM_ANAL="TRUE"


# set RUN_TASK_DACYC TRUE to generate PM2.5/AOD DA tasks 
RUN_TASK_DACYC="TRUE"        
DA_CYCLE_INTERV="6"
ANALYSIS_CYCLEDEF="00 06,12,18 06-06 08 2019 *"
FORECAST_CYCLEDEF="00 00,06,12,18 06-06 08 2019 *"


# Post-processing of meteorological output is enabled by default.
# Please set the variable below to FALSE to disable it.
# RUN_TASK_RUN_POST="FALSE"

# Generate air quality ICs and LBCs
# Set the following variable to TRUE to add air quality LBCs
RUN_TASK_ADD_AQM_LBCS="TRUE"
# Air quality ICs are added automatically between cycled runs
# To disable air quality ICs, set the variable below to FALSE
# RUN_TASK_ADD_AQM_ICS="FALSE"

# Run ARL NEXUS package to generate anthropogenic emissions
# for air quality experiments
RUN_TASK_RUN_NEXUS="TRUE"
# Set non-standard path to NEXUS input emission files
# NEXUS_INPUT_DIR="/path/to/nexus/input/emission/files"

# Set non-standard path to air quality configuration files
# AQM_CONFIG_DIR="/path/to/aqm/config"

# Set non-standard path to air quality emission directory
# AQM_EMIS_DIR="/path/to/emission/data"

# Set non-standard path to air quality boundary conditions
# directory and file names. File names can contain wildcards:
# <YYYYMMDD>, <YYYY>, <MM>, <DD>, which will be replaced with
# the current cycle date, year, month, and day, respectively.
 AQM_LBCS_DIR="/scratch2/BMC/wrfruc/rli/WF1/data/AQM_LBCS"
# AQM_LBCS_FILES="bndy_file_name_<MM>.ext"

# Set non-standard path to input observations directory
# note: this would be BUFR for GSI or IODA-formatted files for JEDI
# DA_OBS_DIR="/path/to/observation/data"

# Please set RESTART_WORKFLOW to TRUE or YES if continuing to run
# from a previous workflow cycle. Default is FALSE.
# RESTART_WORKFLOW="FALSE"
# Set full path to restart cycle. The restart cycle date and
# time must coincide with those from the workflow cycle that
# is expected to precede the starting cycle.
# RESTART_CYCLE_DIR=/scratch1/NCEPDEV/nems/Raffaele.Montuoro/dev/firex/dev/dev/expt_dirs/test_update/2020092100
# Set custom restart interval to an integer number of hours
# via RESTART_INTERVAL as shown below:
# RESTART_INTERVAL=01

PRINT_ESMF="TRUE"

LAYOUT_X=10
LAYOUT_Y=11
WRTCMP_write_groups=1
WRTCMP_write_tasks_per_group=10

# Use "cubed_sphere_grid" for output on the dynamical core grid
# WRTCMP_output_grid="cubed_sphere_grid"
