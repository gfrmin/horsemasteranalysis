library(data.table)
library(lubridate)
library(stringr)

performances <- fread("performances.csv")

# lubridate dates
performances[,race_date := ymd(race_date)]
performances[,`:=`(raceday = day(race_date), racemonth = month(race_date), raceyear = year(race_date))]
performances <- performances[raceyear >= 2000] # don't need all races!

# actual weight should be above 0 and have an on_date_weight
performances <- performances[actual_weight > 0][!is.na(on_date_weight)]

# rating should be numeric?
performances[,rating := as.numeric(rating)]

# convert finish_time to seconds
performances <- performances[!is.na(finish_time)] # must have finish time...
performances <- performances[str_detect(finish_time, "^[:digit:]+\\.[:digit:]+\\.[:digit:]+$")]

finishtimes <- data.table(performances[,str_split_fixed(finish_time, "\\.", 2)])
finishtimes <- finishtimes[,lapply(.SD, as.numeric)]
finishtimes[,V1 := V1*60]
finishtimes[,finish_time := V1 + V2]
performances[,finish_time := finishtimes$finish_time]
rm(finishtimes)

# save clean(er) dataset

write.csv(performances, file = "performancesclean.csv", row.names = FALSE)
