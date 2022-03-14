setwd("/srv/scratch/z5238225/VariableAnnuitiesparallel")
library(dbscan)
# library(funHDDC)
library(neuralnet)
library(nnet)
library(dplyr)
library(plyr)
library(keras)
library(tidyverse)
#library(kerastuneR)
library(plotly)
library(clhs)
library(readr)
library(data.table)
library(foreach)
library(parallel)
library(tfaddons)
library(tfdatasets)
# tfaddons::install_tfaddons()


#load(file="convoneural/finaldata.Rdata")
load(file="scentop50_PCA500_patience2_dropout20_2layerx50/finaldatatop50.Rdata")
numvaroriginal <- numvar
numvar <- 50
numpol <- nrow(alldata_NN)
poldata <- alldata_NN[,-1]
names(alldata_NN)


early_stop <- callback_early_stopping(monitor = "val_loss", 
                                      min_delta = 0.1, 
                                      patience = 2,
                                      restore_best_weights = TRUE,
                                      verbose = 0)


losses <- c(keras::loss_mean_absolute_percentage_error,  
            keras::loss_mean_absolute_error,
            keras::loss_mean_squared_error,
            keras::loss_mean_squared_logarithmic_error)

# opt = tf$keras$optimizers$SGD(0.0001)
# opt = optimizer_swa(opt, start_averaging=10, average_period=10)
# 

tempmodels <- list()
for(i in 1:10){
  
  tempmodels[[i]] <- keras_model_sequential() 
  
  tempmodels[[i]] %>% 
    layer_dense(units = numvar, activation = "relu", input_shape = numvaroriginal) %>% 
    layer_dropout(rate=0.2)%>%
    layer_dense(units = numvar, activation = "relu") %>%
    layer_dropout(rate=0.2)%>%
    layer_dense(units = 1)
  
  # tempmodel[[i]] %>% compile(
  #   loss = "MSE",
  #   optimizer= optimizer_sgd(lr=0.01)
  # )
  tempmodels[[i]] %>% compile(
    optimizer = "rmsprop",
    loss = losses[3],
    metrics = c("mse")
  )
}


tempmodels <- lapply(tempmodels, keras::serialize_model)
# tempmodel <- tempmodels[[1]]
# 
# tempmodel <- keras_model_sequential() 
# 
# tempmodel %>% 
#   layer_dense(units = numvar/2, activation = "relu", input_shape = numvar) %>% 
#   # layer_dropout(rate=0.5)%>%
#   layer_dense(units = numvar/2, activation = "relu") %>%
#   # layer_dense(units = numvar/2, activation = "relu") %>%
#   # layer_dropout(rate=0.5)%>%
#   # layer_dense(units = numvar, activation = "relu") %>% 
#   # layer_dropout(rate=0.5)%>%
#   layer_dense(units = 1)
# 
# # tempmodel[[i]] %>% compile(
# #   loss = "MSE",
# #   optimizer= optimizer_sgd(lr=0.01)
# # )
# tempmodel %>% compile(
#   optimizer = "rmsprop",
#   loss = losses[3],
#   metrics = c("mse")
# )

cl<-makeCluster(10)
doParallel::registerDoParallel(cl)
# rstudioapi::restartSession()
clusterExport(cl=cl, varlist=c("trainx","trainy","testx","testy"),envir = .GlobalEnv)
## load the libraries inside the cluste
clusterEvalQ(cl,  library(keras))

# Start the clock!
ptm <- proc.time()
result <- foreach (tempmodel = tempmodels,.packages=c("keras"))  %dopar% {
  # 
  # tempmodel <-  clone_model(bestmodel) 
  # tempmodel %>% compile(
  #   optimizer = "rmsprop",
  #   loss = losses[3],
  #   metrics = c("mse")
  # )
  early_stop <- callback_early_stopping(monitor = "val_loss", 
                                        min_delta = 0.1, 
                                        patience = 2,
                                        restore_best_weights = TRUE,
                                        verbose = 0)
  
  
  losses <- c(keras::loss_mean_absolute_percentage_error,  
              keras::loss_mean_absolute_error,
              keras::loss_mean_squared_error,
              keras::loss_mean_squared_logarithmic_error)
  model_local <- keras::unserialize_model(tempmodel)
  model_local  %>% fit(
    trainx,
    trainy,
    epochs = 500,
    batch_size = 128,
    verbose = 1,
    validation_split = 0.2,
    callbacks = list(
      early_stop)
  )
  # quantileseq <- c(seq(0.05,0.99,0.01),0.995)
  # testy_pred <- model_local %>% predict(testx)
  # err_ave <- abs(sum(testy_pred)/sum(testy)-1)
  # quantileerr <- quantile(testy_pred,quantileseq)/quantile(testy,quantileseq)
  # quantileerr <- abs(quantileerr-1)
  # err_quant <- max(quantileerr)
  # errtemp <- err_ave
  # testerr <- c(testerr,errtemp)
  # model_local %>% save_model_hdf5(paste("fourier500/tempmodel",iter,".h5",sep=""))
  keras::serialize_model(model_local)
  
}
proc.time() - ptm  
parallel::stopCluster(cl)

for (iter in 1:10){
  localmodel <- keras::unserialize_model(result[[iter]])
  localmodel %>% save_model_hdf5(paste("scentop50_PCA500_patience2_dropout20_2layerx50/model",iter,".h5",sep=""))
}

#scentop50_PCA500_patience2_dropout20_2layerx100-16 minutes
#scentop50_PCA500_patience2_dropout20_2layerx50-11 minutes
