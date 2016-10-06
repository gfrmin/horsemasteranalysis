library(data.table)
library(sparklyr)
library(rsparkling)
library(dplyr)

sc <- spark_connect("local", version = "1.6.2")
h2o.init(nthreads=-1)

performancesdt <- spark_read_csv(sc, "performancesdtclean", "performancesdtclean.csv") 
performancemodel <- performancesdt %>% select(race_no,going,rating,winning_odds,actual_weight,on_date_weight,draw,race_class,distance,course,race_location,track,raceday,racemonth,raceyear,finish_time)
performancemodel <- performancemodel %>% filter(!is.na(rating))

trainset <- performancemodel %>% filter(raceyear != 2016)
testset <- performancemodel %>% filter(raceyear == 2016)

trainframe <- as_h2o_frame(sc, trainset)
testframe <- as_h2o_frame(sc, testset)

convfactor <- function(h2oframe) {
  stringcols <- colnames(h2oframe)[which(unlist(attr(h2oframe, "types")) == "string")]
  for (stringcol in stringcols) {
    h2oframe[,stringcol] <- as.factor(h2oframe[,stringcol])
  }
  return(h2oframe)
}

trainframe <- convfactor(trainframe)
testframe <- convfactor(testframe)

rffit <- h2o.randomForest(x = colnames(trainframe)[-16], y = colnames(trainframe)[16], training_frame = trainframe, validation_frame = testframe, min_rows = 50, mtries = 15)

trainpredict <- h2o.predict(rffit, trainframe)
testpredict <- h2o.predict(rffit, testframe)
trainset$pred <- trainpredict
testset$pred <- testpredict

write.csv(trainset, file = "trainset.csv", row.names = FALSE)
write.csv(testset, file = "testset.csv", row.names = FALSE)
