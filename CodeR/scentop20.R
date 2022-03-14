setwd("/srv/scratch/z5238225/VariableAnnuitiesparallel")

library(dbscan)
library(funHDDC)
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



load(file="PCA500/finaldata.Rdata")
numpol <- nrow(alldata_NN)
poldata <- alldata_NN[,-1]
dim(trainy)
load(file="PCA500_patience2_dropout20_2layerx100/finalresult10000.Rdata")

load(file="PCA500_patience2_dropout20_2layerx100/individualresult10000.Rdata")

# load(file="mfpcanewfdbasis_patience5_dropout20_3layer/individualresult10000.Rdata")

fmvpredicted <- rowSums(result)/ncol(result)
fmvactual <- FMVallpol
###############
errFMV <- c(errFMV,(sum(fmvpredicted)-sum(fmvactual))/sum(fmvactual))
predictedpayoffallscen <- colSums(result)
quantpredicted20 <- quantile(predictedpayoffallscen,0.80)
scentop20 <- which(predictedpayoffallscen>=quantpredicted20)


traindata_NN <- traindata_NN_original[traindata_NN_original$Scenario %in% scentop20,]
testdata_NN <- testdata_NN_original[testdata_NN_original$Scenario %in% scentop20,]

traindata_NN <- merge(traindata_NN,scenario_pca,by.x="Scenario",by.y="Scenario")
testdata_NN <- merge(testdata_NN,scenario_pca,by.x="Scenario",by.y="Scenario")

names(traindata_NN)
head(traindata_NN[,1:50])

traindata_NN <- as.matrix(traindata_NN)
testdata_NN <- as.matrix(testdata_NN)

numvar <- ncol(traindata_NN)-3
# 
################################
##################################
##################################
#####################################
################################
##################################
##################################
##################################### Keras tuner 
##Feedforward
#summary(model)
trainx <- traindata_NN[,-c(1,2,3)]
trainx <- array_reshape(trainx,c(nrow(trainx),ncol(trainx)))
trainy <- traindata_NN[,3] %>% as.matrix()
testx <- as.matrix(testdata_NN[,-c(1,2,3)])
testx <- array_reshape(testx,c(nrow(testx),ncol(testx)))
testy <- testdata_NN[,3] %>% as.matrix()

losses <- c(keras::loss_mean_absolute_percentage_error,  
            keras::loss_mean_absolute_error,
            keras::loss_mean_squared_error,
            keras::loss_mean_squared_logarithmic_error)



##############################
###############################
################################


scendata <- scenario_pca[1:allscensize , !(names(scenario_pca) %in% c("Scenario"))]
scendata <- array_reshape(as.matrix(scendata), c(nrow(scendata), ncol(scendata)))


setwd("/srv/scratch/z5238225/VariableAnnuitiesparallel")
save(scentop20,traindata_NN,testdata_NN,scenario_pca,FMVallpol,payoffallscen, alldata_NN, scendata, trainx,trainy,
     testx,testy,allpol,allscensize,numvar,file="scentop20_PCA500_patience2_dropout20_2layerx100/finaldata.Rdata")





