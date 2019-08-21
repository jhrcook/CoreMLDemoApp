# Demo using CoreML

![ios](https://img.shields.io/badge/iOS-Plant_Tracker-999999.svg?style=flat&logo=apple)
[![jhc github](https://img.shields.io/badge/GitHub-jhrcook-181717.svg?style=flat&logo=github)](https://github.com/jhrcook)
[![jhc twitter](https://img.shields.io/badge/Twitter-JoshDoesaThing-00aced.svg?style=flat&logo=twitter)](https://twitter.com/JoshDoesa)
[![jhc website](https://img.shields.io/badge/Website-Joshua_Cook-5087B2.svg?style=flat&logo=telegram)](https://joshuacook.netlify.com)



This is a demonstration of using CoreML to recognize succulents from images. It is still very much in it's early stages.

**Overview of the process**

1. Create an R script that scrapes the plant names from [World of Succulents](https://worldofsucculents.com/browse-succulents-scientific-name).
2. Create a shell script that uses [Google Images Download](https://github.com/hardikvasa/google-images-download) to download the images to a directory called "data/" and each plant has a subdirectory.
3. Use TransorFlow to retrain an image classifier with my new data set.
4. Use the `core-ml` python package to convert the TensorFlow model into one that can be imported into Xcode for CoreML

## Model Creation

### Small-scale experiment

You can see the results from a small-scale experiement [here](./practice_plant_recognition.md). Overall, it went well, but the plants used were obviously different from each other, so it may be worth running a test with more simillar types of plants.

### Data

I scraped plant names from [World of Succulents](https://worldofsucculents.com/browse-succulents-scientific-name) using '[rvest](https://cran.r-project.org/web/packages/rvest/index.html)' to retrieve and parse the HTML. The code is in "make\_plant\_list.r" and outputs a list of names to "plant_names.txt"

I then used [Snakemake](https://snakemake.readthedocs.io/en/stable/) to download all of the images for the 1,508 plants. Snakemake is a workflow management tool that has defined rules (functions) with general input and output. By passing specific values for the final output, Snakemake builds a directed acyclic graph (DAG) of the rules and inputs necessary to create the output which it then uses to organize the running of the necessary jobs. Therefore, I can build Snakemake to take a single plant name to download the images of. It will then ensure that the expected output is produced. This mechanism will make the process easily scalable to the current 1,500 plants, and even more in the future.

**Description of the Snakefile**

(Describe the Snakefile)

[TODO: Only need to run the command line download-google-images command passing the plant name and limit on images.]

**Description of cluster configuration JSON**

[TODO]

**Preparing for Snakemake**

Create virtual environment.

```bash
module load python/3.6.0
python3 -m venv image-download
```

Install necessary libraries.

```bash
pip3 install --upgrade pip
pip3 snakemake google_images_download setuptools tensorflow tensorflow-hub
```

**Running Snakemake**

```bash
source image-download/bin/activate
snakemake command for O2 (copy from RC_comutation_2)
```

**Filtering out bad images**

Filter out WEBP and corrupt images.

```bash
module load imageMagick/6.9.1.10
Rscript filter_bad_images.r
```




---
[MAY BE ABLE TO DELETE EVERYTHING BELOW THIS]

### Preparing JSON file for doanloading

The Rscript "make\_plant\_list.r" parses the plant names into "plant\_names.txt" and "download_plant_images.json". The maximum number of images I can download without Chrome installed is 100. Therefore, to keep everything on the O2 cluster, I will stick to that limit for the testing phase of this demonstration. Only 5 test plants are being used right now, chosen on the basis that I have unique images of these species (i.e. I own them).

```bash
Rscript make_plant_list.r
```

### Preparing Python virtual environment

Working on the O2 cluster

```bash
module load python/3.6.0
python3 -m venv image-download
```

There should now be a directory called "image-download".

Activate the new virtual environment and install the [Google Images Download](https://github.com/hardikvasa/google-images-download) python library. (You may want to upgrade `pip3` with the following command `pip3 install --upgrade pip`.)


```bash
source image-download/bin/activate
pip3 install google_images_download
```

### Script to download images for plants

The "download_google_images.sh" script simply runs the CLI for `google\_images\_download` and points to the JSON made in the R script.

```bash
source image-download/bin/activate
googleimagesdownload --config_file download_plant_images.json
deactivate
```

To run the download script.

```bash
source download_google_images.sh
```

Some of the images were corrupted or of WEBP format that the TensorFlow script could not accept. These were filtered using another R script.

```bash
module load imageMagick/6.9.1.10
Rscript filter_bad_images.r
```

[KEEP EVERYTHING BELOW THIS]
---



[TODO: REMOVE THE TUTORIAL PART AND RE-PHRASE TO MATCH HOW I USED THE SCRIPTS.]

## ML Model Creation

I began by following the tutorial [How to Retrain an Image Classifier for New Categories](https://www.tensorflow.org/hub/tutorials/image_retraining) to retrain a general image classifier to recognize the images. I can then exported a CoreML object and imported that into a simple iOS app that tries to predict the cactus from a new image.

### Install TensorFlow and TensorFlow Hub

[TensorFlow](https://www.tensorflow.org) is an incredibly powerful machine learning framework that is used extensively in education, research and production. (Excitingly, there is [Swift for TensorFlow](https://www.tensorflow.org/swift), though it is still in beta (as of August 18, 2019)).

"[TensorFlow Hub](https://www.tensorflow.org/hub) is a library for the publication, discovery, and consumption of reusable parts of machine learning models."

To install both, we can use `pip` from within the virtual environment.

```bash
source image-download/bin/activate
pip3 install tensorflow
pip3 install tensorflow-hub
```

### Practice with flowers

There is an example on the tutorial for retraining ImageNet to identify several different plants by their flower. All of this was performed in a subdirectory called "flowers_example".

```bash
mkdir flowers_example
cd flowers_example
```

The images were downloaded and unarchived.

```bash

curl -LO http://download.tensorflow.org/example_images/flower_photos.tgz
tar xzf flower_photos.tgz
ls flower_photos
#> daisy  dandelion  LICENSE.txt  roses  sunflowers  tulips
```

The retraining script was downloaded from GitHub.

```bash
curl -LO https://github.com/tensorflow/hub/raw/master/examples/image_retraining/retrain.py
```

The script was run on the plant images.

```bash
python retrain.py --image_dir ./flower_photos
```

If the connection to O2 is set up correctly, the TensorBoard can be run and opened locally.

```bash
tensorboard --logdir /tmp/retrain_logs
#> TensorBoard 1.14.0 at http://compute-e-16-229.o2.rc.hms.harvard.edu:6006/ (Press CTRL+C to quit)
```

Finally, the newe model was used to classify a photo using the "label_image.py" script (downloaded from GitHub).

```bash
# download the script
curl -LO https://github.com/tensorflow/tensorflow/raw/master/tensorflow/examples/label_image/label_image.py
# run it on an image
python label_image.py \
    --graph=/tmp/output_graph.pb \
    --labels=/tmp/output_labels.txt \
    --input_layer=Placeholder \
    --output_layer=final_result \
    --image=./flower_photos/daisy/21652746_cc379e0eea_m.jpg
#> daisy 0.99798715
#> sunflowers 0.0011478926
#> dandelion 0.00045892605
#> tulips 0.0003524925
#> roses 5.3392014e-05
```

It worked!



---

## Notes

- [Meghan Kane - Bootstrapping the Machine Learning Training Process](https://www.youtube.com/watch?v=ugiPfm8ICZo)
- There are models already available from Apple: https://developer.apple.com/machine-learning/models/
- use "transfer learning" to use knowledge learned from source task (eg. MobileNet or SqueezeNet) to train target task
- "tensorboard" to track learning for the TensorFlow training


## Image sources

* http://www.cacti.co.nz/library/
* https://worldofsucculents.com/browse-succulents-scientific-name


## Code Sources

* [Google Images Download](https://github.com/hardikvasa/google-images-download) python library (can `pip` install)