setwd("/srv/scratch/z5238225/VariableAnnuitiesparallel")

#source("functionalPCANN.R")

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
library(FNN)
library(transport)
library(dgof)
library(WRS2)

# load(file="fourier500/finaldata.Rdata")
load(file="PCA500/finaldata.Rdata")
numvaroriginal <- numvar
numvar <- 50
numscenvar <- ncol(scendata)
numpolvar <- numvaroriginal-numscenvar
numpol <- nrow(alldata_NN)
poldata <- alldata_NN[,-1]

testerr <- c()
testRMSE <- c()
testWS2 <- c()
# testKL <- c()
# testKS_P <- c() #p-value
# testKS_D <- c() #Statistic
for(iter in 1:10) {
  # sess <-  tf$compat$v1$Session()
  # 
  # tf$compat$v1$keras$backend$set_session(sess)
  modelfile <- paste("PCA500_patience2_dropout20_2layerx100_layeradd/model",iter,".h5",sep="")  
  tempmodel <- load_model_hdf5(modelfile,compile=FALSE)
  testy_pred <- tempmodel %>% predict(list(testx[,(numpolvar+1):numvaroriginal],testx[,1:numpolvar]))
  
  err <- sum(testy_pred)/sum(testy)-1
  err_RMSE <- sqrt(mean((testy - testy_pred)^2))
  testerr <- c(testerr,err)
  testRMSE <- c(testRMSE,err_RMSE)
  
  testWS2 <- c(testWS2, wasserstein1d(testy, testy_pred, p=2))
  
  # err_KL <- KL.divergence(testy,testy_pred,k=ceiling(sqrt(length(testy))))
  # testKL <- c(testKL,  mean(as.numeric(grep('^-?[0-9.]+$', err_KL, val = T))))

  # res <- ks.test(jitter(testy),jitter(testy_pred))
  # testKS_P <- c(testKS_P,res$p.value)
  # testKS_D <- c(testKS_D,res$statistic)
  
}


# Dqcomhd(testy,testy_pred,q = c(1:9)/10)
hist(testerr)

