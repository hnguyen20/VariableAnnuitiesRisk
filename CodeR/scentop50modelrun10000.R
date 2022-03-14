#Model 31-40: 500 Fourier PCA
setwd("/srv/scratch/z5238225/VariableAnnuitiesparallel")

#source("functionalPCANN.R")

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



load(file="scentop50_PCA500_patience2_dropout20_2layerx50/finaldata.Rdata")

numpol <- nrow(alldata_NN)
poldata <- alldata_NN[,-1]
dim(trainy)

errFMV <- c()
errCTE70 <- c()
errCTE90 <- c()
errCTE95 <- c()
errCTE995 <- c()
errquant70 <- c()
errquant90 <- c()
errquant95 <- c()
errquant995 <- c()
pvalueKS <- c()
# 
# errFMVv2 <- errFMV
# errCTEv2 <- errCTE
# errquant70v2 <-errquant70
# errquant90v2 <- errquant90
# errquant95v2 <- errquant95
# errquant995v2 <- errquant995
# pvalueKSv2 <- pvalueKS

# errFMV <- c(errFMVv2,errFMV)
# errCTE <- c(errCTEv2,errCTE)
# errquant70 <- c(errquant70v2,errquant70)
# errquant90 <- c(errquant90v2,errquant90)
# errquant95 <- c(errquant95v2,errquant95)
# errquant995 <- c(errquant995v2,errquant995)
# pvalueKS <- c(pvalueKSv2,pvalueKS)



modelpredict <- function(modelfile,scen){
  rowdata <- as.matrix(cbind(poldata,t(scendata[scen,])))
  currentmodel <- load_model_hdf5(modelfile,compile=FALSE)
  
  
  predicted <- currentmodel %>%predict(rowdata,batch_size=numpol) 
  
  
  
}

modelpredictnmod <- function(scen){

  rowdata <- as.matrix(cbind(poldata,t(scendata[scen,])))
  
  predicted <- currentmodel %>%predict(rowdata,batch_size=1000)
}


# modelfile <- paste("PCA500_patience2_dropout20_2layerx50/model",2,".h5",sep="") 
modelfile <- paste("scentop50_PCA500_patience2_dropout20_2layerx50/model",1,".h5",sep="") 

currentmodel <- load_model_hdf5(modelfile,compile=FALSE)
ptm <- proc.time()
result <- sapply(1:10,modelpredictnmod)
proc.time()-ptm

ptm <- proc.time()
result <-  modelpredictnmod(1)
proc.time()-ptm


ptm <- proc.time()
predicted <- currentmodel %>%predict(rowdata,batch_size=numpol)
proc.time()-ptm

# rowdata <- as.matrix(cbind(poldata,t(scendata[1,])))
# rowdata <- as.matrix(cbind(poldata[1:10000],t(scendata[1,])))

for (i in 1:5){
  rowdata <- as.matrix(rbind(rowdata,rowdata))
}
dim(rowdata)
modelfile <- paste("PCA500_patience2_dropout20_2layerx50/model",1,".h5",sep="")  
# model.save_weights() and model.load_weights().
currentmodel <- load_model_hdf5(modelfile,compile=FALSE)



dim(rowdata)
ptm <- proc.time()
result <-  modelpredictnmod(1)
proc.time()-ptm

#5.7 hours 342min  742 min 12.3 hours


# registering clusters
cl <- parallel::makeCluster(20)
doParallel::registerDoParallel(cl)
clusterExport(cl=cl, varlist=c("alldata_NN","scendata","allscensize","numvar",
                               "poldata","numpol"),envir = .GlobalEnv)
## load the libraries inside the cluste
clusterEvalQ(cl,  library(keras))



