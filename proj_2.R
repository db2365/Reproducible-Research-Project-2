#load libraries
library(plyr)
library(ggplot2)
library(dplyr)
library(data.table)

#First, read in the data
url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
download.file(url, "StormData.csv.bz2")
library(R.utils)
bunzip2("StormData.csv.bz2", "StormData.csv")
storm_raw_data <- read.csv("StormData.csv")

#Examine data set
dim(storm_raw_data)
head(storm_raw_data)
str(storm_raw_data)

#Data Cleaning
#Interested in these 7 variables, do not need other columns in data set
fields<-c("EVTYPE","FATALITIES","INJURIES","PROPDMG", "PROPDMGEXP","CROPDMG","CROPDMGEXP")
working_data<-storm_raw_data[fields]
#Remove data where every relevant column is 0
working_data <- working_data %>% filter(INJURIES !=0 | FATALITIES !=0 | PROPDMG !=0 | CROPDMG !=0)
(echo = TRUE)
#Correct the storm types 
working_data_corrected <- working_data
working_data_corrected$EVTYPE <- toupper(working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^(SMALL )?HAIL.*", "HAIL", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("TSTM|THUNDERSTORMS?", "THUNDERSTORM", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("STORMS?", "STORM", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("WINDS?|WINDS?/HAIL", "WIND", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("RAINS?", "RAIN", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^TH?UN?DEE?RS?TO?RO?M ?WIND.*|^(SEVERE )?THUNDERSTORM$|^WIND STORM$|^(DRY )?MI[CR][CR]OBURST.*|^THUNDERSTORMW$", "THUNDERSTORM WIND", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^COASTAL ?STORM$|^MARINE ACCIDENT$", "MARINE THUNDERSTORM WIND", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^FLOODS?.*|^URBAN/SML STREAM FLD$|^(RIVER|TIDAL|MAJOR|URBAN|MINOR|ICE JAM|RIVER AND STREAM|URBAN/SMALL STREAM)? FLOOD(ING)?S?$|^HIGH WATER$|^URBAN AND SMALL STREAM FLOODIN$|^DROWNING$|^DAM BREAK$", "FLOOD", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^FLASH FLOOD.*|^RAPIDLY RISING WATER$", "FLASH FLOOD", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("WATERSPOUTS?", "WATERSPOUT", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("WEATHER/MIX", "WEATHER", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("CURRENTS?", "CURRENT", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^WINDCHILL$|^COLD.*|^LOW TEMPERATURE$|^UNSEASONABLY COLD$", "COLD/WIND CHILL", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^EXTREME WIND ?CHILL$|^(EXTENDED|EXTREME|RECORD)? COLDS?$", "EXTREME COLD/WIND CHILL", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^WILD/FOREST FIRE$|^(WILD|BRUSH|FOREST)? ?FIRES?$", "WILDFIRE", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^RAIN/SNOW$|^(BLOWING|HEAVY|EXCESSIVE|BLOWING|ICE AND|RECORD)? ?SNOWS?.*", "HEAVY SNOW", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^FOG$", "DENSE FOG", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^(GUSTY|NON-SEVERE|NON ?-?THUNDERSTORM)? ?WIND.*|^ICE/STRONG WIND$", "STRONG WIND", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("SURGE$", "SURGE/TIDE", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("CLOUDS?", "CLOUD", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^FROST[/\\]FREEZE$|^FROST$|^(DAMAGING)? ?FREEZE$|^HYP[OE]R?THERMIA.*|^ICE$|^(ICY|ICE) ROADS$|^BLACK ICE$|^ICE ON ROAD$", "FROST/FREEZE", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^GLAZE.*|^FREEZING (RAIN|DRIZZLE|RAIN/SNOW|SPRAY$)$|^WINTRY MIX$|^MIXED PRECIP(ITATION)?$|^WINTER WEATHER MIX$|^LIGHT SNOW$|^FALLING SNOW/ICE$|^SLEET.*", "SLEET", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^HURRICANE.*", "HURRICANE/TYPHOON", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^HEAT WAVES?$|^UNSEASONABLY WARM$|^WARM WEATHER$", "HEAT", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^(EXTREME|RECORD/EXCESSIVE|RECORD) HEAT$", "EXCESSIVE HEAT", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^HEAVY SURF(/HIGH SURF)?.*$|^(ROUGH|HEAVY) SEAS?.*|^(ROUGH|ROGUE|HAZARDOUS) SURF.*|^HIGH WIND AND SEAS$|^HIGH SURF.*", "HIGH SURF", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^LAND(SLUMP|SLIDE)?S?$|^MUD ?SLIDES?$|^AVALANCH?E$", "AVALANCHE", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^UNSEASONABLY WARM AND DRY$|^DROUGHT.*|^HEAT WAVE DROUGHT$", "DROUGHT", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^TORNADO.*", "TORNADO", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^TROPICAL STORM.*", "TROPICAL STORM", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^MARINE MISHAP$|^HIGH WIND/SEAS$", "MARINE HIGH WIND", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^HIGH WIND.*", "HIGH WIND", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^HIGH SEAS$", "MARINE STRONG WIND", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^RIP CURRENT.*", "RIP CURRENT", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^WATERSPOUT.*", "WATERSPOUT", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^EXCESSIVE RAINFALL$|^RAIN.*|^TORRENTIAL RAINFALL$|^(HEAVY|HVY)? (RAIN|MIX|PRECIPITATION).*", "HEAVY RAIN", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^FOG.*", "FREEZING FOG", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^WINTER STORM.*", "WINTER STORM", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^THUNDERSNOW$|^ICE STORM.*", "ICE STORM", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("WAVES?|SWELLS?", "SURF", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^LIGHTNING.*", "LIGHTNING", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^WHIRLWIND$|^GUSTNADO$|^TORNDAO$", "TORNADO", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^COASTAL FLOOD.*", "COASTAL FLOOD", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^TYPHOON", "HURRICANE/TYPHOON", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^EROSION/CSTL FLOOD$|^COASTAL FLOOD/EROSION$|^COASTAL SURGE/TIDE$", "COASTAL FLOOD", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^ASTRONOMICAL HIGH TIDE$", "STORM SURGE/TIDE", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^(GROUND)? ?BLIZZARD.*$", "BLIZZARD", working_data_corrected$EVTYPE)
working_data_corrected$EVTYPE <- gsub("^DUST STORM.*$", "DUST STORM", working_data_corrected$EVTYPE)



#HEALTH
#Remove cost columns to simplify, not required for health analysis
health_total <- subset(working_data_corrected, select = -c(CROPDMGEXP, PROPDMGEXP, CROPDMG, PROPDMG))

#Changing column names for aesthetics
colnames(health_total)[colnames(health_total) == "EVTYPE"] <- "Event"
colnames(health_total)[colnames(health_total) == "FATALITIES"] <- "Fatalities"
colnames(health_total)[colnames(health_total) == "INJURIES"] <- "Injuries"

#aggregate all property costs together
f <- aggregate(health_total$Fatalities, by = list(Event = health_total$Event), FUN = sum)
colnames(f) <- c("Event", "Fatalities")

#aggregate all crops costs together
i <- aggregate(health_total$Injuries, by = list(Event = health_total$Event), FUN = sum)
colnames(i) <- c("Event", "Injuries")

#merge the two dataframes
health <- merge(f,i, by="Event")

#add total column
health$Total_Health <- health$Fatalities + health$Injuries

#order dataframe by total damage
people_total <- health[order(-health$Total_Health), ][1:10, ]


#HEALTH PLOT
#Create plot of health data
#Melt so it is easier to put in a graph
health_plot_data <- melt(people_total, id.vars = "Event", variable.name = "Type")

#remove last 10 rows as they are sum for total
n<-dim(health_plot_data)[1]
health_chart <-health_plot_data[1:(n-10),]

#create plot
g <- ggplot(health_chart, aes(x=reorder(Event, -value), y = value)) + geom_bar(stat="identity", aes(fill = Type)) +  scale_fill_manual(values=c("#6495ED", "#B0E0E6"))
g + coord_flip() + xlab("Event Type") + ylab("Total Number of Individuals Affected") + ggtitle("Fatalities and Injuries Resulting from Weather Events")



#ECONOMY
#fix/merge the values from the exponential columns
damage_total <- working_data_corrected %>% 
        mutate(CROPDMG = ifelse(CROPDMGEXP == "K", CROPDMG * 1000, CROPDMG), CROPDMG = ifelse(CROPDMGEXP == "M", CROPDMG * 1000000, CROPDMG), CROPDMG = ifelse(CROPDMGEXP == "B", CROPDMG * 1000000000, CROPDMG)) %>%
        mutate(PROPDMG = ifelse(PROPDMGEXP == "K", PROPDMG * 1000, PROPDMG), PROPDMG = ifelse(PROPDMGEXP == "M", PROPDMG * 1000000, PROPDMG), PROPDMG = ifelse(PROPDMGEXP == "B", PROPDMG * 1000000000, PROPDMG))

#Remove exponent and health columns for damage dataset, no longer relevant
damage_total <- subset(damage_total, select = -c(CROPDMGEXP, PROPDMGEXP, FATALITIES, INJURIES))

#Changing column names for aesthetics
colnames(damage_total)[colnames(damage_total) == "EVTYPE"] <- "Event"
colnames(damage_total)[colnames(damage_total) == "PROPDMG"] <- "Property"
colnames(damage_total)[colnames(damage_total) == "CROPDMG"] <- "Crops"

#aggregate all property costs together
p <- aggregate(damage_total$Property, by = list(Event = damage_total$Event), FUN = sum)
colnames(p) <- c("Event", "Property")

#aggregate all crops costs together
c <- aggregate(damage_total$Crops, by = list(Event = damage_total$Event), FUN = sum)
colnames(c) <- c("Event", "Crops")

#merge the two dataframes
total <- merge(p,c, by="Event")

#add total column
total$Total_Damage <- total$Property + total$Crops

#order dataframe by total damage
econ_total <- total[order(-total$Total_Damage), ][1:10, ]


#Economic PLOT
#Create plot of health data
#Melt so it is easier to put in a graph
economic_plot_data <- melt(econ_total, id.vars = "Event", variable.name = "Type")

#remove last 10 rows as they are sum for total
n<-dim(economic_plot_data)[1]
economic_chart <-economic_plot_data[1:(n-10),]

#create plot
g <- ggplot(economic_chart, aes(x=reorder(Event, -value), y = value)) + geom_bar(stat="identity", aes(fill = Type)) +  scale_fill_manual(values=c("#FFC0CB", "#F08080"))
g + coord_flip() + xlab("Event Type") + ylab("Total Amount of Damage Cost") + ggtitle("Crop and Property Damage Costs Resulting from Weather Events")

