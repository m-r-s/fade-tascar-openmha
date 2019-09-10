#!/usr/bin/octave
close all
clear
clc

calibration = 65;
range = [40 80];

datas = dir('data*.txt');
datas = {datas(:).name};
colorcode = cubehelix();
for i=1:length(datas)
  data = importdata(datas{i});
  Xs = sort(unique(data(:,1)));
  Ys = sort(unique(data(:,2)));
  %Zs = unique(data(:,3));
  SRT = nan(length(Ys),length(Xs));
  for j=1:size(data,1)
    SRT(data(j,2) == Ys,data(j,1) == Xs) = data(j,4); 
  end
  image_data = SRT + calibration;
  Xs_i = min(Xs):0.05:max(Xs);
  Ys_i = min(Ys):0.05:max(Ys);
  [XX_i, YY_i] = meshgrid(Xs_i, Ys_i);
  
  figure('Position',[0 0 300 200]);
  image_data_i = interp2(Xs, Ys, image_data, XX_i, YY_i,'nearest');
  imagesc(Xs_i, Ys_i, image_data_i, range);
  xticks(floor(Xs(1)):ceil(Xs(end)));
  yticks(floor(Ys(1)):ceil(Ys(end)));
  axis xy;
  axis image;
  caxis(range)
  title(datas{i});
  colormap(colorcode);
  colorbar;
  print('-depsc2',['map-raw-' datas{i} '.eps']);
  
  figure('Position',[0 0 300 200]);
  image_data_i = interp2(Xs, Ys, image_data, XX_i, YY_i,'cubic');
  image_data_i(image_data_i<range(1)) = range(1);
  contourf(Xs_i, Ys_i, image_data_i, range(1):3:range(2));
  xticks(floor(Xs(1)):ceil(Xs(end)));
  yticks(floor(Ys(1)):ceil(Ys(end)));
  axis xy;
  axis image;
  grid on;
  caxis(range)
  title(datas{i});
  colormap(colorcode);
  colorbar;
  print('-depsc2',['map-interp-' datas{i} '.eps']);
  
  figure('Position',[0 0 300 200]);
  angles = linspace(-90,270,100);
  phases = exp(2*pi*1i*angles./360);
  YY_i = 1.5.*real(phases).';
  XX_i = 1.5.*imag(phases).';
  
  plot_data_i = interp2(Xs, Ys, image_data, XX_i, YY_i,'cubic');
  plot(angles-90,plot_data_i,'-o');
  axis tight
  xticks(-180:30:180);
  yticks(-99:1:99);
  grid on;
  print('-depsc2',['plot-interp-' datas{i} '.eps']);
end
