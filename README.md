<b>SKHRecorder LV2 plugin for writing files in the PiPedal service. </b><br>
Based on https://github.com/brummer10/screcord.lv2

- Include a mono and a stereo capture plugin.
- using libsndfile <a href="http://www.mega-nerd.com/libsndfile/">http://www.mega-nerd.com/libsndfile/</a>
- save audio stream as wav  files to /var/pipedal/records/  the folder is created at the first launch

## Changes:
-remove code for X11
-added parameter THRESHOLD (start recording after threshold is exceeded)
-added parameter STATE (REC / WAIT / STOP)

## build:
- no build dependency check, just make
- libsndfile is needed

## install:
- make
- make install # will install into /usr/lib/lv2
