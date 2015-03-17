## Get the largest region of an image
def getLargestRegion(props, labelmap, imagethres):
	regionmaxprop = None
	for regionprop in props:
		#check to see if the region is at least 50% nonzero\n",
		if sum(imagethres[labelmap == regionprop.label])*1.0/regionprop.area < 0.50:
			continue
		if regionmaxprop is None:
			regionmaxprop = regionprop
		if regionmaxprop.filled_area < regionprop.filled_area:
			regionmaxprop = regionprop
			
	return regionmaxprop

## Add more features ontop of ratio
def getMinorMajorRatio_2(image):
    image = image.copy()
    # Create the thresholded image to eliminate some of the background
    imagethr = np.where(image > np.mean(image),0.,1.0)

    #Dilate the image
    imdilated = morphology.dilation(imagethr, np.ones((4,4)))

    # Create the label list
    label_list = measure.label(imdilated)
    label_list = imagethr*label_list
    label_list = label_list.astype(int)
    
    region_list = measure.regionprops(label_list)
    maxregion = getLargestRegion(region_list, label_list, imagethr)
        
    # guard against cases where the segmentation fails by providing zeros
    ratio = 0.0
    minor_axis_length = 0.0
    major_axis_length = 0.0
    area = 0.0
    convex_area = 0.0
    eccentricity = 0.0
    equivalent_diameter = 0.0
    euler_number = 0.0
    extent = 0.0
    filled_area = 0.0
    orientation = 0.0
    perimeter = 0.0
    solidity = 0.0
    centroid = []
    if ((not maxregion is None) and  (maxregion.major_axis_length != 0.0)):
        ratio = 0.0 if maxregion is None else  maxregion.minor_axis_length*1.0 / maxregion.major_axis_length
        minor_axis_length = 0.0 if maxregion is None else maxregion.minor_axis_length 
        major_axis_length = 0.0 if maxregion is None else maxregion.major_axis_length  
        area = 0.0 if maxregion is None else maxregion.area  
        convex_area = 0.0 if maxregion is None else maxregion.convex_area  
        eccentricity = 0.0 if maxregion is None else maxregion.eccentricity  
        equivalent_diameter = 0.0 if maxregion is None else maxregion.equivalent_diameter  
        euler_number = 0.0 if maxregion is None else maxregion.euler_number  
        extent = 0.0 if maxregion is None else maxregion.extent 
        filled_area = 0.0 if maxregion is None else maxregion.filled_area  
        orientation = 0.0 if maxregion is None else maxregion.orientation 
        perimeter = 0.0 if maxregion is None else maxregion.perimeter  
        solidity = 0.0 if maxregion is None else maxregion.solidity
        centroid = [0.0,0.0] if maxregion is None else maxregion.centroid

    return ratio,minor_axis_length,major_axis_length,area,convex_area,eccentricity,\
           equivalent_diameter,euler_number,extent,filled_area,orientation,perimeter,solidity, centroid
           
           
### Add features from mahotas
import mahotas
import mahotas as mh
from mahotas.features import surf
import numpy as np
import skimage.morphology as morphology
import skimage.measure as measure
from skimage.io import imread
import csv
import glob
import os

directory_names = list(set(glob.glob(os.path.join("data_c","train", "*"))).difference(set(glob.glob(os.path.join("data_c","train","*.*")))))

###########################################################################################################################
numberofImages = 0
for folder in directory_names:
    for fileNameDir in os.walk(folder):   
        for fileName in fileNameDir[2]:
             # Only read in the images
            if fileName[-4:] != ".jpg":
              continue
            numberofImages += 1

maxPixel = 60
#maxPixel = 48
imageSize = maxPixel * maxPixel
num_rows = numberofImages # one row for each image in the training dataset
num_features = imageSize 

fileNames = []
featureSet = []
classSize = []

print "Reading images"
# Navigate through the list of directories
for folder in directory_names:
    # Append the string class name for each class
    currentClass = folder.split(os.pathsep)[-1]

    classLabel = currentClass.split("/")[-1]
    fileNames = fileNames + [classLabel]   
    
    for fileNameDir in os.walk(folder):   
        for fileName in fileNameDir[2]:
	    
            # Only read in the images
            if fileName[-4:] != ".jpg":
              continue
            
            # Read in the images and create the features
            nameFileImage = "{0}{1}{2}".format(fileNameDir[0], os.sep, fileName)     
  	    
	    image2 = mh.imread(nameFileImage, as_grey=True)
	       
	    feature  = getMinorMajorRatio_2(image2)
	    rowEntry = (classLabel,)
	    rowEntry = rowEntry + (fileName,)
            rowEntry = rowEntry + feature
	    
	    featureSet = featureSet + [rowEntry] 
      	    
    print "Finished preprocessing", classLabel    
###########################################################################################################################
#print fileNames


#haralick = mh.features.haralick(image2, ignore_zeros=False, preserve_haralick_bug=False, compute_14th_feature=False)
#lbp      =  mh.features.lbp(image2, radius=20, points=7, ignore_zeros=False)
#pftas    = mh.features.pftas(image2)
#zernike_moments = mh.features.zernike_moments(image2, radius=20, degree=8)

print "Writing to eggs.csv"

staticRow = ("classLabel","fileName","ratio","minor_axis_length","major_axis_length","area","convex_area","eccentricity",\
           "equivalent_diameter","euler_number","extent","filled_area","orientation","perimeter","solidity", "centroid")

with open('eggs.csv', 'wb') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=' ',
                            quotechar='"', quoting=csv.QUOTE_MINIMAL)
    spamwriter.writerow(staticRow)
    for feature in featureSet:
	spamwriter.writerow(feature)

print "Done"
