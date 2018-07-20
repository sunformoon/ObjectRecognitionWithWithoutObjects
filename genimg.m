% This is the MATLAB code for genererate the foreground and backgrounds images on the training and val set of ImageNet 2012.
% Reference paper: Object Recognition with and without Objects (https://arxiv.org/abs/1611.06596).
% INPUT_PATH: the directory that contains all the 1000 folders of training images, where each folder is for one class.
% OUTPUT_PATH: the directory to save the cropped foreground or background images.
% BBOX_PATH: the direcoty that contains all the 1000 folders of object bounding boxes in .xml format.

% Change these paths to the path on your own data drive.

%% foreground extract and save

if matlabpool('Size')==0
    matlabpool 8;
end

%% for training foreground images

INPUT_PATH = '/data/datasets/ILSVRC2012_img_train';
OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_train_fg'; 
BBOX_PATH = '/data/bboxes/ILSVRC2012_bbox_train';

folders = dir(INPUT_PATH);

parfor i = 1: length(folders)
    if (length(folders(i).name) > 3)
        inputDirectory = fullfile(INPUT_PATH, folders(i).name);
        fprintf('%s\n', inputDirectory);
        bboxDirectory = fullfile(BBOX_PATH, folders(i).name);
        outputDirectory = fullfile(OUTPUT_PATH, folders(i).name);
        if (~isdir(outputDirectory))
            mkdir(outputDirectory);
        end
        files = dir(fullfile(inputDirectory, '*.JPEG'));
        for j = 1: 1: length(files)
            [~, name_, ~] = fileparts(files(j).name);
            inputFile = fullfile(inputDirectory, [name_, '.JPEG']);
            bboxFile = fullfile(bboxDirectory, [name_, '.xml']);
            outputFile = fullfile(outputDirectory, [name_, '.JPEG']);
			if (~exist(bboxFile, 'file')||exist(outputFile, 'file'))
				continue;
			end
			try
	            image = imread(inputFile);
			catch exc
				fprintf('%s\n', exc.identifier);
				continue;
			end
			[height, width, ~] = size(image);
            mask=uint8(zeros(size(image)));
            bbx=[];
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
                    bbx=[bbx;ymin ymax xmin xmax];
                    mask(ymin: ymax, xmin: xmax, :) = 1;% get the foreground mask
                end
            end
            fclose(input);
            ymin=min(bbx(:,1));ymax=max(bbx(:,2));
            xmin=min(bbx(:,3));xmax=max(bbx(:,4));
            image=image.*mask;
            image=image(ymin: ymax, xmin: xmax, :);
            % take the whole image into consideration
            imwrite(image, outputFile, 'jpeg');
        end
    end
end

% 
% if matlabpool('Size')>0
%     matlabpool close;
% end



%% for validation foreground images
INPUT_PATH = '/data/datasets/ILSVRC2012_img_val';
OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_val_fg'; % now is for the foreground
BBOX_PATH = '/data/bboxes/ILSVRC2012_bbox_val';

folders = dir(INPUT_PATH);
if ~isdir(OUTPUT_PATH)
    mkdir(OUTPUT_PATH);
end


files = dir(fullfile(INPUT_PATH, '*.JPEG'));
parfor j = 1: length(files)
    [~, name_, ~] = fileparts(files(j).name);
    inputFile = fullfile(INPUT_PATH, [name_, '.JPEG']);
    bboxFile = fullfile(BBOX_PATH, [name_, '.xml']);
    outputFile = fullfile(OUTPUT_PATH, [name_, '.JPEG']);
    if (~exist(bboxFile, 'file')||exist(outputFile, 'file'))
        continue;
    end
    try
        image = imread(inputFile);
    catch exc
        fprintf('%s\n', exc.identifier);
        fprintf('%s\n',name_);
        continue;
    end
    [height, width, ~] = size(image);
    mask=uint8(zeros(size(image)));
    bbx=[];
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
            bbx=[bbx;ymin ymax xmin xmax];
            mask(ymin: ymax, xmin: xmax, :) = 1;% get the foreground mask
        end
    end
    fclose(input);
    ymin=min(bbx(:,1));ymax=max(bbx(:,2));
    xmin=min(bbx(:,3));xmax=max(bbx(:,4));
    image=image.*mask;
    image=image(ymin: ymax, xmin: xmax, :);
    % take the whole image into consideration
    imwrite(image, outputFile, 'jpeg');
end

if matlabpool('Size')>0
    matlabpool close;
end


% % background extract and save
% 
% if matlabpool('Size')==0
%     matlabpool 8;
% end

% %% for training background images
% 
% INPUT_PATH = '/data/datasets/ILSVRC2012_img_train';
% OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_train_bg';
% BBOX_PATH = '/data/bboxes/ILSVRC2012_bbox_train';
% 
% folders = dir(INPUT_PATH);
% 
% parfor i = 1: length(folders)
%     if (length(folders(i).name) > 3)
%         inputDirectory = fullfile(INPUT_PATH, folders(i).name);
%         fprintf('%s\n', inputDirectory);
%         bboxDirectory = fullfile(BBOX_PATH, folders(i).name);
%         outputDirectory = fullfile(OUTPUT_PATH, folders(i).name);
%         if (~isdir(outputDirectory))
%             mkdir(outputDirectory);
%         end
%         files = dir(fullfile(inputDirectory, '*.JPEG'));
%         for j = 1: 1: length(files)
%             [~, name_, ~] = fileparts(files(j).name);
%             inputFile = fullfile(inputDirectory, [name_, '.JPEG']);
%             bboxFile = fullfile(bboxDirectory, [name_, '.xml']);
%             outputFile = fullfile(outputDirectory, [name_, '.JPEG']);
% 			if (~exist(bboxFile, 'file'))
% 				continue;
% 			end
% 			try
% 	            image = imread(inputFile);
% 			catch exc
% 				fprintf('%s\n', exc.identifier);
% 				continue;
% 			end
% 			[height, width, ~] = size(image);
%             input = fopen(bboxFile, 'r');
%             while (~feof(input))
%                 str = fgetl(input);
%                 index = strfind(str, '<bndbox>');
%                 if (index > 0)
%                     str = fgetl(input);
%                     index1 = strfind(str, '<xmin>');
%                     index2 = strfind(str, '</xmin>');
%                     substr = str(index1 + 6: index2 - 1);
%                     xmin = max(str2double(substr), 1);
%                     str = fgetl(input);
%                     index1 = strfind(str, '<ymin>');
%                     index2 = strfind(str, '</ymin>');
%                     substr = str(index1 + 6: index2 - 1);
%                     ymin = max(str2double(substr), 1);
%                     str = fgetl(input);
%                     index1 = strfind(str, '<xmax>');
%                     index2 = strfind(str, '</xmax>');
%                     substr = str(index1 + 6: index2 - 1);
%                     xmax = min(str2double(substr), width);
%                     str = fgetl(input);
%                     index1 = strfind(str, '<ymax>');
%                     index2 = strfind(str, '</ymax>');
%                     substr = str(index1 + 6: index2 - 1);
%                     ymax = min(str2double(substr), height);
%                     image(ymin: ymax, xmin: xmax, :) = 0;
%                 end
%             end
%             fclose(input);
%             imwrite(image, outputFile, 'jpeg');
%         end
%     end
% end
% 
% % 
% % if matlabpool('Size')>0
% %     matlabpool close;
% % end
% 
% 
% 
% %% for validation background images
% INPUT_PATH = '/data/datasets/ILSVRC2012_img_val';
% OUTPUT_PATH = '/data/datasets/ILSVRC2012_img_val_bg';
% BBOX_PATH = '/data/bboxes/ILSVRC2012_bbox_val';
% 
% folders = dir(INPUT_PATH);
% if ~isdir(OUTPUT_PATH)
%     mkdir(OUTPUT_PATH);
% end
% 
% 
% files = dir(fullfile(INPUT_PATH, '*.JPEG'));
% parfor j = 1: length(files)
%     [~, name_, ~] = fileparts(files(j).name);
%     inputFile = fullfile(INPUT_PATH, [name_, '.JPEG']);
%     bboxFile = fullfile(BBOX_PATH, [name_, '.xml']);
%     outputFile = fullfile(OUTPUT_PATH, [name_, '.JPEG']);
%     if (~exist(bboxFile, 'file'))
%         continue;
%     end
%     try
%         image = imread(inputFile);
%     catch exc
%         fprintf('%s\n', exc.identifier);
%         fprintf('%s\n',name_);
%         continue;
%     end
% %     [height, width, ~] = size(image);
% %     input = fopen(bboxFile, 'r');
% %     while (~feof(input))
% %         str = fgetl(input);
% %         index = strfind(str, '<bndbox>');
% %         if (index > 0)
% %             str = fgetl(input);
% %             index1 = strfind(str, '<xmin>');
% %             index2 = strfind(str, '</xmin>');
% %             substr = str(index1 + 6: index2 - 1);
% %             xmin = max(str2double(substr), 1);
% %             str = fgetl(input);
% %             index1 = strfind(str, '<ymin>');
% %             index2 = strfind(str, '</ymin>');
% %             substr = str(index1 + 6: index2 - 1);
% %             ymin = max(str2double(substr), 1);
% %             str = fgetl(input);
% %             index1 = strfind(str, '<xmax>');
% %             index2 = strfind(str, '</xmax>');
% %             substr = str(index1 + 6: index2 - 1);
% %             xmax = min(str2double(substr), width);
% %             str = fgetl(input);
% %             index1 = strfind(str, '<ymax>');
% %             index2 = strfind(str, '</ymax>');
% %             substr = str(index1 + 6: index2 - 1);
% %             ymax = min(str2double(substr), height);
% %             image(ymin: ymax, xmin: xmax, :) = 0;
% %         end
% %     end
% %     fclose(input);
% %     imwrite(image, outputFile, 'jpeg');
% % end
% % if matlabpool('Size')>0
% %     matlabpool close;
% % end
