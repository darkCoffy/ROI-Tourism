#load the req libraries
library("tidyverse")
library("eurostat")
library(readxl)

#load Wec dataset as a tibble
init.data<- data.frame(read.csv("../data/WEF_TTCR17_data_for_download.csv"))
as_tibble(init.data)


#Clean and transform the WEC dataset to a usable format for making a cube
colnames(init.data) <- as.character(unlist(init.data[1,]))
reqCol <- c('Series','Attribute','AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN', 'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'ROU', 'SVK', 'SVN','TUR', 'ESP', 'SWE', 'GBR')
prelimData <- init.data[,reqCol]
WECTTCI17 <- filter(prelimData,Attribute == 'Value')
WECTTCI17 <- select(WECTTCI17,-(Attribute))
WECTTCI17$Series <- gsub(",","",WECTTCI17$Series)
WECTTCI17 <- WECTTCI17[-c(8),]
WECTTCI17 <- t(WECTTCI17)
WECTTCI17 <-as.data.frame(WECTTCI17)
col <- c(6,25,27:31,38,41,43,50,52,53,55,56,80:90)
WECTTCI17 <- select(WECTTCI17,col)
colnames(WECTTCI17) <- as.character(unlist(WECTTCI17[1,]))
WECTTCI17$year <-  c(2017)
WECTTCI17 <- WECTTCI17[c(27,1:26)]
WECTTCI17 <- WECTTCI17[,-c(9)]
WECTTCI17 <- WECTTCI17[-c(1),]
write.csv(WECTTCI17,file = "interimWec.csv",row.names = TRUE)
WECTTCI17 <- read.csv("interimWec.csv")
colnames(WECTTCI17) <- c("country","year","gdp_share","terrorism_cost","homicides","physician","improved_sanitation","improved_water","hospital","pay","ict","electricity","tourism_spent","marketing_effectivenes","open_data","brand_rating","roads","railroad","port","ground_transport","railroad_density","hotel_rooms","tourism_infra","car_rental","atm","heritage_sites","species")
write.csv(WECTTCI17,file = "WECTTCI.csv",row.names = FALSE)

#clean and transform the Statista dataset
Statista <- read_excel("../data/statistic_id314340_leading-european-city-tourism-destinations-in-2017-by-number-of-bednights.xlsx",sheet = "Data",skip=4)
names(Statista) <- c('City','Count')
Statista$CountryTwo <- c("GB","FR","DE","IT","ES","ES","CZ","TR","AT","DE","NL","SE","DE","IT","PT")
Statista$CountryThree <- c("GBR","FRA","DEU","ITA","ESP","ESP","CZE","TUR","AUT","DEU","NLD","SWE","DEU","ITA","PRT")
Statista <- Statista[c(4,3,1,2)]
write.csv(Statista,file = "Statista.csv",row.names = FALSE)

#cleaning and transforming the footfall eurostat data
eutwoletter <- c("AT","BE","BG","HR","CY","CZ","DK","EE","FI","FR","DE","GR","HU","IE","IT","LV","LT","LU","MT","NL","PL","PT","RO","SK","SI","ES","SE","GB")
byFootfall<- get_eurostat("tour_dem_extot", filters = list(nongeo=1,geo = eutwoletter,sinceTimePeriod=2012,purpose="TOTAL",precision=1,duration="N_GE1",unit="THS_EUR",partner="DOM"), time_format = "num")
byFootfall <- select(byFootfall,geo:values)
year <- unique(byFootfall$time)
geo <- unique(byFootfall$geo)
geo <- as.character(geo)
footfall <- c()

for (i in 1:length(geo)) {
  for (j in 1:length(year)) {
    test <- filter(byFootfall,geo==geo[i],year==year[j])%>% select(values)
    row <- c(year[j],geo[i],unlist(test,recursive = TRUE,use.names = FALSE))
    footfall <- rbind(footfall,row)
    
  }
}
colnames(footfall) <- c("Year","Geo","Footfall_in_mil")
write.csv(footfall,file = "Footfall.csv",row.names = FALSE)




#Clean and transform the Age wise eurostat data
byAge<- get_eurostat("tour_dem_toage", filters = list(nongeo=1,geo = eutwoletter,sinceTimePeriod=2012,purpose="TOTAL",precision=1,duration="N_GE1",unit="NR",partner="DOM",age=c("Y15-24","Y25-34","Y35-44","Y45-64","Y_GE65")), time_format = "num")
byAge <- select(byAge,age:values)
ageFactor <- unique(byAge$age)
year <- unique(byAge$time)
geo <- unique(byAge$geo)
geo <- as.character(geo)
age <- c()

for (i in 1:length(geo)) {
  for (j in 1:length(year)) {
    test <- filter(byAge,geo==geo[i],year==year[j])%>% select(values)
    row <- c(year[j],geo[i],unlist(test,recursive = TRUE,use.names = FALSE))
    age <- rbind(age,row)
    
  }
}
colnames(age) <- c("Year","Geo","Y15-24","Y25-34","Y35-44","Y45-64","Y_GE65")
write.csv(age,file = "Age.csv",row.names = FALSE)


#clean and transform the Sex wise eurostat data
bySex <- get_eurostat("tour_dem_tosex", filters = list(nongeo=1,geo = eutwoletter,sinceTimePeriod=2012,precision=1,duration="N_GE1",unit="NR",partner="DOM",sex=c("M","F")), time_format = "num")
bySex <- select(bySex,sex:values)
sexFactor <- unique(bySex$sex)
year <- unique(bySex$time)
geo <- unique(bySex$geo)
geo <- as.character(geo)
sex <- c()

for (i in 1:length(geo)) {
  for (j in 1:length(year)) {
    test <- filter(bySex,geo==geo[i],year==year[j])%>% select(values)
    row <- c(year[j],geo[i],unlist(test,recursive = TRUE,use.names = FALSE))
    sex <- rbind(sex,row)
    
  }
}
colnames(sex) <- c("Year","Geo","F","M")
write.csv(sex,file = "Sex.csv",row.names = FALSE)