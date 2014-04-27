Getting-and-Cleaning-Data-Project
=================================
# run\_analysis.R: a R script that prepare tidy data for the Human Activity Recognition study

## Introduction
The R script is developed to read data from raw data from the Human Activity Recognition study and prepare tidy data that can be used for later analysis

## Requirements
The following packages are required to run this script
- reshape2
- data.table

## Usage
- Download the raw data [here] and extract the included files to the working directory
- Run the script in the IDE of your choice

## Details about the script
Here is a brief outlines of how the script works

1. Get raw data from working directory
2. Merge the training and the test data sets into one, name the variables and sort the combined data set by subject id and activity type
3. Extract only the measurements on the mean and standard deviation for each measurement
4. Use descriptive activity names to name the activities in the data set and appropriately label the data set with descriptive activity names
5. Create a second, independent tidy data set with the average of the selected variables for each activity and each subject
	6. The average of the mean and standard deviation values of each measurement was calculated
	7. The data set was "melted" to long format using subject id and activity
	8. The feature variable was split into several new variables (domain, sensor and signal)
	9. The data was casted to wide format by the two statistical measures, and was written into a space delimited file called "tidy.txt"
## Comments
Post bugs, issues, feature requests via [GitHub Issues].

## Reference
Hadley Wickham, 2011. Tidy data. [http://vita.had.co.nz/papers/tidy-data.pdf]‎

Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

Human Activity Recognition Using Smartphones Data Set [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones]