function label_add(els)
%     Copyright (C) 2009  K.J. Miller
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
    
msize=20; %marker size

hold on, plot3(els(:,1)*1.01,els(:,2)*1.01,els(:,3)*1.01,'.','MarkerSize',msize,'Color',[.99 .99 .99])
for k=1:length(els(:,1))
    text(els(k,1)*1.01,els(k,2)*1.01,els(k,3)*1.01,num2str(k),'FontSize',12,'HorizontalAlignment','center','VerticalAlignment','middle')
end



