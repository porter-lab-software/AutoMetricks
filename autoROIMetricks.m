%This is a program to automatically Rename files in the ROIs and compute
%Metricks on the ROIs 

%1. Program loops through folder containing Folders of ROIs and renames
%the tif and coordinate files so they are compatible with Metricks. 
% After renaming the file in the ROI, the program continue to run Metricks
% and saves the results in the Metricks folder created for the ROI

%3. Since we now do fixed number of cones, the program creates an Excel
%sheet containing the ROIs where the Metricks program could not get between
%95 -105 cones to analyze. 



%Written by Godfred Sakyi-Badu December 19,2025


clear;
clc;


folder_path_str= uigetdir(pwd, 'Please select Folder containing the ROIs'); %Getting the user to select the folder containing the ROIs 
folder = dir(folder_path_str);






scaling_microns = inputdlg("Input the scale in UNITS/PIXEL:", "Physical Scale Input"); %Scaling in Microns per pixel which will be applied to all ROIs in the folder
scaling_pixels = inputdlg ("Input the angular scale in PIXELS/DEGREE",'Angular Scale Input');%Scaling in Pixels per degree which will be applied to all ROIs in the folder

liststr = {'microns (mm density)','degrees','arcmin'};
[selectedunit, oked] = listdlg('PromptString','Select output units:',...
                      'SelectionMode','single',...
                      'ListString',liststr); %List of output units

selectedunit = liststr{selectedunit}; %The same unit of calculation of metrics will be applied to all of the ROIs


addpath('C:\MATLAB\AutoMetricks'); %Adding the folder containing the Metricks Code to the path 
savepath;


for i = 1: length(folder)

    if strlength(folder(i).name)>3 %Exclude pointers to the folder itself and the folder above it
        
        path = strcat(folder(i).folder,"\" ,folder(i).name); %Get the path for the individual folders like the fovea folder etc
        cd (path); % Change directory to that folder

        subfolder = dir;
        subfolder.name; %Now that folder becomes the subfolder the rest of the program is going to work on

        newfolder = strcat(folder(i).folder,'\',folder(i).name,'\Metricks'); %This is the directory for metrics in that ROI

        mkdir(newfolder); %Creating a new Metricks folder

        

        

        %Reading in the image file in the subfolder
        img_file_pattern = fullfile(path,'*.tif');
        img_dir = dir(img_file_pattern);

        img = imread(img_dir.name);
        
        
        %Getting the file parts used for Renaming the Tif and Coords file

        subpath = strcat(img_dir.folder,"\", img_dir.name);

        len_sub_folder_path = length(strsplit(img_dir.folder,'\')); %Get the length of the subfolder directory fileparts

        stringCompSub = strsplit(subpath,['\',"_"]); %Spliting the subpath directory based on the delimiters for the renaming 
    
        stringCompSub = stringCompSub(len_sub_folder_path+1:end); %Remove the basepath fileparts from the complilation string

        stringCompFull = strsplit(folder(i).name," "); %Split the folder name for eg (Inferior 100)= 1x2 Cell array
    
        combined = cell2mat(join(stringCompFull,'_')); %Join the elements in the cell array using _ and then convert to normal array.(Output = Inferior_100) Used that for creating the filename


        %Writing the Image into the Metricks Folder
        filename_img = strcat(stringCompSub(1),"_",combined,"_",stringCompSub(4),".tif"); %Filename for tifs
     
        fullPath = fullfile(newfolder,filename_img);

        imwrite(img, fullPath) %Writing the tif file into the Metricks folder created

        
        %Reading and Writing the Coords file 
        coord_file_pattern = fullfile(path,"*.csv");
        coord_dir = dir(coord_file_pattern);

        table = readtable(coord_dir.name);
        
        filename = strcat(stringCompSub(1),"_",combined,"_",stringCompSub(4),"_coords.csv");%Filename for coordinate files 6-Monkey ID and 9- Date of imaging

        fullPath = fullfile(newfolder, filename);

        writetable(table,fullPath, 'WriteVariableNames', false); %Writing the coordinate file into the Metricks folder created

 

      
                
    
        %Changing the directory to the Metricks folder
        metric_path = strcat(path, "\Metricks");
        cd(metric_path);
        basepath = pwd;
        
        %Computing the Metricks for that ROI

        [cellsBound]=Coordinate_Mosaic_Metrics_Non_Map_Auto(basepath, scaling_microns, scaling_pixels, selectedunit, oked); %Calling the Metricks function
   
         not_enough_cells = {}; % Creating a cell array containing the names of the ROIs not having enough number of Bound Cells. 

        if cellsBound<95 && cellsBound>105
            not_enough_cells{end+1} = path;
        end
    
    
        cd(folder_path_str); %Change the directory to the base folder containing the ROIs
    end
end

writecell(not_enough_cells, folder_path_str) %Writing a CSV containing the ROIs which do not have enought bound cells. 