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



load(file="PCA500/finaldata.Rdata")
numpol <- nrow(alldata_NN)
poldata <- alldata_NN[,-1]
dim(trainy)

errFMV <- c()
errquant70 <- c()
errquant90 <- c()
errquant95 <- c()
errquant995 <- c()
errCTE70 <- c()
errCTE90 <- c()
errCTE95 <- c()
errCTE995 <- c()
pvalueKS <- c()

# errFMVv2 <- errFMV
# errCTEv2 <- errCTE
# errquant70v2 <-errquant70
# errquant90v2 <- errquant90
# errquant95v2 <- errquant95
# errquant995v2 <- errquant995
# pvalueKSv2 <- pvalueKS
# 
# errFMV <- c(errFMVv2,errFMV)
# errCTE <- c(errCTEv2,errCTE)
# errquant70 <- c(errquant70v2, errquant70)
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
  
  predicted <- currentmodel %>%predict(rowdata,batch_size=numpol) 
  
}


modelfile <- paste("PCA500_patience2_dropout20_2layerx50/model",1,".h5",sep="") 
currentmodel <- load_model_hdf5(modelfile,compile=TRUE)

ptm <- proc.time()
result <- sapply(1:10000,modelpredictnmod)
proc.time()-ptm


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
  modelfile <- paste("PCA500_patience2_dropout20_2layerx50/model",i,".h5",sep="")  
  
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
  result <- parSapply(cl,1:10000,FUN=modelpredict, modelfile=modelfile)

  fmvpredicted <- rowSums(result)/ncol(result)
  fmvactual <- FMVallpol
  ###############
  errFMV <- c(errFMV,(sum(fmvpredicted)-sum(fmvactual))/sum(fmvactual))
  
  predictedpayoffallscen <- colSums(result)
  
  res_KSscen <- ks.test(predictedpayoffallscen, payoffallscen)
  pvalueKS <- c(pvalueKS,res_KSscen$p.value)
  
  
  
  ###Calculate quantile 95% and CTE 95%
  quantpredicted95 <- quantile(predictedpayoffallscen,0.95)
  quantactual95 <- quantile(payoffallscen,0.95)
  errquant95 <- c(errquant95,(quantpredicted95-quantactual95)/quantactual95)
  
  CTE95predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted95)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted95)])
  CTE95actual <- sum(payoffallscen[which(payoffallscen>=quantactual95)])/length(payoffallscen[which(payoffallscen>=quantactual95)])
  errCTE95 <- c(errCTE95,(CTE95predicted-CTE95actual)/CTE95actual)
  
  ##70
  quantpredicted70 <- quantile(predictedpayoffallscen,0.70)
  quantactual70 <- quantile(payoffallscen,0.70)
  errquant70 <- c(errquant70,(quantpredicted70-quantactual70)/quantactual70)
  
  CTE70predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted70)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted70)])
  CTE70actual <- sum(payoffallscen[which(payoffallscen>=quantactual70)])/length(payoffallscen[which(payoffallscen>=quantactual70)])
  errCTE70 <- c(errCTE70,(CTE70predicted-CTE70actual)/CTE70actual)
  
  ##90
  quantpredicted90 <- quantile(predictedpayoffallscen,0.90)
  quantactual90 <- quantile(payoffallscen,0.90)
  errquant90 <- c(errquant90,(quantpredicted90-quantactual90)/quantactual90)
  
  CTE90predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted90)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted90)])
  CTE90actual <- sum(payoffallscen[which(payoffallscen>=quantactual90)])/length(payoffallscen[which(payoffallscen>=quantactual90)])
  errCTE90 <- c(errCTE90,(CTE90predicted-CTE90actual)/CTE90actual)
  
  ##99.5
  quantpredicted995 <- quantile(predictedpayoffallscen,0.995)
  quantactual995 <- quantile(payoffallscen,0.995)
  errquant995 <- c(errquant995,(quantpredicted995-quantactual995)/quantactual995)
  
  CTE995predicted <- sum(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted995)])/length(predictedpayoffallscen[which(predictedpayoffallscen>=quantpredicted995)])
  CTE995actual <- sum(payoffallscen[which(payoffallscen>=quantactual995)])/length(payoffallscen[which(payoffallscen>=quantactual995)])
  errCTE995 <- c(errCTE995,(CTE995predicted-CTE995actual)/CTE995actual)
  
 
  save(testerr,testRMSE,testWS2,pvalueKS,errFMV, errquant95,errCTE70,
       errCTE90, errCTE95, errCTE995, errquant995,errquant90,errquant70, file="PCA500_patience2_dropout20_2layerx50/finalresult10000.Rdata")
}
 save(testerr,testRMSE,testWS2,pvalueKS,errFMV, errquant95,errCTE70,
      errCTE90, errCTE95, errCTE995, errquant995,errquant90,errquant70, file="PCA500_patience2_dropout20_2layerx50/finalresult10000.Rdata")

 save(result, file="PCA500_patience2_dropout20_2layerx50/individualresult10000.Rdata")

# Stop the clock
time <- proc.time() - ptm 
save(time, testerr,testRMSE,testWS2,pvalueKS,errFMV, errquant95,errCTE70,
     errCTE90, errCTE95, errCTE995, errquant995,errquant90,errquant70, file="PCA500_patience2_dropout20_2layerx50/finalresult10000.Rdata")


parallel::stopCluster(cl)


# 
load(file="PCA500_patience2_dropout20_2layerx50/finalresult10000.Rdata")



vec <- c(1,2,3)
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



#PCA500_patience2_dropout20_2layerx50: 5.6 hours (actual 4.2 hours)
