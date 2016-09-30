library(data.table)

performancesdt <- fread("performancesdt.csv")
performancesdt <- performancesdt[,list(horse_id, horse_no, race_no, race_date, race_class, going, rating, jockey_name, trainer_name, winning_odds, actual_weight, on_date_weight, gears, draw, race_class, distance, course, race_location, track)]

library(lubridate)
performancesdt[,race_date := ymd(race_date)]
performancesdt[,`:=`(raceday = day(race_date), racemonth = month(race_date), raceyear = year(race_date))][,race_date := NULL]