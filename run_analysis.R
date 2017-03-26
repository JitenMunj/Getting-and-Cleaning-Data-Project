# setwd - code removed
# After setting working directory - download the file in data folder (create data folder if not exists)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Get list of files in above unzipped file
path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)
files

###### Read data from the files into the variables
# Read the Activity Files
dataActivityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)

# Read the Subject Files
dataSubjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

# Read the Features Files
dataFeaturesTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

# Familarize with the Data
summary(dataActivityTest)
summary(dataActivityTrain)
str(dataActivityTest)
str(dataActivityTrain)

summary(dataSubjectTrain)
summary(dataSubjectTest)
str(dataSubjectTrain)
str(dataSubjectTest)

summary(dataFeaturesTest)
summary(dataFeaturesTrain)
str(dataFeaturesTest)
str(dataFeaturesTrain)



############ Part-1 Merges the training and the test sets to create one data set ############

# Use rbind to merge the rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

# Set names of variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

# Merge the columns to get the data frame of Subject and Activity
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)
str(Data)




############ Part-2 Extracts only the measurements on the mean and standard deviation for each measurement ############

# Subset Name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

str(subdataFeaturesNames)

# Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
str(Data)




############ Part-3 Uses descriptive activity names to name the activities in the data set ############

# Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
summary(activityLabels)

# Update the column names of activityLabels 
names(activityLabels) <- c('act_id', 'act_name')
names(activityLabels)
head(activityLabels)

# Update the descriptive names of Data$activity with activityLabels and validate
Data$activity <- activityLabels[Data$activity, 2]
head(Data$activity,30)



########## Part-4 Appropriately labels the data set with descriptive variable names ############
summary(Data)

# Remove parentheses
names(Data) <- gsub('\\(|\\)',"",names(Data), perl = TRUE)
# Make syntactically valid names
names(Data) <- make.names(names(Data))
# Make clearer names
names(Data) <- gsub('Acc',"Acceleration",names(Data))
names(Data) <- gsub('GyroJerk',"AngularAcceleration",names(Data))
names(Data) <- gsub('Gyro',"AngularSpeed",names(Data))
names(Data) <- gsub('Mag',"Magnitude",names(Data))
names(Data) <- gsub('^t',"TimeDomain.",names(Data))
names(Data) <- gsub('^f',"FrequencyDomain.",names(Data))
names(Data) <- gsub('\\.mean',".Mean",names(Data))
names(Data) <- gsub('\\.std',".StandardDeviation",names(Data))
names(Data) <- gsub('Freq\\.',"Frequency.",names(Data))
names(Data) <- gsub('Freq$',"Frequency",names(Data))

# Validate
names(Data)

########## Part-5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject ############
library(plyr)
Data_avg_by_act_sub <- ddply(Data, c("subject","activity"), numcolwise(mean))
write.table(Data_avg_by_act_sub, file = "Data_avg_by_act_sub.txt", row.name=FALSE)


