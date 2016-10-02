library(data.table)
library(PivotalR)

# connect to database

source("secretconnect.R")

# load data and model

performances <- db.data.frame("public.performances")
performancesdt <- data.table(lk(performances, -1))

write.csv(performancesdt, file = "performances.csv", row.names = FALSE)

# finish

db.disconnect(con, verbose = TRUE)
