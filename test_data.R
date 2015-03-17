## Janindu : Reading from csv files

## ==============================
## Main variables
## ==============================

## Set the path to your data here
data_dir <- "./data"

train_data_dir <- paste(data_dir,"/train", sep="")
test_data_dir <- paste(data_dir,"/test", sep="")

j_test_data_csv <- "eggs1.csv"


## ==============================
## Load packages
## ==============================

## These packages are available from CRAN

#install.packages("jpeg",repos="http://cran.rstudio.com/")
library(jpeg)

#install.packages("randomForest",repos="http://cran.rstudio.com/")
library(randomForest)


## ==============================
## Define Functions
## ==============================

## Handy function to display a greyscale image of the plankton
im <- function(image) image(image, col = grey.colors(32))


## Function to read from csv file and extract stats ###########################################################
j_get_testing_data <- function (){
	j <- read.csv(file = j_test_data_csv <- "eggs1.csv", header=TRUE, sep = " ", stringsAsFactors = FALSE)
	
	return (j)	
}


## Function to extract stats from each row of the testing csv data #############################################
j_extract_test_stats <- function (csv_row = csv_row){
	j_fileName 	<- csv_row$image
	j_ratio		<- csv_row$ratio
	j_minorAxisLength <- csv_row$minor_axis_length
	j_majorAxisLength <- csv_row$major_axis_length
	j_area		<- csv_row$area
	j_convexArea	<- csv_row$convex_area
	j_eccentricity	<- csv_row$eccentricity
	j_equivalentDiameter <- csv_row$equivalent_diameter
	j_euler_number	<- csv_row$euler_number
	j_extent	<- csv_row$extent
	j_filledArea	<- csv_row$filled_area
	j_orientation	<- csv_row$orientation
	j_perimeter	<- csv_row$perimeter
	j_solidity	<- csv_row$solidity

	return (c(fileName=j_fileName,ratio=j_ratio,minAxLen=j_minorAxisLength,majAxLen=j_majorAxisLength,
		area=j_area,convex=j_convexArea,eccentricity=j_eccentricity,equiD=j_equivalentDiameter,euler=j_euler_number,
		extent=j_extent,filledArea=j_filledArea,orientation=j_orientation,perimeter=j_perimeter,solidity=j_solidity))
}

## ==============================
## Read test data and make predictions
## ==============================


test_data <- data.frame(fileName=character(),ratio=numeric(),minAxLen=numeric(),majAxLen=numeric(),
			area=numeric(),convex=numeric(),eccentricity=numeric(),equiD=numeric(),euler=numeric(),extent=numeric(),
			filledArea=numeric(),orientation=numeric(),perimeter=numeric(),solidity=numeric(), stringsAsFactors = FALSE)
 

working_data <- data.frame(class="a",fileName="a",ratio=0,minAxLen=0,majAxLen=0,area=0,convex=0,eccentricity=0,equiD=0,
				euler=0,extent=0,filledArea=0,orientation=0,perimeter=0,solidity=0, 
				stringsAsFactors = FALSE)

## Read test data from csv file  
j_testing_data <- j_get_testing_data()

## Iterating through each row 
for (r in 1:nrow(j_testing_data)){
	working_data <- j_extract_test_stats(j_testing_data[r,])
	
	test_data <- rbind(test_data,data.frame(as.list(working_data), stringsAsFactors=FALSE))

	if (r %% 10000 == 0) cat('Finished loading', r, 'of', nrow(j_testing_data), 'test images', '\n')

}    

save(test_data, file="test_data.Rdata")	