nummodel <- 10
ptm <- proc.time()
for (i in 1:nummodel){
  #iter <- smallestIter[i]
  modelfile <- paste("scentop50_PCA500_patience2_dropout20_2layerx50/model",i,".h5",sep="")  
  
  # modelfile <- "convoneuraldropout/tempmodel32.h5"  
  ## Serialize the model and export it as a RAW vector
  # serialized_model=serialize_model(model)
  # tmp <- tempfile(pattern = paste("model",i,sep=""))
  # saveRDS(serialized_model,tmp)
  ## Model can be recovered just fine from an RDS file
  
  #result <- parSapply(cl,1:1000,FUN=modelpredict, modelfile=modelfile)
  # currentmodel <- load_model_hdf5(modelfile,compile=FALSE)
  #currentmodel <- model_local
  # result <- sapply(1:1000,modelpredictnmod)
  ptm <- proc.time()
  
  result <- parSapply(cl,scentop50,FUN=modelpredict, modelfile=modelfile)
  ptm - proc.time()
  
  # save(result, file=paste("convoneuraldropout/scenresult500rep_5filter",i,".Rdata",sep=""))
  
  fmvpredicted <- rowSums(result)/ncol(result)
  fmvactual <- FMVallpol
  ###############
  errFMV <- c(errFMV,(sum(fmvpredicted)-sum(fmvactual))/sum(fmvactual))
  
  predictedpayoffallscen <- colSums(result)
  
  res_KSscen <- ks.test(predictedpayoffallscen, payoffallscen[scentop50])
  pvalueKS <- c(pvalueKS,res_KSscen$p.value)
  
  # sortedquantilepredicted <- sort(quantilepredicted)
  # sortedquantilepredicted[951]
  # which(quantilepredicted == sortedquantilepredicted[951])
  # quantileactual[10]
  # quantilepredicted[10]
  # hist(quantilepredicted/quantileactual)
  # hist(quantileactual)
  # hist(quantilepredicted)
  
  
  
  
  ###Calculate quantile 95% and CTE 95%
  quantpredicted95 <- quantile(predictedpayoffallscen,(5000-500)/5000)
  quantactual95 <- quantile(payoffallscen,0.95)
  errquant95 <- c(errquant95,(quantpredicted95-quantactual95)/quantactual95)
  
  CTE95predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted95)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted95)])
  CTE95actual <- sum(payoffallscen[which(payoffallscen>=quantactual95)])/length(payoffallscen[which(payoffallscen>=quantactual95)])
  errCTE95 <- c(errCTE95,(CTE95predicted-CTE95actual)/CTE95actual)
  
  ##70
  quantpredicted70 <- quantile(predictedpayoffallscen,(5000-3000)/5000)
  quantactual70 <- quantile(payoffallscen,0.70)
  errquant70 <- c(errquant70,(quantpredicted70-quantactual70)/quantactual70)
  
  CTE70predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted70)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted70)])
  CTE70actual <- sum(payoffallscen[which(payoffallscen>=quantactual70)])/length(payoffallscen[which(payoffallscen>=quantactual70)])
  errCTE70 <- c(errCTE70,(CTE70predicted-CTE70actual)/CTE70actual)
  
  ##90
  quantpredicted90 <- quantile(predictedpayoffallscen,(5000-1000)/5000)
  quantactual90 <- quantile(payoffallscen,0.90)
  errquant90 <- c(errquant90,(quantpredicted90-quantactual90)/quantactual90)
  
  CTE90predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted90)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted90)])
  CTE90actual <- sum(payoffallscen[which(payoffallscen>=quantactual90)])/length(payoffallscen[which(payoffallscen>=quantactual90)])
  errCTE90 <- c(errCTE90,(CTE90predicted-CTE90actual)/CTE90actual)
  
  ##99.5
  quantpredicted995 <- quantile(predictedpayoffallscen,(5000-50)/5000)
  quantactual995 <- quantile(payoffallscen,0.995)
  errquant995 <- c(errquant995,(quantpredicted995-quantactual995)/quantactual995)
  
  CTE995predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted995)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted995)])
  CTE995actual <- sum(payoffallscen[which(payoffallscen>=quantactual995)])/length(payoffallscen[which(payoffallscen>=quantactual995)])
  errCTE995 <- c(errCTE995,(CTE995predicted-CTE995actual)/CTE995actual)
  
  # 
  #   
  #   numobs <- length(predictedpayoffallscen)
  #   sorted_predscen <- sort(predictedpayoffallscen, index.return=TRUE)$ix
  #   sorted_scen <- sort(payoffallscen, index.return=TRUE)$ix
  #   #70%
  #   scenquantselect <- numobs * 0.7
  #   quantpredicted70_v1 <- predictedpayoffallscen[sorted_predscen[scenquantselect]]
  #   quantactual70 <- payoffallscen[sorted_scen[scenquantselect]]
  #   
  # 
  #   scens <- seq(scenquantselect-5,scenquantselect+5)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted70_v2 <- sort(payoffallscen[scensquantpred])[6]
  #   
  #   scens <- seq(scenquantselect-10,scenquantselect+10)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted70_v3 <- sort(payoffallscen[scensquantpred])[11]
  #   
  #   errquant70_v1 <- c(errquant70_v1,(quantpredicted70_v1-quantactual70)/quantactual70)
  #   errquant70_v2 <- c(errquant70_v2,(quantpredicted70_v2-quantactual70)/quantactual70)
  #   errquant70_v3 <- c(errquant70_v3,(quantpredicted70_v3-quantactual70)/quantactual70)
  #   
  #   #90%
  #   scenquantselect <- numobs * 0.9
  #   quantpredicted90_v1 <- predictedpayoffallscen[sorted_predscen[scenquantselect]]
  #   quantactual90 <- payoffallscen[sorted_scen[scenquantselect]]
  #   
  #   
  #   scens <- seq(scenquantselect-5,scenquantselect+5)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted90_v2 <- sort(payoffallscen[scensquantpred])[6]
  #   
  #   scens <- seq(scenquantselect-10,scenquantselect+10)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted90_v3 <- sort(payoffallscen[scensquantpred])[11]
  #   
  #   errquant90_v1 <- c(errquant90_v1,(quantpredicted90_v1-quantactual90)/quantactual90)
  #   errquant90_v2 <- c(errquant90_v2,(quantpredicted90_v2-quantactual90)/quantactual90)
  #   errquant90_v3 <- c(errquant90_v3,(quantpredicted90_v3-quantactual90)/quantactual90)
  #   
  # 
  #   
  #   #95%
  #   scenquantselect <- numobs * 0.95
  #   quantpredicted95_v1 <- predictedpayoffallscen[sorted_predscen[scenquantselect]]
  #   quantactual95 <- payoffallscen[sorted_scen[scenquantselect]]
  #   
  #   
  #   scens <- seq(scenquantselect-5,scenquantselect+5)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted95_v2 <- sort(payoffallscen[scensquantpred])[6]
  #   
  #   scens <- seq(scenquantselect-10,scenquantselect+10)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted95_v3 <- sort(payoffallscen[scensquantpred])[11]
  #   
  #   errquant95_v1 <- c(errquant95_v1,(quantpredicted95_v1-quantactual95)/quantactual95)
  #   errquant95_v2 <- c(errquant95_v2,(quantpredicted95_v2-quantactual95)/quantactual95)
  #   errquant95_v3 <- c(errquant95_v3,(quantpredicted95_v3-quantactual95)/quantactual95)
  #   
  #   
  #   #995%
  #   scenquantselect <- numobs * 0.995
  #   quantpredicted995_v1 <- predictedpayoffallscen[sorted_predscen[scenquantselect]]
  #   quantactual995 <- payoffallscen[sorted_scen[scenquantselect]]
  #   
  #   
  #   scens <- seq(scenquantselect-5,scenquantselect+5)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted995_v2 <- sort(payoffallscen[scensquantpred])[6]
  #   
  #   scens <- seq(scenquantselect-10,scenquantselect+10)
  #   scensquantpred <- sorted_predscen[scens]
  #   scensquant <- sorted_scen[scens]
  #   quantpredicted995_v3 <- sort(payoffallscen[scensquantpred])[11]
  #   
  #   errquant995_v1 <- c(errquant995_v1,(quantpredicted995_v1-quantactual995)/quantactual995)
  #   errquant995_v2 <- c(errquant995_v2,(quantpredicted995_v2-quantactual995)/quantactual995)
  #   errquant995_v3 <- c(errquant995_v3,(quantpredicted995_v3-quantactual995)/quantactual995)
  #   
  #   
  #   
  #   save(testerr,errFMV,errCTE,errquant995_v1,errquant995_v2,errquant995_v3,
  #        errquant95_v1,errquant95_v2,errquant95_v3,errquant90_v1,errquant90_v2,errquant90_v3,
  #        errquant70_v1,errquant70_v2,errquant70_v3, file="convoneuraldropout/finalresult500fourier_v2.Rdata")
  #   
  #   
  save(testerr,testRMSE,testWS2,pvalueKS,errFMV, errquant95,errCTE70,
       errCTE90, errCTE95, errCTE995, errquant995,errquant90,errquant70, file="scentop50_PCA500_patience2_dropout20_2layerx50/finalresult10000.Rdata")
}
# save(testerr,errFMV, errquant,errCTE,errquant995,errquant90,errquant70, file="convoneuraldropout/finalresult500fourier.Rdata")

