#Change path to regPolfull in the code


setwd("D:/Document/Research/eclipse-workspace-nested/VariableAnnuitiesparallel")

library(dbscan)
library(funHDDC)
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

#kerastuneR::install_kerastuner(python_path = 'C:/Users/hangn/Anaconda3')

#memory.limit(size=1800000)

normalize <- function(x) {
  if (max(x) == min(x)){
    return (x)
  }
  return ((x - min(x)) / (max(x) - min(x)))
  
}

scenariofolder <-  "src/Result/inforcevaluation/RW10000/"
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
scenvec_size <- ncol(allasset_scen)
scen_vec1 <- rep("ScenVec",scenvec_size)
scen_vec2 <- seq(1,scenvec_size)
scen_vec <- cbind(scen_vec1,scen_vec2)
scen_vec <- apply(scen_vec,1,paste,collapse="")
names(allasset_scen) <- scen_vec
allasset_scen$Scenario <- seq(1:10000)
head(allasset_scen[,1:50])
rm(largeCapEquity, smallCapEquity,intlEquity,fixedIncome,money)

dim(allasset_scen)



inforcecluster <- fread(file = "src/Data/inforce_cluster.csv", header = TRUE)
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
alldata_NN[, 1:(numcolNN-2)]
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



trainpolsize <- 10000
testpolsize <- 10000
#clusterrestrain <- clhs(alldata_NN[,-1],size=trainpolsize, simple = TRUE, track = NULL)
clusterrestrain <- sample(1:nrow(alldata_NN),trainpolsize,replace = FALSE)
trainPols <- alldata_NN$recordID[clusterrestrain]
# clusterrestest <- clhs(alldata_NN[-clusterrestrain,][,-1],size=testpolsize, simple = TRUE, track = NULL)
clusterrestest <- sample(1:(nrow(alldata_NN)-trainpolsize),testpolsize,replace = FALSE)

testPols <- alldata_NN[-clusterrestrain,]$recordID[clusterrestest]


allscenario <- fread("src/Data/regPolsfull_part1.csv",  header=TRUE,showProgress = FALSE)

allscensize <- ncol(allscenario)-1

allscenario_train <- allscenario[allscenario$recordID %in% trainPols,]
allscenario_test <- allscenario[allscenario$recordID %in% testPols,]

FMVallpol <- rowSums(allscenario[,2:(allscensize+1)])/allscensize
payoffallscen <- colSums(allscenario[,2:(allscensize+1)])

for (i in 2:20){
  allscenario <- fread(paste("src/Data/regPolsfull_part",i,".csv",sep=""),  header=TRUE,showProgress = FALSE)
  
  allscenario_train <- rbind(allscenario_train, allscenario[allscenario$recordID %in% trainPols,])
  allscenario_test <- rbind(allscenario_test, allscenario[allscenario$recordID %in% testPols,])
  
  FMVallpol <- c(FMVallpol,rowSums(allscenario[,2:(allscensize+1)])/allscensize)
  payoffallscen <- payoffallscen+colSums(allscenario[,2:(allscensize+1)])

}
length(unique(allscenario_test$recordID))
rm(allscenario)
# 
# trainpolindex <- sample(1:allpolsize, trainpolsize, replace=FALSE)
# testpolindex <- sample(setdiff(1:allpolsize,trainpolindex), testpolsize, replace=FALSE)
# traindata <- alldata_NN[reppolindex,]
# testdata <- alldata_NN[testpolindex,]

trainscensize <- 50000 #must be multiple of total number of scenarios
testscensize <- 50000 #must be multiple of total number of scenarios
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

trainpolpos <- rep(0,trainscensize)
testpolpos <- rep(0,testscensize)
trainscendiv <- trainscensize/trainpolsize
testscendiv <- testscensize/testpolsize

