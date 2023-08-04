## Read in data after parsing using query_sql code

covidDir = "../data/covid"
fileNames = list.files(file.path(covidDir))
#temp = readr::read_csv(file.path(dataDir, fileNames[1]))
#colNames = names(temp)
covidData = data.frame()
for(i in 1:length(fileNames)){
    data = readr::read_csv(file.path(covidDir, fileNames[i]))
    covidData = rbind(covidData, data)
}
## Format data
library(dplyr)
covidData$biosamplemodel_sam = if_else(stringr::str_detect(covidData$biosamplemodel_sam, "wastewater"), "wastewater", covidData$biosamplemodel_sam)
covidData$biosamplemodel_sam = if_else(stringr::str_detect(covidData$biosamplemodel_sam, "clinical"), "clinical", covidData$biosamplemodel_sam)
covidData$biosamplemodel_sam = if_else(stringr::str_detect(covidData$biosamplemodel_sam, "Pathogen"), "path", covidData$biosamplemodel_sam)
covidData$geo_loc_name_sam = stringr::str_replace(covidData$geo_loc_name_sam, "\\[", "")
covidData$geo_loc_name_sam = stringr::str_replace(covidData$geo_loc_name_sam, "\\]", "")
covidData$geo_loc_name_sam = as.factor(covidData$geo_loc_name_sam)
covidData$collection_date_sam = stringr::str_replace(covidData$collection_date_sam, "\\[", "")
covidData$collection_date_sam = stringr::str_replace(covidData$collection_date_sam, "\\]", "")
covidData$variant = paste("p", covidData$pos, "_r", covidData$ref, "_a",covidData$alt, sep = "")
### Filter by 0.4 frequency
covidData$frequency = covidData$g_ad_2 / covidData$dp
collectionDates = as.data.frame(stringr::str_split(covidData$collection_date_sam, "-", simplify = T))
colnames(collectionDates) = c("year", "month", "day")
covidData = cbind(covidData, collectionDates)
covidData = covidData[covidData$biosamplemodel_sam == "clinical" | covidData$biosamplemodel_sam == "wastewater", ]
## Filter
unique(covidData$effect)
filteredCovidData = covidData[covidData$effect == "INTERGENIC" | covidData$effect == "SYNONYMOUS_CODING", ]
filteredCovidData = filteredCovidData[filteredCovidData$frequency < 0.4, ]
#### TODO
#### 1. remove cl samples.
#### 2. Get counts for both wastwater and clinical samples.
#### 3. Get counts for both wastewater variants and clinical variants.
#### 4. Get overlaps between variants in groups.
## Calculate summary metrics.
library(dplyr)
covidSummary = covidData %>%
    group_by(geo_loc_name_sam, year, month) %>%
    summarize(total = length(unique(acc)),
              waste_samples = length(unique(acc[biosamplemodel_sam == "wastewater"])),
              clinical_samples = length(unique(acc[biosamplemodel_sam == "clinical"])),
              waste_variants = length(unique(variant[biosamplemodel_sam == "wastewater"])),
              clinical_variants = length(unique(variant[biosamplemodel_sam == "clinical"])),
              overlap_variants = sum(unique(variant[biosamplemodel_sam == "wastewater"]) %in%
                                         unique(variant[biosamplemodel_sam == "clinical"]), na.rm = T))
filteredCovidSummary = filteredCovidData %>%
    group_by(geo_loc_name_sam, year, month) %>%
    summarize(total = length(unique(acc)),
              waste_samples = length(unique(acc[biosamplemodel_sam == "wastewater"])),
              clinical_samples = length(unique(acc[biosamplemodel_sam == "clinical"])),
              filtered_waste_variants = length(unique(variant[biosamplemodel_sam == "wastewater"])),
              filtered_clinical_variants = length(unique(variant[biosamplemodel_sam == "clinical"])),
              filtered_overlap_variants = sum(unique(variant[biosamplemodel_sam == "wastewater"]) %in%
                                                  unique(variant[biosamplemodel_sam == "clinical"]), na.rm = T))
combinedCovidSummary = left_join(covidSummary, filteredCovidSummary[, c("geo_loc_name_sam", "year", "month", "filtered_waste_variants", "filtered_clinical_variants", "filtered_overlap_variants")],
          by = c("geo_loc_name_sam" = "geo_loc_name_sam", "year" = "year", "month" = "month"))
readr::write_csv(covidSummary, file.path(covidDir, "covid_summary.csv"))
readr::write_csv(combinedCovidSummary, file.path(covidDir, "combined_covid_summary.csv"))
