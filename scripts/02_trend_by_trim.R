# loading packages ----
library(data.table)
library(magrittr)
library(rtrim)
library(stringr)
library(ggplot2)
library(rgdal)

# import data ----
dat.analysis <- 
  readRDS("data/dat_pre.rds")

# split data by species ----
# species region list
sp.TW <- 
  dat.analysis[analysis == "TW trend", vernacularName] %>% 
  as.character %>% 
  unique

# data list
dat.TW <- 
  lapply(sp.TW, 
         function(x)
           dat.analysis[vernacularName == x,
                        list(Year, Site, region, Count, Weight, X_wgs84, Y_wgs84)]
      )

# shapefile of Taiwan (for trend map)
TW.poly <- 
  readOGR("data/mapdata201805310314/COUNTY_MOI_1070516.shp") %>% 
  fortify()

# construct model by trim ----
# TW model with region as covariate
TW.model <- 
  lapply(1:length(dat.TW),
         function(x)
           tryCatch({
           # data
           dat.trim <- dat.TW[[x]] %>% as.data.frame
           
           dat.trim$region %<>% as.character %>% as.factor
           
           # trim model
           m1 <- trim(dat.trim,
                      count_col = "Count",
                      site_col = "Site",
                      year_col = "Year",
                      weights_col = "Weight",
                      covar_cols = "region",
                      model = 2,
                      overdisp = T, serialcor = T,
                      autodelete = TRUE
                      )
           
           # for trim results ----
           # summary result of model
           overall_m1 <- overall(m1)$slope
           slope <- overall_m1$mul
           p_value <- overall_m1$meaning
           # plot the result and save
            # 給slope, p-value of trend (round 2)
           png(sprintf("results/trim_plot_TW/%s.png", sp.TW[x]), 
               width = 600, height = 600, res = 100)
           
           plot(overall(m1, which = "imputed"))
           title(main = sp.TW[x], 
                 family="Hiragino Sans W3", adj = 0)
           
           mtext(sprintf("slope = %s, %s", 
                               round(slope,digits = 2),
                               p_value),
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
             setnames(c("Site", 2009:2016)) %>% 
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
           
           map.p <- ggplot() +
             geom_polygon(data = TW.poly,
                          aes(x = long, y = lat, group = group),
                          color = "grey", fill = "white") +
             geom_point(data = trend.map,
                        aes(x = X_wgs84, y = Y_wgs84,
                            size = Pop.size, color = Slope)) +
             labs(title = sp.TW[x]) +
             scale_color_gradient2(high = "#006600", low = "#990000", 
                                   mid = "#FFFF99", midpoint = 0) +
             coord_fixed() +
             theme_bw() +
             theme(axis.title = element_blank(),
                   text = element_text(family="Hiragino Sans W3"))
           ggsave(sprintf("%s_map.png", sp.TW[x]),
                  path = "results/trim_plot_TW",
                  width = 6, height = 9, dpi = 200)
           
           print(x)
         },
         error = function(msg) {
           cat(sprintf("%s, %s", sp.TW[x], msg),
               file = "results/Error_msg_TW.txt",
               append = TRUE)
           }
         )
  )


## model for certain region
sp.region <- 
  dat.analysis[analysis != "TW trend", list(vernacularName, region)] %>% 
  unique

# data list
dat.region <- 
  lapply(1:nrow(sp.region), 
         function(x)
           dat.analysis[vernacularName == sp.region$vernacularName[x] &
                          region == sp.region$region[x],
                        list(Year, Site, region, Count, Weight, X_wgs84, Y_wgs84)]
  )


region.model <- 
  lapply(1:length(dat.region),
         function(x)
           tryCatch({
             # data
             dat.trim <- dat.region[[x]] %>% as.data.frame
             
             # run model
             m1 <- trim(dat.trim,
                        count_col = "Count",
                        site_col = "Site",
                        year_col = "Year",
                        weights_col = "Weight",
                        model = 2,
                        overdisp = T, serialcor = T,
                        autodelete = TRUE
             )
             
             # summary result of model
             overall_m1 <- overall(m1)$slope
             slope <- overall_m1$mul
             p_value <- overall_m1$meaning
             # plot the result and save
             # 給slope, p-value of trend (round 2)
             png(sprintf("results/trim_plot_region/%s_%s.png", 
                         sp.region$vernacularName[x],
                         sp.region$region[x]), 
                 width = 600, height = 600, res = 100)
             
             plot(overall(m1, which = "imputed"))
             title(main = sprintf("%s %s", 
                                  sp.region$vernacularName[x],
                                  sp.region$region[x]),
                   family="Hiragino Sans W3", adj = 0)
             
             mtext(sprintf("slope = %s, %s", 
                           round(slope,digits = 2),
                           p_value),
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
               setnames(c("Site", 2009:2016)) %>% 
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
             
             map.p <- ggplot() +
               geom_polygon(data = TW.poly,
                            aes(x = long, y = lat, group = group),
                            color = "grey", fill = "white") +
               geom_point(data = trend.map,
                          aes(x = X_wgs84, y = Y_wgs84,
                              size = Pop.size, color = Slope)) +
               labs(title = sprintf("%s %s", 
                                    sp.region$vernacularName[x],
                                    sp.region$region[x])) +
               scale_color_gradient2(high = "#006600", low = "#990000", 
                                      mid = "#FFFF99", midpoint = 0) +
               # scale_color_distiller(palette="RdYlGn", direction = 1) +
               coord_fixed() +
               theme_bw() +
               theme(axis.title = element_blank(),
                     text = element_text(family="Hiragino Sans W3"))
             ggsave(sprintf("%s_%s_map.png", 
                            sp.region$vernacularName[x],
                            sp.region$region[x]),
                    path = "results/trim_plot_region/",
                    width = 6, height = 9, dpi = 200)
             
             print(x)
           },
           error = function(msg) {
             cat(sprintf("%s, %s", sp.TW[x], msg),
                 file = "results/Error_msg_region.txt",
                 append = TRUE)
           }
           )
  )
