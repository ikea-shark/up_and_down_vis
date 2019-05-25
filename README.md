This repository works as the master branch for building a visualization platform showing trends of populations for certain monitored species.

The purpose of this project is to provide datasets opened via GBIF a data visualization tool.

### Population trends with Bokeh App

- [Bokeh](https://bokeh.pydata.org/en/latest/)

![](https://i.imgur.com/O6SLFU9.png)


### Population trends

Example #1 : Taiwan Breeding Bird Survey Data from GBIF

Condition satisfication for each species to enter population trend analysis:
* Total accumulated number of recorded sites across Taiwan (regardless of region) > 30 sites
  * will use region as covariate in rtrim model
  * certain region is included in covariate only when average number of recorded sites of that region > 5 sites
* or Total accumulated number of recorded sites in certain region > 20 sites
  * will not use region as covariate in rtrim model
  
Result
* Plot "overall" (i.e. count value not index) instead of "index"
  * if standardization is needed than
* Show slope (multiplicative) value and corresponding p-value

Visualization Platform Draft
* Divided by tabs
* Tabs include
  * EDA (Exploratory Data Analysis) - Table View 
  * EDA - Figure View (4 figures, e.g. histogram, scatterplot, ...etc)
  * Trend - 4 to 6 figures including Taiwan and different regions (North, East, West, Mountain, Sea Islands)
  * Map - Spatial map displaying sampling sites and each sites' trend
