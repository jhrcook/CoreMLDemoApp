#!/bin/bash

source image-download/bin/activate
googleimagesdownload --config_file download_plant_images.json
deactivate
