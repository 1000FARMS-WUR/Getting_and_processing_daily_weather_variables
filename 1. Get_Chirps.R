# CHIRPS
# By: H. Achicanoy, https://github.com/haachicanoy 2022

# R options
g <- gc(reset = T); rm(list = ls()) # Empty garbage collector
.rs.restartR()                      # Restart R session
options(warn = -1, scipen = 999)    # Remove warning alerts and scientific notation
suppressMessages(library(pacman))

suppressMessages(pacman::p_load(raster, geodata, terra, imager, lubridate))

# Time frame
ini <- as.Date('2021-01-01')
end <- as.Date(Sys.time())
dts <- seq(from = ini, to = end, by = 'day'); rm(ini, end)

# Output directory
Out  <- 'Weather_data/Rainfall_chirps/'; if(!dir.exists(Out)){dir.create(Out,F,T)}

# Main function
chirps2gray <- function(date = dts[1]){
  # CHIRPS base URL
  chrps <- 'https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/tifs/p05'
  # Get day and year
  Day  <- date
  Year <- lubridate::year(Day)
  # Target file
  tfile <- paste0(chrps,'/',Year,'/chirps-v2.0.',gsub('-','.',Day,fixed=T),'.tif.gz')
  # Destination file
  dfile <- paste0(Out,'/',basename(tfile))
  # Raster file
  rfile <- gsub('.gz','',dfile,fixed = T)
  
  if(!file.exists(rfile)){
    tryCatch(expr = {
      utils::download.file(url = tfile, destfile = dfile)
    },
    error = function(e){
      cat(paste0(basename(tfile),' failed.\n'))
    })
    
    # Unzip
    R.utils::gunzip(dfile)
  }
}

# Loop through the dates
dts %>% purrr::map(.f = chirps2gray)
