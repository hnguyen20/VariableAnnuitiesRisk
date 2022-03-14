setwd("/srv/scratch/z5238225/VariableAnnuitiesparallel")
#install_keras()
# library(tensorflow)
# install_tensorflow()

library(dbscan)
library(neuralnet)
library(nnet)
library(dplyr)
library(plyr)
library(keras)
library(tidyverse)
library(kerastuneR)
library(plotly)
library(clhs)
library(readr)
library(data.table)
library(fda)
library(MFPCA)


#kerastuneR::install_kerastuner(python_path = 'C:/Users/hangn/Anaconda3')

#memory.limit(size=1800000)

normalize <- function(x) {
  if (max(x) == min(x)){
    return (x)
  }
  return ((x - min(x)) / (max(x) - min(x)))
  
}
##################
##################Reloading previous saved file so can skip to the following line:
# traindata_NN <- traindata_NN_original
# testdata_NN <- testdata_NN_original
## Used to recreate a new dataset with a different number of PCA for MPCA
########Skip to recreat the dataset file from scratch
load(file="PCA500/finaldata.Rdata")

scenariofolder <-  "~/VariableAnnuitiesparallel/src/Result/inforcevaluation/RW10000/"
file_FixedIncome <-  paste(scenariofolder ,"base/FixedIncome.csv", sep = "")
file_IntlEquity <-  paste(scenariofolder, "base/IntlEquity.csv", sep = "")
file_LargeCapEquity <-  paste(scenariofolder, "base/LargeCapEquity.csv", sep = "")
file_SmallCapEquity <-  paste(scenariofolder, "base/SmallCapEquity.csv", sep = "")
file_Money <-  paste(scenariofolder, "base/Money.csv", sep = "")
fixedIncome <- read.csv(file = file_FixedIncome, header = FALSE)
fixedIncome <- fixedIncome[,-1]
intlEquity <- read.csv(file = file_IntlEquity, header = FALSE)
intlEquity <- intlEquity[,-1]
largeCapEquity <- read.csv(file = file_LargeCapEquity, header = FALSE)
largeCapEquity <- largeCapEquity[,-1]
smallCapEquity <- read.csv(file = file_SmallCapEquity, header = FALSE)
smallCapEquity <- smallCapEquity[,-1]
money <- read.csv(file = file_Money, header = FALSE)
money <- money[,-1]

#Scenario Column
allasset_scen <- cbind(largeCapEquity,smallCapEquity,intlEquity,fixedIncome,money)
dim(allasset_scen)
num_pca <- 
  pca_vec1 <- rep("ScenPCA",ncol(allasset_scen))
pca_vec2 <- seq(1,ncol(allasset_scen))
pca_vec <- cbind(pca_vec1,pca_vec2)
pca_vec <- apply(pca_vec,1,paste,collapse="")
head(pca_vec)

dim(allasset_scen)
#allasset_scen <- as.data.frame(lapply(allasset_scen , normalize))
names(allasset_scen) <- pca_vec
allasset_scen$Scenario <- seq(1:10000)


times_basis <- seq(1,360,1)
dim(largeCapEquity)
length(times_basis)
largeCapEquity <- funData(times_basis, as.matrix(largeCapEquity))
smallCapEquity <- funData(times_basis, as.matrix(smallCapEquity))
intlEquity <- funData(times_basis, as.matrix(intlEquity))
fixedIncome <- funData(times_basis, as.matrix(fixedIncome))
money <- funData(times_basis, as.matrix(money))
# pca <- PACE(largeCapEquity,nbasis=50)
# plot(largeCapEquity[1,],xlim=range(c(0,360)),ylim=range(c(0.85,1.2)))
# par(new=TRUE)
# library(fda)
# plot(largeCapEquity, lwd = 2, obs = 1)
# plot(pca$fit,lty = 2, obs = 1)
# legend("bottomright", c("True", "Estimate"), lwd = c(2,1), lty = c(1,2))
# plotfit.fd(largeCapEquity[1,], times_basis, pca$fit[1,])
           


allasset_fd <- multiFunData(largeCapEquity,smallCapEquity,intlEquity,fixedIncome,money)
basis <- create.fourier.basis(c(1,360), nbasis=300)

