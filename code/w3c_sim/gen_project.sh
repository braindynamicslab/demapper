
# Generate the cohort file based on this json
echo """
{
      "id0": "SBJ99",
      "id1": "", "id2": "",
      "path": "w3c_simulated_bold.npy",
      "TR": 1.0
}""" > W3C_ids.json

# Generate the project
cd $GROUP_SCRATCH/dh/pipeline/
python3 neupipe/mapper.py w3c \
    /scratch/groups/saggar/demapper-w3c/data \
    --data-json-path W3C_ids.json \
    --output-path /scratch/groups/saggar/demapper-w3c/ \
    --project-dir $GROUP_SCRATCH/dh/pipeline/neupipe/projects/w3c/ \
    --mappertoolbox-dir /scratch/groups/saggar/dh/mappertoolbox-matlab/ \
    --extra-args has_TR=True,RepetitionTime=1.0

# Start the job on all configs
sbatch -p owners /scratch/groups/saggar/dh/pipeline/neupipe/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv1.json \
    --rerun_uncomputed

sbatch -p owners /scratch/groups/saggar/dh/pipeline/neupipe/projects/w3c/run_mapper.sbatch \
    /home/users/hasegan/demapper/code/configs/mappers_w3cv2.json \
    --rerun_uncomputed
