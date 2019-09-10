# Speech recognition performance prediction with FADE, TASCAR, and openMHA
This expert-software can be used to simulate speech recognition experiments in complex acoustic scenes.

Copyright (C) 2019 Marc René Schädler

E-mail: marc.r.schaedler@uni-oldenburg.de

![Motivating image](https://raw.githubusercontent.com/m-r-s/fade-tascar-openmha/master/images/motivation.png)

The scripts provided in this software package can be used to simulate aided speech recognition experiments with the Framework for Auditory Discrimination Experiments (FADE, [1]) in acoustic scenes that are rendered with the Toolbox for Acoustic Scene Creation and Rendering (TASCAR, [2]) and the data from the OlHeaD-HRTF Database [3] where the hearing aid is simulated with the open Master Hearing Aid (openMHA, [4]).

Please note that these scripts expects recordings to be 32-bit wav files, sampled at 48kHz, that are calibrated such that an RMS of 1 means 130 dB SPL .
The speech material for the German Matrix sentence test [5] is not free and not provided in this repository.

# Usage
This is a collection of scripts that we use for studying the aided speech recognition performance of listeners with impaired hearing in acoustically complex listening conditions.

'''There is no guarantee that these scripts work, nor that their output will help you in any way.'''

We offer this example as a reference or starting point for colleagues who want to better understand our work.
If you don't know the tools FADE, TASCAR, or openMHA it is very likely that the provided code won't help you.
The scripts were developed and used on Ubuntu Linux 19.04.
They require a functional installation of the following programs:

- FADE (https://github.com/m-r-s/fade)
- TASCAR (https://github.com/HoerTech-gGmbH/tascar/)
- openMHA (https://github.com/HoerTech-gGmbH/openMHA)

The script "run_experiment.sh" runs a set of simulations with the exemplary acoustic scene defined in "scene-complex-processing" using the hearing aid configured in the "processing-openMHA" folder and plots the outcome as a map.

# References
[1] Schädler, M. R., Warzybok, A., Ewert, S. D., Kollmeier, B. (2016) "A simulation framework for auditory discrimination experiments: Revealing the importance of across-frequency processing in speech perception", Journal of the Acoustical Society of America, Volume 139, Issue 5, pp. 2708–2723, URL: http://link.aip.org/link/?JAS/139/2708

[2] Grimm, G., Luberadzka, J., Herzke, T., Hohmann, V. (2015) "Toolbox for acoustic scene creation and rendering (TASCAR) - Render methods and research applications", in Proceedings of the Linux Audio Conference, Mainz, 2015

[3] F. Denk, S.M.A. Ernst, S.D. Ewert, B. Kollmeier, (2018) "Adapting hearing devices to the individual ear acoustics: Database and target response correction functions for various device styles", Trends in Hearing, vol 22, p. 1-19. DOI:10.1177/2331216518779313

[4] Herzke, T., Kayser, H., Loshaj, F., Grimm, G., Hohmann, V. "Open signal processing software platform for hearing aid research (openMHA)", in Proceedings of the Linux Audio Conference. Université Jean Monnet, Saint-Étienne, pp. 35-42, 2017.

[5] URL http://www.hoertech.de/en/medical-devices/olsa.html