# res.pca <- MFPCA(allasset_fd, M = 500, uniExpansions = list(list(type = "uFPCA",nbasis=10),
#                                                             list(type = "uFPCA",nbasis=10),list(type = "uFPCA",nbasis=10),
#                                                             list(type = "uFPCA",nbasis=10),list(type = "uFPCA",nbasis=10)))
res.pca <- MFPCA(allasset_fd, M = 500, uniExpansions = list(list(type = "fda",basis),
                                                            list(type = "fda",basis),list(type = "fda",basis),
                                                            list(type = "fda",basis),list(type = "fda",basis)))
dim(res.pca$scores)


#Change number of principle components
num_pca <- ncol(res.pca$scores)
pca_vec1 <- rep("ScenPCA",num_pca)
pca_vec2 <- seq(1,num_pca)
pca_vec <- cbind(pca_vec1,pca_vec2)
pca_vec <- apply(pca_vec,1,paste,collapse="")
scenario_pca <- as.data.frame(res.pca$scores[,1:num_pca])
dim(scenario_pca)
# for (i in 1:10000){
#   scenario_pca[i,] <-  normalize(scenario_pca[i,])
# }
 # scenario_pca <- as.data.frame(lapply(scenario_pca , normalize))
names(scenario_pca) <- pca_vec
# max(res.pca$scores[,500])
# max(res.pca$scores[,1])
max(abs(scenario_pca[,500]))
scenario_pca$Scenario <- seq(1:10000)
dim(scenario_pca)

# rm(largeCapEquity, smallCapEquity,intlEquity,fixedIncome,money)
# rm(largecapmat,smallcapmat,intlmat,fixedincomemat,moneymat)
# rm(largecapfd,smallcapfd,intlfd,fixedincomefd,moneyfd)


save(scenario_pca,file="scenario_pca1000.Rdata")

inforcecluster <- fread(file = "~/VariableAnnuitiesparallel/src/Data/inforce_cluster.csv", header = TRUE)
allpol <- inforcecluster$recordID
inforcecluster <- inforcecluster[,1:33]
# alldata <- merge(alldata,scenario_pca,by.x="Scenario",by.y="Scenario")
# alldata <- merge(alldata,inforcecluster,by.x="recordID",by.y="recordID")
# names(alldata)
# rm(inforcecluster)
# numcol <- length(names(alldata))
# save(alldata,file="Paper2/alldata50PCA.RData")
sapply(inforcecluster,class)
alldata_NN <- inforcecluster
numcolNN <- length(names(alldata_NN))
alldata_NN <- cbind(alldata_NN[, 1:(numcolNN-2)], class.ind(as.factor(alldata_NN$productType)), class.ind(as.factor(alldata_NN$gender)))
head(alldata_NN)
#Remove redundant columns Fund Fee and base Fee (constant throughout)
alldata_NN [,seq(12,22):=NULL]
#Normalize columns
numcolNN <- length(names(alldata_NN))
alldata_NN[,c(numcolNN,numcolNN-2):=NULL] #remove 1 dummy column from each categorical varaible
numcolNN <- length(names(alldata_NN))
names(alldata_NN)
alldata_NN[,2:numcolNN] <- as.data.frame(lapply(alldata_NN[,2:numcolNN] , normalize))
head(alldata_NN)



trainpolsize <- 50000
testpolsize <- 10000
clusterrestrain <- sample(1:nrow(alldata_NN),trainpolsize,replace = FALSE)
trainPols <- alldata_NN$recordID[clusterrestrain]
clusterrestest <- sample(1:(nrow(alldata_NN)-trainpolsize),testpolsize,replace = FALSE)
testPols <- alldata_NN[-clusterrestrain,]$recordID[clusterrestest]
length(unique(testPols))

allscenario <- fread("/srv/scratch/z5238225/VariableAnnuitiesparallel/regPolsfull.csv",  header=TRUE,showProgress = FALSE)

allscensize <- ncol(allscenario)-1

allscenario_train <- allscenario[allscenario$recordID %in% trainPols,]
allscenario_test <- allscenario[allscenario$recordID %in% testPols,]

