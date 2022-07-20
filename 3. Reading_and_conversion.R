

library(sp)
library(raster)
library(exactextractr)
library(sf)
library(tidyverse)


rm(list=ls())

source(here::here('3.1 getting_weather_daily_FUN.R'))

# Reading files and converting in stacks

folder <- "Africa_weather_files"

vars <- c("srad","rain","tmax","tmin","vapr","wind") # should match with the folder´s name

date_ini <- as.Date("2021-01-01")
date_end <- as.Date("2021-12-31")

layers <- readWeatherLayers(vars = vars,folder = folder,date_ini =date_ini,date_end=date_end)

# Cordinate extraction

events <- data.frame(longitude=c(21.85,18,25.92),latitude=c(-12,-6.11,-28.33),
                    date_ini=as.Date(c("2021-02-01","2021-04-01","2021-06-01")),
                    date_end=as.Date(c("2021-05-31","2021-07-30","2021-09-28")))



start_time <- Sys.time()
full_data <- extraWeatherData(stack_fls=layers,events = events)
Sys.time() - start_time

save(full_data,file = here::here("weather_daily_data.Rdata"))


