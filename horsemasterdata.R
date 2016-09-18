library(data.table)
library(PivotalR)

# connect to database

source("secretconnect.R")

# load data and model

performances <- db.data.frame("public.performances")
performances <- performances[performances$race_date > "2006-01-01"]
performancesdt <- lk(performances, -1)

# finish

db.disconnect(con, verbose = TRUE)
