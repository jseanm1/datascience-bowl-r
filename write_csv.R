library(randomForest)

cat("loading plankton model...\n")
load("plankton_model_700.Rdata")
cat("pkankton_model.data loaded\n")

cat("loading test data...\n")
load("test_data.Rdata")
cat("test data loaded\n")

cat("Making predictions...\n")
## Make predictions with class probabilities
test_pred <- predict(plankton_model, test_data, type="prob")
ymin <- 1/1000
test_pred[test_pred<ymin] <- ymin
cat("Predictions made\n")

## ==============================
## Save Submission File
## ==============================
cat("creating csv file...\n")
## Combine image filename and class predictions, then save as csv
submission <- cbind(image = test_data$fileName, test_pred)
submission_filename <- "./results/submission.csv"
write.csv(submission, submission_filename, row.names = FALSE)
cat("saved submission file", '\n')
