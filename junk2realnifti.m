% g_name='./data_EG/t1_2gray.nii'; %gray
% w_name='./data_EG/t1_aligned_class.nii'; % white

g_name='./data_EG/EG_left_grey.nii'; %grey
w_name='./data_EG/EG_left_white.nii'; %white

anat_name='./data_EG/t1_avg.nii'; %t1


brain_info=spm_vol([g_name]); [g]=spm_read_vols(brain_info);
brain_info=spm_vol([w_name]); [w]=spm_read_vols(brain_info);


brain_info=spm_vol(anat_name); 
dataOut=brain_info;

dataOut.fname='./data_EG/test_g.img';
spm_write_vol(dataOut,g);

dataOut.fname='./data_EG/test_w.img';
spm_write_vol(dataOut,w);