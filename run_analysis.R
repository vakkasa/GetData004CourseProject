# function which returns a tidy data set for HAR project and gets as parameters
# the HAR directory and the dataset we need to tidy (train or test)
makeHARTidySet <- function(dataSetDir="UCI HAR Dataset", dataSetName){
    # constract dataset directory path
    dataSetPath<-paste0("./",dataSetDir,"/",dataSetName,"/")
    
    # read Activity Labels and name variables
    activityLabels<-read.table(paste0("./",dataSetDir,"/activity_labels.txt"))
    names(activityLabels)<-c("ActivityId","ActivityName")
    
    # read features info
    features<-read.table(
        paste0("./",dataSetDir,"/features.txt"),
        stringsAsFactors=FALSE)
    
    # read the data set and name variables
    x<-read.table(
        paste0(dataSetPath,"x_",dataSetName,".txt"),
        stringsAsFactors=FALSE)
    names(x)<-features[,2]
    
    # read the data set labels and name variable
    y<-read.table(
        paste0(dataSetPath,"y_",dataSetName,".txt"),
        stringsAsFactors=FALSE)
    names(y)<-"ActivityId"
    
    # read the data set subjects and name variable
    sub<-read.table(
        paste0(dataSetPath,"subject_",dataSetName,".txt"),
        stringsAsFactors=FALSE)
    names(sub)<-"SubjectId"
    
    # merge data set labels with activity labels
    activities<-merge(y,activityLabels,by="ActivityId")
    
    # bind the the data sets in one tidy set
    tidyDataSet<-cbind(sub,activities,x)
    
    return(tidyDataSet)
}

# 1. Merge the training and the test sets to create one data set.
trainSet<-makeHARTidySet(dataSetName="train")
testSet<-makeHARTidySet(dataSetName="test")

mergedSet<-rbind(trainSet,testSet)

# 2.Extract only the measurements on the mean and standard deviation
# for each measurement.

meanColIndexes<-grep("mean()",colnames(mergedSet),fixed=TRUE)
stdColIndexes<-grep("std()",colnames(mergedSet),fixed=TRUE)
colIndexes<-sort(c(meanColIndexes,stdColIndexes))
tidyDataSet<-mergedSet[,c(1:3,colIndexes)]

# 3. Use descriptive activity names to name the activities in the data set.
# 4. Appropriately label the data set with descriptive variable names.

# The above have been already performed on the makeHARTidySet function for
# each data set, train and test.

# Write the tidy data set to file tidyDataSet.txt
#write.table(tidyDataSet, file="./tidyDataSet.txt", sep="\t", row.names=FALSE)

# 5. Create a second, independent tidy data set with the average of 
# each variable for each activity and each subject.

require(reshape2)
moltenData <- melt(tidyDataSet, id=c("SubjectId","ActivityId","ActivityName"))
castedData <- dcast(moltenData,SubjectId + ActivityId + ActivityName ~ variable,mean)