traindata_NN <- c()
testdata_NN <- c()
for (i in 1:trainpolsize){
  for (j in 1:trainscendiv){
    scen <- trainscens[(trainscendiv*(i-1)+1):(trainscendiv*(i-1)+trainscendiv)][j]
    temp <- data.frame(recordID=allscenario_train[i,1],Scenario=scen,ScenVal=unlist(allscenario_train[i,scen+1,with=FALSE]) )
    traindata_NN <- rbind(traindata_NN,temp)
  }
}
for (i in 1:testpolsize){
  for (j in 1:testscendiv){
    scen <- testscens[(testscendiv*(i-1)+1):(testscendiv*(i-1)+testscendiv)][j]
    temp <- data.frame(recordID=allscenario_test[i,1],Scenario=scen,ScenVal=unlist(allscenario_test[i,scen+1,with=FALSE]) )
    testdata_NN <- rbind(testdata_NN,temp)
  }
}
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

head(traindata_NN)

# 
# traindata_NN <- merge(traindata_NN,scenario_pca,by.x="Scenario",by.y="Scenario")
# testdata_NN <- merge(testdata_NN,scenario_pca,by.x="Scenario",by.y="Scenario")

names(traindata_NN)

traindata_NN_scen <- traindata_NN[,1:2]
testdata_NN_scen <- testdata_NN[,1:2]

names(traindata_NN_scen)
length(names(allasset_scen))
traindata_NN_scen <- merge(traindata_NN_scen,allasset_scen,by.x="Scenario",by.y="Scenario")
testdata_NN_scen <- merge(testdata_NN_scen,allasset_scen,by.x="Scenario",by.y="Scenario")
numscen <- ncol(traindata_NN_scen)-2
numvar <- ncol(traindata_NN)-3

conv_model <- keras_model_sequential()
conv_model %>% 
  layer_conv_1d(filters = 1, kernel_size = 3, activation = 'relu',
                input_shape = c(numscen, 1)) %>% 
  layer_conv_1d(filters = 1, kernel_size = 3, activation = 'relu') %>% 
  layer_average_pooling_1d(pool_size = 3)%>% 
  layer_flatten() %>% 
  layer_dense(units = 100, activation = "relu")
  # layer_conv_1d(filters = 128, kernel_size = 3, activation = 'relu') %>% 
  # layer_conv_1d(filters = 128, kernel_size = 3, activation = 'relu') %>% 
  # layer_global_average_pooling_1d() %>% 

fc_model <- keras_model_sequential()
fc_model %>% 
  layer_dense(units = 100+numvar, activation = "relu", input_shape = 100+numvar) %>% 
  layer_dense(units = 100+numvar, activation = "relu") %>% 
  layer_dense(units = 1) 


input_scen <- layer_input(c(numscen))
input_pol <- layer_input(c(numvar))

output_scen <- input_scen %>% conv_model
input_scenpol <- layer_concatenate(list(output_scen, input_pol))
output <- input_scenpol%>%fc_model
model <-  keras_model( list(input_scen , input_pol) , output )

early_stop <- callback_early_stopping(monitor = "val_loss", 
                                      min_delta = 0.1, 
                                      patience = 5,
                                      restore_best_weights = TRUE,
                                      verbose = 0)


losses <- c(keras::loss_mean_absolute_percentage_error,  
            keras::loss_mean_absolute_error,
            keras::loss_mean_squared_error,
            keras::loss_mean_squared_logarithmic_error)
model %>% compile(
  optimizer = "rmsprop",
  loss = losses[3],
  metrics = c("mse")
)

trainx1 <- traindata_NN_scen[1:10,-c(1,2)] %>% as.matrix()
trainx1 <- array_reshape(trainx1,c(nrow(trainx1),ncol(trainx1),1))
trainx2 <- traindata_NN[1:10,-c(1,2,3)] %>% as.matrix()
trainx2 <- array_reshape(trainx2,c(nrow(trainx2),ncol(trainx2),1))
trainy <- traindata_NN[1:10,3] %>% as.matrix()
dim(trainx1)
model(list(trainx1,trainx2),trainy)
model %>% fit(
  list(trainx1,trainx2),
  trainy,
  epochs = 500,
  batch_size = 128,
  verbose = 1,
  validation_split = 0.2,
  callbacks = list(
    early_stop)
)


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
testx <- testdata_NN[,-c(1,2,3)]
testx <- array_reshape(testx,c(nrow(testx),ncol(testx)))
testy <- testdata_NN[,3] %>% as.matrix()

