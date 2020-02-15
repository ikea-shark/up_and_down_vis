library(data.table)
library(magrittr)
library(tidyr)

# import data
occ <- fread("data/occurrence.txt") %>% 
    separate("eventID", 
             c("project", "obsYear", "samplingSite", "samplingPoint", "survey"),
             sep = "_") %>% 
    .[!is.na(vernacularName)] %>% 
    .[, list(occurrenceID,
             samplingSite, 
             samplingPoint,
             obsYear,
             survey,
             scientificName,
             vernacularName
             )]

fwrite(occ,
       "data/data_processed.txt")