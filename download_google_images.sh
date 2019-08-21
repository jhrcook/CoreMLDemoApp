#!/bin/bash

module load python/3.6.0 R/3.5.1 imageMagick/6.9.1.10

source image-download/bin/activate
googleimagesdownload --config_file download_plant_images.json
deactivate

Rscript filter_bad_images.r