early_stop <- callback_early_stopping(monitor = "val_loss", 
                                      min_delta = 0.0001, 
                                      patience = 5,
                                      restore_best_weights = TRUE,
                                      verbose = 0)


losses <- c(keras::loss_mean_absolute_percentage_error,  
            keras::loss_mean_absolute_error,
            keras::loss_mean_squared_error,
            keras::loss_mean_squared_logarithmic_error)

build_model = function(hp) {
    model = keras_model_sequential()
    
    num_layers <- hp$Int('num_layers',min_value=1, max_value=3, step=1)
    for (i in 1: num_layers)  {
      if (i == 1){
        model %>% layer_dense(units = hp$Int(paste('layer',i,sep=""),
                                             min_value=20,
                                             max_value=numvar,
                                             step=5), activation = "relu",input_shape = numvar)
      } else {
        model %>% layer_dense(units = hp$Int(paste('layer',i,sep=""),
                                 min_value=20,
                                 max_value=numvar,
                                 step=5), activation = "relu")
      }
    }
    model %>% layer_dense(units = 1)

  
  model %>% compile(
    optimizer = "rmsprop",
    loss = losses[3],
    metrics = c("mse")
  )
  

  return(model)
}
tuner = RandomSearch(
  build_model,
  objective = 'val_mse',
  max_trials = 100,
  executions_per_trial = 3,
  directory = 'Paper2/tunerPCA50',
  project_name = 'tuningresult')
tuner %>% search_summary()
tuner %>% fit_tuner(trainx,trainy,
                    epochs=3,
                    validation_data = list(testx,testy))

#result = kerastuneR::plot_tuner(tuner)
# the list will show the plot and the data.frame of tuning results
#result 


best_5_models = tuner %>% get_best_models(5)
#best_5_models[[1]] %>% plot_keras_model()

bestmodel <- best_5_models[[5]] 


##############################
###############################
################################
scendata <- scenario_pca[1:allscensize , !(names(scenario_pca) %in% c("Scenario"))]
scendata <- array_reshape(as.matrix(scendata), c(nrow(scendata), ncol(scendata)))
dim(scendata)
#Feedforward
modelpredict <- function(recordid,modelfile){
  findi <- which(alldata_NN$recordID==recordid)
  poldata <- alldata_NN[findi,-1]
  poldata <- reticulate::array_reshape(as.matrix(poldata), c(nrow(poldata), length(names(alldata_NN))-1))
  poldata <- matrix(poldata, nrow=allscensize, ncol=length(poldata), byrow=TRUE)
  rowdata <- cbind(poldata,scendata)
  rowdata <- reticulate::array_reshape(rowdata, c(nrow(rowdata), numvar))
  # K <- backend()
  # K$clear_session()
  currentmodel <- load_model_hdf5(modelfile)
  predicted <- currentmodel %>% predict(rowdata) 
}
scendata1000 <- scenario_pca[1:1000 , !(names(scenario_pca) %in% c("Scenario"))]
scendata1000 <- array_reshape(as.matrix(scendata1000), c(nrow(scendata1000), ncol(scendata1000)))
dim(scendata1000)
#Feedforward
modelpredict1000 <- function(recordid,modelfile){
  findi <- which(alldata_NN$recordID==recordid)
  poldata <- alldata_NN[findi,-1]
  poldata <- reticulate::array_reshape(as.matrix(poldata), c(nrow(poldata), length(names(alldata_NN))-1))
  poldata <- matrix(poldata, nrow=1000, ncol=length(poldata), byrow=TRUE)
  rowdata <- cbind(poldata,scendata1000)
  rowdata <- reticulate::array_reshape(rowdata, c(nrow(rowdata), numvar))
  # K <- backend()
  # K$clear_session()
  currentmodel <- load_model_hdf5(modelfile)
  predicted <- currentmodel %>% predict(rowdata) 
}

save(allscenario_train,allscenario_test,FMVallpol,payoffallscen, alldata_NN, scendata, scendata1000, trainx,trainy,
     testx,testy,allpol,allscensize,maxy,miny,numvar,modelpredict,modelpredict1000,file="Paper2/finaldata.Rdata")
bestmodel%>%save_model_hdf5("Paper2/bestmodel.h5")