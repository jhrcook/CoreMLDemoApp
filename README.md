# Demo using CoreML

![ios](https://img.shields.io/badge/iOS-Plant_Tracker-999999.svg?style=flat&logo=apple)
[![jhc github](https://img.shields.io/badge/GitHub-jhrcook-181717.svg?style=flat&logo=github)](https://github.com/jhrcook)
[![jhc twitter](https://img.shields.io/badge/Twitter-JoshDoesaThing-00aced.svg?style=flat&logo=twitter)](https://twitter.com/JoshDoesa)
[![jhc website](https://img.shields.io/badge/Website-Joshua_Cook-5087B2.svg?style=flat&logo=telegram)](https://joshuacook.netlify.com)



This is a demonstration of using CoreML to recognize succulents from images. It is still very much in it's early stages.

**Overview of the process**

1. Create an R script that scrapes the plant names from [World of Succulents](https://worldofsucculents.com/browse-succulents-scientific-name).
2. Create a shell script that uses ['googliser'](https://github.com/teracow/googliser) to download the images to a directory called "images/" and each plant has a subdirectory.
3. Use TransorFlow to retrain an image classifier with my new data set.
4. Use the `core-ml` python package to convert the TensorFlow model into one that can be imported into Xcode for CoreML.

**Current Status**

* I have made the web-scraping script and created a list of over 1,500 succulents.
* I have ['googliser'](https://github.com/teracow/googliser) funcitoning and a job-array submission system to parrallelize the process for each plant.
* [Here](./practice_plant_recognition.md), I have demonstrated the feasibility of the workflow using a sample of 5 plants.


# Work-flow {#workflow}

## Data Acquisition

### Create plant name list

I scraped plant names from [World of Succulents](https://worldofsucculents.com/browse-succulents-scientific-name) using '[rvest](https://cran.r-project.org/web/packages/rvest/index.html)' to retrieve and parse the HTML. The code is in "make\_plant\_list.r" and outputs a list of names to "plant_names.txt"

```bash
Rscript make_plant_list.r
```

### Download images

I am using the bash tool ['googliser'](https://github.com/teracow/googliser) to download plant images. It currently has a limit of 1,000 images  per query. This should be sufficient for my needs, though.

#### Set up 'googliser'

The tool can be installed from GitHub using the following command.

```bash
wget -qN git.io/googliser.sh && chmod +x googliser.sh
```

It requires `imagemagick`, which is available on O2.

```bash
module load imageMagick/6.9.1.10
```

Below is an example command to download 20 images of *Euphorbia obesa*.

```bash
./googliser.sh \
  --phrase "Euphorbia obesa" \
  --number 20 \
  --no-gallery \
  --output images/Euphorbia_obesa
```
#### Downloading the images in parallel

I downloaded all of the images for every plant by submitting a job-array, where each job downloads *N* images for a single plant. The script "download_google_images.sh" takes an integer (the job number) and downloads the images for the plant on that line of "plant_names.txt".

```bash
sbatch --array=1-$(wc -l < plant_names.txt) download_google_images.sh plant_names.txt
```

### Remove corrupted files and wrong formats

**(The following step may no longer be necessary since each image is reportedly a JPEG.)**

Some of the images were corrupted or of WEBP format that the TensorFlow script could not accept. These were filtered using another R script.

```bash
module load imageMagick/6.9.1.10
Rscript filter_bad_images.r
```

### Ensure all images were properly downloaded.

The R Markdown file "check_images_downloaded.Rmd" checks that each plant has images downloaded. It outputs an HTML file of the results.

```bash
Rscript -e 'rmarkdown::render("check_images_downloaded.Rmd")'
```

In addition, if there are plants that do not have all of the images downloaded, it creates the file "failed_dwnlds_plant_names.txt" with the list of plant names to be run, again.

```bash
sbatch --array=1-$(wc -l < failed_dwnlds_plant_names.txt) download_google_images.sh failed_dwnlds_plant_names.txt
```


## ML Model Creation

I began by following the tutorial [How to Retrain an Image Classifier for New Categories](https://www.tensorflow.org/hub/tutorials/image_retraining) to retrain a general image classifier to recognize the images. I can then exported a CoreML object and import that into a simple iOS app that tries to predict the cactus from a new image.

### Install TensorFlow and TensorFlow Hub

[TensorFlow](https://www.tensorflow.org) is an incredibly powerful machine learning framework that is used extensively in education, research and production. (Excitingly, there is [Swift for TensorFlow](https://www.tensorflow.org/swift), though it is still in beta (as of August 18, 2019)).

"[TensorFlow Hub](https://www.tensorflow.org/hub) is a library for the publication, discovery, and consumption of reusable parts of machine learning models."

To install both, we can use `pip` from within the virtual environment.

Create virtual environment.

```bash
# create and activate a virtual environment
module load python/3.6.0
python3 -m venv image-download
source image-download/bin/activate

# install the necessary packages
pip3 install --upgrade pip
pip3 install tensorflow tensorflow-hub
```

### Example retraining: practice with flowers

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

### Small-scale experiment

You can see the results from a small-scale experiement [here](./practice_plant_recognition.md). Overall, it went well, but the plants used were obviously different from each other, so it may be worth running a test with more similar types of plants.

### Retraining work-flow

**TODO:** write out the standard workflow for this process.

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
* [googliser](https://github.com/teracow/googliser)