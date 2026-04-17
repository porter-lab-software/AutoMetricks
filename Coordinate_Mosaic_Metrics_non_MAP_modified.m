% Coordinate_Mosaic_Metrics_modified2.m% Updated by John Assan: 2025
% Eliminates LUT use, input scaleval_deg as pixels/degree, uses original determine_mosaic_stats

clear;
close all force;

windowsize = [];

if length(windowsize) > 1
   error('Window size can only be empty ([]), or a single value!');
end

basePath = which('Coordinate_Mosaic_Metrics_modified2.m');
[basePath] = fileparts(basePath);
path(path,fullfile(basePath,'lib')); % Add library if needed

basepath = uigetdir(pwd);

% Read folder contents
[fnamelist, isadir] = read_folder_contents(basepath,'csv');
[fnamelisttxt, isadirtxt] = read_folder_contents(basepath,'txt');

% Fix to ensure vertical concatenation without dimension mismatch
if isrow(fnamelist)
    fnamelist = fnamelist(:);
end
if isrow(fnamelisttxt)
    fnamelisttxt = fnamelisttxt(:);
end

if isrow(isadir)
    isadir = isadir(:);
end
if isrow(isadirtxt)
    isadirtxt = isadirtxt(:);
end

% Combine lists vertically
fnamelist = [fnamelist; fnamelisttxt];
isadir = [isadir; isadirtxt];

liststr = {'microns (mm density)','degrees','arcmin'};
[selectedunit, oked] = listdlg('PromptString','Select output units:',...
                              'SelectionMode','single',...
                              'ListString',liststr);
if oked == 0
    error('Cancelled by user.');
end
selectedunit = liststr{selectedunit};

% Get scale and scale in degrees

scaleinput = NaN;
scaleval_deg = NaN;

while isnan(scaleinput)
    scaleinput_str = inputdlg('Input the scale in UNITS/PIXEL:', 'Physical Scale Input');
    if isempty(scaleinput_str)
        error('Cancelled by user.');
    end
    scaleinput = str2double(scaleinput_str);
end

while isnan(scaleval_deg)
    scaleval_pix_per_deg_str = inputdlg('Input the angular scale in PIXELS/DEGREE:', 'Angular Scale Input');
    if isempty(scaleval_pix_per_deg_str)
        error('Cancelled by user.');
    end
    
    scaleval_pix_per_deg = str2double(scaleval_pix_per_deg_str);
    
    if isnan(scaleval_pix_per_deg) || scaleval_pix_per_deg <= 0
        warndlg('Please enter a positive numeric value for pixels per degree.');
        continue;
    end
    
    % Convert pixels/degree to degrees/pixel
    scaleval_deg = 1 / scaleval_pix_per_deg;
end

scaleval = scaleinput;

first = true;
proghand = waitbar(0,'Processing...');

for i=1:size(fnamelist,1)
    try
        if ~isadir{i}
            fname = fnamelist{i};
            if length(fname)>42
                waitbar(i/size(fnamelist,1), proghand, strrep(fname(1:42),'_','\_') );
            else
                waitbar(i/size(fnamelist,1), proghand, strrep(fname,'_','\_') );
            end

            coords = dlmread(fullfile(basepath, fname));
            if size(coords,2) ~= 2
                warning('Coordinate list contains more than 2 columns! Skipping...');
                continue;
            end

            imname = fullfile(basepath, [fname(1:end-length('_coords.csv')) '.tif']);
            if exist(imname, 'file')
                im = imread(imname);
                width = size(im,2); height = size(im,1);

                if ~isempty(windowsize)
                    pixelwindowsize = windowsize/scaleval;
                    diffwidth = (width - pixelwindowsize)/2;
                    diffheight = (height - pixelwindowsize)/2;
                    diffwidth = max(diffwidth, 0);
                    diffheight = max(diffheight, 0);
                else
                    pixelwindowsize = [height width];
                    diffwidth=0; diffheight=0;
                end

                clipped_coords = coordclip(coords,[diffwidth  width-diffwidth],...
                                                  [diffheight height-diffheight],'i');
                clip_start_end = [diffwidth  width-diffwidth diffheight height-diffheight];
            else
                warning(['No matching image file found for ' fname]);
                width  = max(coords(:,1)) - min(coords(:,1));
                height = max(coords(:,2)) - min(coords(:,2));
                if ~isempty(windowsize)
                    pixelwindowsize = windowsize/scaleval;
                    diffwidth  = (width-pixelwindowsize)/2;
                    diffheight = (height-pixelwindowsize)/2;
                else
                    pixelwindowsize = [height width];
                    diffwidth=0; diffheight=0;
                end
                clipped_coords = coordclip(coords,...
                    [min(coords(:,1))+diffwidth-0.01, max(coords(:,1))-diffwidth+0.01],...
                    [min(coords(:,2))+diffheight-0.01, max(coords(:,2))-diffheight+0.01],'i');
                clip_start_end = [min(coords(:,1))+diffwidth-0.01 max(coords(:,1))-diffwidth+0.01 ...
                                  min(coords(:,2))+diffheight-0.01 max(coords(:,2))-diffheight+0.01];
            end

            % Call the original determine_mosaic_stats function
           statistics = determine_mosaic_stats_modified(clipped_coords, scaleval, scaleval_deg, selectedunit, clip_start_end, NaN, 4); %Changed to use the modified function that automatically gets the number of bound cells within range Godfred Sakyi-Badu(November 17, 2025)


            [ success ] = mkdir(basepath,'Results');
            if isempty(windowsize)
                result_fname = [getparent(basepath,'short') '_coordstats_' date '.csv'];
            else
                result_fname = [getparent(basepath,'short') '_coordstats_' date '_' num2str(windowsize) selectedunit '.csv'];
            end

            if success
                if first
                    fid= fopen(fullfile(basepath,'Results', result_fname),'w');
                    fprintf(fid,'Filename');
                    datafields = fieldnames(statistics);
                    for k=1:length(datafields)
                        val = statistics.(datafields{k});
                        if isscalar(val)
                            fprintf(fid,',%s',datafields{k});
                        end
                    end
                    fprintf(fid,'\n');
                    first = false;
                else
                    fid= fopen(fullfile(basepath,'Results', result_fname),'a');
                end

                fprintf(fid,'%s', fname);
                for k=1:length(datafields)
                    val = statistics.(datafields{k});
                    if isscalar(val)
                        fprintf(fid,',%1.2f',val);
                    end
                end
                fprintf(fid,'\n');
                fclose(fid);
            else
                error('Failed to make results folder! Exiting...');
            end
        end
    catch ex
        warning(['Error processing file ' fnamelist{i} ': ' ex.message]);
    end
end
close(proghand);

% Ensure your original determine_mosaic_stats function is on path and accessible.
