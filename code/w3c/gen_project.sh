
# Generate the cohort file based on this json
echo """
{
      \"id0\": \"SBJ99\",
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"{{id0}}_bold.npy\",
      \"TR\": 0.72
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

# Generate the project with the new data location
cd $HOME/
# python3 neupipe/mapper.py w3c \
neupipe mapper w3c_1sbj \
    /oak/stanford/groups/saggar/demapper/data/w3c/data_subsampled/\
    --data-json-path W3C_ids.json \
    --output-path /scratch/groups/saggar/demapper-w3c/1sbj_results \
    --project-dir $HOME/projects/w3c_1sbj/ \
    --mappertoolbox-dir /home/groups/saggar/repos/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72

# Start the job on all configs
sbatch -p owners /scratch/groups/saggar/dh/pipeline/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv1.json \
    --rerun_uncomputed

sbatch -p owners /scratch/groups/saggar/dh/pipeline/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv2.json \
    --rerun_uncomputed

sbatch -p saggar $HOME/projects/w3c_1sbj/run_mapper.sbatch \
    $HOME/demapper/code/configs/mappers_w3cv5lens2_disp.json \
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


module load matlab
CONF=mappers_w3cv8embed_fast.json
DATAFOLDER="/scratch/groups/saggar/demapper-w3c/${CONF}/"
COHORT_PATH="/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_1sbj.csv"
OUTPUT_DIR="/scratch/groups/saggar/demapper-w3c/analysis/${CONF}/"
ARGS="datafolder='${DATAFOLDER}'; cohort_path='${COHORT_PATH}'; output_dir='${OUTPUT_DIR}';"
matlab -r "${ARGS} run('code/w3c/circle_test_multitiming.m')"


## Within a shell, combine the stats:
python3 code/combine.py /scratch/groups/saggar/demapper-w3c/mappers_w3cv1.json \
    /scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv1.json/

python3 code/combine.py /scratch/groups/saggar/demapper-w3c/mappers_w3cv2.json \
    /scratch/groups/saggar/demapper-w3c/analysis/mappers_w3cv2.json/

# For wnoise
python3 code/combine.py /scratch/groups/saggar/demapper-w3c/wnoise_results/mappers_w3cv2.json \
    /scratch/groups/saggar/demapper-w3c/wnoise_results/analysis/mappers_w3cv2.json/


##############################################
####################### Subsampled Data ######
##############################################


echo """
{
      \"id0\": [\"SBJ99\", \"SBJ20\", \"SBJ21\", \"SBJ40\", \"SBJ41\", \"SBJ42\", \"SBJ43\", \"SBJ80\", \"SBJ81\", \"SBJ82\", \"SBJ83\", \"SBJ84\", \"SBJ85\", \"SBJ86\", \"SBJ87\", \"SBJ99-50.0\", \"SBJ20-50.0\", \"SBJ40-50.0\", \"SBJ80-50.0\", \"SBJ99-75.0\", \"SBJ20-75.0\", \"SBJ40-75.0\", \"SBJ80-75.0\", \"SBJ99-83.0\", \"SBJ20-83.0\", \"SBJ40-83.0\", \"SBJ80-83.0\"],
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"{{id0}}_bold.npy\",
      \"TR\": 0.72
}""" > W3C_ids_ss.json


echo """
{
      \"id0\": [\"SBJ-50-00\", \"SBJ-50-25\", \"SBJ-50-50\", \"SBJ-60-00\", \"SBJ-60-20\", \"SBJ-60-40\", \"SBJ-70-00\", \"SBJ-70-15\", \"SBJ-70-30\", \"SBJ-80-00\", \"SBJ-80-10\", \"SBJ-80-20\", \"SBJ-90-00\", \"SBJ-90-05\", \"SBJ-90-10\", \"SBJ-99-00\"],
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"{{id0}}_bold.npy\",
      \"task_path_G\": \"/oak/stanford/groups/saggar/demapper/data/w3c/data_ss2/task_info_{{id0}}.csv\",
      \"TR\": 0.72
}""" > W3C_ids_ss2.json


# subsampled
python3 neupipe/mapper.py w3c_subsampled \
    /scratch/groups/saggar/demapper-w3c/data_subsampled \
    --data-json-path W3C_ids_ss.json \
    --output-path /scratch/groups/saggar/demapper-w3c/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/projects/w3c_subsampled/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72


# subsampled 2
neupipe mapper w3c_ss2 \
    /oak/stanford/groups/saggar/demapper/data/w3c/data_ss2/\
    --data-json-path W3C_ids_ss2.json \
    --output-path /scratch/groups/saggar/demapper-w3c/ss2_results \
    --project-dir $HOME/projects/w3c_ss2/ \
    --mappertoolbox-dir /home/groups/saggar/repos/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72



# (deprecated) change in run_mapper.sbatch so that the cohort file points to the correct file:
vim /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled//run_mapper.sbatch
# (deprecated) Point to:
/scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_shorter.csv

# start the mappers
sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv6lens2_fast.json \
    --rerun_uncomputed

# Run on 1sbj only
sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/w3c_subsampled/run_mapper-1sbj.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv4_reg.json \
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

# subsampled 2
sbatch -p saggar $HOME/projects/w3c_ss2/run_mapper.sbatch \
    $HOME/demapper/code/configs/mappers_w3cv5lens2_fast.json \
    --rerun_uncomputed

# Compute stats
python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_1sbj.csv \
    --mapper_dir /scratch/groups/saggar/demapper-w3c/mappers_w3cv8embed_fast.json/

python3 neupipe/tools/cache.py compute_stats \
    --cohort_path /scratch/groups/saggar/demapper-w3c/data_subsampled/cohort_shortest.csv \
    --mapper_dir /scratch/groups/saggar/demapper-w3c/mappers_w3cv5lens2_fast.json/


python3 neupipe/tools/cache.py compute_stats \
    --cohort_path $HOME/projects/w3c_ss2/cohort_mapper.csv \
    --mapper_dir $GROUP_SCRATCH/demapper-w3c/ss2_results/mappers_w3cv5lens2_fast.json/


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


echo """
{
      \"id0\": [\"SBJ\", \"SBJ-A007\", \"SBJ-A014\", \"SBJ-A020\", \"SBJ-A027\", \"SBJ-A033\", \"SBJ-A050\", \"SBJ-A066\", \"SBJ-A083\", \"SBJ-A099\", \"SBJ-A132\", \"SBJ-SNR00.5\", \"SBJ-SNR00.6\", \"SBJ-SNR00.8\", \"SBJ-SNR01.0\", \"SBJ-SNR01.3\", \"SBJ-SNR02.0\", \"SBJ-SNR02.5\", \"SBJ-SNR03.3\", \"SBJ-SNR05.0\", \"SBJ-SNR10.0\"],
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"{{id0}}.npy\",
      \"TR\": 0.72
}""" > W3C_ids_wnoise2.json


python3 neupipe/mapper.py w3c_wnoise \
    /scratch/groups/saggar/demapper-w3c/data_wnoise \
    --data-json-path W3C_ids_wnoise.json \
    --output-path /scratch/groups/saggar/demapper-w3c/wnoise_results/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/projects/w3c_wnoise/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72


# Generate the project with the new data location
neupipe mapper w3c_wnoise2 \
    /oak/stanford/groups/saggar/demapper/data/w3c/data_wnoise2/\
    --data-json-path W3C_ids_wnoise2.json \
    --output-path /scratch/groups/saggar/demapper-w3c/wnoise2_results \
    --project-dir $HOME/projects/w3c_wnoise2/ \
    --mappertoolbox-dir /home/groups/saggar/repos/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=0.72


sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/w3c_wnoise//run_mapper-highmem.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv3.json \
    --rerun_uncomputed

sbatch -p saggar $HOME/projects/w3c_wnoise2/run_mapper.sbatch \
    $HOME/demapper/code/configs/mappers_w3cv5lens2_fast.json \
    --rerun_uncomputed

# Compute stats
python3 neupipe/tools/cache.py compute_stats \
    --cohort_path $HOME/projects/w3c_wnoise2/cohort_mapper.csv \
    --mapper_dir $GROUP_SCRATCH/demapper-w3c/wnoise2_results/mappers_w3cv5lens2_fast.json/


###########################
### Data with high TR #####
###########################


## version 1:
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


## Version 2:
echo """
{
      \"id0\": [\"e2v0\", \"e2v1\", \"e3v0\", \"e3v1\"],
      \"id1\": \"\", \"id2\": \"\",
      \"path\": \"SBJ{{id0}}_bold.npy\",
      \"task_path_G\": \"/oak/stanford/groups/saggar/demapper/data/w3c/data_hightr/task_info_{{id0}}.csv\",
      \"TR\": \"XXX\"
}""" > W3C_ids_hightr2.json

neupipe mapper w3c_hightr2 \
    /oak/stanford/groups/saggar/demapper/data/w3c/data_hightr/\
    --data-json-path W3C_ids_hightr2.json \
    --output-path /scratch/groups/saggar/demapper-w3c/hightr2_results \
    --project-dir $HOME/projects/w3c_hightr2/ \
    --mappertoolbox-dir /home/groups/saggar/repos/mappertoolbox-matlab/ \
    --extra-args has_TR=True

# Change the TR file:
vim $HOME/projects/w3c_hightr2/cohort_mapper.csv



sbatch -p saggar /scratch/groups/saggar/dh/pipeline/projects/w3c_hightr/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv6lens2_fast.json \
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


sbatch -p saggar $HOME/projects/w3c_hightr2/run_mapper.sbatch \
    $HOME/demapper/code/configs/mappers_w3cv5lens2_fast.json \
    --rerun_uncomputed

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
    --mapper_dir /scratch/groups/saggar/demapper-w3c/hightr_results/mappers_w3cv5lens2_fast.json/

# Compute stats
cd /home/groups/saggar/repos/pipeline
python3 neupipe/tools/cache.py compute_stats \
    --cohort_path $HOME/projects/w3c_hightr2/cohort_mapper.csv \
    --mapper_dir $GROUP_SCRATCH/demapper-w3c/hightr2_results/mappers_w3cv5lens2_fast.json/


## Regenrated for figure 4, in matlab, run code:

fn_timing = '/Users/dh/workspace/BDL/demapper/data/cme/timing.csv';
stat_in_path = '/Users/dh/workspace/BDL/demapper/results/cme/ch10_mappers_cmev3.json/degrees_TRs/avgstat_BDLMapper_12_30_58.1D';
CHANGE_POINTS = 10;
mapper_name = 'BDLMapper_12_30_58';
output_path = '/Users/dh/workspace/BDL/demapper/results/cme/ch10_mappers_cmev3.json/TRs_degs-BDLMapper_12_30_58.png';

avg_degs = read_1d(stat_in_path);

plot_degs(avg_degs, timing_labels, timing_changes, chgs, mapper_name, output_path);




