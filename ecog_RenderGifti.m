function tH = ecog_RenderGifti(g)
% function to render a gifti 
% 
% input:
%   g: gifti file with faces and vertices
%
% Viewing Angle: can be changed with ecog_ViewLight(90,0), changes both
% angle and light accordingly
%
% DH 2017

% convert surface labels into colors for vertices in mesh (c)
c = 0.7+zeros(size(g.vertices,1),3);

tH = trimesh(g.faces, g.vertices(:,1), g.vertices(:,2), g.vertices(:,3), c); axis equal; hold on
set(tH, 'LineStyle', 'none', 'FaceColor', 'interp', 'FaceVertexCData',c)
l1 = light;
lighting gouraud
material([.3 .9 .2 50 1]); 
axis off
set(gcf,'Renderer', 'zbuffer')
view(270, 0);
set(l1,'Position',[-1 0 1])

