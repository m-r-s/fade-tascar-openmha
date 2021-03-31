#!/usr/bin/octave
% Author: Marc René Schädler (2020)
% E-Mail: marc.rene.schaedler@uni-oldenburg.de
close all
clear
clc

% Use QT for interactive figure
graphics_toolkit qt
h = figure;

% Increase font size
fontsize = 24;
set(0,'defaultAxesFontSize',fontsize)

% Fullscreen mode without toolbars/menus
pause(0.1);
screensize = get(0, 'Screensize');
set(gcf, 'Position', screensize, 'MenuBar', 'none', 'ToolBar', 'none');
drawnow;
% Setup levels
level_range = [45 85];
level_ticks = [40 50 55 60 67 70 75 80 85];
level_labels = {'40 dB SPL', '50 dB SPL', 'casual', 'normal (60 dB SPL)', 'raised', '70 dB SPL' , 'loud', '80 dB SPL', 'shouted'};

% Use strongly quantized attenuated jet colormap to imitate "contour" effect
colorcode = jet(12)*0.8;
objectlinewidth = 4;

% Positions of objects
walls_pos = [-2.1 1.6 1.6 -2.1 -2.1; -2.1 -2.1 0.6 0.6 -2.1];
tv_pos = [-0.059 0.332];
cr_pos = [-1.9 0.6];
head_pos = [-0.059 -1.6];

% Setup data request
xx = -2:0.5:1.5;
yy = -2:0.5:0.5;
zz = 0;
angles = [0 45 90 135 180];
tvmodes = [0 1];
crmodes = [0 1];
reverb = [0 1];
impairment = {'' '-hi' '-hi-ha'};

% Could be used for comparisons between conditions
image_data_reference = zeros(numel(yy),numel(xx));

% Import requested data from result files
srtdata = nan(numel(zz),numel(yy),numel(xx),numel(angles),numel(tvmodes),numel(crmodes),numel(reverb),numel(impairment));
for i = 1:length(angles)
  for j = 1:length(tvmodes)
    for k = 1:length(crmodes)
      for l = 1:length(reverb)
        for m = 1:length(impairment)
          % Build file name
          filename = ['livingroom-var' impairment{m} filesep 'parameter_ortf_' sprintf('%i_%i_%i_%i',angles(i),tvmodes(j),crmodes(k),reverb(l)) filesep 'data-levels.txt'];
          if exist(filename,'file')
            fid = fopen(filename);
            if fid > 0
              % Read X Y Z SRT
              data_tmp = textscan(fid,'%f %f %f %f');
              fclose(fid);
              data_tmp = horzcat(data_tmp{:});
              % Write matching data to our variable
              for o = 1:size(data_tmp,1)
                zidx = zz > data_tmp(o,3)-0.01 & zz < data_tmp(o,3)+0.01;
                yidx = yy > data_tmp(o,2)-0.01 & yy < data_tmp(o,2)+0.01;
                xidx = xx > data_tmp(o,1)-0.01 & xx < data_tmp(o,1)+0.01;
                if sum(xidx) == 1 && sum(yidx) == 1 && sum(zidx) == 1
                  srtdata(zidx,yidx,xidx,i,j,k,l,m) = data_tmp(o,4);
                end
              end
            end
          end
        end
      end
    end
  end
end

% Get absolute level in dB SPL. Simulated SRTs are relative to 65 dB
srtdata = srtdata + 65;

% Initialize image map
image_data = zeros(size(image_data_reference));
image_data(:,:) = 0;
h_image = imagesc(xx, yy, image_data, [50 80]);
hold all;
xticks(floor(xx(1)):ceil(xx(end)));
yticks(floor(yy(1)):ceil(yy(end)));

% Draw walls
plot(walls_pos(1,:),walls_pos(2,:),'k','linewidth',5);

% Draw TV
h_tv = patch(tv_pos(1)+[-0.3 -0.3 0.3 0.3],tv_pos(2)+[-0.04 0.04 0.04 -0.04],[0 0 0],'linewidth',objectlinewidth);
text(tv_pos(1),tv_pos(2),'TV','fontsize',fontsize,'horizontalalignment','center');

% Draw connected room
h_cr = patch(cr_pos(1)+[-0.2 -0.2 0.2 0.2],cr_pos(2)+[-0.00 -0.08 -0.08 0.00],[0 0 0],'linewidth',objectlinewidth);
text(cr_pos(1),cr_pos(2)-0.04,'door','fontsize',fontsize,'horizontalalignment','center');

% Set aspect, range, colormap, labels...
axis xy;
axis image;
grid off;
caxis(level_range)
colormap(colorcode);
colorbar('YTick', level_ticks, 'YTickLabel', level_labels);
xlabel('meters');
ylabel('meters');

% Draw head (with ears)
head_coords = [1.4 e.^(2*pi*1i.*(1:31)./32) 1.4].*0.15.*e.^(1i*2*pi/4);
earsmod = 1+[0 0 0 0 0 0 0 0.1 -0.1 0.1 0 0 0 0 0 0 0 0 0 0 0 0 0 0.1 -0.1 0.1 0 0 0 0 0 0 0];
head_coords = head_coords.*earsmod;
h_head = patch(head_pos(1)+real(head_coords),head_pos(2)+imag(head_coords),[1 1 1],'linewidth',objectlinewidth);