save(result, file="scentop50_PCA500_patience2_dropout20_2layerx50/individualresult10000.Rdata")

# Stop the clock
proc.time() - ptm 

parallel::stopCluster(cl)
# 
load(file="scentop50_PCA500_patience2_dropout20_2layerx50/finalresult10000.Rdata")
# load(file="convoneuraldropout/finalresult10000.Rdata")
# 
# load(file="scentop50_patience2_dropout20_2layer/finalresult10000.Rdata")
# load(file="scentop50_patience5_dropout20_2layer/finalresult10000.Rdata")

vec <- c(1,2,3)
vec <- which(abs(testerr)<0.005)
vec <- sort(abs(testerr), index.return=TRUE)$ix[1:5]

mean(testerr)
mean(errFMV)
mean(errquant70)
mean(errquant90)
mean(errquant95)
mean(errquant995)
mean(errCTE70)
mean(errCTE90)
mean(errCTE95)
mean(errCTE995)

mean(testerr[vec])
mean(errFMV[vec])
mean(errquant70[vec])
mean(errquant90[vec])
mean(errquant95[vec])
mean(errquant995[vec])
mean(errCTE70[vec])
mean(errCTE90[vec])
mean(errCTE95[vec])
mean(errCTE995[vec])

pvalueKS

#scentop50_PCA500_patience2_dropout20_2layerx100: 4.2-5 hours (actual 2.5 hours)
#scentop50_PCA500_patience2_dropout20_2layerx100: 3.9 hours (2.1-2.6 hours)



