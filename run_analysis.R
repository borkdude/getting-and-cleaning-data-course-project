# TODO make variable names cleaner:
# - lowercase when possible
# - descriptive
# - no underscores, dots or whitespace: AgeAtDiagnosis instead of AgeDx



# TODO, write code book: http://jtleek.com/modules/03_GettingData/01_03_componentsOfTidyData/#5

# TODO check if all dependencies are met
# TODO Google Style Guide on code? Constants start with k. etc?
# TODO Lowercase activity names?

library(plyr)
library(reshape2)

DeriveRawData <- function(dataRootDir = "UCI HAR Dataset") {

  # utility function
  FilePath <- function(file) {
    paste(dataRootDir,"/",file,sep="")
  }

  # some constants describing file locations
  kXTestFile <- FilePath("test/X_test.txt")
  kXTrainFile <- FilePath("train/X_train.txt")
  kFeaturesFile <- FilePath("features.txt")
  kActivityLabelsFile <- FilePath("activity_labels.txt")
  kTestActivitiesFile <- FilePath("test/y_test.txt")
  kTrainActivitiesFile <- FilePath("train/y_train.txt")
  kSubjectTestFile <- FilePath("test/subject_test.txt")
  kSubjectTrainFile <- FilePath("train/subject_train.txt")

  # step 1: merge training and test sets
  testSet <- read.table(kXTestFile)
  trainingSet <- read.table(kXTrainFile)
  allObservations <- rbind(testSet,trainingSet)

  # add feature names as column names
  featureNames <- read.table(kFeaturesFile,stringsAsFactors=FALSE)[[2]]
  colnames(allObservations) <- featureNames
  # step 2: only select the columns that have mean, std or activityLabel in their name
  allObservations <- allObservations[,grep("mean|std|activityLabel",featureNames)]

  # rename variable names to more readable form.
  # I have deliberately chosen not to rename to a full English words,
  # because column names tend to get very long then
  varNames = names(allObservations)
  varNames <- gsub(pattern="^t",replacement="time",x=varNames)
  varNames <- gsub(pattern="^f",replacement="freq",x=varNames)
  varNames <- gsub(pattern="-?mean[(][)]-?",replacement="Mean",x=varNames)
  varNames <- gsub(pattern="-?std[()][)]-?",replacement="Std",x=varNames)
  varNames <- gsub(pattern="-?meanFreq[()][)]-?",replacement="MeanFreq",x=varNames)
  varNames <- gsub(pattern="BodyBody",replacement="Body",x=varNames)
  names(allObservations) <- varNames

  # step 3: use the activity names to name the activities in the set
  activityLabels <- read.table(kActivityLabelsFile,stringsAsFactors=FALSE)
  colnames(activityLabels) <- c("activityID","activityLabel")

  # step 4: appropriately label the data set with descriptive activity names
  # first we create the activity column for the entire dataset, test+train:
  testActivities <- read.table(kTestActivitiesFile,stringsAsFactors=FALSE)
  trainingActivities <- read.table(kTrainActivitiesFile,stringsAsFactors=FALSE)
  allActivities <- rbind(testActivities,trainingActivities)
  # assign a column name so we can merge on it
  colnames(allActivities)[1] <- "activityID"
  # join the activityLabels - we use join from the plyr package and not merge, because join
  # preserves order
  activities <- join(allActivities,activityLabels,by="activityID")

  # and add the column to the entire dataset
  allObservations <- cbind(activity=activities[,"activityLabel"],allObservations)

  # extra step: include the subject ids, for processing in the next step
  testSubjects <- read.table(kSubjectTestFile,stringsAsFactors=FALSE)
  trainingSubjects <- read.table(kSubjectTrainFile,stringsAsFactors=FALSE)
  allSubjects <- rbind(testSubjects,trainingSubjects)
  colnames(allSubjects) <- "subject"
  allObservations <- cbind(allSubjects,allObservations)

  sorted <- allObservations[order(allObservations$subject,allObservations$activity),]
  sorted
}

DeriveTidyDataSet <- function(rawData) {
  molten <- melt(rawData,id.vars= c("subject","activity"))
  cast <- dcast(molten, subject+activity ~ variable, fun.aggregate=mean)
  cast
}

DeriveAndWriteDataSets <- function() {
  raw <- DeriveRawData()
  tidy <- DeriveTidyDataSet(raw)
  write.csv(raw,file="raw.csv")
  write.csv(tidy,file="tidy.csv")
}
