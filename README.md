# Demo using CoreML

![ios](https://img.shields.io/badge/iOS-Plant_Tracker-999999.svg?style=flat&logo=apple)
[![jhc github](https://img.shields.io/badge/GitHub-jhrcook-181717.svg?style=flat&logo=github)](https://github.com/jhrcook)
[![jhc twitter](https://img.shields.io/badge/Twitter-JoshDoesaThing-00aced.svg?style=flat&logo=twitter)](https://twitter.com/JoshDoesa)
[![jhc website](https://img.shields.io/badge/Website-Joshua_Cook-5087B2.svg?style=flat&logo=telegram)](https://joshuacook.netlify.com)

This is a demonstration of using CoreML to recognize succulents from images. It is still very much in it's early stages.

**Overview**

1. Create an R script that scrapes the plant names from [World of Succulents](https://worldofsucculents.com/browse-succulents-scientific-name).
2. Create a shell script that uses [Google Images Download](https://github.com/hardikvasa/google-images-download) to download the images to a directory called "data/" and each plant has a subdirectory.
3. Use TransorFlow to retrain an image classifier with my new data set.
4. Use the `core-ml` python package to convert the TensorFlow model into one that can be imported into Xcode for CoreML


## Data

I scraped plant names from [World of Succulents](https://worldofsucculents.com/browse-succulents-scientific-name) using 'rvest' to retrieve and parse the HTML. The code is in "webscrape.r" and outputs a list of names to "plant_names.txt". Then, "test_download_plants.py" downloads the first N images from a Google Images search using the [Google Images Download](https://github.com/hardikvasa/google-images-download) python library.

**TODO:** Change the output from the R script to a JSON with the format as shown [here](https://google-images-download.readthedocs.io/en/latest/examples.html). Then just use the command line form of Google Images Download (don't forget to activate and deactivate the virtual enviorment).

```bash
source test-web-scraping/bin/activate
...
deactivate
```

### Preparing JSON file for doanloading

The Rscript "make_plant_list.r" parses the plant names into "plant_names.txt" and "download_plant_images.json". The maximum number of images I can download without Chrome installed is 100. Therefore, to keep everything on the O2 cluster, I will stick to that limit for the testing phase of this demonstration. Only 5 test plants are being used right now, chosen on the basis that I have unique images of these species (i.e. I own them).

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

The "download_google_images.sh" script simply runs the CLI for `google_images_download` and points to the JSON made in the R script.

```bash
source image-download/bin/activate
googleimagesdownload --config_file download_plant_images.json
deactivate
```

To run the download script.

```bash
source download_google_images.sh
```


## ML Model Creation

I will begin by following the tutorial [How to Retrain an Image Classifier for New Categories](https://www.tensorflow.org/hub/tutorials/image_retraining) to retrain a general image classifier to recognize the images. I can then export a CoreML object and import than into a simple iOS app that tries to predict the cactus from a new image.

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