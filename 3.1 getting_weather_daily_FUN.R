

# Read files

readWeatherLayers <- function(vars,folder,date_ini =date_ini,date_end=date_end){
  
  range <- gsub("-","",as.Date(date_ini:date_end, origin = "1970-01-01"))
  
  stack_fls <- 
    lapply(vars,function(vr){
      print(vr)
      files <- list.files(paste0(folder,"/",vr,"/"),pattern =  ".tif$",full.names = T)
      
      fil_sub <- grep(paste(range,collapse = "|"),files,value = T)
      
      lrster <- lapply(fil_sub,raster)
      
      stack(lrster)
    }
    )
  names(stack_fls) <- vars
  stack_fls
}

# Getting info

extraWeatherData <- function(stack_fls,events){
  
  ls_weather_data <- lapply(seq(nrow(events)), function(ci){ 
    print(paste(ci,"-"))
    cord <- events[ci,]
    
    extraction <-
      lapply(seq(length(stack_fls)), function(sr){
        
        st <- stack_fls[[sr]]
        
        rang_date <- gsub("-","",as.Date(cord$date_ini:cord$date_end,origin = "1970-01-01"))
        
        rang_date2 <- grep(paste(rang_date,collapse = "|"),names(st),value = T)
        
        st <- st[[rang_date2]]
        
        getInfo <- terra::extract(st,cord[c("longitude","latitude")])
        
        getInfoLong <- separate(data.frame(nam=colnames(getInfo)),nam,c("var","date"),"_")
        
        data.frame(
          date = as.Date(getInfoLong$date,
                         "%Y%m%d"),getInfoLong$var,var=as.numeric(getInfo))
        
      }
      )
    pw <- pivot_wider( do.call(rbind,extraction),
                 names_from = getInfoLong.var, 
                 values_from = var)
    
    pw %>% mutate(srad=srad/1000,tmax=tmax-273.15,tmin=tmin-273.15, vapr=vapr*10)
    
  }
  )
  ls_weather_data
}


# Getting info

extraWeatherData2 <- function(stack_fls,events,date_ini,date_end){

    extraction <-
      lapply(seq(length(stack_fls)), function(sr){
        
        st <- stack_fls[[sr]]
        
        rang_date <- gsub("-","",as.Date(date_ini:date_end,origin = "1970-01-01"))
        
        rang_date2 <- grep(paste(rang_date,collapse = "|"),names(st),value = T)
        
        st <- st[[rang_date2]]
        
        getInfo <- terra::extract(st,events[c("longitude","latitude")])
        
        getInfoLong <- separate(data.frame(nam=colnames(getInfo)),nam,c("var","date"),"_")
        
        var = data.frame(t(getInfo))
        
        names(var) <- paste0(events$longitude,"_",events$latitude)
        
        data.frame(
          date = as.Date(getInfoLong$date,
                         "%Y%m%d"),getInfoLong$var,var)

      }
    )
    
    pw0 <- do.call(rbind,extraction)
    
    pw0 <- pw0 %>% pivot_longer(!(date:getInfoLong.var),names_to = "coords",values_to = "value")
    
    pw <- pivot_wider(pw0 ,
                       names_from = getInfoLong.var, 
                       values_from = value)
    
    pw <- pw %>% arrange(coords,date)
    
    pw %>% mutate(srad=srad/1000,tmax=tmax-273.15,tmin=tmin-273.15, vapr=vapr/10)
  
}


