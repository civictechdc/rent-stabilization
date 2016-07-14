#Pre-computation data cleaning

data.res <- read.csv('Residential_CAMA.csv')
data.comm <- read.csv('Commercial_CAMA.csv')
data.condo <- read.csv('Condominium_CAMA.csv')

#remove all the irregular years in each subset
data.res <- data.res %>% filter(nchar(AYB) == 4)
data.comm <- data.comm %>% filter(nchar(AYB) == 4)
data.condo <- data.condo %>% filter(nchar(AYB) == 4)

data.res <- data.res %>% filter(USECODE %in% c(11, 12, 13, 24, 23, 21, 1, 15, 19, 25, 28))

#filtering out all condo codes we don't care about
data.condo <- data.condo %>% filter(USECODE %in% c(16, 17, 117))

#filtering out all commercial codes we don't care about
data.comm <- data.comm %>% filter(USECODE %in% c(11, 12, 21, 217, 1))

#within residential buildings, how many one-unit buildings are there?
#oneUnitRes <- codeRes %>% filter(USECODE %in% c(11, 12, 13, 1, 15, 19))


#restructure the three data sets such that each row/observation is a unit in a building; first, for commercial buildings
#note: this removes all instances where the number of units is zero or NA
rows <- nrow(data.comm)
data.comm.new <- data.frame()

for (i in 1:rows) {
  
  if (is.na(data.comm$NUM_UNITS[i]) == FALSE) {
    
    temp <- data.comm[i,]
    data.comm.new <- bind_rows(data.comm.new, mefa:::rep.data.frame(temp, as.numeric(data.comm$NUM_UNITS[i])))
  }
}

#stimating the number of units for residential records that have between 3 and 5 units in them
#we will also get all residential units located in buildings with 3-5 units as separate rows
temp.res.data <- data.res %>% filter(USECODE %in% c(23,24))
data.res.new <- temp.res.data[rep(seq_len(nrow(temp.res.data)), 4), ]


#create a side copy of all residential buildings we'll assume to have 1 unit
res.unfiltered <- data.res %>% filter(!(USECODE %in% c(23,24)))


#now preparing each subset to be appended on top of each other
indecies.r <- which(colnames(data.res.new) %in% colnames(data.comm.new))
data.res.new <- data.res.new %>% select(indecies.r) %>% select(-NUM_UNITS)

indecies.comm <- which(colnames(data.comm.new) %in% colnames(data.res.new))
data.comm.new <- data.comm.new %>% select(indecies.comm)

indecies.condo <- which(colnames(data.condo) %in% colnames(data.res.new))
data.condo.new <- data.condo %>% select(indecies.condo)

indecies.rn <- which(colnames(res.unfiltered) %in% colnames(data.res.new))
data.res.oneunit <- res.unfiltered %>% select(indecies.rn)

data.final <- bind_rows(list(data.res.new, data.condo.new, data.comm.new, data.res.oneunit))
