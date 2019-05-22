This repository works as the master branch for building a visualization platform showing trends of populations for certain monitored species.

The purpose of this project is to provide datasets opened via GBIF a data visualization tool.

### Project Structure

```bash
.
├── LICENSE
├── README.md
├── app
│   └── README.md
├── docs
│   ├── architecture.drawio
│   ├── architecture.png
│   └── minutes_meetup.md
└── model
    ├── GBIF_BBS.Rproj
    ├── README.md
    ├── data
    │   └── clean
    │       ├── 02_樣區表_v2.7.xlsx
    │       ├── dat_pre.rds
    │       ├── mapdata201805310314
    │       │   ├── COUNTY_MOI_1070516.dbf
    │       │   ├── COUNTY_MOI_1070516.prj
    │       │   ├── COUNTY_MOI_1070516.shp
    │       │   ├── COUNTY_MOI_1070516.shx
    │       │   └── Metadata.xml
    │       └── weight.xlsx
    ├── results
    │   ├── Error_msg_TW.txt
    │   ├── Error_msg_region.txt
    │   ├── trim_plot_TW
    │   └── trim_plot_region
    └── scripts
        ├── 01_data_wrangling.R
        └── 02_trend_by_trim.R
```


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
