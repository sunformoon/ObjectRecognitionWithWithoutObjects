# ObjectRecognitionWithWithoutObjects

The data generation code for the paper Object Reconition with and without Objects (https://arxiv.org/abs/1611.06596).

We provide the MATLAB code to generate the foreground image data and background image data of the ImageNet 2012, which are used for training the AlexNet in our paper.

You need the ImageNet 2012 training, val datasets and the xml bounding boxes annotations before you can run this code.


Brief descriptions here, while detailed comments are available inside the code. 

./genimg.m: the code to generate the foreground and background images given you have the images and object bounding box annotations.
./imageratio.m: the code to obtain the statistics of the object bounding boxes.
./gentxt.m: the code to generate the list for the lmdb generation with the offical Caffe code.

