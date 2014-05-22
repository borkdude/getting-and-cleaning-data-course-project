# Check if dependencies are installed and require them.
RequireOrInstall <- function(package) {
  suppressWarnings({
    if (!require(package,character.only=TRUE)) {
      installPackage <- readline(paste("Package",package,"not found. Install? (y for yes, otherwise for no): "))
      if (installPackage == "y") {
        install.packages(package)
      }
      require(package,character.only=TRUE)  
  }})
}
RequireOrInstall("plyr")
RequireOrInstall("reshape2")

DeriveTidy1 <- function(dataRootDir = "UCI HAR Dataset") {

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

  #merge training and test sets
  testSet <- read.table(kXTestFile)
  trainingSet <- read.table(kXTrainFile)
  allObservations <- rbind(testSet,trainingSet)

  #add feature names as column names
  featureNames <- read.table(kFeaturesFile,stringsAsFactors=FALSE)[[2]]
  colnames(allObservations) <- featureNames
  #only select the columns that have mean, std or activityLabel in their name
  allObservations <- allObservations[,grep("mean|std|activityLabel",featureNames)]

  #rename variable names to more readable form.
  #I have deliberately chosen not to rename to a full English words,
  #because column names tend to get very long then
  varNames = names(allObservations)
  varNames <- gsub(pattern="^t",replacement="time",x=varNames)
  varNames <- gsub(pattern="^f",replacement="freq",x=varNames)
  varNames <- gsub(pattern="-?mean[(][)]-?",replacement="Mean",x=varNames)
  varNames <- gsub(pattern="-?std[()][)]-?",replacement="Std",x=varNames)
  varNames <- gsub(pattern="-?meanFreq[()][)]-?",replacement="MeanFreq",x=varNames)
  varNames <- gsub(pattern="BodyBody",replacement="Body",x=varNames)
  names(allObservations) <- varNames

  #use the activity names to name the activities in the set
  activityLabels <- read.table(kActivityLabelsFile,stringsAsFactors=FALSE)
  colnames(activityLabels) <- c("activityID","activityLabel")

  #appropriately label the data set with descriptive activity names
  #first we create the activity column for the entire dataset, test+train:
  testActivities <- read.table(kTestActivitiesFile,stringsAsFactors=FALSE)
  trainingActivities <- read.table(kTrainActivitiesFile,stringsAsFactors=FALSE)
  allActivities <- rbind(testActivities,trainingActivities)
  #assign a column name so we can merge on it
  colnames(allActivities)[1] <- "activityID"
  #join the activityLabels - we use join from the plyr package and not merge, because join
  #preserves order
  activities <- join(allActivities,activityLabels,by="activityID")

  #and add the column to the entire dataset
  allObservations <- cbind(activity=activities[,"activityLabel"],allObservations)

  #extra step: include the subject ids, for processing in the next step
  testSubjects <- read.table(kSubjectTestFile,stringsAsFactors=FALSE)
  trainingSubjects <- read.table(kSubjectTrainFile,stringsAsFactors=FALSE)
  allSubjects <- rbind(testSubjects,trainingSubjects)
  colnames(allSubjects) <- "subject"
  allObservations <- cbind(allSubjects,allObservations)

  sorted <- allObservations[order(allObservations$subject,allObservations$activity),]
  sorted
}

DeriveTidy2 <- function(rawData) {
  #create a long shaped dataset from a wide shaped dataset
  molten <- melt(rawData,id.vars= c("subject","activity"))
  #transform the long shaped dataset back into a wide shaped dataset, aggregating on subject 
  #and activity using the mean function
  cast <- dcast(molten, subject+activity ~ variable, fun.aggregate=mean)
  cast
}

DeriveAndWriteDataSets <- function() {
  tidy1 <- DeriveTidy1()
  tidy2 <- DeriveTidy2(tidy1)
  write.csv(tidy1,file="tidy1.csv")
  write.csv(tidy2,file="tidy2.csv")
}
