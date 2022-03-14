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



load(file="scentop50_PCA500_patience2_dropout20_2layerx100_layeradd/finaldata.Rdata")

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


modelpredictnmod <- function(scen){
  intermediate_output <- sweep(intermediate_output_pol, 2, intermediate_output_scen[scen,], "+")
  predicted <- finalmodel%>%predict(intermediate_output,batch_size=numpol)
}

modelpredict <- function(modelfile,scen){
  currentmodel <- load_model_hdf5(modelfile,compile=FALSE)
  
  finalmodel <- keras_model(inputs = get_layer(currentmodel, index=5)$output,
                            outputs = currentmodel$output)
  
  intermediate_output <- sweep(intermediate_output_pol, 2, intermediate_output_scen[scen,], "+")
  predicted <- finalmodel%>%predict(intermediate_output,batch_size=numpol)  
  
  
}


nummodel <- 10
ptm <- proc.time()
for (i in 1:nummodel){
  #iter <- smallestIter[i]
  modelfile <- paste("scentop50_PCA500_patience2_dropout20_2layerx100_layeradd/model",i,".h5",sep="")  
  currentmodel <- load_model_hdf5(modelfile,compile=FALSE)
  
  intermediate_layer_model_scen <- keras_model(inputs = get_layer(currentmodel, index=3)$input,
                                               outputs = get_layer(currentmodel, index=3)$output)
  intermediate_layer_model_pol <- keras_model(inputs = get_layer(currentmodel, index=4)$input,
                                              outputs = get_layer(currentmodel, index=4)$output)
  finalmodel <- keras_model(inputs = get_layer(currentmodel, index=5)$output,
                            outputs = currentmodel$output)
  intermediate_output_scen <- intermediate_layer_model_scen%>%predict(scendata)
  intermediate_output_pol <- intermediate_layer_model_pol%>%predict(as.matrix(poldata))
  
  
  cl <- parallel::makeCluster(20)
  doParallel::registerDoParallel(cl)
  clusterExport(cl=cl, varlist=c("alldata_NN","scendata","allscensize","numvar",
                                 "poldata","numpol","intermediate_output_scen",
                                 "intermediate_output_pol"),envir = .GlobalEnv)
  ## load the libraries inside the cluste
  clusterEvalQ(cl,  library(keras))
  
  # currentmodel <- load_model_hdf5(modelfile,compile=FALSE)
  #currentmodel <- model_local
  # result <- sapply(1:10000,modelpredictnmod)
  result <- parSapply(cl,scentop50,FUN=modelpredict, modelfile=modelfile)
  parallel::stopCluster(cl)
  
  
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
  
 
  save(testerr,testRMSE,testWS2,pvalueKS,errFMV, errquant95,errCTE70,
       errCTE90, errCTE95, errCTE995, errquant995,errquant90,errquant70, file="scentop50_PCA500_patience2_dropout20_2layerx100_layeradd/finalresult10000.Rdata")
}
# save(testerr,errFMV, errquant,errCTE,errquant995,errquant90,errquant70, file="convoneuraldropout/finalresult500fourier.Rdata")

save(result, file="scentop50_PCA500_patience2_dropout20_2layerx100_layeradd/individualresult10000.Rdata")

# Stop the clock
proc.time() - ptm 

# 
load(file="scentop50_PCA500_patience2_dropout20_2layerx100_layeradd/finalresult10000.Rdata")

vec <- c(1,2,3)
vec <- which(abs(testerr)<0.005)
vec <- sort(abs(testerr), index.return=TRUE)$ix[1:5]
vec <- c(1,2,3,4,5)
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



