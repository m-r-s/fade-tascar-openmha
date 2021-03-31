#!/usr/bin/octave
close all
clear
clc

[recording,fs] = audioread('recording.wav');

recording = recording .* 10.^(65./20);

FFTN = 2.^nextpow2(length(recording));

recording_fft = fft(recording,FFTN);
gains = 20*log10(abs(recording_fft));
f = linspace(0,fs*(1-1/FFTN),FFTN);
plot(log(f),gains);
xticks(log(1000*2.^(-3:3)))
xticklabels(1000*2.^(-3:3))
xlim(log([50 20000]));

for i=-3:3
  idx = find(f>1000.*2.^(i),1,'first');
  printf('Gain is %.2fdB at %.1fHz\n',gains(idx),f(idx));
end
