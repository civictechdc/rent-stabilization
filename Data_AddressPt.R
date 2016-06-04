# DESCRIPTION: Download dataset of building addresses from opendata.dc.gov
# AUTHOR:      Nate
# Source data web page:  http://opendata.dc.gov/datasets/aa514416aaf74fdc94748f1e56e7cc8a_0
# Variable descriptions: https://www.arcgis.com/sharing/rest/content/items/aa514416aaf74fdc94748f1e56e7cc8a/info/metadata/metadata.xml?format=default&output=html


# PRELIMINARIES ---------------------------------------------------------------

# Load packages
library(readr)
library(RColorBrewer)
library(ggplot2)

# Set working directory
setwd("C://Users/nbanion/Desktop/rent")

# Download csv 
download.file("http://opendata.dc.gov/datasets/aa514416aaf74fdc94748f1e56e7cc8a_0.csv",
              "AddressPt.csv")


# DATA PROCESSING -------------------------------------------------------------

# Read address dataset into R
addr <- read_csv("AddressPt.csv")
str(addr)
str(addr$ACTIVE_RES_UNIT_COUNT)
summary(addr$ACTIVE_RES_UNIT_COUNT)

# Subset dataset to addresses with one or more residential units
res1 <- addr[addr$ACTIVE_RES_UNIT_COUNT > 0, ]
summary(res1$ACTIVE_RES_UNIT_COUNT)
hist(res1$ACTIVE_RES_UNIT_COUNT)

# Subset dataset to addresses with four or more residential units
res5 <- addr[addr$ACTIVE_RES_UNIT_COUNT > 5, ]
summary(res4$ACTIVE_RES_UNIT_COUNT)
hist(res4$ACTIVE_RES_UNIT_COUNT)

# EXPLORATORY ANALYSIS --------------------------------------------------------

# Map of addresses, colored by unit count
# Pattern washed out by all the single units
ggplot(data = res1) +
  aes(LONGITUDE, LATITUDE, color = ACTIVE_RES_UNIT_COUNT)+
  scale_color_gradientn(colors = brewer.pal(6, "Purples")) +
  geom_point(pch = 16, alpha = 0.5) +
  theme_void()

# Map of addresses, transparency by unit count
# Interesting, but misleading, because dark areas caused by high unit count 
# or by close proximity
ggplot(data = res1) +
  aes(LONGITUDE, LATITUDE, alpha = ACTIVE_RES_UNIT_COUNT)+
  geom_point(pch = 16, color = "black") +
  theme_void()

# Map of addresses, with shading for 5+ units
ggplot() +
  aes(LONGITUDE, LATITUDE)+
  geom_point(data = addr, pch = 16, color = "grey50") +
  geom_point(data = res5, pch = 16, color = "black") +
  theme_void()