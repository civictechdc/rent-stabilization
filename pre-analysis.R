library(dplyr)
library(tidyr)

data.res <- read.csv('Residential_CAMA.csv')
data.comm <- read.csv('Commercial_CAMA.csv')
data.condo <- read.csv('Condominium_CAMA.csv')

#remove all the irregular years in each subset
data.res <- data.res %>% filter(nchar(AYB) == 4)
data.comm <- data.comm %>% filter(nchar(AYB) == 4)
data.condo <- data.condo %>% filter(nchar(AYB) == 4)


#tabulating the number of RESIDENTIAL BUILDINGS per year built:
yearlyRes <- data.res %>% group_by(AYB) %>% summarise(n = n())

#tabulating the number of COMMERCIAL BUILDINGS per year built:
yearlyComm <- data.comm %>% group_by(AYB) %>% summarise(n = n())

#tabulating the number of CONDO units per year built:
yearlyCondo <- data.condo %>% group_by(AYB) %>% summarise(n = n())

#taking the residential addresses, grouping these by use code while preserving year built
codeRes <- data.res %>% group_by(AYB, USECODE) %>% summarise(n = n())

#taking the condo addresses, grouping these by use code while preserving year built
codeCondo <- data.condo %>% group_by(AYB, USECODE) %>% summarise(n = n())

#taking the commercial address, grouping these by use code while preserving year built
codeComm <- data.comm %>% group_by(AYB, USECODE) %>% select(AYB, USECODE, NUM_UNITS)

#filtering out all residential codes we don't care about
codeRes <- codeRes %>% filter(USECODE %in% c(11, 12, 13, 24, 23, 21, 1, 15, 19, 25, 28))

#filtering out all condo codes we don't care about
codeCondo <- codeCondo %>% filter(USECODE %in% c(16, 17, 117))

#filtering out all commercial codes we don't care about
codeComm <- codeComm %>% filter(USECODE %in% c(11, 12, 21, 217, 1))

#within residential buildings, how many one-unit buildings are there?
oneUnitRes <- codeRes %>% filter(USECODE %in% c(11, 12, 13, 1, 15, 19))
sum(oneUnitRes$n)

#how many total condo units are there?
sum(codeCondo$n)

#how many total commercial units are there in DC?
sum(codeComm$NUM_UNITS, na.rm = TRUE)

#creating categories for pre/post 1975
codeCondo <- codeCondo %>% mutate(ifelse(AYB <= 1975, 1, 2))
colnames(codeCondo) <- c('AYB', 'USECODE', 'n', 'pre1975')
codeCondo %>% group_by(pre1975) %>% mutate(total = sum(n)) %>% distinct()

oneUnitRes <- oneUnitRes %>% mutate(ifelse(AYB <= 1975, 1, 2))
colnames(oneUnitRes) <- c('AYB', 'USECODE', 'n', 'pre1975')
oneUnitRes %>% group_by(pre1975) %>% mutate(total = sum(n)) %>% select(4:5) %>% distinct()

codeComm <- codeComm %>% mutate(ifelse(AYB <= 1975, 1, 2))
colnames(codeComm) <- c('AYB', 'USECODE', 'n', 'pre1975')
codeComm %>% group_by(pre1975) %>% mutate(total = sum(n, na.rm = TRUE)) %>% select(4:5) %>% distinct()
