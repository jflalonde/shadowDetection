This software package detects shadows from single images by using an 
approach described in the following paper:

J.-F. Lalonde, A. A. Efros, and S. G. Narasimhan, "Detecting ground shadows 
in outdoor consumer photographs," presented at the European Conference on 
Computer Vision, 2010.

Please cite this paper if you use this code in your work. 

Getting started
===============

1.  Install the required packages (see below), and compile them;
2.  From the `mycode` directory, run:
        
        $ setPath
        $ demoShadowDetection

3.  The results should appear as they are computed. Enjoy!


Changing the input image
========================

If you want to make it work on your own image, here's what you should do:

1.  Copy your image in the `img` directory (should have .jpg extension);
2.  Change the `imgName` variable with the new filename (leave the .jpg extension out);
3.  If you want to detect shadows on the ground only:

    3.1  Compute the ground probability map (e.g. with Geometric Context, see below);
    3.2  Save the ground probability map as variable `groundProb` in a .mat file;
    3.1  Copy the .mat file containing the variable `groundProb` in the `img` directory;
    3.2  Rename the file to `<image name as in step 2>-groundProb.mat`.

4. Watch the output while the program is running to make sure there are no errors or warnings;
5. That's it!


Requirements
============

Required 3rd-party software *not included* in this package
-----------

*  My "utils" package, available at: https://github.com/jflalonde/utils/.
*  [Lightspeed matlab toolbox](http://research.microsoft.com/en-us/um/people/minka/software/lightspeed/) by Tom Minka, 
   need at least version 2.4.
*  [Graph cut wrapper](http://www.wisdom.weizmann.ac.il/~bagon/matlab.html) by Shai Bagon
   which uses C++ code by Olga Veksler.
  
If you put these 3rd-party packages in a `pathUtils` folder in the same base
folder as the `shadowDetection`, they should be picked up automatically by
`setPath`. 

Make sure you follow the respective instructions to install those packages.


Required 3rd-party software *included* in this package
-----------

In addition, this code uses the following freely-available matlab code: 

*   [Bilateral filtering](http://mesh.brown.edu/dlanman) by Douglas R. Lanman
*   [Boundary extraction](http://www.andrewstein.net/) from Andrew Stein
*   [Fast nearest-neighbor search](http://www.advancedmcode.org/k-nearest-neigbours-search.html) by Luigi Giaccari,
    also available [here](http://www.mathworks.co.uk/matlabcentral/fileexchange/22407-k-nearest-neighbours-and-radius-range-search);
*   [Boosted decision tree](http://www.cs.uiuc.edu/homes/dhoiem/) by Derek Hoiem
  

Compilation
-----------

Check within each of the following directories and make sure you compile 
the .mex files. They are required for this software to run:

*   Boosted decision trees

        $ cd 3rd_party/boost
        $ mex treevalc.c

*   Nearest neighbor

        $ cd 3rd_party/nearestneighbor
        $ mex BruteSearchMex.cpp

Optional 3rd-party software *not included* in this package
-----------

*   [Geometric context](http://www.cs.uiuc.edu/homes/dhoiem/) by Derek Hoiem.
  

Tuning the parameters
==================

There are a few parameters you might want to fiddle with in order to tune the results to your liking. 

* Resize the image to ~600 pixels along the vertical dimension, since computing features is 
likely to be prohibitively expensive for images of larger size.

* If the algorithm fails to detect shadows that are too soft, try reducing the image size, or modify the 
Canny edge detection parameters to make it fire on that edge. We are, after all, looking for shadow *edges*. 
You will find the Canny edge detection call at line 39 of `applyLocalBoundaryClassifier.m`.

* If the detected shadow edges are too discontinuous, you can experiment with the over-segmentation parameters
to obtain larger, more continuous segments. You will face a trade-off, however: larger segments will be less precise
at capturing small details. For this, look at `extractImageBoundaries.m` and experiment with the `prctMax` parameter.

News
====

-  10/03/2012: Code is now on github, see commit messages for news and changes! 
-  05/24/2011: The code should now work without requiring the Matlab 
   Statistics Toolbox (thanks to M. Chen for helping me figure this out!). 
   It's best to re-download the code completely. The following changes have 
   been made:
   -  The `data/bdt-eccv10.mat` file has been changed to use built-in 'structs' 
      instead of `classtreereg`.
   -  The `skewness.m` function has been added to replace the toolbox's. 
