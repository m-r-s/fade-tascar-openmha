#!/usr/bin/octave -q

close all
clear
clc

cd ('OlHeaDHRTF_database');

% For TASCAR Azimuth is counter-clockwise!!!
AZs = 0:7.5:359; 

subject = 'KEMAR';
positions = {'BTE_fr' 'BTE_rear'};

[~, c_channels, srate] = loadHRIR(subject,'ED',0,0);

HRIR = [];
for i=1:length(AZs)
  % In Denk DB Azimuth it is clockwise
  az = 360 - AZs(i	);
  if az >= 180
    az = az - 360;
  end
  HRIR_tmp = cell(length(positions),1);
    for j=1:length(positions)
      HRIR_tmp{j} = loadHRIR(subject,positions{j},az,0);
    end
  HRIR_tmp = horzcat(HRIR_tmp{:});
  HRIR = [HRIR HRIR_tmp];
end

HRIR = HRIR.*10.^(-65/20);

cd('..');

fid = fopen('layout.spk','w');
if fid > 0
  fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
  fprintf(fid,'<layout name="generic%i">\n',length(AZs));
  for i=1:length(AZs)
    fprintf(fid,'<speaker az="%.2f"/>\n',AZs(i));
  end
  fprintf(fid,'</layout>\n',length(AZs));
  fclose(fid);
end

audiowrite(sprintf('HRIR-%s-%s-%i.wav',subject,sprintf('%s',positions{:}),length(AZs)),HRIR,srate,'BitsPerSample',32);
