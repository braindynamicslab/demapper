
# `sdev` and then run the following:
module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-cme/mappers_cmev3.json/"
FN_TIMING="/oak/stanford/groups/saggar/data-cme-shine375/timing.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-cme/analysis/mappers_cmev3.json/"
STAT_TYPE="degrees_TRs"
CHANGE_POINTS=7
HAS_INSTRUCTIONS=1;
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}'; stat_type='${STAT_TYPE}';"
ARGS="$ARGS HAS_INSTRUCTIONS=${HAS_INSTRUCTIONS}; CHANGE_POINTS=${CHANGE_POINTS};"
matlab -r "${ARGS} run('code/cme/deg_analysis_sbjs.m')"





python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/dh/pipeline/projects/cme/cohort_mapper.csv \
    --mapper_dir /scratch/groups/saggar/demapper-cme/mappers_cmev3.json/
