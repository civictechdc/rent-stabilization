# script joins into a single df residential CAMA datasets processed in pre-analysis
# joins single CAMA df to MAR address points subset with at least one housing unit
## author: ursula.kaczmarek@gmail.com

library(dplyr)
library(RSQLite)

# load cleaned CAMA residential data sets to frames
cama.res <- read.csv("~/cama.res.clean.csv", stringsAsFactors=FALSE)
cama.condo <- read.csv("~/cama.condo.clean.csv", stringsAsFactors=FALSE)
cama.comm <- read.csv("~/cama.comm.clean.csv", stringsAsFactors=FALSE)

# download MAR address points and load to frame
download.file("http://opendata.dc.gov/datasets/aa514416aaf74fdc94748f1e56e7cc8a_0.csv","mar.csv")
mar <- read.csv("mar.csv")

# subset MAR to addresses with at least one housing unit
mar <- mar[mar$ACTIVE_RES_OCCUPANCY_COUNT > 0, ]

# combine CAMA dfs into single df 
# coercing to character message OK, some variables have different types
cama.all <- bind_rows(list(cama.res, cama.condo, cama.comm))

# remove whitespace from both CAMA and MAR SSL column
cama.all$SSL <- gsub(" ","",cama.all$SSL)
mar$SSL <- gsub(" ","",mar$SSL)

# join MAR to CAMA on matching SSLs
cama.mar <- left_join(cama.all, mar, by = "SSL")
