#!/bin/bash

#SBATCH -p short
#SBATCH -c 1
#SBATCH -t 0-00:5
#SBATCH --mem=500
#SBATCH --mail-type=NONE
#SBATCH -o slurm_logs/imgdnld_%A_%a.log
#SBATCH -e slurm_logs/imgdnld_%A_%a.log

module load imageMagick/6.9.1.10

plant=$(sed -n "$SLURM_ARRAY_TASK_ID p" $1)
save_dir=$(echo $plant | tr " " "_")

# how many images to download per plant
num_images=500

./googliser.sh \
  --phrase "$plant" \
  --number $num_images \
  --no-gallery \
  --output /n/scratch2/jc604_plantimages/${save_dir} \
  --failures $num_images
