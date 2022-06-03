
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
    --project-dir $GROUP_SCRATCH/dh/pipeline/projects/w3c/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72

# Start the job on all configs
sbatch -p owners /scratch/groups/saggar/dh/pipeline/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv1.json \
    --rerun_uncomputed

sbatch -p owners /scratch/groups/saggar/dh/pipeline/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv2.json \
    --rerun_uncomputed




# Or run the circle test:
module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/mappers_w3cv2.json/"
FN_TIMING="/scratch/groups/saggar/demapper-w3c/data/task_info.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv2.json/"
ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
matlab -r "${ARGS} run('code/w3c_sim/circle_test.m')"

# Circle test for added noise
module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/wnoise_results/mappers_w3cv1.json/"
FN_TIMING="/scratch/groups/saggar/demapper-w3c/data/task_info.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/wnoise_results/analysis/mappers_w3cv1.json/"

ARGS="datafolder='${DATAFOLDER}'; fn_timing='${FN_TIMING}'; output_dir='${OUTPUT_DIR}';"
matlab -r "${ARGS} run('code/w3c/circle_test.m')"


## Within a shell, combine the stats:
python3 code/combine.py /scratch/groups/saggar/demapper-w3c/mappers_w3cv1.json \
    /scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv1.json/

python3 code/combine.py /scratch/groups/saggar/demapper-w3c/mappers_w3cv2.json \
    /scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv2.json/

# For wnoise
python3 code/combine.py /scratch/groups/saggar/demapper-w3c/wnoise_results/mappers_w3cv2.json \
    /scratch/groups/saggar/demapper-w3c/wnoise_results/analysis/mappers_w3cv2.json/


# Subsampled data

echo """
{
      \"id0\": [\"SBJ99\", \"SBJ20\", \"SBJ21\", \"SBJ40\", \"SBJ41\", \"SBJ42\", \"SBJ43\", \"SBJ80\", \"SBJ81\", \"SBJ82\", \"SBJ83\", \"SBJ84\", \"SBJ85\", \"SBJ86\", \"SBJ87\", \"SBJ99-50.0\", \"SBJ20-50.0\", \"SBJ40-50.0\", \"SBJ80-50.0\", \"SBJ99-75.0\", \"SBJ20-75.0\", \"SBJ40-75.0\", \"SBJ80-75.0\", \"SBJ99-83.0\", \"SBJ20-83.0\", \"SBJ40-83.0\", \"SBJ80-83.0\"],
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"{{id0}}_bold.npy\",
      \"TR\": 0.72
}""" > W3C_ids_ss.json


# subsampled
python3 neupipe/mapper.py w3c_subsampled \
    /scratch/groups/saggar/demapper-w3c/data_subsampled \
    --data-json-path W3C_ids_ss.json \
    --output-path /scratch/groups/saggar/demapper-w3c/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/projects/w3c_subsampled/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72

# change in run_mapper.sbatch so that the cohort file points to the correct file:
vim /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled//run_mapper.sbatch

# Point to:
/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_shorter.csv

# start the mappers
sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv4.json \
    --rerun_uncomputed

# might need highmem for some configs:
sbatch -p saggar \
    /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled/run_mapper-highmem.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv4_euc.json \
    --rerun_uncomputed

sbatch -p bigmem \
    /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled/run_mapper-highmem.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv7embed.json \
    --rerun_uncomputed

# Compute stats
python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_shorter.csv \
    --mapper_dir /scratch/groups/saggar/demapper-w3c/mappers_w3cv7embed.json/



## Regenerate plots without the legend
cd $HOME/demapper/code/configs/
mv mappers_w3cv3.json mappers_w3cv3.json-backup
cp mappers_w3cv3_reg.json mappers_w3cv3.json


# then run:
sbatch -p saggar \
    /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv3.json \
    --rerun_analysis plot_task

# Fix back: 
mv $HOME/demapper/code/configs/mappers_w3cv3.json-backup $HOME/demapper/code/configs/mappers_w3cv3.json

##############################################
####################### Data with noise ######
##############################################

python3 neupipe/mapper.py w3c_wnoise \
    /scratch/groups/saggar/demapper-w3c/data_wnoise \
    --data-json-path W3C_ids_wnoise.json \
    --output-path /scratch/groups/saggar/demapper-w3c/wnoise_results/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/projects/w3c_wnoise/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72


sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/w3c_wnoise//run_mapper-highmem.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv3.json \
    --rerun_uncomputed

sbatch -p normal /scratch/groups/saggar/dh/pipeline/projects/w3c_wnoise//run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv4_euc.json \
    --rerun_uncomputed

# Compute stats
python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/dh/pipeline/projects/w3c_wnoise/cohort_mapper.csv \
    --mapper_dir /scratch/groups/saggar/demapper-w3c/wnoise_results/mappers_w3cv3.json/

### Data with high TR


python3 neupipe/mapper.py w3c_hightr \
    /scratch/groups/saggar/demapper-w3c/data_hightr \
    --data-json-path W3C_ids_hightr.json \
    --output-path /scratch/groups/saggar/demapper-w3c/hightr_results/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/projects/w3c_hightr/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72


# change in run_mapper.sbatch so that the cohort file points to the correct file:
vim /scratch/groups/saggar/dh/pipeline/projects/w3c_hightr/run_mapper.sbatch

# Point to:
/scratch/groups/saggar/demapper-w3c/data_hightr/cohort.csv

sbatch -p owners /scratch/groups/saggar/dh/pipeline/projects/w3c_hightr/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv2.json \
    --rerun_uncomputed

sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/w3c_hightr/run_mapper-highmem.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv4_euc.json \
    --rerun_uncomputed

sbatch -p owners /scratch/groups/saggar/dh/pipeline/projects/w3c_hightr/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv1.json \
    --rerun_uncomputed


sbatch -p owners /scratch/groups/saggar/dh/pipeline/projects/w3c_hightr/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv2.json \
    --rerun_uncomputed --rerun_analysis plot_task

## Compute and combine

module load matlab
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/hightr_results/mappers_w3cv1.json/"
COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_hightr/cohort.csv"
TIMING_BASE_PATH="/scratch/groups/saggar/demapper-w3c/data_hightr/"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/hightr_results/analysis/mappers_w3cv1.json/"

ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}'; timing_base_path='${TIMING_BASE_PATH}';"
matlab -r "${ARGS} run('code/w3c/circle_test_multitiming.m')"


python3 code/combine.py /scratch/groups/saggar/demapper-w3c/hightr_results/mappers_w3cv2.json \
    /scratch/groups/saggar/demapper-w3c/hightr_results/analysis/mappers_w3cv2.json/

cd /scratch/groups/saggar/dh/pipeline
python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/demapper-w3c/data_hightr/cohort.csv \
    --mapper_dir /scratch/groups/saggar/demapper-w3c/hightr_results/mappers_w3cv3.json/
