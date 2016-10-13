library(data.table)
library(caret)

performancesdt <- fread("performancesclean.csv")
performancemodel <- performancesdt[,list(race_no,going,rating,winning_odds,actual_weight,on_date_weight,draw,race_class,distance,course,race_location,track,raceday,racemonth,raceyear,finish_time)]

performancemodel <- performancemodel[!is.na(rating)]

trainset <- performancemodel[raceyear != 2016]
testset <- performancemodel[raceyear == 2016]

fitControl <- trainControl(
  method = "oob", verboseIter = TRUE
  )

rffit <- train(finish_time ~ ., data = trainset, method = "rf", trControl = fitControl, tuneGrid = data.frame(mtry = c(5,15)), nodesize = 5)

trainpredict <- predict(rffit, trainset)
testpredict <- predict(rffit, testset)
trainset$predtime <- trainpredict
testset$predtime <- testpredict

write.csv(trainset, file = "trainset.csv", row.names = FALSE)
write.csv(testset, file = "testset.csv", row.names = FALSE)

trainset[,predrank := rank(predtime, ties.method = "random"), by=list(race_no, raceday, racemonth, raceyear)]
setnames(testset, "pred", "predtime")
testset[,predrank := rank(predtime, ties.method = "random"), by=list(race_no, raceday, racemonth, raceyear)]

trainmore <- merge(trainset, performancesdt, by = intersect(names(trainset), names(performancesdt)), all.x = TRUE)
testmore <- merge(testset, performancesdt, by = intersect(names(testset), names(performancesdt)), all.x = TRUE)

# betting strategy... profit?
testbet <- testmore[predrank == 1]
testbet[,profit := ifelse(final_placing == 1 & !is.na(final_placing), winning_odds, -1)]
testtotalprofit <- testbet[,sum(profit)] # PROFIT!

# what's going on?
testtest <- testbet[order(winning_odds),list(profit=sum(profit)),by=winning_odds]