FMVallpol <- rowSums(allscenario[,2:(allscensize+1)])/allscensize
payoffallscen <- colSums(allscenario[,2:(allscensize+1)])


  allscenario <- fread("/srv/scratch/z5238225/VariableAnnuitiesparallel/regmissingpol.csv",  header=TRUE,showProgress = FALSE)
  
  allscenario_train <- rbind(allscenario_train, allscenario[allscenario$recordID %in% trainPols,])
  allscenario_test <- rbind(allscenario_test, allscenario[allscenario$recordID %in% testPols,])
  
  FMVallpol <- c(FMVallpol,rowSums(allscenario[,2:(allscensize+1)])/allscensize)
  payoffallscen <- payoffallscen+colSums(allscenario[,2:(allscensize+1)])



rm(allscenario)
# 
# trainpolindex <- sample(1:allpolsize, trainpolsize, replace=FALSE)
# testpolindex <- sample(setdiff(1:allpolsize,trainpolindex), testpolsize, replace=FALSE)
# traindata <- alldata_NN[reppolindex,]
# testdata <- alldata_NN[testpolindex,]

trainscensize <-1000000 #must be multiple of total number of scenarios
testscensize <- 100000 #must be multiple of total number of scenarios
if (trainscensize<=allscensize){
  trainscens <- sample(1:allscensize, trainscensize, replace=FALSE)
} else {
  mult <- trainscensize/allscensize
  trainscens <- c()
  for (i in 1:mult){
    trainscens <- c(trainscens,sample(1:allscensize, allscensize, replace=FALSE))
  }
}
if (testscensize<=allscensize){
  testscens <- sample(1:allscensize, testscensize, replace=FALSE)
} else {
  mult <- testscensize/allscensize
  testscens <- c()
  for (i in 1:mult){
    testscens <- c(testscens,sample(1:allscensize, allscensize, replace=FALSE))
  }
}


trainscendiv <- trainscensize/trainpolsize
testscendiv <- testscensize/testpolsize

traindata_NN <- matrix(data=NA,nrow=trainscensize,ncol=3)
testdata_NN <- matrix(data=NA,nrow=testscensize,ncol=3)

iter <- 1
for (i in 1:trainpolsize){
  for (j in 1:trainscendiv){
    scen <- trainscens[(trainscendiv*(i-1)+1):(trainscendiv*(i-1)+trainscendiv)][j]
    temp <- data.frame(recordID=allscenario_train[i,1],Scenario=scen,ScenVal=unlist(allscenario_train[i,scen+1,with=FALSE]) )
    traindata_NN[iter,] <-  t(temp)
    iter <- iter+1
  }
}

iter <- 1
for (i in 1:testpolsize){
  for (j in 1:testscendiv){
    scen <- testscens[(testscendiv*(i-1)+1):(testscendiv*(i-1)+testscendiv)][j]
    temp <- data.frame(recordID=allscenario_test[i,1],Scenario=scen,ScenVal=unlist(allscenario_test[i,scen+1,with=FALSE]) )
    testdata_NN[iter,] <-  t(temp)
    iter <- iter+1
  }
}
colnames(traindata_NN) <- c("recordID","Scenario","ScenVal")
colnames(testdata_NN) <- c("recordID","Scenario","ScenVal")

traindata_NN <- merge(traindata_NN,alldata_NN,by.x="recordID",by.y="recordID")
testdata_NN <- merge(testdata_NN,alldata_NN,by.x="recordID",by.y="recordID")
head(traindata_NN)
length(unique(traindata_NN$recordID))
length(unique(traindata_NN$Scenario))
length(unique(testdata_NN$recordID))
length(unique(testdata_NN$Scenario))

traindata_NN <- unique(traindata_NN)
testdata_NN <- unique(testdata_NN)
dim(traindata_NN)
dim(testdata_NN)

traindata_NN_original <- traindata_NN
testdata_NN_original <- testdata_NN
# traindata_NN <- traindata_NN_original
# testdata_NN <- testdata_NN_original

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
save(traindata_NN_original,testdata_NN_original,scenario_pca,FMVallpol,payoffallscen, alldata_NN, scendata, trainx,trainy,
     testx,testy,allpol,allscensize,numvar,file="PCA500/finaldata.Rdata")



