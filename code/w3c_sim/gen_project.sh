
# Generate the cohort file based on this json
echo """
{
      "id0": "SBJ99",
      "id1": "", "id2": "",
      "path": "w3c_simulated_bold.npy",
      "TR": 0.72
}""" > W3C_ids.json

# Generate the project
cd $GROUP_SCRATCH/dh/pipeline/
python3 neupipe/mapper.py w3c \
    /scratch/groups/saggar/demapper-w3c/data \
    --data-json-path W3C_ids.json \
    --output-path /scratch/groups/saggar/demapper-w3c/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/neupipe/projects/w3c/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72

# Start the job on all configs
sbatch -p owners /scratch/groups/saggar/dh/pipeline/neupipe/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv1.json \
    --rerun_uncomputed

sbatch -p owners /scratch/groups/saggar/dh/pipeline/neupipe/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv2.json \
    --rerun_uncomputed



# `sdev` and then run the following:
module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/mappers_w3cv2.json/"
FN_TIMING="/scratch/groups/saggar/demapper-w3c/data/task_info.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv2.json/"
STAT_TYPE="degrees_TRs"
CHANGE_POINTS=7
HAS_INSTRUCTIONS=0;
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}'; stat_type='${STAT_TYPE}';"
ARGS="$ARGS HAS_INSTRUCTIONS=${HAS_INSTRUCTIONS}; CHANGE_POINTS=${CHANGE_POINTS};"
matlab -r "${ARGS} run('code/cme/deg_analysis_sbjs.m')"

# Or run the circle test:
module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/mappers_w3cv2.json/"
FN_TIMING="/scratch/groups/saggar/demapper-w3c/data/task_info.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv2.json/"
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
matlab -r "${ARGS} run('code/w3c_sim/circle_test.m')"
