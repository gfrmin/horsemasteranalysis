library(data.table)
library(lubridate)
library(stringr)

performances <- fread("performancesdt.csv")
performancesdt <- performances[,list(horse_id, horse_no, race_no, race_date, going, rating, jockey_name, trainer_name, winning_odds, actual_weight, on_date_weight, gears, draw, race_class, distance, course, race_location, track, finish_time)]

# lubridate dates
performancesdt[,race_date := ymd(race_date)]
performancesdt[,`:=`(raceday = day(race_date), racemonth = month(race_date), raceyear = year(race_date))]
performancesdt <- performancesdt[raceyear >= 2000] # don't need all races!

# actual weight should be above 0 and have an on_date_weight
performancesdt <- performancesdt[actual_weight > 0][!is.na(on_date_weight)]

# rating should be numeric?
performancesdt[,rating := as.numeric(rating)]

# convert finish_time to seconds
performancesdt <- performancesdt[!is.na(finish_time)] # must have finish time...
performancesdt <- performancesdt[str_detect(finish_time, "^[:digit:]+\\.[:digit:]+\\.[:digit:]+$")]

finishtimes <- data.table(performancesdt[,str_split_fixed(finish_time, "\\.", 2)])
finishtimes <- finishtimes[,lapply(.SD, as.numeric)]
finishtimes[,V1 := V1*60]
finishtimes[,finish_time := V1 + V2]
performancesdt[,finish_time := finishtimes$finish_time]
rm(finishtimes)

# save clean(er) dataset

write.csv(performancesdt, file = "performancesdtclean.csv", row.names = FALSE)
