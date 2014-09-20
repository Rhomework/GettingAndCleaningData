# Getting and Cleaning Data -- Final Project

These are files for the final project of the "Getting and Cleaning Data" course offered by Coursera.

## Content
- README.md -- a readme file explaining what all the files in this repo do
- run_analysis.R -- an R file reading in data from a Samsung Galaxy S study and creating a tidy data set
- tidy_data.txt -- the tidy data set created by run_analysis.R (can also be found on my coursera submission page)
- CodeBook.md -- a code book explaining the data given in tidy_data.txt

While README.md and CodeBook.md are explanatory files, the content of tidy_data.txt is explained in CodeBook.md. 
This README.me file explains how run_analysis.R works, i.e. how tidy_data.txt was created.

## run_analysis.R

### Input Files

run_analysis.R requires some files as input. These are all provided on the coursera course page. Originally, they 
can be found here: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

For run_analysis.R to run, the following files in the mentioned folders are required:
- train/X_train.txt -- a file containing data obtained at the study
- train/y_train.txt -- a file with activity IDs corresponding to the data points in X_train.txt
- train/subject_train.txt -- a file with subject IDs corresponding to the data points in X_train.txt
- test/X_test.txt -- like train/X_train.txt but from the testing set and not the training set
- test/y_test.txt -- like train/y_train.txt but from the testing set and not the training set
- test/subject_test.txt -- like train/subject_train.txt but from the testing set and not the training set
- features.txt -- a file containing the features that are given as columns in the "X_..." files
- activity_labels.txt -- a file containing the labels of the activities that are given as IDs in the "y_..." files

### Code

1. run_analysis.R uses one external package, plyr, which is included using "library(plyr)".

2. The two functions i) ".simpleCap" and ii) "rewrite" are defined. 

    1. ".simpleCap" is copied from the "?tolower" help page of R and slightly modified because the strings in 
run_analysis.R are given with "_" as a separator. It takes a string as its input and converts it into one where all 
first letters are capitalized and all other letters are given in lower case.

    2. "rewrite" is based on ".simpleCap". It takes a string given in the "activity label" format of the data and transforms
it into a string which is formatted in such a way that it can be used as the label for a variable in the tidy data 
set. It also fixes those labels that contain "BodyBody" instead of just "Body" once.

3. The raw data components from the training set are read in as "train_x", "train_y" and "train_subject" from 
"train/X_train.txt", "train/y_train.txt" and "train/subject_train.txt". They have the dimensions 7352 X 561, 7352 X 1 and 
7352 X 1, respectively.

4. The raw data components from the testing set are read in as "test_x", "test_y" and "test_subject" from
"test/X_test.txt", "test/y_test.txt", "test/subject_test.txt". They have the dimensions 2947 X 561, 2947 X 1 and 2947 X 1, 
respectively.

5. The raw data components are merged into data frames which now contain both the training and the testing set data.
These are "total_x", "total_y" and "total_subject" and have the dimensions 10299 X 561, 10299 X 1 and 10299 X 1,
respectively.

6. All data is assigned to "total" by binding "total_subject", "total_y" and "total_x" together. Every row of this data 
set contains the corresponding subject ID, the acticity ID and the measured variables. The dimensions of this data frame
are 10299 X 563.

7. In a next step, only those variables that measure means or standard deviations are selected. For this, the relevant
features are selected.

8. The list of features is loaded from "features.txt", stored in "features" and given the proper variable names "Feature.ID" 
and "Feature". There are 561 features, i.e. as many as there are columns in "total_x".

9. With grepl, a logical vector is created and stored in "rel_feat" which contains "TRUE" for every feature with "mean()"
or "std()" in its name and "FALSE" for all others. It contains 66 "TRUE" entries.

10. The "rel_feat" vector is used to select only those 66 features names from "features" that are relevant. They are 
stored in "rel_feat_names" and given a nicer format with the help of "rewrite" (see 2.ii)). 

11. From the total data of "total", only the first two columns with the subject ID and the acticity ID and all those 66
columns with relevant features are kept. The result is stored in "mean_std". "mean_std" has the dimensions 10299 X 68.

12. The next step replaces the activity IDs given in the second column by proper names.

13. Activity labels are read in from "activity_labels.txt" and stored in "activity_labels". The six labels are brought 
into a proper format with ".simpleCap" (see 2.i) and the data frame is given proper variable names.

14. With the help of "mapvalues", the second column of "mean_std" is overwritten. Every ID is replaced by its
corresponding name.

15. All columns of the data frame "mean_std" are given proper names. The first two are called "Subject" and "Activity"
and the rest gets its name according to the re-formatted feature names.

16. Next, a tidy data set is computed using "aggregate". Rows are combined according to "Subject" and "Activity" and
for every "Subject" X "Activity" pair, the mean of each feature column for those entries is computed. The result is the
data frame "avg_data" with 180 rows -- 30 subjects times 6 activities -- and 68 columns.

17. Since "aggregate" has renamed the columns "Subject" and "Activity", these columns are named once again for "avg_data".

18. The finished tidy data set is written to a file with "write.table".
