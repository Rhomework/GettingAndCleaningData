# This program loads data from a Samsung Galaxy S study on movements
# of the phone's users. It selects only the data that deals with
# means and standard deviations. Then, it provides proper names for
# activities and variables and creates a new tidy data set. This set
# contains the averages for every subject X activity pair.

library(plyr)

# Two functions for providing nicer names are used.

# The function .simpleCap is used to visually improve the naming
# of the acitivites. It is copied from the ?tolower help page.
# I have modified it to fit my needs.
# This is not a case of plagiarism because I cite my source and
# the use of this function is not crucial for the project!
.simpleCap <- function(x) {
    s <- strsplit(tolower(x), "_")[[1]]
    paste(toupper(substring(s, 1, 1)), 
          substring(s, 2),
          sep = "", 
          collapse = " ")
}

# The function rewrite takes a feature name as introduced by the
# study data and transforms it into a nicer format for variables.
# The general inspiration for this also stems from .simpleCap.
rewrite <- function(x) {
    # fix "BodyBody" problem
    x <- gsub("BodyBody", "Body", x)
    # split activity label into parts
    parts <- strsplit(x, "-")[[1]]
    parts <- c(substring(parts[1], 1, 1),
               substring(parts[1], 2),
               parts[-c(1)])
    
    # change the names of some parts
    parts[1] <- mapvalues(parts[1], 
                          from = c("t", "f"), 
                          to = c("Time", "Freq"))
    parts[3] <- mapvalues(parts[3],
                          from = c("mean()", "std()"),
                          to = c("Mean", "Std"))
    
    # add "Avg" prefix and convert into proper variable name
    paste(c("Avg", parts), collapse = ".")
}

# The actual processing starts here.

# load training files
train_x <- read.table(file = "train/X_train.txt")
train_y <- read.table(file = "train/y_train.txt")
train_subj <- read.table(file = "train/subject_train.txt")

# load testing files
test_x <- read.table(file = "test/X_test.txt")
test_y <- read.table(file = "test/y_test.txt")
test_subj <- read.table(file = "test/subject_test.txt")

# merge training and testing data
total_x <- rbind(train_x, test_x)
total_y <- rbind(train_y, test_y)
total_subj <- rbind(train_subj, test_subj)

# merge all data
total <- cbind(total_subj, total_y, total_x)

# load feature data
features <- read.table(file = "features.txt")
colnames(features) <- c("Feature.ID", "Feature")

# select mean and std features, i.e. those containing "mean()" or "std()"
rel_feat <- grepl("(mean|std)\\(\\)", features[,"Feature"])

# select relevant feature names and improve their format
rel_feat_names <- as.character(features[rel_feat, "Feature"])
rel_feat_names <- lapply(rel_feat_names, rewrite)
    
# keep only subject IDs, activity IDs, and relevant features
# subject ID and acticity are the first two columns
mean_std <- total[, c(TRUE, TRUE, rel_feat)]

# load activity data
activity_labels <- read.table(file = "activity_labels.txt")
colnames(activity_labels) <- c("ID", "Label")

# get activity names and improve their format
activity_labels$Label <- lapply(as.character(activity_labels$Label), function(x) .simpleCap(x))

# properly name the activities in the data set
mean_std[, 2] <- mapvalues(mean_std[, 2], 
                           from = as.numeric(as.character(activity_labels$ID)),
                           to = as.character(activity_labels$Label))

# properly name the variables in the data set
colnames(mean_std) <- c("Subject", "Activity", rel_feat_names)

# compute the means for every Subject X Activity pair
# this creates the tidy data set avg_data
avg_data <- aggregate(mean_std[,-c(1,2)], 
                      by = list(mean_std$Subject, mean_std$Activity), 
                      FUN = mean)

# rename Subject and Activity columns which got changed during aggregation
colnames(avg_data)[1:2] <- c("Subject", "Activity")

# write tidy data set to txt file
write.table(avg_data, file = "tidy_data.txt", row.names = FALSE)