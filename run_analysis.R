library(data.table)
library(tidyr)

dataPath <- "./Data/"
outputPath <- "./Output/"
fileNames <- c("test/subject_test.txt", "test/X_test.txt", "test/y_test.txt",
               "train/subject_train.txt", "train/X_train.txt",
               "train/y_train.txt")

# The names of the measurements (i.e, variables or column names) are in a
# flat file named features.txt
features <- fread(paste0(dataPath, "features.txt"))

# Select only the "mean" and "std" variables from the features list.
# grep on this platform requires exclusion of alpha chars after "mean"
# and "std" to eliminate all unwanted matches
tmp <- grep("mean[^A-Z,a-z]()|std[^A-Z,a-z]()", features$V2, value = TRUE)

# avg_std now contains only the indices and names of the relevant columns
avg_std <- features[features$V2 %in% tmp, ]
orig_length <- nrow(avg_std) # for future reference

# Clean up these names a little bit before applying them to the columns to
# be imported
avg_std$V2 <- sub("BodyBody", "Body", avg_std$V2)
avg_std$V2 <- sub("mean\\(\\)", "Mean", avg_std$V2)
avg_std$V2 <- sub("std\\(\\)", "Std", avg_std$V2)
avg_std$V2 <- gsub("-", "", avg_std$V2)
avg_std$V2 <- gsub("^t", "time", avg_std$V2)
avg_std$V2 <- gsub("^f", "freq", avg_std$V2)

# Check that we didn't accidentally create any duplicate strings
if(!length(unique(avg_std$V2)) == orig_length)
    print("Duplicate column names detected.")

# Use the column indices to read  only the desired data, and apply
# "cleaned up" features as column names
testData <- fread(paste0(dataPath, fileNames[2]),
                  select = avg_std$V1, col.names = avg_std$V2)
trainData <- fread(paste0(dataPath, fileNames[5]),
                   select = avg_std$V1, col.names = avg_std$V2)

# Activity identifiers are stored in flat files named y_test.txt and
# y_train.text; create a factor to give them meaningful labels
activity <- c("Walking", "WalkingUpstairs", "WalkingDownstairs",
                     "Sitting", "Standing", "Lying")
testActivity <- fread(paste0(dataPath,fileNames[3]), col.names = c("Activity"))
trainActivity <- fread(paste0(dataPath,fileNames[6]), col.names = c("Activity"))

# Convert the activity level integers to  be activity factors
testActivity$Activity <- factor(testActivity$Activity, levels = 1:6,
                                labels = activity)

trainActivity$Activity <- factor(trainActivity$Activity, levels = 1:6,
                                labels = activity)

# Add activity identifiers to the front of the respective data tables
testData <- cbind(testActivity, testData)
trainData <- cbind(trainActivity, trainData)

# subject identifiers for each observation are stored in flat files named
# subject_test.txt and subject_train.txt
testSubject <- fread(paste0(dataPath,fileNames[1]), col.names = c("SubjectID"))
trainSubject <- fread(paste0(dataPath,fileNames[4]), col.names = c("SubjectID"))

# Add activity identifiers to the front of the respective data tables
testData <- cbind(testSubject, testData)
trainData <- cbind(trainSubject, trainData)

# combine the data
allData <- rbind(testData, trainData)

# make sure there are no missing values before sorting
if(any(is.na(allData))) print("Missing values detected.")
allData <- allData[order(allData$SubjectID, allData$Activity), ]

# Initialize a data table to hold the averages of all the features
# by subject and activity
avgData <- NULL

# Define a function that calculates the means of all feature variables in
# a data table that contains feature values for a single subject and single
# activity, and adds the result to avgData
meanIt <- function(x) {
    vf <- vector()
    f <- as.data.frame(x)[avg_std$V2]
    avgf <- for( i in f) {
        vf <- c(vf, mean(i))
    }
    lf <- list(vf)
    dt <- data.table(matrix(vf, nrow = 1, ncol = 66))
    colnames(dt) <- avg_std$V2
    Activity <- x$Activity[1]
    dt <- cbind(Activity, dt)
    SubjectID <- x$SubjectID[1]
    dt <- cbind(SubjectID, dt)
    if(is.null(avgData)) {
        avgData <<- dt
    }
    else avgData <<- rbind(avgData, dt)
}
# split the full data set by SubjectID
b <- split(allData, allData$SubjectID)

# Across the resulting list, split each item by Activity and process the
# result through the meanIt function
c <- sapply(b, function(x) {
    tmp <- split(x, x$Activity)
    sapply(tmp, function(x) {
        meanIt(x)
        })
    })

# avgData now contains the means for each feature, by activity and subject
# Flatten this into a tidy data set with the 4 variables specified by the
# assignment: subject, activity, feature (variable), average
tidyData <- pivot_longer(avgData,
                         cols = !c(SubjectID, Activity),
                         names_to = "Feature",
                         values_to = "Average")

# Write the tidy data set to a CSV file.
write.csv(tidyData, paste0(outputPath, "HARUS Averages.csv"),
          row.names = FALSE)
