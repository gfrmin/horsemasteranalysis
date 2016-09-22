library(data.table)
library(PivotalR)

# connect to database

source("secretconnect.R")

# load data and model

performances <- db.data.frame("public.performances")
performances <- performances[performances$race_date >= "2007-09-09"]
performances <- performances[,c("horse_id", "horse_no", "race_no", "race_date", "season", "going", "rating", "jockey_id", "trainer_id", "winning_odds", "actual_weight", "on_date_weight", "gears", "draw", "race_class", "distance", "course", "race_location", "finish_time")]
performancesdt <- data.table(lk(performances, -1))

write.csv(performancesdt, file = "performancesdt.csv", row.names = FALSE)

# finish

db.disconnect(con, verbose = TRUE)
