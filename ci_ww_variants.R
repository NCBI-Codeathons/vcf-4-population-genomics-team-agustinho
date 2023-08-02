## Read in data after parsing using query_sql code

dataDir = "../data"
data = readr::read_csv(file.path(dataDir, "subset_data.csv"))
covidData = readr::read_csv(file.path(dataDir, "SARS_COV_2_NY_2022.csv"))

## Find duplicates

covidData$variant = paste("p", covidData$pos, "_r", covidData$ref, "_a",covidData$alt, sep = "")
library(dplyr)
covidData$biosamplemodel_sam = if_else(stringr::str_detect(covidData$biosamplemodel_sam, "wastewater"), "wastewater", covidData$biosamplemodel_sam)
covidData$biosamplemodel_sam = if_else(stringr::str_detect(covidData$biosamplemodel_sam, "clinical"), "clinical", covidData$biosamplemodel_sam)
covidData$biosamplemodel_sam = if_else(stringr::str_detect(covidData$biosamplemodel_sam, "Pathogen"), "path", covidData$biosamplemodel_sam)
table(covidData$biosamplemodel_sam)

### 2 duplicate wastewater variants

wastewaterCounts = covidData[covidData$biosamplemodel_sam == "wastewater", ] %>%
  group_by(variant, acc) %>%
  summarize(n = n()) %>%
  arrange(desc(n))

### 25 duplicates for clinical variants

clinicalCounts = covidData[covidData$biosamplemodel_sam == "clinical", ] %>%
  group_by(variant, acc) %>%
  summarize(n = n()) %>%
  arrange(desc(n))

###  duplicates for clinical isolates

pathCounts = covidData[covidData$biosamplemodel_sam == "path", ] %>%
  group_by(variant, acc) %>%
  summarize(n = n()) %>%
  arrange(desc(n))

## Remove duplicates

wasteCovidData = covidData[covidData$biosamplemodel_sam == "wastewater", ]
clinicalCovidData = covidData[covidData$biosamplemodel_sam == "clinical", ]
pathCovidData = covidData[covidData$biosamplemodel_sam == "path", ]
uniqueWasteVariants = unique(wasteCovidData$variant)
uniqueClinicalVariants = unique(clinicalCovidData$variant)
uniquePathVariants = unique(pathCovidData$variant)

## Visualize overlap

library(ggvenn)
sampleList = list(waste = uniqueWasteVariants,
                  clinical = uniqueClinicalVariants,
                  path = uniquePathVariants)
ggvenn(sampleList)