getting-and-cleaning-data-course-project
========================================

Course project deliverables for the Coursera course [Getting and Cleaning Data](https://www.coursera.org/course/getdata)

## Installation
* Create a directory for this project, henceforth called `samsung`
* Download the script `run_analysis.R` to `samsung` 
* Download the raw data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip to `samsung` and unzip it. You can delete the zip file after this step.
  Your directory structure should look like this now (only shown 2 levels deep):
 
 ```
    ├── UCI HAR Dataset
    │   ├── README.txt
    │   ├── activity_labels.txt
    │   ├── features.txt
    │   ├── features_info.txt
    │   ├── test
    │   └── train
    └── run_analysis.R
```

## Dependencies
The script `run_analysis.R` depends on the libraries `plyr` and `reshape2`. If you have not installed them, you will be prompted a choice to do so.
    
## Running the analysis     
* Change the working directory in R to the installation directory (called `samsung` in the [Installation](#Installation) section).     
* Source the script `run_analysis.R` in R: `source("run_analysis.R")`
* Execute the function `DeriveAndWriteDataSets` with no arguments: `DeriveAndWriteDataSets()`
  Two datasets will be written to your working directory now: `tidy1.csv` and `tidy2.csv` 

If you want to retrieve the datasets in R, without writing them to CSV-files, you can run

    tidy1 <- DeriveTidy1()
    tidy2 <- DeriveTidy2(tidy1)

Note that `DeriveTidy2` uses the result from `DeriveTidy1` as input.
The objects `tidy1` and `tidy2` are of class `data.frame`.

## Codebook
Information about the datasets is provided in `CodeBook.md`.     

## Code 
The code contains detailed commments explaining the steps in which the original data was transformed to `tidy1.csv` and `tidy2.csv` 

