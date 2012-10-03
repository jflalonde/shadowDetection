This software package detects shadows from single images by using an 
approach described in the following paper:

J.-F. Lalonde, A. A. Efros, and S. G. Narasimhan. Detecting Ground Shadows 
in Outdoor Consumer Photographs. in European Conference on Computer Vision, 
2010.

Please cite this paper if you use this code in your work. See 
'demoShadowDetection.m' as a starting point on how to use the software.


*** CHANGING THE INPUT IMAGE ***

If you want to make it work on your own image, here's what you should do:

1. Copy your image in the img/ directory (should have .jpg extension);
2. Change the imgName variable with the new filename (leave the .jpg extension out);
3. If you want to detect shadows on the ground only:
   3.1 Compute the ground probability map (e.g. with Geometric Context, see below);
   3.2 Save the ground probability map as variable 'groundProb' in a .mat file;
   3.1 Copy the .mat file containing the variable 'groundProb' in the img/ directory;
   3.2 Rename the file to '<image name as in step 2>-groundProb.mat'.
4. Watch the output while the program is running to make sure there are no errors or warnings;
5. That's it!

*** NEWS ***

- 05/24/2011: The code should now work without requiring the Matlab 
  Statistics Toolbox (thanks to M. Chen for helping me figure this out!). 
  It's best to re-download the code completely. The following changes have 
  been made:
  - The 'data/bdt-eccv10.mat' file has been changed to use built-in 'structs' 
    instead of 'classtreereg'.
  - The 'skewness.m' function has been added to replace the toolbox's. 


*** REQUIRED 3RD-PARTY SOFTWARE NOT INCLUDED WITH THIS PACKAGE ***

Required 3rd-party software: 
- lightspeed matlab toolbox by Tom Minka, available at: 
   http://research.microsoft.com/en-us/um/people/minka/software/lightspeed/
   need at least version 2.4

- graph cut wrapper by Shai Bagon, which uses C++ code by Olga Veksler, available at:
  http://www.wisdom.weizmann.ac.il/~bagon/matlab.html

Make sure these 3rd-party packages are added to the path before launching 
the program.


*** OPTIONAL 3RD-PARTY SOFTWARE NOT INCLUDED WITH THIS PACKAGE ***

Optional 3rd-party software (use this to pre-compute the ground probability)

- geometric context code by Derek Hoiem, available at: 
  http://www.cs.uiuc.edu/homes/dhoiem/


*** REQUIRED 3RD-PARTY SOFTWARE INCLUDED WITH THIS PACKAGE ***

In addition, this code uses the following freely-available matlab code: 

- Bilateral filtering by Douglas R. Lanman
  http://mesh.brown.edu/dlanman

- Boundary extraction from Andrew Stein
  http://www.andrewstein.net/

- The parseArgs argument-parsing library from Malcolm Wood, available at:
  http://www.mathworks.com/matlabcentral/fileexchange/10670-parseargs-simplifies-input-processing-for-functions-with-multiple-options

- Fast nearest-neighbor search by Luigi Giaccari, available at:
  http://www.advancedmcode.org/k-nearest-neigbours-search.html
  or 
  http://www.mathworks.co.uk/matlabcentral/fileexchange/22407-k-nearest-neighbours-and-radius-range-search

- Boosted decision tree code by Derek Hoiem, available at:
  http://www.cs.uiuc.edu/homes/dhoiem/

Check within each of the following directories and make sure you compile 
the .mex files. They are required for this software to run:
  - boost, nearestneighbor
