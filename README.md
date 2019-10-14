
<!-- README.md is generated from README.Rmd. Please edit that file -->

# paresseux

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of paresseux is to launcn app easily

## Installation

You can install the released version of paresseux from
[CRAN](https://CRAN.R-project.org) with:

``` r
remotes::install_github("thinkr-open/paresseux")
```

## Example

This is a basic example which shows you how to use this package with app
initialized with golem

``` r
library(paresseux)
path_golem_app <- system.file("app_with_golem/showsloth", package = "paresseux")

my_app <- AppLaunch$new(is_golem = TRUE, app_dir = path_golem_app)  

my_app$open_app()

my_app$auto_restart()


### made modification inside your app folder

test <- file.path(path_golem_app,"test")
if(file.exists(test)){
  file.remove(test)
}else{
  file.create(test)
}

### stop autorestart

my_app$stop_restart()
```
