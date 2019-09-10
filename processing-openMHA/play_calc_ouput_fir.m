# FIR OUTPUT openMHA
a = loadHRIR('KEMAR', 'ED', 0, 0);
b = loadHRIR('KEMAR', 'BTE_fr', 0, 0);
a_fft = fft(a,512);
b_fft = fft(b,512);
b_fft_mod = b_fft;
idx = abs(b_fft)<0.01;
b_fft_mod(idx) = 0.01.*exp(1i.*angle(b_fft(idx)));
c_fft = a_fft./b_fft;
c_fft(end/3:end,:) = 0;
ir = (fftshift(2.*real(ifft(c_fft))));
ir_short = ir(240:240+95,:);
ir_short(1:10,:) .*= hann(22)(2:11);
ir_short(end-9:end,:) .*= hann(22)(12:end-1);
printf('\n\n')
printf('%.15f ',ir_short(:,1))
printf('\n\n')
printf('%.15f ',ir_short(:,2))
printf('\n\n')