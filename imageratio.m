% The MATLAB code for the statistics of object bounding box ratios on ImageNet 2012 

% % change code for the validation set

%% for train
% INPUT_PATH = '/data/datasets/ILSVRC2012_img_train';
OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_train_bg';
BBOX_PATH = '/data/bboxes/ILSVRC2012_bbox_train';

folders = dir(OUTPUT_PATH);
% if matlabpool('Size')==0
%     matlabpool 8;
% end

imtrratio=zeros(1e3,2e3);% 
% the 1-st dimension order is the same order in the synsets.txt
% the 2-nd dimension order is the same order of images with available BBX; 
imtrclsnum=zeros(1e3,1);% valid number of image for matlab input

for i = 1: length(folders)
    if (length(folders(i).name) > 3)
        tic
        numtrratio=0;
        
        outputDirectory = fullfile(OUTPUT_PATH, folders(i).name);
%         fprintf('%s\n', inputDirectory);
        bboxDirectory = fullfile(BBOX_PATH, folders(i).name);
        
        
        files = dir(fullfile(outputDirectory, '*.JPEG'));
        for j = 1: 1: length(files)
            [~, name_, ~] = fileparts(files(j).name);
            outputFile = fullfile(outputDirectory, [name_, '.JPEG']);
            bboxFile = fullfile(bboxDirectory, [name_, '.xml']);
			if (~exist(bboxFile, 'file'))
				error('No bbx for this image\n');
			end
% 			try
% 	            zrmat = imread(inputFile);
% 			catch exc
% 				fprintf('%s\n', exc.identifier);
%                 numinval=numinval+1;
% 				continue;
% 			end
			
            
            zrmat = imread(outputFile);
            numtrratio=numtrratio+1;
            [height, width, ~] = size(zrmat);
            zrmat=zeros(height,width);
            
            input = fopen(bboxFile, 'r');
            while (~feof(input))
                str = fgetl(input);
                index = strfind(str, '<bndbox>');
                if (index > 0)
                    str = fgetl(input);
                    index1 = strfind(str, '<xmin>');
                    index2 = strfind(str, '</xmin>');
                    substr = str(index1 + 6: index2 - 1);
                    xmin = max(str2double(substr), 1);
                    str = fgetl(input);
                    index1 = strfind(str, '<ymin>');
                    index2 = strfind(str, '</ymin>');
                    substr = str(index1 + 6: index2 - 1);
                    ymin = max(str2double(substr), 1);
                    str = fgetl(input);
                    index1 = strfind(str, '<xmax>');
                    index2 = strfind(str, '</xmax>');
                    substr = str(index1 + 6: index2 - 1);
                    xmax = min(str2double(substr), width);
                    str = fgetl(input);
                    index1 = strfind(str, '<ymax>');
                    index2 = strfind(str, '</ymax>');
                    substr = str(index1 + 6: index2 - 1);
                    ymax = min(str2double(substr), height);
                    zrmat(ymin: ymax, xmin: xmax, :) = 1;
                end
            end
            fclose(input);
            ratio=sum(zrmat(:))/(height*width);
            imtrratio(i-2,j)=ratio;
        end
        
        imtrclsnum(i-2,1)=numtrratio;
        toc
        i-2
    end
end

% imtrratio=1-imtrratio;

%% for validation

% INPUT_PATH = '/data/datasets/ILSVRC2012_img_val';
OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_val_bg';
BBOX_PATH = '/data/bboxes/ILSVRC2012_bbox_val';

imtsratio=zeros(5e4-1,1);%

files = dir(fullfile(OUTPUT_PATH, '*.JPEG'));
for j = 1: length(files)
    [~, name_, ~] = fileparts(files(j).name);
    bboxFile = fullfile(BBOX_PATH, [name_, '.xml']);
    outputFile = fullfile(OUTPUT_PATH, [name_, '.JPEG']);
    if (~exist(bboxFile, 'file'))
        error('No bbx for this image\n');
    end
    image = imread(outputFile);
%     try
%         image = imread(inputFile);
%     catch exc
%         fprintf('%s\n', exc.identifier);
%         continue;
%     end
    [height, width, ~] = size(image);
    image=zeros(height,width);
    input = fopen(bboxFile, 'r');
    while (~feof(input))
        str = fgetl(input);
        index = strfind(str, '<bndbox>');
        if (index > 0)
            str = fgetl(input);
            index1 = strfind(str, '<xmin>');
            index2 = strfind(str, '</xmin>');
            substr = str(index1 + 6: index2 - 1);
            xmin = max(str2double(substr), 1);
            str = fgetl(input);
            index1 = strfind(str, '<ymin>');
            index2 = strfind(str, '</ymin>');
            substr = str(index1 + 6: index2 - 1);
            ymin = max(str2double(substr), 1);
            str = fgetl(input);
            index1 = strfind(str, '<xmax>');
            index2 = strfind(str, '</xmax>');
            substr = str(index1 + 6: index2 - 1);
            xmax = min(str2double(substr), width);
            str = fgetl(input);
            index1 = strfind(str, '<ymax>');
            index2 = strfind(str, '</ymax>');
            substr = str(index1 + 6: index2 - 1);
            ymax = min(str2double(substr), height);
            image(ymin: ymax, xmin: xmax, :) = 1;
        end
    end
    fclose(input);
    imtsratio(j)=sum(image(:))/(height*width);
end

% imtsratio=1-imtsratio;

if matlabpool('Size')>0
    matlabpool close;
end

save('bboxratio','imtsratio','imtrratio','imtrclsnum');

% refine the code
figure(1)
trh=histogram(imtrratio(:,1:imtrclsnum));
trh.Normalization='cdf';
xlabel('Ratio');
ylabel('Histogram');
title('Histograms of bounding box ratio on training set');

figure(2)
tsh=histogram(imtsratio);
tsh.Normalization='cdf';
xlabel('Ratio');
ylabel('Histogram');
title('Histograms of bounding box ratio on validation set');
