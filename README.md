MRMotion
========

MATLAB GUI tool to simulate effects of in-plane motion on 2D Cartesian Magnetic Resonance Images


### Usage
1.  Start MATLAB
2.  Use `cd` command within MATLAB to change to directory where MRMotion m-files are located
3.  Type `MRMotion` at MATLAB prompt
4.  Load in an image
    a.  CIMG - complex image float32   (assumed to be byte swapped)
    b.  KSP  - complex k-space float32 (assumed to be byte swapped)
5.  Create motion records or load a .MOT file


### Saving

* Corrupted image results can be saved as .CIMG or .KSP
* Motion records can be saved and later loaded as .MOT files
* Corrupted images can also be saved as .TIF files.  They will have window and level equal to the current display,


### Notes

* Wrist images may need to have the window and level adjusted before they display well.
* "Phase Chopping" (quadrant swapping in the conjugate domain) can be performed using `Chop X` and `Chop Y` buttons.
* Don't forget the ROI feature!
