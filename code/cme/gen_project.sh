
# run local
# poolsize=8;
cohort_csv='/Users/dh/workspace/BDL/demapper/data/cme/cohort_mapper.csv';
% from: /scratch/groups/saggar/dh/pipeline/projects/cme/cohort_mapper.csv
config_path='/Users/dh/workspace/BDL/demapper/code/configs/mappers_cmev6kval_fast.json';
data_root='/Users/dh/workspace/BDL/demapper/data/cme/shine';
output_dir='/Users/dh/workspace/BDL/demapper/results/cme_mappers/mappers_cmev6kval_fast.json';
run_main


# `sdev` and then run the following:
module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-cme/mappers_cmev4_euc.json/"
FN_TIMING="/oak/stanford/groups/saggar/data-cme-shine375/timing.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-cme/analysis/ch8_mappers_cmev4_euc.json/"
STAT_TYPE="degrees_TRs" # "compute_degrees_from_TCM", "compute_degrees"
CHANGE_POINTS=8
HAS_INSTRUCTIONS=1;
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}'; stat_type='${STAT_TYPE}';"
ARGS="$ARGS HAS_INSTRUCTIONS=${HAS_INSTRUCTIONS}; CHANGE_POINTS=${CHANGE_POINTS};"
matlab -r "${ARGS} run('code/cme/deg_analysis_sbjs.m')"





python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/dh/pipeline/projects/cme/cohort_mapper.csv \
    --mapper_dir /scratch/groups/saggar/demapper-cme/mappers_cmev3_fast.json

sbatch -p normal /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev3.json \
     --rerun_uncomputed --rerun_analysis plot_task


sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev6kval_fast.json \
    --rerun_uncomputed 

sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev4_euc_fast.json --rerun_uncomputed 

sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev5MH.json --rerun_uncomputed 



MAPPERCONF=mappers_cmev4_euc.json
python3 code/utils/plot_task_grid.py \
    /scratch/groups/saggar/demapper-cme/${MAPPERCONF} \
    /scratch/groups/saggar/demapper-cme/analysis/ch8_${MAPPERCONF}/plot_task-grids
