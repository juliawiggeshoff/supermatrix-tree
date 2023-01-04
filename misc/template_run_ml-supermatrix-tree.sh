#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -j y
#$ -o cluster_logs/
#$ -q small.q,medium.q,large.q
#$ -N ml-supermatrix-tree
#$ -pe smp 31
#$ -M user.email@gmail.com
#$ -m be

mkdir -p cluster_logs/

module load anaconda3/2022.05
conda activate /home/myusername/.conda/envs/localconda/envs/ml-supermatrix-tree

#one core will be used by snakemake to monitore the other processes
THREADS=$(expr ${NSLOTS} - 1)

snakemake \
    --snakefile workflow/Snakefile \
    --configfile config/configfile.yaml \
    --keep-going \
    --latency-wait 300 \
    --use-conda \
    --cores ${THREADS} \
    --verbose \
    --printshellcmds \
    --reason \
    --nolock 
