# ObjectRecognitionWithWithoutObjects

The data generation code for the paper Object Reconition with and without Objects (https://arxiv.org/abs/1611.06596).

We provide the MATLAB code to generate the foreground image data and background image data of the ImageNet 2012, which are used for training the AlexNet in our paper.

You need the ImageNet 2012 training, val datasets and the xml bounding boxes annotations before you can run this code.


Brief descriptions here, while detailed comments are available inside the code. 

./genimg.m: the code to generate the foreground and background images given you have the images and object bounding box annotations. <br />
./imageratio.m: the code to obtain the statistics of the object bounding boxes. <br />
./gentxt.m: the code to generate the list for the lmdb generation with the offical Caffe code. <br />

If you find this code useful for your research, please consider citing this paper via the .bibtex.

@inproceedings{zhu2017object,
  title={Object Reconition with and without Objects},
  author={Zhu, Zhuotun and Xie, Lingxi and Yuille, Alan},
  booktitle={IJCAI},
  year={2017}
}

