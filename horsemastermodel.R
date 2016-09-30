library(data.table)
library(caret)

performancesdt <- fread("performancesdtclean.csv")
performancemodel <- performancesdt[,list(race_no,going,rating,winning_odds,actual_weight,on_date_weight,draw,race_class,distance,course,race_location,track,raceday,racemonth,raceyear,finish_time)]

performancemodel <- performancemodel[!is.na(rating)]

trainset <- performancemodel[raceyear != 2016]
testset <- performancemodel[raceyear == 2016]

fitControl <- trainControl(
  method = "oob", verboseIter = TRUE
  )

rffit <- train(finish_time ~ ., data = trainset, method = "rf", trControl = fitControl, tuneGrid = data.frame(mtry = c(2,6,10,14,17)))


