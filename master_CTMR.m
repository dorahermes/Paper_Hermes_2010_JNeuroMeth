
%% 1) run segment anatomical MR in SPM5
% startup SPM (spm functions are used)
% coregister + reslice CT to anatomical MR
% in SPM5 reference image = MR, source image = CT
% segment MR
%% 2) generate surface (The Hull) to project electrodes to

% get_mask(subject,gray,white,outputdir,degree of smoothing,threshold) 
% e.g. get_mask(6,0.1) or get_mask(16,0.3)

% if using SPM segmentation to create mask
% get_mask('name',10,0.2);% for popups
get_mask_V1('name',...
    16,0.3,...% settings for smoothing and threshold
    './data/c1name_t1.nii',...% gray matter segmentation probability map
    './data/c2name_t1.nii',...% white matter segmentation probability map
    './data/');% where you want to safe the file
% hull is not very nice, because segmentation is not so nice

% if using ITK output: 
% gray and white are generally in the same file, so just select the whole thing twice
get_mask_V2('name',... % subject name
    './data/name_t1_class_electrodes.nii',... % gray matter file
    './data/name_t1_class_electrodes.nii',... % white matter file
    './data/name_t1.nii',... % t1 file
    './data/',... % where you want to safe the file
    'r',... % 'l' for left 'r' for right
    13,0.2); % settings for smoothing and threshold

% if using freesurfer: (not always nice)
get_mask_V3('name',... % subject name
    './data/t1_class.nii',... % freesurfer class file
    './',... % where you want to safe the file
    'r',... % 'l' for left 'r' for right
    13,0.3); % settings for smoothing and threshold


%% 3) select electrodes from ct
ctmr
% view result
% save image: saves as nifti hdr and img files

%% 4) sort unprojected electrodes
sortElectrodes;
% loads img file with electrodes from previous step
% saves as electrodes_locX;

% electrode 104 is sitting on top of antother, after assigning numbers,
% change into NaN:

%% 5) plot electrodes 2 surface
% electrodes2surf(subject,localnorm index,do not project electrodes closer than 3 mm to surface)

% electrodes2surf(
    % 1: subject
    % 2: number of electrodes local norm for projection (0 = whole grid)
    % 3: 0 = project all electrodes, 1 = only project electrodes > 3 mm
    %    from surface, 2 = only map to closest point (for strips)
    % 4: electrode numbers
    % 5: (optional) electrode matrix.mat (if not given, SPM_select popup)
    % 6: (optional) surface.img (if not given, SPM_select popup)
    % 7: (optional) mr.img for same image space with electrode
    %    positions
% saves automatically a matrix with projected electrode positions and an image
% with projected electrodes
% saves as electrodes_onsurface_filenumber_inputnr2

% % 1: for a grid use:
% [out_els,out_els_ind]=electrodes2surf('name',...
%     5,1,... % use these settings for the grid
%     [1:32],... % electrode numbers from the following file
%     './data/electrodes_loc1.mat',... % file with electrode XYZ coordinates
%     './data/name_surface1_13_02.img',... % surface to which the electrodes are projected
%     './data/t1_aligned.nii');
% % 2: for a 2xN strip use:
% [out_els,out_els_ind]=electrodes2surf('name',4,1,[1:32],'./data/electrodes_loc1.mat','./data/name_surface1_13_02.img','./data/t1_aligned.nii');
% % 3: for a 1xN strip use (project to closest point on the surface, no direction):
% [out_els,out_els_ind]=electrodes2surf('name',0,2,[1:32],'./data/electrodes_loc1.mat','./data/name_surface1_13_02.img','./data/t1_aligned.nii');

surface_name='./data/name_surface1_13_02.img';
t1_name='./data/name_t1.nii';

% lateral grid:
[out_els,out_els_ind]=electrodes2surf('name',5,1,[1:64],'./data/electrodes_loc1.mat',surface_name,t1_name);

%% 6) combine electrode files into one and make an image
%
subject='name';
elecmatrix=nan(137,3);
switch subject
    case 'name'
    load('./data/name_electrodesOnsurface1_5.mat'); % Lateral Grid
    elecmatrix(1:64,:)=out_els;
    load('./data/name_electrodesOnsurface1_4.mat'); % mST
    elecmatrix(71:80,:)=out_els;
    load('./data/name_electrodesOnsurface1_0.mat'); % aST
    elecmatrix(65:70,:)=out_els;
    load('./data/name_electrodesOnsurface2_0.mat'); % OCC
    elecmatrix(91:96,:)=out_els;
    load('./data/name_electrodesOnsurface3_0.mat'); % pIH (104 excluded)
    elecmatrix(97:103,:)=out_els;
    load('./data/name_electrodesOnsurface4_0.mat'); % aIH
    elecmatrix(105:112,:)=out_els;
    load('./data/name_electrodesOnsurface2_4.mat'); % PST
    elecmatrix(81:90,:)=out_els;
  
    [output,els,els_ind,outputStruct]=position2reslicedImage(elecmatrix,'./data_freesurfer/name_t1.nii');

    for filenummer=1:100
        save(['./data/' subject '_electrodes_surface_loc_all' int2str(filenummer) '.mat'],'elecmatrix');
        outputStruct.fname=['./data/electrodes_surface_all' int2str(filenummer) '.img' ];
        if ~exist(outputStruct.fname,'file')>0
            disp(['saving ' outputStruct.fname]);
            % save the data
            spm_write_vol(outputStruct,output);
            break
        end
    end
end

%% 6) generate cortex to render images:

% from SPM
gen_cortex_click_V1('name',0.3,2,.98); 

% from ITK
gen_cortex_click_V2('name',0.4,[15 3],'r'); 

% from freesurfer
gen_cortex_click_V3('name_R',0.4,[15 3],'r'); 
gen_cortex_click_V3('name_L',0.4,[15 3],'l'); 


%% 7) plot electrodes on surface 
% load cortex
load(['./data/name_cortex.mat']);
% load(['./data_spm/name_cortex.mat']);
% load electrodes on surface
load(['./data/name_electrodes_surface_loc_all1.mat']);

% plot projected electrodes:
ctmr_gauss_plot(cortex,[0 0 0],0) % generates cortex rendering
el_add(elecmatrix,'g',30);
% or maybe add numbers:
label_add(elecmatrix);
% adjust view
loc_view(90,0)

% plot electrodes wiht nice colors:
r2=[1:length(elecmatrix)];% example value to plot
max = length(elecmatrix); % maximum for scaling
el_add_sizable(elecmatrix,r2,max)



