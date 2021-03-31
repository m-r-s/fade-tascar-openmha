#!/usr/bin/octave -q

close all
clear
clc

cd ('OlHeaDHRTF_database');

% For TASCAR Azimuth is counter-clockwise!!!
AZs = 0:7.5:359; 

subject = 'KEMAR';
position = 'ED';

[~, c_channels, srate] = loadHRIR(subject,position,0,0);

HRIR = [];
for i=1:length(AZs)
  % In Denk DB Azimuth it is clockwise
  az = 360 - AZs(i	);
  if az >= 180
    az = az - 360;
  end
  HRIR = [HRIR loadHRIR(subject,position,az,0)];
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

audiowrite(sprintf('HRIR-%s-%s-%i.wav',subject,position,length(AZs)),HRIR,srate,'BitsPerSample',32);
