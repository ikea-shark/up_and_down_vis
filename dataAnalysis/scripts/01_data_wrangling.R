# loading packages --------
library(data.table)
library(magrittr)
library(dplyr)
library(tidyr)
library(stringr)
library(readxl)

dat <- 
  fread("data/clean/exp_data.csv") %>% 
  # select event fit survey method
  .[`時段` %in% c("0-6minutes", "0-3minutes", "3-6minutes")] %>% 
  .[`距離` %in% c("0-50m", "25-50m", "0-25m", "25-100m")] %>% 
  .[`天氣代號` %in% c("A", "B", "C", "D", NA)] %>% 
  .[`風速代號` %in% c("0", "1", "2", NA)] %>% 
  .[hour %in% 4:12] %>% 
  .[!is.na(vernacularName)]

# # check eventID that not included in event table --------
# t <- dat[is.na(Year), "eventID"] %>% unique

# check number of na of each column --------
na_count <- 
  lapply(dat, function(x)
    x[is.na(x)] %>% length) %>% 
  do.call(cbind, .)


# Aggregate data ----
  # 1. sum inidividual count by survey point
  # 2. fill zero count records
dat.aggr <- 
  dat[, .(sumCount = sum(Count)),
      by = list(eventID, 
                Year, 
                Month, 
                Date, 
                locationID,
                vernacularName,
                Longitude,
                Latitude)] %>% 
  .[, Site := str_sub(locationID, 1, 6), by = locationID] %>% 
  .[, Survey := str_sub(eventID, -2, -1), by = eventID] %>% 
  # calculate weight by site and year (survey times)
  .[, Weight := 1/uniqueN(eventID), by = list(Year, Site)] %>% 
  # sum individual count by event (site and year)
  .[, .(Count = sum(sumCount, na.rm = TRUE)),
    by = list(Year, vernacularName, Site, Weight)] %>% 
  .[, Year := as.numeric(as.character(Year))] %>% 
  # fill zero count
  dcast(Year + Site + Weight ~ vernacularName,
        value.var = "Count",
        fill = 0) %>%
  melt(id = 1:3, measure = 4:ncol(.),
       variable.name = "vernacularName",
       value.name = "Count") %>%
  # remove site without any individual count from 2009 to 2016
  .[, Site_total := sum(Count), 
    by = list(Site, vernacularName)] %>% 
  .[Site_total != 0]
  

# bind region of site ----
site.region <- 
  read_xlsx("data/raw/02_樣區表_v2.7.xlsx", sheet = 2) %>% 
  setDT %>% 
  .[, list(Site = `樣區編號`, HJHsiu3, ELEV, X_wgs84, Y_wgs84)] %>% 
  .[ELEV %in% 2:3, region := "Mountain"] %>% 
  .[is.na(region), region := HJHsiu3] %>% 
  .[, list(Site, region, X_wgs84, Y_wgs84)]

dat.region <- 
  site.region[dat.aggr, on = "Site"] %>% 
  .[region %in% c("North", "East", "West", "Mountain")]


# filter by number of survey site counted target species in a region
## more than 30 site counted target species, and only includes region more than 5 sites
## less than 30 sites in Taiwan but has 20 sites in a region
filter.region <- 
  dat.region[Count > 0, 
             .(N_site = uniqueN(Site)), 
             by = list(region, Year, vernacularName)] %>% 
  .[, .(region_site = mean(N_site)), 
    by = list(region, vernacularName)] %>% 
  .[region_site >= 5, 
    TW_site := sum(region_site), 
    by = vernacularName] %>% 
  .[!is.na(TW_site), 
    N_region := uniqueN(region),
    by = vernacularName]

dat.analysis <- 
  filter.region[dat.region, on = c("vernacularName", "region")] %>% 
  .[TW_site >= 30 & N_region > 1, analysis := "TW trend"] %>% 
  .[is.na(analysis) & region_site >= 20, analysis := paste0(region, " trend")] %>% 
  .[!is.na(analysis), 
    list(region, vernacularName, Site, X_wgs84, Y_wgs84, 
         Year, Weight, Count, analysis)]


# write data as RData
saveRDS(dat.analysis, "data/clean/dat_pre.rds")

