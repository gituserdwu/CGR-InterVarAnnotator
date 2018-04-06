#!/bin/bash

module load python/3.5
cd /data/karlinser/OsteoExome/interVar/working/Test6
sbcmd="sbatch --export=ALL --cpus-per-task={threads} --mem={cluster.mem}"
sbcmd+=" --time={cluster.time} --partition=quick"
sbcmd+=" --out={cluster.out} {cluster.extra}"
snakemake -pr --keep-going --local-cores 1 --jobs 100 --cluster-config cluster.json --cluster "$sbcmd" --latency-wait 120 all
