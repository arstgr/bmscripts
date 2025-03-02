#!/bin/bash
#
source hpcx-v2.22.1-gcc-inbox-ubuntu24.04-cuda12-aarch64/hpcx-init.sh
hpcx_load

export LDPTH=$PWD/nvidia_hpc_benchmarks_openmpi-linux-sbsa-25.02.04-archive/lib/
export LD_LIBRARY_PATH=$LDPTH/cuda:$LDPTH/gdrcopy:$LDPTH/nccl:$LDPTH/nvpl_blas:$LDPTH/nvpl_lapack:$LDPTH/nvpl_sparse:$LDPTH/nvshmem:$LDPTH/omp:$LDPTH/tcmalloc:$LD_LIBRARY_PATH

cd $PWD/nvidia_hpc_benchmarks_openmpi-linux-sbsa-25.02.04-archive/hpl-linux-aarch64-gpu/

if test -f "HPL.dat"; then
    rm HPL.dat
fi

cat << EOF > HPL.dat
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
284672       Ns
1            # of NBs
2048         NBs
1            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
2            Ps
2            Qs
16.0         threshold
1            # of panel fact
0 1 2        PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
2 8          NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
0 1 2        RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
3 2          BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1 0          DEPTHs (>=0)
1            SWAP (0=bin-exch,1=long,2=mix)
192          swapping threshold
1            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
0            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOF

mpirun -np 4 --map-by ppr:4:node:PE=32 -x OMP_NUM_THREADS=32 -x LD_LIBRARY_PATH -x UCX_IB_PCI_RELAXED_ORDERING=on  -x UCX_RNDV_SCHEME=get_zcopy -x CUDA_VISIBLE_DEVICES="0,1,2,3" -x NVSHMEM_REMOTE_TRANSPORT=none -x NVSHMEM_DISABLE_NVLS=1 -x NCCL_NVLS_ENABLE=0 -x WARMUP_END_PROG=40 --mca coll ^hcoll ./xhpl
