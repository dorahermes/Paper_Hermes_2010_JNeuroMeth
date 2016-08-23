function [a]=hollow_brain(brain)
%this hollows out the brain prior to tesselation
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
    
%nearest neighbor identification
a=brain(1:(size(brain,1)-2),2:(size(brain,2)-1),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),1:(size(brain,2)-2),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),2:(size(brain,2)-1),1:(size(brain,3)-2)).*...
    brain(3:(size(brain,1)),2:(size(brain,2)-1),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),3:(size(brain,2)),2:(size(brain,3)-1)).*...
    brain(2:(size(brain,1)-1),2:(size(brain,2)-1),3:(size(brain,3)));
%fill edges back in
b=cat(1,zeros(1,size(brain,2)-2,size(brain,3)-2),a,zeros(1,size(brain,2)-2,size(brain,3)-2));
b=cat(2,zeros(size(brain,1),1,size(brain,3)-2),b,zeros(size(brain,1),1,size(brain,3)-2));
b=cat(3,zeros(size(brain,1),size(brain,2),1),b,zeros(size(brain,1),size(brain,2),1));
%remove enclosed points
a=brain-b; a(a<0)=0; clear b g w brain


