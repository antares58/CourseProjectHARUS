CourseProjectHARUS

This repository contains the files for the R Project, CourseProjectHARUS,
which creates a tidy data set of averages of the mean and standard deviation
time and frequency features of the Human Activity Recognition Using Smartphones Dataset, available at:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

A full description of the source data can be found in the README.txt file at the link above.

A brief summary of the data, a description of the processing and analysis performed on the original data, and a description of the resulting data can be found in CodeBook.pdf. (The code used to generate the codebook can be found in in the RMarkdown file, CodeBook.Rmd.)

The R code which was used to process the source data and perform the analysis can be found in the R script file, run_analysis.R.

The Data directory contains the Human Activity Recognition Using Smartphones Dataset, downloaded from:

 https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The results of the analysis can be found in HARUS Averages.csv, which is a comma-separated text file with headings. This data set is tidy, according to Hadley Wickham's criteria for tidy data:

1. Each variable forms a column
2. Each observation forms a row
3. Each type of observational unit forms a table
