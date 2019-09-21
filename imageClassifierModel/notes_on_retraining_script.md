# Notes on the image classifier retraining script

author: Josh Cook  
date: 2019-09-20

## Introduction

The example can use any module from TF Hub that uses an image input. It currently uses the feature vectors computed by Invecption V3 trained on ImageNet.

The top layer (input) recieves a 2048-dimensional vector for each image. The model also uses a softmax layer to "squash" the output values to between 0 and 1 such that they sum to 1. This represents the probabilty that the NN assigns to each category.

## The retraining function

The retraining of the model occurs in the function `add_final_retrain_ops()` (line 719) 
