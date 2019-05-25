# import packages ----
library(data.table)
library(magrittr)
library(dplyr)
library(tidyr)
# library(stringr)
# library(readxl)

# import data and extract column needed --------
## occurrence table
dat.occ <- 
  fread("data/raw/occurrence.txt") %>% 
  Filter(function(x)!all(is.na(x)), .) %>%  # remove na column
  .[, list(id = occurrenceID,
           eventID,
           Count = individualCount,
           vernacularName)]

## event table
dat.evt <- 
  fread("data/raw/event.txt") %>% 
  .[, list(eventID,
           eventDate,
           eventTime = substr(eventTime, 1, 5),
           locationID,
           Latitude = decimalLatitude,
           Longitude = decimalLongitude)] %>% 
  separate(eventDate, c("Year", "Month", "Date"), "-") %>% 
  .[eventTime == "NA:NA", eventTime := NA] %>% 
  separate(eventTime, c("hour", "minute"), ":") %>% 
  .[, hour := as.numeric(hour)]

## measurment or fact  
dat.mof <- 
  fread("data/raw/measurementorfact.txt") %>% 
  # add index of each row
  .[, Row := .I] %>% 
  .[measurementType %in% c("時段", "距離", "天氣代號", "風速代號")] %>%
  # if there are two value of one measurementType in one event, 
  # keep the first value
  .[.[, .I[which.min(Row)], by = list(id, measurementType)]$V1] %>% 
  dcast(id ~ measurementType, value.var = "measurementValue")

# combind three table --------
dat <- 
  dat.evt[dat.occ, on = "eventID"] %>%  # with dat.evt
  dat.mof[, list(id, `時段`, `距離`)][., on = "id"] %>% # bind interval, distance
  dat.mof[, list(eventID = id, `天氣代號`, `風速代號`)][., on = "eventID"] 

# extract first 10 species as example data
sp.list <- dat$vernacularName %>% unique %>% .[1:10]

exp.data <- 
  dat[vernacularName %in% sp.list]

fwrite(exp.data, "data/clean/exp_data.csv", sep = ",")
