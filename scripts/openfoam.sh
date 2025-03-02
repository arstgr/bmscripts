#!/bin/bash

export PPN_LIST=(120) 
export THRD_LIST=(1)
export REPS=1

export mpi_library=hpcx

export INPUTDIR="/home/jonsteam/amir/openfoam/data"  #directory where the initial conditions are residing
export RUNDIR="/home/jonsteam/amir/openfoam/results-avx2/"
###################################################################
basedir=$(pwd)

export PATH=/home/jonsteam/amir/uProf/AMDuProf_Nda_Linux_x64_4.1.284/bin:$PATH
source /home/jonsteam/amir/aocc/setenv_AOCC.sh
source /home/jonsteam/amir/mpi/hpcx-v2.15-gcc-MLNX_OFED_LINUX-5-redhat8-cuda12-gdrcopy2-nccl2.17-x86_64/hpcx-init.sh
hpcx_load
export PMIX_INSTALL_PREFIX=$OPAL_PREFIX

source /home/jonsteam/amir/spack/share/spack/setup-env.sh
echo "Loading openfoam ..."
# 5yigy6ycw => znver4
# ehr5da6mbp => znver2
spack load openfoam@2206 /ehr5da6mbp

export az_FOAMROOT=$WM_PROJECT_DIR
source $INSTALL_DIR/etc/bashrc FOAMY_HEX_MESH=yes
source $FOAM_ETC/bashrc

. ${WM_PROJECT_DIR:?}/bin/tools/RunFunctions

which mpirun
which potentialFoam
which simpleFoam

cp ${basedir}/decomposeParDict $WM_PROJECT_DIR/tutorials/incompressible/simpleFoam/motorBike/system/

cd $RUNDIR

for NPPNS in ${PPN_LIST[@]}; do
for NTHRDS in ${THRD_LIST[@]}; do
for ((i=1 ; i<= $REPS ; i++)); do

OUTPUTDIR=BENCH_${NPPNS}_1_${NPPNS}.$i
mkdir $OUTPUTDIR
cd $OUTPUTDIR

if [ "$NPPNS" == "96" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 2,3,4,5,10,11,12,13,16,17,18,19,24,25,26,27,32,33,34,35,40,41,42,43,50,51,52,53,58,59,60,61,64,65,66,67,72,73,74,75,80,81,82,83,88,89,90,91,98,99,100,101,106,107,108,109,112,113,114,115,120,121,122,123,128,129,130,131,136,137,138,139,146,147,148,149,154,155,156,157,160,161,162,163,160,161,162,163,168,169,170,171,176,177,178,179,184,185,186,187 --rank-by slot --report-bindings "
elif [ "$NPPNS" == "120" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 2,3,4,5,6,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,32,33,34,35,36,40,41,42,43,44,50,51,52,53,54,58,59,60,61,62,64,65,66,67,68,72,73,74,75,76,80,81,82,83,84,88,89,90,91,92,98,99,100,101,102,106,107,108,109,110,112,113,114,115,116,120,121,122,123,124,128,129,130,131,132,136,137,138,139,140,146,147,148,149,150,154,155,156,157,158,160,161,162,163,164,168,169,170,171,172,176,177,178,179,180,184,185,186,187,188  --rank-by slot --report-bindings "
elif [ "$NPPNS" == "144" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 2,3,4,5,6,7,10,11,12,13,14,15,18,19,20,21,22,23,26,27,28,29,30,31,34,35,36,37,38,39,42,43,44,45,46,47,50,51,52,53,54,55,58,59,60,61,62,63,66,67,68,69,70,71,74,75,76,77,78,79,82,83,84,85,86,87,90,91,92,93,94,95,98,99,100,101,102,103,106,107,108,109,110,111,114,115,116,117,118,119,122,123,124,125,126,127,130,131,132,133,134,135,138,139,140,141,142,143,146,147,148,149,150,151,154,155,156,157,158,159,162,163,164,165,166,167,170,171,172,173,174,175,178,179,180,181,182,183,186,187,188,189,190,191 --rank-by slot --report-bindings "
elif [ "$NPPNS" == "176" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 2,3,4,5,6,7,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,50,51,52,53,54,55,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,98,99,100,101,102,103,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,146,147,148,149,150,151,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191 --rank-by slot --report-bindings "
else
            echo "No defined setting for Core count: $NPPNS"
            mppflags="--report-bindings"
fi

export mpi_options="-np $NPPNS $mppflags --rank-by slot -x LD_LIBRARY_PATH -x PATH -x PWD 
-x MPI_BUFFER_SIZE -x WM_PROJECT_DIR -x WM_DIR -x WM_PROJECT_USER_DIR -x WM_PROJECT_INST_DIR --allow-run-as-root"

echo mpi_options: $mpi_options


DECOMPOSE_NAME=DECOMPOSE_${NPPNS}_1_${NPPNS}
DECOMPOSE_DIR=$INPUTDIR/${DECOMPOSE_NAME}
if [ -d ${DECOMPOSE_DIR} ]; then
  cp -pr $DECOMPOSE_DIR/* .
else
  echo "Error: Decompose directory ${DECOMPOSE_DIR} not found"
  exit
fi

decompDict="decomposePar -decomposeParDict system/decomposeParDict"

restore0Dir -processor

foamDictionary -entry relaxationFactors.equations.U -set 0.1 system/fvSolution                                ###was 0.1
foamDictionary -entry relaxationFactors.equations.k -set 0.1 system/fvSolution                                ###was 0.1
foamDictionary -entry relaxationFactors.equations.omega -set 0.025 system/fvSolution                            ###was 0.025
foamDictionary -entry relaxationFactors.fields.p -set 0.08 system/fvSolution                                   ###was 0.08

foamDictionary -entry writeInterval -set 1000 system/controlDict
foamDictionary -entry runTimeModifiable -set "false" system/controlDict
foamDictionary -entry functions -set "{}" system/controlDict
foamDictionary -entry endTime -set 100 system/controlDict

echo -n "Azure benchmark: running potentialFoam "
date +%s ; date -u

export PMIX_INSTALL_PREFIX=$OPAL_PREFIX
mpirun $mpi_options -x PMIX_INSTALL_PREFIX=$OPAL_PREFIX potentialFoam -parallel 2>&1 | tee log.potentialFoam

echo -n "Azure benchmark: running simpleFoam "
date +%s ; date -u
#mpirun $mpi_options simpleFoam -decomposeParDict system/decomposeParDict -parallel 2>&1 | tee log.simpleFoam
export PMIX_INSTALL_PREFIX=$OPAL_PREFIX
mpirun $mpi_options -x PMIX_INSTALL_PREFIX=$OPAL_PREFIX simpleFoam -parallel 3>&1 | tee log.simpleFoam

echo -n "Azure benchmark: cleaning up "
date +%s ; date -u

rm -rf ./processor*
echo -n "Azure benchmark: finish run_benchmark "
date +%s ; date -u

cd ..

done
done
done
