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
load(file="PCA500/finaldata.Rdata")

# h <- hist(payoffallscen,main="Distribution of portfolio liability over 10,000 scenarios")
# plot(h, xlab = "Portfolio net liability", ylab = "Frequency",
#       col = "pink")
# hist(payoffallscen,main=NULL,
#      xlab = "Portfolio net liability", ylab = "Frequency",
#      col = "pink")

numvaroriginal <- numvar
numvar <- 300
numscenvar <- ncol(scendata)
numpolvar <- numvaroriginal-numscenvar
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

# 
scenmodel <- keras_model_sequential()
scenmodel %>%
  layer_dense(units = numvar, input_shape = numscenvar)
polmodel <- keras_model_sequential()
polmodel %>%
  layer_dense(units = numvar, input_shape = numpolvar)
inputscen <- layer_input(c(numscenvar))
inputpol <- layer_input(c(numpolvar))
outputscen <- inputscen %>% scenmodel
outputpol <- inputpol %>% polmodel
inputlayer <- activation_relu(layer_add(list(outputscen, outputpol)))
tempmodel <-  keras_model_sequential()
tempmodel %>% layer_dropout(rate=0.2,input_shape = numvar)%>%
  layer_dense(units = numvar, activation = "relu") %>%
  layer_dropout(rate=0.2)%>%
  layer_dense(units = numvar, activation = "relu") %>%
  layer_dropout(rate=0.2)%>%
  layer_dense(units = 1)
output <- inputlayer%>%tempmodel
model <-  keras_model( list(inputscen , inputpol) , output )
model %>% compile(
  optimizer = "rmsprop",
  loss = losses[3],
  metrics = c("mse")
)
model %>% get_layer()
model  %>% fit(
  list(trainx[,(numpolvar+1):numvaroriginal],trainx[,1:numpolvar]),
  trainy,
  epochs = 100,
  batch_size = 128,
  verbose = 1,
  validation_split = 0.2,
  callbacks = list(
    early_stop)
)
# model %>% save_model_hdf5("PCA500_patience2_dropout20_2layerx50_layeradd/model1.h5")
# model3 <- load_model_hdf5("PCA500_patience2_dropout20_2layerx50_layeradd/model1.h5",compile=FALSE)


tempmodels <- list()
for(i in 1:10){
  
  scenmodel <- keras_model_sequential() 
  scenmodel %>% 
    layer_dense(units = numvar, input_shape = numscenvar) 
  polmodel <- keras_model_sequential() 
  polmodel %>% 
    layer_dense(units = numvar, input_shape = numpolvar) 
  inputscen <- layer_input(c(numscenvar))
  inputpol <- layer_input(c(numpolvar))
  outputscen <- inputscen %>% scenmodel
  outputpol <- inputpol %>% polmodel
  inputlayer <- activation_relu(layer_add(list(outputscen, outputpol)))
  

  tempmod <- keras_model_sequential() 
  
  tempmod %>% layer_dropout(rate=0.2,input_shape = numvar)%>%
    layer_dense(units = numvar, activation = "relu") %>% 
    layer_dropout(rate=0.2)%>%
    layer_dense(units = 1)
  
  output <- inputlayer%>%tempmod
  tempmodels[[i]] <-  keras_model( list(inputscen , inputpol) , output )
  tempmodels[[i]] %>% compile(
    optimizer = "rmsprop",
    loss = losses[3],
    metrics = c("mse")
  )
  
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
    list(trainx[,(numpolvar+1):numvaroriginal],trainx[,1:numpolvar]),
    trainy,
    epochs = 500,
    batch_size = 128,
    verbose = 1,
    validation_split = 0.2,
    callbacks = list(
      early_stop)
  )
  keras::serialize_model(model_local)
  
}
proc.time() - ptm  
hist(testerr)
parallel::stopCluster(cl)

for (iter in 1:10){
  localmodel <- keras::unserialize_model(result[[iter]])
  localmodel %>% save_model_hdf5(paste("PCA500_patience2_dropout20_2layerx50_layeradd/model",iter,".h5",sep=""))
}

#PCA500_patience2_dropout20_2layerx50_layeradd: 52 minutes
