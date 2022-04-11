
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


## Within a shell, combine the stats:
python3 code/combine.py /scratch/groups/saggar/demapper-w3c/mappers_w3cv1.json \
    /scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv1.json/

python3 code/combine.py /scratch/groups/saggar/demapper-w3c/mappers_w3cv2.json \
    /scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv2.json/


# Subsampled data

echo """
{
      \"id0\": [\"SBJ99\", \"SBJ20\", \"SBJ21\", \"SBJ40\", \"SBJ41\", \"SBJ42\", \"SBJ43\", \"SBJ80\", \"SBJ81\", \"SBJ82\", \"SBJ83\", \"SBJ84\", \"SBJ85\", \"SBJ86\", \"SBJ87\", \"SBJ99-50.0\", \"SBJ20-50.0\", \"SBJ40-50.0\", \"SBJ80-50.0\", \"SBJ99-75.0\", \"SBJ20-75.0\", \"SBJ40-75.0\", \"SBJ80-75.0\", \"SBJ99-83.0\", \"SBJ20-83.0\", \"SBJ40-83.0\", \"SBJ80-83.0\"],
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"{{id0}}_bold.npy\",
      \"TR\": 0.72
}""" > W3C_ids_ss.json


# subsampled
python3 neupipe/mapper.py ss_w3c \
    /scratch/groups/saggar/demapper-w3c/data_subsampled \
    --data-json-path W3C_ids_ss.json \
    --output-path /scratch/groups/saggar/demapper-w3c/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/neupipe/projects/ss_w3c/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72

# change in run_mapper.sbatch so that the cohort file points to the correct file:
vim /scratch/groups/saggar/dh/pipeline/neupipe/projects/ss_w3c//run_mapper.sbatch

# Point to:
/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_short.csv

# start the mappers
sbatch -p owners /scratch/groups/saggar/dh/pipeline/neupipe/projects/ss_w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv2.json \
    --rerun_uncomputed

sbatch -p owners /scratch/groups/saggar/dh/pipeline/neupipe/projects/ss_w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv1.json \
    --rerun_uncomputed
