## run.analysis.R (27 Apr 2014, v1.0)
## Please refer to the included readme file for a description and usage 
## of this script. A codebook document that describes the variables and data
#$ is alos included in repository.
## -----------------------------------------------------------------------------
## Get raw data from working directory 
ds_list <- 
    c("./UCI HAR Dataset/activity_labels.txt", "./UCI HAR Dataset/features.txt",
        list.files(path="./UCI HAR Dataset/train", pattern=".txt", 
                   full.names=TRUE),
        list.files(path="./UCI HAR Dataset/test", pattern=".txt", 
                   full.names=TRUE))
for(i in ds_list){
    colClasses = sapply(read.table(i,nrows=20, as.is=TRUE),class)
    assign(paste("df_", sub(".txt", "", basename(i), fixed=TRUE), sep=""), 
           read.table(i, comment.char="", colClasses=colClasses))
}
rm(i,ds_list,colClasses)
## -----------------------------------------------------------------------------
## Merge the training and the test data sets into one, name the variables and
## sort the data set by id and activity
df_merged <- rbind(cbind(df_subject_train, df_y_train, df_X_train), 
                    cbind(df_subject_test, df_y_test, df_X_test))
colnames(df_merged) <- c("id", "activity", df_features[,2])
df_merged <- df_merged[with(df_merged, order(id,activity)),]
## -----------------------------------------------------------------------------
## Extract only the measurements on the mean and standard deviation 
## for each measurement
df_merged <- 
    df_merged[,c(1,2,c((grep("mean()", colnames(df_merged), fixed=TRUE)), 
                        (grep("std()", colnames(df_merged), fixed=TRUE))))]
## -----------------------------------------------------------------------------
## Use descriptive activity names to name the activities in the data set
## and appropriately label the data set with descriptive activity names 
df_activity_labels <- df_activity_labels[order(df_activity_labels[,1]),]
proper <- function(s) {
    s <- sub("_", " ", s, fixed=TRUE)
    paste(toupper(substring(s, 1, 1)), 
          tolower(substring(s, 2, nchar(s))), sep="")
}
df_activity_labels[,2] <- proper(df_activity_labels[,2])
df_merged$activity <- factor(df_merged$activity, levels=c(1:6), 
                                 labels=df_activity_labels[,2])
## -----------------------------------------------------------------------------
## Create a second, independent tidy data set with the average of 
## the following variables for each activity and each subject
##
##  tBodyAcc-XYZ
##  tGravityAcc-XYZ
##  tBodyAccJerk-XYZ
##  tBodyGyro-XYZ
##  tBodyGyroJerk-XYZ
##  tBodyAccMag
##  tGravityAccMag
##  tBodyAccJerkMag
##  tBodyGyroMag
##  tBodyGyroJerkMag
##  fBodyAcc-XYZ
##  fBodyAccJerk-XYZ
##  fBodyGyro-XYZ
##  fBodyAccMag
##  fBodyAccJerkMag
##  fBodyGyroMag
##  fBodyGyroJerkMag
##
require(reshape2)
require(data.table)
## Change data set' class to data table type
dt_merged <- data.table(df_merged)
## Calculate the mean of the mean and standard deviation values
## of each measurement by id and activity
dt_merged <- dt_merged[,lapply(.SD,mean),by=list(id,activity)]
## Melt the data set to long format using id and activity
dt_merged <- melt(dt_merged, id=(1:2), variable.factor=FALSE, 
                  variable.name="measure")
## Split the measurement variable (eg. tBodyAcc-mean()-X) into 3 new ones:
## 1. Feature (eg. tBodyAcc)
## 2. Statistics (eg. mean())
## 3. Axial (eg. X)
dt_merged[grep("Mag", dt_merged$measure, fixed=TRUE), 3] <- 
    paste(dt_merged[grep("Mag", dt_merged$measure, fixed=TRUE), measure], "- ", 
          sep="")
newvars <- data.frame(matrix(
    unlist(strsplit(dt_merged$measure, "-", fixed=TRUE)), ncol=3, byrow=TRUE))
dt_merged <- (dt_merged[,feature:=newvars$X1]
                        [,stats:=newvars$X2]
                        [,axial:=newvars$X3])
## Calculate the mean of the axial measurements by id, activity, 
## feature and statistics
dt_merged <- dt_merged[,mean(value),by=list(id,activity,feature,stats)]
## Cast data to wide format using the two values of statistics
dt_merged <- dcast.data.table(dt_merged, id + activity + feature ~ stats, value.var="V1")
## Split feature into the following new variables
## 1. Domain
## 2. Sensor
## 3. Signal
domain <- ifelse(substring(dt_merged$feature, 1, 1)=="t", "time", "frequency")
sensor <- ifelse(grepl("BodyAcc", dt_merged$feature, fixed=TRUE), "BodyAcc", 
                 ifelse(grepl("BodyGyro", dt_merged$feature, fixed=TRUE), "BodyGyro",
                        "GravityAcc"))
signal <- ifelse(grepl("JerkMag", dt_merged$feature, fixed=TRUE), "JerkMag", 
                 ifelse(grepl("Mag", dt_merged$feature, fixed=TRUE), "Mag",
                        ifelse(grepl("Jerk", dt_merged$feature, fixed=TRUE), 
                               "Jerk-XYZ", "XYZ")))
tidy <- cbind(dt_merged, domain, sensor, signal)
## Clean up variable name and factor all string variables in the tidy data set
tidy$feature <- NULL
setnames(tidy,3,"meanAvg")
setnames(tidy,4,"stdAvg")
setcolorder(tidy, c("id", "activity", "domain", "sensor", "signal", "meanAvg", "stdAvg"))
tidy$domain <- factor(tidy$domain)
tidy$sensor <- factor(tidy$sensor)
tidy$signal <- factor(tidy$signal)
## Write the tidy data into a space delimited file
write.table(tidy, file="tidy.txt", row.names=FALSE)

## Clean up all objects
rm(df_activity_labels, df_features, df_merged, df_subject_test, df_subject_train,
   df_X_test, df_X_train, df_y_test, df_y_train, proper, newvars, domain,
   sensor, signal, dt_merged, tidy)