% Collect all handles for plotted objects in a struct for easy updates
handles = struct('image', h_image, 'tv', h_tv, 'cr', h_cr, 'head', h_head);

% Figure refresh function (called after each change)
function refresh_data(handles)
  % Load map data
  image_userdata = get(handles.image,'UserData');
  angles = image_userdata.angles;
  srtdata = image_userdata.srtdata;

  % Load TV data
  tv_userdata = get(handles.tv,'UserData');
  tv_toggle = tv_userdata.toggle;
  tv_color = [0 0 0];
  switch tv_toggle
    case 1
      tv_color = [0 1 0];
    case 2
      tv_color = [1 0 0];
  end
  set(handles.tv,'facecolor',tv_color);

  % Load connected room data
  cr_userdata = get(handles.cr,'UserData');
  cr_toggle = cr_userdata.toggle;
  cr_color = [0 0 0];
  switch cr_toggle
    case 1
      cr_color = [0 1 0];
    case 2
      cr_color = [1 0 0];
  end
  set(handles.cr,'facecolor',cr_color);
  
  % Load head data
  head_userdata = get(handles.head,'UserData');
  head_coords = head_userdata.head_coords;
  head_pos = head_userdata.head_pos;
  head_dir = head_userdata.head_dir;
  head_toggle = head_userdata.toggle;
  phi = head_dir./360.*2.*pi;
  head_rotation = e.^(1i.*(phi-pi/2));
  head_color = [0 0 0];
  switch head_toggle
    case 1
      head_color = [1 1 1];
    case 2
      head_color = [1 0.5 0];
    case 3
      head_color = [0 0.5 1];
  end
  set(handles.head,'xdata',head_pos(1)+real(head_coords.*head_rotation));
  set(handles.head,'ydata',head_pos(2)+imag(head_coords.*head_rotation));
  set(handles.head,'facecolor',head_color);
  
  % Update image data
  image_data = get(handles.image,'cdata');
  [~, diridx] = min(abs(angles - head_dir));
  tvidx = tv_toggle;
  cridx = cr_toggle;
  impidx = head_toggle;
  % srtdata = nan(numel(zz),numel(yy),numel(xx),numel(angles),numel(tvmodes),numel(crmodes),numel(reverb),numel(impairment));
  image_data(:,:) = srtdata(1,:,:,diridx,tvidx,cridx,2,impidx); 
  set(handles.image,'cdata',image_data);
  drawnow;
end

function imageclickcallback (objectHandle)
  axesHandle  = get(objectHandle,'Parent');
  coordinates = get(axesHandle,'CurrentPoint');
  userdata = get(objectHandle,'UserData');
  head_userdata = get(userdata.handles.head,'UserData');
  head_pos = head_userdata.head_pos;

  % Get coordinates of clicked point
  coordinates = coordinates(1,1:2);
  [x_max, y_max] = size(get(objectHandle,'cdata'));
  x = coordinates(1)-head_pos(1);
  y = coordinates(2)-head_pos(2);
  
  % Calculate angle
  phi = atan(y./x) + (x<0).*pi;
  head_dir = phi./(2*pi)*360;
  
  % Round angle to nearest available data
  angles = userdata.angles;
  [~, diridx] = min(abs(angles - head_dir));
  head_dir = angles(diridx);
  
  % Store angle
  head_userdata = get(userdata.handles.head,'UserData');
  head_userdata.head_dir = head_dir;
  set(userdata.handles.head,'UserData',head_userdata);
  
  % Refresh figure
  refresh_data(userdata.handles);
end

function tvclickcallback (objectHandle)
  userdata = get(objectHandle,'UserData');
  switch userdata.toggle
    case 2
      userdata.toggle = 1;
    case 1
      userdata.toggle = 2;
  end
  set(objectHandle,'UserData',userdata);
  
  % Refresh figure
  refresh_data(userdata.handles);
end

function crclickcallback (objectHandle)
  userdata = get(objectHandle,'UserData');
  switch userdata.toggle
    case 2
      userdata.toggle = 1;
    case 1
      userdata.toggle = 2;
  end
  set(objectHandle,'UserData',userdata);
  
  % Refresh figure
  refresh_data(userdata.handles);
end

function headclickcallback (objectHandle)
  userdata = get(objectHandle,'UserData');
  switch userdata.toggle 
    case 3
      userdata.toggle = 1;
    case 1
      userdata.toggle = 2;
    case 2
      userdata.toggle = 3;
  end
  set(objectHandle,'UserData',userdata);
  
  % Refresh figure
  refresh_data(userdata.handles);
end

% Set callbacks, and other object related data
set(h_image,'UserData',struct('handles',handles,'srtdata',srtdata,'angles',angles));
set(h_image,'ButtonDownFcn',@imageclickcallback);

set(h_tv,'UserData',struct('handles',handles,'toggle',2));
set(h_tv,'ButtonDownFcn',@tvclickcallback);

set(h_cr,'UserData',struct('handles',handles,'toggle',2));
set(h_cr,'ButtonDownFcn',@crclickcallback);

set(h_head,'UserData',struct('handles',handles,'toggle',1,'head_coords',head_coords,'head_pos',head_pos,'head_dir',90));
set(h_head,'ButtonDownFcn',@headclickcallback);

% Refresh figure to match current variable values
refresh_data(handles);
waitfor(h);
