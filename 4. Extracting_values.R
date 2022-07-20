
library(geodata)
library(terra)
library(sp)
library(sf)
library(here)

source('3.1 getting_weather_daily_FUN.R')


# Download data

elevation_30s(country="UGA", path= "Shape_africa/")

geodata::gadm(country = 'UGA', level = 1, path = "Shape_africa/", version = '4.0')

# Process

shp_uganda <- raster(here::here("Shape_africa","UGA_elv_msk.tif"))

plot(shp_uganda)

Uganda_Shp <- as_sf(terra::vect(readRDS(here::here("Shape_africa","gadm40_UGA_1_pk.rds"))))

Uganda_Shp <- as(Uganda_Shp,"Spatial")

plot(Uganda_Shp)

rs_base <- raster(here::here("Weather_data","10m_wind_speed",
                             "Wind-Speed-10m-Mean_C3S-glob-agric_AgERA5_20210101_final-v1.0.nc"))

grilla <- terra::crop(rs_base,Uganda_Shp)

grilla <- mask(grilla,Uganda_Shp)

plot(grilla)

long_lat <- terra::as.data.frame(grilla, xy = T, na.rm = T)[,1:2]


# Reading files and converting in stacks

folder <- "Africa_weather_files"

vars <- c("srad","rain","tmax","tmin","vapr","wind") # should match with the folder´s name

date_ini <- as.Date("2021-01-01")
date_end <- as.Date("2021-12-31")

layers <- readWeatherLayers(vars = vars,folder = folder,date_ini =date_ini,date_end=date_end)

# Coordinate extraction

events <- data.frame(longitude=long_lat$x,latitude=long_lat$y,
                     date_ini=as.Date(c("2021-08-01")),
                     date_end=as.Date(c("2021-12-31")))



start_time <- Sys.time()
full_data <- extraWeatherData(stack_fls=layers,events = events[1:3,])
Sys.time() - start_time


start_time <- Sys.time()
full_data <- extraWeatherData2(stack_fls=layers,events = events,
                               date_ini = as.Date(c("2021-01-01")),
                               date_end = as.Date(c("2021-12-31")) )
Sys.time() - start_time

save(full_data,file = "weather_daily_data.Rdata")




