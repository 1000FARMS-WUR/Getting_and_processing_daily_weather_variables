
# ERDAS

library(raster)
library(ncdf4)
library(rgdal)
library(sp)
library(dplyr)
library(tidyverse)

africa <- readOGR("Shape_africa/afr_g2014_2013_0.shp")

weatherpath <- "Weather_data/"

weathervars <- list.files(weatherpath)

weathervars

folders_names <- c("wind","rhum","tmax","tmin","rain","srad","vapr")

math_df <- data.frame(weathervars,folders_names)

math_df # Change vapor preasure for hmn

# Creat new  folders

new_folder <- "Africa_weather_files"

dir.create(new_folder,showWarnings = F,recursive = T)

lapply(paste0(new_folder,"/",folders_names),dir.create,showWarnings = F,recursive = T)

# Crop files

vars_ini <- list.files(weatherpath,full.names = T)

seq(nrow(math_df))
    
lapply(8, function(d){
  
    md <- math_df[d,]
    print(md)
    w <- vars_ini[d]
    
    extn = if(md[2] == "rain"){".tif$"}else{".nc$"}
    nams <- list.files(w,pattern =  extn)

    ds <- if(md[2] != "rain"){
      data.frame(nam=nams) %>% separate(nam,c("var","sorce","date","ver","rest"),"_")
      
      }else{
      data.frame(ver = gsub("\\.","",substring(nams,13,22)))
    }

    newNam <- paste(md[2] ,ds$ver,sep="_")
    
    
    stcvar <- stack(lapply(paste0(w,"/",list.files(w,pattern =  extn)),raster))

    names(stcvar) <- newNam

    crop_file <- crop(stcvar,africa)

    save_path <- paste(new_folder,"/",md[2],"/",newNam,".tif",sep="")

    lapply(seq(length(save_path)), function(w){
      raster::writeRaster(crop_file[[w]],save_path[w],format="GTiff", overwrite=TRUE)
    })
    
  }
)

