function [mask_matrix,mask_indices]=get_mask_V1(subject,varargin)
% function [mask_matrix,mask_indices]=get_mask(FWHM for smoothing, brain_cutoff)
% default FWHM for smoothing = 6
% default brain_cutoff = 0.1 (of smoothed images)
%
% this function extracts a surface map of the brain from the gray matter
% input (in the structure "data"), thresholding at value "threshold"
% make sure that data has the fields designated in the
%
%     Copyright (C) 2009  D. Hermes & K.J. Miller, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

if length(varargin)>2
    data.grayfilename=varargin{3};
    data.whitefilename=varargin{4};
    outputdir=varargin{5};
else
    % use spm_select to get image file 
    data.grayfilename=spm_select(1,'image','select gray matter image','');
    data.whitefilename=spm_select(1,'image','select white matter image','');
    outputdir= spm_select(1,'dir','select directory to save surface');
end

if length(varargin)==0
    sm_lvl=6; %smoothing parameter for rendering gray
    br_cutoff=.1; %cutoff for thresholding
elseif length(varargin)==1
    sm_lvl=varargin{1};
    br_cutoff=.1; %cutoff for thresholding
elseif length(varargin)>=2
    sm_lvl=varargin{1};
    br_cutoff=varargin{2};
end

%lightly smooth gray matter
spm_smooth([data.grayfilename],'tempg.img',[sm_lvl sm_lvl sm_lvl]);
%load grey
brain_info=spm_vol(['tempg.img']); [g]=spm_read_vols(brain_info);
%lightly smooth white matter
spm_smooth([data.whitefilename],'tempw.img',[sm_lvl sm_lvl sm_lvl]);
%load white
brain_info=spm_vol(['tempw.img']); [w]=spm_read_vols(brain_info);

%identifies "enclosed points" for later removal
a=(g+w)>br_cutoff; %clear g w %combination of grey and white matter
a=hollow_brain(a);

bwa=bwlabeln(a);
% [x,y,z]=ind2sub(size(bwa),...
%     find(bwa==2));
brainsize=length(a(:));
size4surface=[brainsize/10 brainsize/500]; %set required size for surface
for k=1:max(max(max(bwa)))
    if length(find(bwa==k))<size4surface(1) && length(find(bwa==k))>size4surface(2)
        a=bwa==k;
        disp('nice surface found');
        break;
    end
end
if max(max(max(a)))>1
    disp('no good surface representation found, change size of surface in get_mask');
end
%%%%
dataOut=brain_info;
for k=1:100
    br_cutoff_str=num2str(br_cutoff);
    outputnaam=strcat([outputdir subject '_surface' int2str(k) '_'...
        int2str(sm_lvl) '_' br_cutoff_str([1 3]) '.img']);
    if ~exist(outputnaam,'file')
        dataOut.fname=outputnaam;
        disp(strcat(['saving ' outputnaam]));
        spm_write_vol(dataOut,a);
        break;
    end
end

