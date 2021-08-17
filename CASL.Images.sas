/*
Copyright © 2021, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*/
/* cas &_sessref_ terminate; */
cas;

/* Create CASLIB and upload image */

proc cas ;
   loadactionset 'image';
   loadactionset 'table';
   table.addCaslib / name='imagelib' path='/viyafiles/sasss1/images'
   		subdirectories=true;
  
  image.loadimages / caslib='imagelib' path='Lesson3PracticePicture'
   		recurse=true casout={name='Lesson3PracticePicture', replace=true};
quit;

caslib _all_ assign;

/* View the picture */
data _NULL_;
/* Man in France */
  dcl odsout obj1();
  obj1.image(file:'/viyafiles/sasss1/images/Lesson3PracticePicture/ManInFrance.jpg',
                width: "320",
                height: "580");
 run;


/* processImages: Flip, rotate */
proc cas;
image.processImages /
    casout={name='solution_p1', replace=True}
    imagefunctions={{functionOptions={functionType='MUTATIONS' type="HORIZONTAL_FLIP"
        }},{functionOptions={functionType = 'MUTATIONS' type="ROTATE_RIGHT"}}}
    table={name='Lesson3PracticePicture'};
run;


/* augmentImages: Crop */
proc cas;
image.augmentImages  /
    casout={name='solution_p2', replace=True}
    cropList={{x=100 y=100 width=500 Height=500 outputWidth=683 outputHeight=1024
        }}
    table={name='solution_p1'};
run;


/*processImages: Blur*/
proc cas;
image.processImages /
    casout={name='solution_p3', replace=True}
    imagefunctions={{functionOptions={functionType='GAUSSIAN_FILTER'
  kernelWidth=20
  kernelHeight=20           
        }}}
    table={name='solution_p2'};
run;


/* Save and Print */
proc cas;
   saveImages / caslib='imagelib' prefix="solution1_image"
   subdirectory='Lesson3SaveSolution'
   images = {table={name='solution_p3'}, image='_image_'}
   overwrite=TRUE
   type="jpg";
run;



data _NULL_;
/* Man in France */
  dcl odsout obj1();
  obj1.image(file:'/viyafiles/sasss1/images/Lesson3SaveSolution/solution1_image.jpg',
                width: "320",
                height: "580");
run;
