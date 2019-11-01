#!/bin/sh
#############################################################################
# Script name:		exfv3cam_cleanup.sh
# Script description:	Scrub old files and directories
# Script history log:
#   1) 2018-04-09	Ben Blake
#			new script
#############################################################################
set -x

# Remove temporary working directories
cd ${STMP}
if [ $RUN = fv3sar -o $RUN = fv3sar_da ]; then
  cd tmpnwprd
elif [ $RUN = fv3nest ]; then
  cd tmpnwprd_nest
fi

rm -rf regional_make_bc_*_${CDATE}
rm -rf regional_make_ic_*_${CDATE}
rm -rf regional_forecast_firstguess_${dom}_${CDATE}
rm -rf regional_forecast_tm*_${dom}_${CDATE}
rm -rf regional_gsianl_tm*_${dom}_${CDATE}
rm -rf regional_post_*_${dom}_${CDATE}
rm -rf regional_post_goes_${dom}_f*_${CDATE}

exit
