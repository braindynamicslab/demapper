


echo """
{
      \"id0\": [\"SBJ01\", \"SBJ02\", \"SBJ03\", \"SBJ04\", \"SBJ06\", \"SBJ07\", \"SBJ08\", \"SBJ09\", \"SBJ10\", \"SBJ12\", \"SBJ13\", \"SBJ14\", \"SBJ15\", \"SBJ16\", \"SBJ17\", \"SBJ18\", \"SBJ19\", \"SBJ20\"],
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"{{id0}}_Shine_375.npy\",
      \"TR\": 1.5
}""" > CME_ids.json


neupipe mapper cme \
    /oak/stanford/groups/saggar/data-cme-shine375/ \
    --data-json-path CME_ids.json \
    --output-path /scratch/groups/saggar/demapper-cme/ \
    --project-dir $HOME/projects/cme/ \
    --mappertoolbox-dir /home/groups/saggar/repos/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=1.5



# run local
# poolsize=8;
cohort_csv='/Users/dh/workspace/BDL/demapper/data/cme/cohort_mapper.csv';
% from: /scratch/groups/saggar/dh/pipeline/projects/cme/cohort_mapper.csv
config_path='/Users/dh/workspace/BDL/demapper/code/configs/mappers_cmev6kval_debug.json';
data_root='/Users/dh/workspace/BDL/demapper/data/cme/shine';
output_dir='/Users/dh/workspace/BDL/demapper/results/cme_mappers/mappers_cmev6kval_fast.json';
run_main


# `sdev` and then run the following:
module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-cme/mappers_cmev7kval_fast.json/"
FN_TIMING="/oak/stanford/groups/saggar/data-cme-shine375/timing.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-cme/analysis/ch10_mappers_cmev7kval_fast.json/"
STAT_TYPE="compute_degrees_from_TCM" # "compute_degrees_from_TCM", "compute_degrees", "degrees_TRs"
CHANGE_POINTS=10
HAS_INSTRUCTIONS=1;
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}'; stat_type='${STAT_TYPE}';"
ARGS="$ARGS HAS_INSTRUCTIONS=${HAS_INSTRUCTIONS}; CHANGE_POINTS=${CHANGE_POINTS};"
matlab -r "${ARGS} run('code/cme/deg_analysis_sbjs.m')"



python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/dh/pipeline/projects/cme/cohort_mapper.csv \
    --mapper_dir /scratch/groups/saggar/demapper-cme/mappers_cmev7kval_fast.json


sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev3_disp.json \
     --rerun_uncomputed --rerun_analysis plot_task


sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev6kval_disp.json \
    --rerun_uncomputed 

sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev4_euc_fast.json --rerun_uncomputed 

sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev5MH.json --rerun_uncomputed 


---
### the new versions

sbatch /home/users/hasegan/projects/cme/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_cmev3_disp.json \
    --rerun_uncomputed

# cache
python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /home/users/hasegan/projects/cme/cohort_mapper.csv \
    --mapper_dir /scratch/groups/saggar/demapper-cme/mappers_cmev3_disp.json




MAPPERCONF=mappers_cmev4_euc.json
python3 code/utils/plot_task_grid.py \
    /scratch/groups/saggar/demapper-cme/${MAPPERCONF} \
    /scratch/groups/saggar/demapper-cme/analysis/ch8_${MAPPERCONF}/plot_task-grids



# RERUN_UNCOMPUTED
RERUN_UNCOMPUTED=1;
datafolder='/scratch/groups/saggar/demapper-cme/mappers_cmev6kval_fast.json/';
fn_timing='/oak/stanford/groups/saggar/data-cme-shine375/timing.csv';
output_dir='/scratch/groups/saggar/demapper-cme/analysis/ch7_mappers_cmev6kval_fast.json/';
stat_type='compute_degrees_from_TCM'; HAS_INSTRUCTIONS=1; CHANGE_POINTS=7;
run('code/cme/deg_analysis_sbjs.m')

MAPPER_NAME=ch7_mappers_cmev6kval_fast.json
mkdir $MAPPER_NAME
pushd $MAPPER_NAME
scp hasegan@login.sherlock.stanford.edu:/scratch/groups/saggar/demapper-cme/analysis/${MAPPER_NAME}/compute_degrees_from_TCM/combined-compute_degrees_from_TCM.csv .
popd 
