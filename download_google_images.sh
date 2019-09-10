#!/bin/bash

#SBATCH -p short
#SBATCH -c 1
#SBATCH -t 0-00:03
#SBATCH --mem=4G
#SBATCH --mail-type=NONE
#SBATCH -o slurm_logs/imgdnld_%a.log
#SBATCH -e slurm_logs/imgdnld_%a.log

module load imageMagick/6.9.1.10

plant=$(sed -n "$SLURM_ARRAY_TASK_ID p" $1)
save_dir=$(echo $plant | tr " " "_")

# how many images to download per plant
num_images=300

./googliser.sh \
  --phrase $plant \
  --number $num_images \
  --no-gallery \
  --output images/${save_dir}
