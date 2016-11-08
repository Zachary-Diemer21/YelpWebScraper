#WHOLE CLEANUP CODE TO REMOVE DUPLICATES FROM A CSV AND REMOVE WHITESPACE + ENTERS
require(stringr)
CSVLoc <- "/home/zackymo/Desktop/Vape_Project/Cleaned_Datasets/vapeshopsnj.csv"

vapeshopsnj <- read.csv(CSVLoc, row.names = NULL, quote = "\"", header = TRUE, colClasses= "character", encoding= "utf-8")
#View(vapeshopsnj)

#DO NOT NEED TO USE THIS COMMAND ON AN ALREADY CLEANED DATASET 

vapeshopsn = vapeshopsnj[!duplicated(vapeshopsnj),]
#View(vapeshopsn) #INVESTIGATE THE TWO DATASETS AND COMPARE

#REMOVE WHITESPACE AND ENTERS FROM EACH INDIVIDUAL COLUMN 
vapeshopsn$bizname <- str_trim(vapeshopsn$bizname, "both")
vapeshopsn$addr <- str_trim(vapeshopsn$addr, "both")
vapeshopsn$bizphone <- str_trim(vapeshopsn$bizphone, "both")
vapeshopsn$numrevs <- str_trim(vapeshopsn$numrevs, "both")
#CREATE A NEW COLUMN TO BE ABLE TO SORT BY ZIPCODES USING REGULAR EXPRESSIONS
vapeshopsn$zips <- regmatches(vapeshopsnj$addr, gregexpr('(?<!\\d)\\d{5}(?:[ -]\\d{4})?\\b', vapeshopsnj$addr, perl=T))

#vapeshopsn$zips <- str_trim(regmatches(vapeshopsnj$addr, gregexpr('(?<!\\d)\\d{5}(?:[ -]\\d{4})?\\b', vapeshopsnj$addr, perl=T)), "both")

vapeshopsjersey = vapeshopsn[!duplicated(vapeshopsn),]

write.csv(vapeshopsn, CSVLoc, row.names=F)