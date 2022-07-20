
# Decadal format
# Hugo Dorado
# 18-07-2022

library(here)
library(lubridate)
library(terra)
library(raster)
library(gtools)

# Genereate a decadal sequence 

dates <- 
  do.call(rbind,lapply(2017:2021, function(w){
    
    date_ini <- as.Date(paste0(w,"-01-01"))
    date_end <- as.Date(paste0(w,"-12-31"))
    
    data.frame(Date = as.Date(date_ini:date_end,  origin = "1970-01-01")[1:360],
               decad=do.call(c,lapply(1:36,rep,10)))
  }
  )
)

decadal <- data.frame(dates,Date2 = gsub("-","",dates$Date),Year=year(dates$Date))

decadal$decad <- decadal$decad

splt <- paste(year(dates$Date),decadal$decad,sep="-")

splt <- factor(splt,levels = unique(splt) )

spDecadal <- split(decadal,splt)



# Read weather data


covertDecadal <- function(spDecadal,path,fun="sum")
{
  lapply(spDecadal,function(dec){ 
    
    print(paste(dec[1,1],dec[10,1],"-"))
    
    namFiles <- list.files(path,pattern = ".tif$")
    
    fullPath <- list.files(path,pattern = ".tif$",full.names = T)
    
    # Rasterized
    
    rsters <- raster::stack(
      tr <- terra::rast(grep(paste0(dec$Date2,collapse = "|"),fullPath,value = T))
    )
    
    #rsters[rsters[] == -9999] <- NA
    
    converted <- if(fun == "sum")
    {
      sum(rsters)
    }else if(fun == "avg"){
      mean(rsters)  
    }else{return(print("Error"))}
    converted
  }
  )
}

vars <- c("tmax","tmin","rain","tmean","rhum","esol","wind")

dirpath <- here::here('Decadal',vars)

lapply(dirpath,dir.create,showWarnings = F,recursive = T)


# Decadal

path_tmax <- here::here("Africa_weather_files","tmax")

tmax <- covertDecadal(spDecadal,path =path_tmax,fun = "avg")

# Write decadal

nmsSv <- here::here("Decadal","tmax",paste0("tmax_",names(tmax),".tif"))

lapply(seq(length(nmsSv)), function(w){
  terra::writeRaster(tmax[[w]],nmsSv[w],format="GTiff", overwrite=TRUE)
})


path_tmin <- here::here("Africa_weather_files","tmin")

tmin <- covertDecadal(spDecadal,path =path_tmin,fun = "avg")

# Write decadal

nmsSv <- here::here("Decadal","tmin",paste0("tmin_",names(tmin),".tif"))

lapply(seq(length(nmsSv)), function(w){
  terra::writeRaster(tmin[[w]],nmsSv[w],format="GTiff", overwrite=TRUE)
})


path_tmean <- here::here("Africa_weather_files","tmen")

tmean <- covertDecadal(spDecadal=spDecadal,path =path_tmean,fun = "avg")

# Write decadal

nmsSv <- here::here("Decadal","tmean",paste0("tmean_",names(tmean),".tif"))

lapply(seq(length(nmsSv)), function(w){
  terra::writeRaster(tmean[[w]],nmsSv[w],format="GTiff", overwrite=TRUE)
})


path_srad <- here::here("Africa_weather_files","srad")

srad <- covertDecadal(spDecadal,path =path_srad,fun = "sum")

# Write decadal

nmsSv <- here::here("Decadal","srad",paste0("srad_",names(srad),".tif"))

lapply(seq(length(nmsSv)), function(w){
  terra::writeRaster(srad[[w]],nmsSv[w],format="GTiff", overwrite=TRUE)
})


path_rhum <- here::here("Africa_weather_files","rhum")

rhum <- covertDecadal(spDecadal,path =path_rhum,fun = "avg")

# Write decadal

nmsSv <- here::here("Decadal","rhum",paste0("rhum_",names(rhum),".tif"))

lapply(seq(length(nmsSv)), function(w){
  terra::writeRaster(rhum[[w]],nmsSv[w],format="GTiff", overwrite=TRUE)
})

path_wind <- here::here("Africa_weather_files","wind")

wind <- covertDecadal(spDecadal,path =path_wind,fun = "avg")

# Write decadal

nmsSv <- here::here("Decadal","wind",paste0("wind_",names(wind),".tif"))

lapply(seq(length(nmsSv)), function(w){
  terra::writeRaster(wind[[w]],nmsSv[w],format="GTiff", overwrite=TRUE)
})


path_rain <- here::here("Africa_weather_files","rain")

rain <- covertDecadal(spDecadal,path =path_rain,fun = "sum")

# Write decadal

nmsSv <- here::here("Decadal","rain",paste0("rain_",names(rain),".tif"))

lapply(seq(length(nmsSv)), function(w){
  terra::writeRaster(rain[[w]],nmsSv[w],format="GTiff", overwrite=TRUE)
})

