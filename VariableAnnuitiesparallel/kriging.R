setwd("/srv/scratch/z5238225/VariableAnnuitiesparallel")
load(file="PCA500/finaldata.Rdata")
library(Rfast)


kriging <- function(x,y){
  
  k <- length(y)
  M = matrix(numeric((k+1)*(k+1)), nrow = k+1, ncol = k+1) # empty matrix
  M[,k+1] <- 1
  M[k+1,] <- 1
  M[k+1,k+1] <- 0
  
  
  alpha <- 0
  distancevec <- rep(1, k*(k-1)/2)
  distancevec_beta <- rep(1,k*k)
  iterbeta <- 1
  iter <- 1
  
  distancemat <- as.matrix(dist(x,diag=TRUE,upper=TRUE))
  for (i in 1:k){
    for (j in 1:k){
      distance <- dist(rbind(x[i,], x[j,]))
      if (i<j){
        distancevec_beta[iterbeta] <- distance
        iterbeta <- iterbeta+1
      }
      distancevec[iter] <- distance
      iter <- iter+1
      
    }
  }
  
  beta <- quantile(distancemat[lower.tri(distancemat, diag = FALSE)],0.95)
  
  for (i in 1:k){
    for (j in 1:k){
      M[i,j] <- alpha+exp(-3/beta*distancemat[i,j])
    }
  }
  M <- c(y,0)%*%solve(M)
  
  # M <- c(y,0)%*%spdinv(M)
  
  return (list(M,alpha,beta))
}

krigingpredict <- function(newx,x,y){
  Mab <- kriging(x,y)
  M <- Mab[[1]]
  alpha <- Mab[[2]]
  beta <- Mab[[3]]
  k <- length(y)
  Dvec <- rep(1,k+1)
  for (i in 1:k){
    Dvec[i] <- alpha+exp(-3/beta*dist(rbind(newx,x[i,])))
  }
  ypred <- M%*%Dvec
}

krigingpredict <- function(newx,x,y,M,alpha,beta){
  k <- length(y)
  Dvec <- rep(1,k+1)
  for (i in 1:k){
    Dvec[i] <- alpha+exp(-3/beta*dist(rbind(newx,x[i,])))
  }
  ypred <- M%*%Dvec
}

dim(scendata)
dim(scenario_pca)
length(payoffallscen)
scensample<- sample(1:10000, 1000,replace=F)
# inputx <- scendata[scensample,]
allasset_scen <- as.matrix(allasset_scen)

inputx <- allasset_scen[scensample,]
inputy <- payoffallscen[scensample]

ptm <- proc.time()
Mab <- kriging(inputx,inputy)
proc.time()-ptm

M <- Mab[[1]]
alpha <- Mab[[2]]
beta <- Mab[[3]]
# payoffpred <- apply(scendata,1,krigingpredict,inputx,inputy,M,alpha,beta)
payoffpred <- apply(allasset_scen,1,krigingpredict,inputx,inputy,M,alpha,beta)

quantile(payoffallscen[scensample])
quantile(payoffpred[scensample])

quantile(payoffallscen)
quantile(payoffpred)
hist((payoffpred-payoffallscen)/payoffallscen)

ypred <- krigingpredict(x,y,newx)
newx <- c(1,2,3)
newx <- matrix(c(1,2,3,4,5,6),nrow=2,ncol=3)
spred <- apply(newx,1,krigingpredict,x,y)

