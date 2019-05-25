# loading packages ----
library(data.table)
library(magrittr)
library(rtrim)
library(stringr)
library(ggplot2)
library(rgdal)

# import data ----
dat.analysis <- 
  readRDS("data/clean/dat_pre.rds")

# split data by species and type of analysis ----
sp.region <- 
  dat.analysis[, list(vernacularName, analysis)] %>% 
  unique

# data list
dat.sp <- 
  lapply(sp.region$vernacularName, 
         function(x)
           dat.analysis[vernacularName == x,
                        list(Year, Site, region, Count, Weight, X_wgs84, Y_wgs84)]
  )

# construct model by trim ----
# TW model with region as covariate
model <- 
  lapply(1:length(dat.sp),
         function(x)
           tryCatch({
           # extract data
           dat.trim <- dat.sp[[x]] %>% as.data.frame
           
           dat.trim$region %<>% as.character %>% as.factor
           
           # trim model
           ifelse(sp.region$analysis[x] == "TW trend",
                  m1 <- trim(Count ~ Site + Year + region, 
                             weights = "Weight",
                             data = dat.trim,
                             model = 2,
                             overdisp = T, serialcor = T),
                  m1 <- trim(Count ~ Site + Year, 
                             weights = "Weight",
                             data = dat.trim,
                             model = 2,
                             overdisp = T, serialcor = T,
                             autodelete = TRUE)
                  ) %>% 
             invisible
                  
           # for trim results ----
           # plot the result and save
            # 給slope, p-value of trend (round 2)
           png(sprintf("results/trim_plot/%s.png", sp.region$vernacularName[x]), 
               width = 600, height = 600, res = 100)
           
           plot(overall(m1, which = "imputed"))
           title(main = sp.region$vernacularName[x], 
                 family="Hiragino Sans W3", adj = 0)
           
           mtext(sprintf("slope = %s, %s", 
                         round(overall(m1)$slope$mul, digits = 2),
                         overall(m1)$slope$meaning),
                 side = 3, adj = 0)
           
           dev.off()
             
           # for trend map
           site.info <- 
             dat.trim[, c("Site", "X_wgs84", "Y_wgs84")] %>% 
             as.data.table %>% 
             unique
           
           map.dat <- 
             cbind(m1$site_id, m1$imputed) %>% 
             as.data.table %>% 
             setnames(c("Site", (2016-ncol(.)+2):2016)) %>% 
             site.info[., on = "Site"] %>% 
             melt(id = 1:3, measure = 4:ncol(.),
                  variable.name = "year",
                  value.name = "count") %>% 
             .[, count := as.numeric(count)] %>% 
             .[, year := as.numeric(year)]
           
           trend.map <- 
             lapply(site.info$Site,
                    function(i){
                      glm.dat <- map.dat[Site == i]
                      site.model <- 
                        glm(count ~ year, 
                            data = glm.dat)
                      result.dat <- 
                        data.frame(Site = i,
                                   Pop.size = mean(glm.dat$count),
                                   Slope = site.model$coefficients[2],
                                   X_wgs84 = glm.dat$X_wgs84[1],
                                   Y_wgs84 = glm.dat$Y_wgs84[1])
                      
                      return(result.dat)
                    }
                    ) %>% 
             do.call(rbind, .)
           
           fwrite(trend.map, 
                  sprintf("results/trend_map_tb/%s.csv", 
                          sp.region$vernacularName[x]),
                  sep = ",")
           
           print(x)
         },
         error = function(msg) {
           cat(sprintf("%s, %s", sp.region$vernacularName[x], msg),
               file = "results/Error_msg_TW.txt",
               append = TRUE)
           }
         )
  )
