#!/bin/bash
#PBS -N bench_motorBike_4M
#PBS -l walltime=03:00:00
#PBS -l select=8:ncpus=176:mpiprocs=120:ompthreads=1
#PBS -l place=scatter:exclhost
#PBS -j oe

ulimit -s unlimited
ulimit -l unlimited
ulimit -a

module load mpi/hpcx
cd $PBS_O_WORKDIR
. /anf/apps/spack/share/spack/setup-env.sh
spack load openfoam@2206

export PMIX_INSTALL_PREFIX=$OPAL_PREFIX

NODES=$(sort -u < $PBS_NODEFILE | wc -l)
PPN=$(uniq -c < $PBS_NODEFILE | tail -n1 | awk '{print $1}')
CORES=$(wc -l <$PBS_NODEFILE)

if [ "$PPN" == "96" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 0,1,2,3,8,9,10,11,16,17,18,19,24,25,26,27,32,33,34,35,38,39,40,41,44,45,46,47,52,53,54,55,60,61,62,63,68,69,70,71,76,77,78,79,82,83,84,85,88,89,90,91,96,97,98,99,104,105,106,107,112,113,114,115,120,121,122,123,126,127,128,129,132,133,134,135,140,141,142,143,148,149,150,151,156,157,158,159,164,165,166,167,170,171,172,173 --rank-by slot --report-bindings"
elif [ "$PPN" == "120" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 0,1,2,3,4,8,9,10,11,12,16,17,18,19,20,24,25,26,27,28,32,33,34,35,36,38,39,40,41,42,44,45,46,47,48,52,53,54,55,56,60,61,62,63,64,68,69,70,71,72,76,77,78,79,80,82,83,84,85,86,88,89,90,91,92,96,97,98,99,100,104,105,106,107,108,112,113,114,115,116,120,121,122,123,124,126,127,128,129,130,132,133,134,135,136,140,141,142,143,144,148,149,150,151,152,156,157,158,159,160,164,165,166,167,168,170,171,172,173,174 --rank-by slot --report-bindings"
elif [ "$PPN" == "144" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 0,1,2,3,4,5,8,9,10,11,12,13,16,17,18,19,20,21,24,25,26,27,28,29,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,52,53,54,55,56,57,60,61,62,63,64,65,68,69,70,71,72,73,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,96,97,98,99,100,101,104,105,106,107,108,109,112,113,114,115,116,117,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,140,141,142,143,144,145,148,149,150,151,152,153,156,157,158,159,160,161,164,165,166,167,168,169,170,171,172,173,174,175 --rank-by slot --report-bindings"
elif [ "$PPN" == "176" ]
then
            mppflags="--bind-to cpulist:ordered --cpu-set 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175 --rank-by slot --report-bindings"
else
            echo "No defined setting for Core count: $PPN"
            mppflags="--map-by ppr:1:node --report-bindings"
	    #UCX_IB_NUM_PATHS=1
fi
export mpi_options="-machinefile $PBS_NODEFILE -np $CORES $mppflags --rank-by slot -x LD_LIBRARY_PATH -x PATH -x PWD -x WM_PROJECT_DIR -x WM_DIR -x WM_PROJECT_USER_DIR -x WM_PROJECT_INST_DIR"

mkdir $PBS_O_WORKDIR/$PBS_JOBID
cd $PBS_O_WORKDIR/$PBS_JOBID

if [ ! -f $PBS_O_WORKDIR/motorBikeDemo.tgz ]; then
    wget 'https://static.us-east-1.prod.workshops.aws/public/e6925ebe-b285-46d8-bfc4-6160c69f8742/static/resources/motorBikeDemo.tgz' -O motorBikeDemo.tgz
    tar -xzf motorBikeDemo.tgz
fi
cp -r $PBS_O_WORKDIR/motorBikeDemo/* . 

source /anf/apps/spack/share/spack/setup-env.sh
spack load openfoam@2206
source /anf/apps/spack/opt/spack/linux-almalinux8-x86_64/aocc-4.0.0/openfoam-2206-niw5fjy5lhgm6aa57p757oopf6hvv75l/etc/bashrc

cp $FOAM_TUTORIALS/resources/geometry/motorBike.obj.gz constant/triSurface/
starta=`date +%s`
surfaceFeatureExtract  > ./log.surfaceFeatureExtract 2>&1
blockMesh  > ./log.blockMesh 2>&1

foamDictionary -entry numberOfSubdomains -set $CORES system/decomposeParDict
foamDictionary -entry method -set multiLevel system/decomposeParDict
foamDictionary -entry multiLevelCoeffs -set "{}" system/decomposeParDict
foamDictionary -entry scotchCoeffs -set "{}" system/decomposeParDict
foamDictionary -entry hierarchicalCoeffs -set "{}" system/decomposeParDict
foamDictionary -entry multiLevelCoeffs.level0 -set "{}" system/decomposeParDict
foamDictionary -entry multiLevelCoeffs.level0.numberOfSubdomains -set $NODES system/decomposeParDict
foamDictionary -entry multiLevelCoeffs.level0.method -set scotch system/decomposeParDict
foamDictionary -entry multiLevelCoeffs.level1 -set "{}" system/decomposeParDict
foamDictionary -entry multiLevelCoeffs.level1.numberOfSubdomains -set $PPN system/decomposeParDict
foamDictionary -entry multiLevelCoeffs.level1.method -set scotch system/decomposeParDict

decomposePar -decomposeParDict system/decomposeParDict  > ./log.decomposePar 2>&1
mpirun $mpi_options snappyHexMesh -parallel -overwrite -decomposeParDict system/decomposeParDict   > ./log.snappyHexMesh 2>&1
mpirun $mpi_options checkMesh -parallel -allGeometry -constant -allTopology -decomposeParDict system/decomposeParDict > ./log.checkMesh 2>&1 
mpirun $mpi_options redistributePar -parallel -overwrite -decomposeParDict system/decomposeParDict > ./log.decomposePar2 2>&1 
mpirun $mpi_options renumberMesh -parallel -overwrite -constant -decomposeParDict system/decomposeParDict > ./log.renumberMesh 2>&1
mpirun $mpi_options patchSummary -parallel -decomposeParDict system/decomposeParDict > ./log.patchSummary 2>&1
ls -d processor* | xargs -i rm -rf ./{}/0
ls -d processor* | xargs -i cp -r 0.orig ./{}/0
mpirun $mpi_options potentialFoam -parallel -noFunctionObjects -initialiseUBCs -decomposeParDict system/decomposeParDict > ./log.potentialFoam 2>&1
starts=`date +%s`
mpirun $mpi_options simpleFoam -parallel  -decomposeParDict system/decomposeParDict > ./log.simpleFoam 2>&1
end=`date +%s`

runtime=$((end-starta))
runtimes=$((end-starts))

echo "****************************" > log.run
echo "N=$NODES  PPN=$PPN" >> log.run
echo "TOTAL RUNTIME=$runtime" >> log.run
echo "simpleFOAM RUNTIME=$runtimes" >> log.run
echo "****************************" >> log.run

