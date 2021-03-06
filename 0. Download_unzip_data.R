
# CHIRPS
# # By: Anny, 2022

devtools::install_github("bluegreen-labs/ecmwfr")
# install.packages("ecmwfr")

library(ecmwfr)

# credentials
UID = "139257"
key = "33b9a000-757d-478f-8efd-ba560695a437"

# save key for CDS
wf_set_key(user = UID,
           key = key,
           service = "cds")


getERA5 <- function(i, qq, year, month, datadir){
  q <- qq[i,]
  format <- "zip"
  ofile <- paste0(paste(q$variable, q$statistics, year, month, sep = "-"), ".",format)
  
  if(!file.exists(file.path(datadir,ofile))){
    ndays <- lubridate::days_in_month(as.Date(paste0(year, "-" ,month, "-01")))
    ndays <- 1:ndays
    ndays <- sapply(ndays, function(x) ifelse(length(x) == 1, sprintf("%02d", x), x))
    ndays <- dput(as.character(ndays))
    
    cat("Downloading", q[!is.na(q)], "for", year, month, "\n"); flush.console();
    
    request <- list("dataset_short_name" = "sis-agrometeorological-indicators",
                    "variable" = q$variable,
                    "statistic" = q$statistics,
                    "year" = year,
                    "month" = month,
                    "day" = ndays,
                    "area" = "90/-180/-90/179.9", # download global #c(ymax,xmin,ymin,xmax)? 
                    "time" = q$time,
                    "format" = format,
                    "target" = ofile)
    
    request <- Filter(Negate(anyNA), request)
    
    file <- wf_request(user     = UID,   # user ID (for authentification)
                       request  = request,  # the request
                       transfer = TRUE,     # download the file
                       path     = datadir)  
  } else {
    cat("Already exists", q[!is.na(q)], "for", year, month, "\n"); flush.console();
  }
  return(NULL)
}


########################################################################################################
# change data directory
datadir <- here::here("Zip")
# datadir <- ""
dir.create(datadir, FALSE, TRUE)

# combinations to download
qq <- data.frame(variable = c("solar_radiation_flux",rep("2m_temperature",3),
                              "10m_wind_speed", "2m_relative_humidity"),
                 statistics = c(NA, "24_hour_maximum", "24_hour_mean", "24_hour_minimum",
                                "24_hour_mean", NA),
                 time = c(NA,NA,NA,NA,NA, "12_00"))

qq <- data.frame(variable = c("vapour_pressure"),
                 statistics = c( "24_hour_mean"),
                 time = c(NA))


# temporal range
years <- as.character(2017:format(Sys.time(), "%Y"))
years <- as.character(2017:2020)

months <- c(paste0("0", 1:9), 10:12)

# all download
for (i in 1:nrow(qq)){
  for (year in years){
    for (month in months){
      tryCatch(getERA5(i, qq, year, month, datadir), error = function(e)NULL)
    }
  }
}

for (year in as.character(1999:2001)){
  for (month in months){
    getERA5(i=5, qq, year, month, datadir)
  }
}

# unzip
datadir <-  here::here("Zip")

zz <- list.files(datadir, ".zip$", full.names = TRUE)

vars <- c("solar_radiation_flux","10m_wind_speed","2m_temperature-24_hour_maximum",
          "2m_temperature-24_hour_mean","2m_temperature-24_hour_minimum","2m_relative_humidity","vapour_pressure-24_hour_mean")




extractNC <- function(var, zz, datadir,subFolder="", ncores = 1){
  z <- grep(var, zz, value = TRUE)
  fdir <- file.path(dirname(datadir),subFolder, var)
  dir.create(fdir, showWarnings = FALSE, recursive = TRUE)
  parallel::mclapply(z, function(x){unzip(x, exdir = fdir)}, mc.cores = ncores, mc.preschedule = FALSE)
  return(NULL)
} 


for (var in vars){
  extractNC(var, zz, datadir,subFolder = "Weather_data", ncores = 1)
}



