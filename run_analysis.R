if (!file.exists('./data')) {dir.create('./data')}

x_train = read.table(file='./data/UCI HAR Dataset/train/X_train.txt')
x_test = read.table('./data/UCI HAR Dataset/test/X_test.txt')
X <- rbind(x_train, x_test)

subject_train = read.table('./data/UCI HAR Dataset/train/subject_train.txt')
subject_test = read.table('./data/UCI HAR Dataset/test/subject_test.txt')
S = rbind(subject_train, subject_test)

y_train = read.table(file='./data/UCI HAR Dataset/train/y_train.txt')
y_test = read.table('./data/UCI HAR Dataset/test/y_test.txt')
Y <- rbind(y_train, y_test)

# Let's get the feature names so we can map those to the columns in our frame(s)
feature_names = read.table('./data/UCI HAR Dataset/features.txt')

# We only want to extract the measurements on the mean and standard deviation for each measurement.


indices_of_good_features <- grep("-mean\\(\\)|-std\\(\\)", feature_names[, 2])
X <- X[, indices_of_good_features]
names(X) <- feature_names[indices_of_good_features, 2]
names(X) <- gsub("\\(|\\)", "", names(X))
names(X) <- tolower(names(X))  # convert each name to a uniform lower-case format



##### Define the activities in our data set, and label them with descriptive names

# First, create the labels
activities <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
activities[, 2] = gsub("_", "", tolower(as.character(activities[, 2])))
Y[,1] = activities[Y[,1], 2]
names(Y) <- "activity"

# Then apply them as appropriate
names(S) <- "subject"
cleaned <- cbind(S, Y, X)
write.table(cleaned, "merged_clean_data.txt")


#### Finally, we'll make a 2nd, independent tidy data set with the average of each variable for each activity and each subject.

uniqueSubjects = unique(S)[,1]
numSubjects = length(unique(S)[,1])
numActivities = length(activities[,1])
numCols = dim(cleaned)[2]
result = cleaned[1:(numSubjects*numActivities), ]

row = 1
for (s in 1:numSubjects) {
        for (a in 1:numActivities) {
                result[row, 1] = uniqueSubjects[s]
                result[row, 2] = activities[a, 2]
                tmp <- cleaned[cleaned$subject==s & cleaned$activity==activities[a, 2], ]
                result[row, 3:numCols] <- colMeans(tmp[, 3:numCols])
                row = row+1
        }
}
write.table(result, "data_set_with_the_averages.txt")



