#!/bin/bash -l

set +x
. /apps/lmod/lmod/init/sh
set -x

. /scratch2/NCEPDEV/fv3-cam/Eric.Rogers/regional_workflow/rocoto/machine-setup.sh
export machine=${target}

module use ${HOMEfv3}/modulefiles/${machine}
module load fv3

module use /apps/modules/modulefiles
module load rocoto/1.3.1

rocotorun -v 10 -w /scratch2/NCEPDEV/fv3-cam/Eric.Rogers/regional_workflow/rocoto/old/drive_fv3sar_da.xml -d /scratch2/NCEPDEV/fv3-cam/Eric.Rogers/regional_workflow/rocoto/old/drive_fv3sar_da.db
