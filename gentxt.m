% This is to generate the train.txt and val.txt for Caffe use.
% The train.txt and val.txt are used to create the .lmdb data for caffe.
% The offical Caffe code to create the lmdb data is under caffe/examples/imagenet/create_imagenet.sh, 
% which is available on the Caffe github repository (https://github.com/BVLC/caffe/tree/master/examples/imagenet).


% The statistics of the bounding box ratios obtrained from the imageratio.m.
load('bboxratio.mat');
% Only keep the images whose background ratios are less than 0.5 (i.e., foreground object ratio greater or equal than 0.5)
% for training the background networks. However, keep all the foreground images no matter how large the foreground is. 
bgthr=0.5;% less then 0.5 
%% for train
% INPUT_PATH = '/data/datasets/ILSVRC2012_img_train';
OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_train_fg';
CLS_PATH='/data/libs/caffe-master-new/data/ilsvrc12/synsets.txt';
% TR_PATH=['/data/libs/caffe-master-new/data/ilsvrc12/train_bg' num2str(bgthr) '.txt'];
% VAL_PATH=['/data/libs/caffe-master-new/data/ilsvrc12/val_bg' num2str(bgthr) '.txt'];

TR_PATH=['/ImageNet/caffe/caffe-master/data/ilsvrc12/train_fg.txt'];
VAL_PATH=['/ImageNet/caffe/caffe-master/data/ilsvrc12/val_fg.txt'];


folders=textread(CLS_PATH,'%s');
% if matlabpool('Size')==0
%     matlabpool 8;
% end
fileID=fopen(TR_PATH,'w');
for i = 1: length(folders)
    outputDirectory = fullfile(OUTPUT_PATH, folders{i});
    
    files = dir(fullfile(outputDirectory, '*.JPEG'));
    
    %% the folders in imageratio is in the same order with the synsets.txt
%     bgflag=find(imtrratio(i,1:imtrclsnum(i))<bgthr+eps);
    %% get the wanted images.
    for j = 1: 1: length(files)
        [~, name_, ~] = fileparts(files(j).name);
%         [~, name_, ~] = fileparts(files(bgflag(j)).name);
        strname=[folders{i} '/' name_ '.JPEG ' num2str(i-1)];
        fprintf(fileID,strname);
        fprintf(fileID,'\n');
    end
end
fclose(fileID);

% validation set on the foreground is same with the original val_bg.txt 

% %% for validation
% 
% % INPUT_PATH = '/data/datasets/ILSVRC2012_img_val';
% OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_val_fg';% foreground image
% 
% VALCLS_PATH='/ImageNet/caffe/caffe-master/data/ilsvrc12/val_bg.txt';
% % choose bounding box whose ratio is less then the desired ones.
% [valname, cls]=textread(VALCLS_PATH,'%s %d');
% % write the text file
% fileID=fopen(VAL_PATH,'w');
% 
% bgflag=find(imtsratio<bgthr+eps);
% files = dir(fullfile(OUTPUT_PATH, '*.JPEG'));
% for j = 1: length(bgflag)
%     strname=[valname{bgflag(j)} ' ' num2str(cls(bgflag(j)))];
%     fprintf(fileID,strname);
%     fprintf(fileID,'\n');
% end
% fclose(fileID);
