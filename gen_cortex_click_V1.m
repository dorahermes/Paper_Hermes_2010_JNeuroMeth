function cortex=gen_cortex_click_V1(subject,isoparm,sm_par,th_gm)
% function generates cortex rendering to display electrodes
% cortex=gen_cortex_click(subject,isoparm,sm_par)
% subject = 'name'; string sith subject name
% isoparm = degree of atrophy 0.2 for smooth, 0.65 unsmooth
% sm_par = smoothing, 1 or 2
%
% dh & kjm 240509

if exist('isoparm')~=1, isoparm=.65; %value of desired isosurface after smoothing
end
if exist('sm_par')~=1,
sm_par=2; %smoothing parameter for rendering gray (dim of lattice)
end
%load grey
[data.gName]=spm_select(1,'image','select image with gray matter');
brain_info=spm_vol(data.gName); [g]=spm_read_vols(brain_info);
%load white
[data.wName]=spm_select(1,'image','select image with white matter');
brain_info=spm_vol(data.wName); [w]=spm_read_vols(brain_info);

%combined grey and white "enclosed points" for later removal
a=(g+w); clear g w,
% threshold:
a(a<th_gm)=0;
a=sm_filt2(a,sm_par);

xst=(sum(brain_info.mat(:,2).^2)).^.5; %temporary x scaling for tesselation
yst=(sum(brain_info.mat(:,1).^2)).^.5; %temporary y scaling
zst=(sum(brain_info.mat(:,3).^2)).^.5; %temporary z scaling

fv=isosurface([1:size(a,2)].*xst, [1:size(a,1)].*yst, [1:size(a,3)].*zst, a, isoparm); %generate surface that is properly expanded for tesselation later fix indices to be in proper coordinates
vert=fv.vertices; tri=fv.faces;% clear fv

%reordering, etc
vert(:,1)=vert(:,1)/xst; vert(:,2)=vert(:,2)/yst; vert(:,3)=vert(:,3)/zst; 
cx=vert(:,1); cy=vert(:,2);
vert(:,1)=cy; vert(:,2)=cx; clear cx cy
vert=vert*brain_info.mat(1:3,1:3)'+repmat(brain_info.mat(1:3,4)',size(vert,1),1);
cortex.vert=vert; cortex.tri=tri; %familiar nomenclature

outputdir= spm_select(1,'dir','select directory to save cortex');

for k=1:100
    outputnaam=[outputdir subject '_cortex'];
    if ~exist(outputnaam,'file')
        dataOut.fname=outputnaam;
        disp(strcat(['saving ' outputnaam]));
        save([outputdir subject '_cortex'],'cortex');
        break;
    end
end



