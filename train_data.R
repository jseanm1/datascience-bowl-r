## Janindu : Reading from csv files and train the model

## ==============================
## Main variables
## ==============================

## Set the path to your data here
data_dir <- "./data"

train_data_dir <- paste(data_dir,"/train", sep="")
test_data_dir <- paste(data_dir,"/test", sep="")

j_train_data_csv <- "eggs.csv"

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
j_get_training_data <- function (){
	j <- read.csv(file = j_train_data_csv, header=TRUE, sep = " ", stringsAsFactors = FALSE)
	
	return (j)	
}

## Function to extract stats from each row of the training csv data ###########################################
j_extract_stats <- function (csv_row = csv_row){
	j_classLabel 	<- csv_row$classLabel
	j_fileName 	<- csv_row$fileName
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

	return (c(class=j_classLabel,fileName=j_fileName,ratio=j_ratio,minAxLen=j_minorAxisLength,majAxLen=j_majorAxisLength,
		area=j_area,convex=j_convexArea,eccentricity=j_eccentricity,equiD=j_equivalentDiameter,euler=j_euler_number,
		extent=j_extent,filledArea=j_filledArea,orientation=j_orientation,perimeter=j_perimeter,solidity=j_solidity))
}



## Function to calculate multi-class loss on train data
mcloss <- function (y_actual, y_pred) {
    dat <- rep(0, length(y_actual))
    for(i in 1:length(y_actual)){
        dat_x <- y_pred[i,y_actual[i]]
        dat[i] <- min(1-1e-15,max(1e-15,dat_x))
    }
    return(-sum(log(dat))/length(y_actual))
}

## ==============================
## Read training data
## ==============================


## Create empty data structure to store summary statistics from each image file
train_data <- data.frame(class=character(),fileName=character(),ratio=numeric(),minAxLen=numeric(),majAxLen=numeric(),
			area=numeric(),convex=numeric(),eccentricity=numeric(),equiD=numeric(),euler=numeric(),extent=numeric(),
			filledArea=numeric(),orientation=numeric(),perimeter=numeric(),solidity=numeric(), stringsAsFactors = FALSE)

## Create same thing for each row
working_data <- data.frame(class="a",fileName="a",ratio=0,minAxLen=0,majAxLen=0,area=0,convex=0,eccentricity=0,equiD=0,
				euler=0,extent=0,filledArea=0,orientation=0,perimeter=0,solidity=0, 
				stringsAsFactors = FALSE)

## Read training data from the csv file
j_training_data <- j_get_training_data()

## Iterate through the rows
for (r in 1:nrow(j_training_data)) {
	working_data <- j_extract_stats(j_training_data[r,])
	
	train_data <- rbind(train_data,data.frame(as.list(working_data), stringsAsFactors=FALSE))
	
	if (r %% 1000 == 0) {
		cat(r,"rows processed\n")
	}

}
cat("All rows done")


## ==============================
## Create Model
## ==============================

## We need to convert class to a factor for randomForest
## so we might as well get subsets of x and y data for easy model building
y_dat <- as.factor(train_data$class)
x_dat <- train_data[,3:15]
num_trees <- 700

plankton_model <- randomForest(y = y_dat, x = x_dat, ntree = num_trees)

# Compare importance of the variables
importance(plankton_model)


## Check overall accuracy... 24%, not very good but not bad for a simplistic model
table(plankton_model$predicted==y_dat)
#  FALSE  TRUE 
#  22959  7377

## Make predictions and calculate log loss
y_predictions <- predict(plankton_model, type="prob")

ymin <- 1/1000
y_predictions[y_predictions<ymin] <- ymin

mcloss(y_actual = y_dat, y_pred = y_predictions)
# 3.362268


save(plankton_model, file="plankton_model_700.Rdata")
