setwd("D:/Document/Research/eclipse-workspace-nested/VariableAnnuitiesparallel")

numscen<-10000
numstep<-360
numyear<-30
numindex <- 5
LC  <- matrix(0L, nrow= numscen, ncol = numstep+1) 
SC  <- matrix(0L, nrow= numscen, ncol = numstep+1) 
IE  <- matrix(0L, nrow= numscen, ncol = numstep+1) 
FI  <- matrix(0L, nrow= numscen, ncol = numstep+1) 
MN  <- matrix(0L, nrow= numscen, ncol = numstep+1)
for (i in 1:numscen){
  LC[i,1] <- 1
  SC[i,1] <- 1
  IE[i,1] <- 1
  FI[i,1] <- 1
  MN[i,1] <- 1
}

delta <- numyear/numstep
#Transition matrix
p12<-0.05
p21<-0.20
scenariofolder <-  "src/Result/inforcevaluation/RW10000/"
file_FixedIncome <-  paste(scenariofolder,"base/FixedIncome.csv", sep = "")
file_IntlEquity <-  paste(scenariofolder, "base/IntlEquity.csv", sep = "")
file_LargeCapEquity <-  paste(scenariofolder, "base/LargeCapEquity.csv", sep = "")
file_SmallCapEquity <-  paste(scenariofolder, "base/SmallCapEquity.csv", sep = "")
file_Money <-  paste(scenariofolder, "base/Money.csv", sep = "")
#Geometrix Mean
mean1LC<-0.1110; mean2LC<--0.0294 #Large Cap
mean1SC<-0.1333; mean2SC<--0.0508 #Small Cap
mean1IE<-0.0834; mean2IE<--0.0770 #International Equity
mean1FI<-0.0457; mean2FI<-0.0457 #Fixed Income
mean1MN<-0.0264; mean2MN<-0.0264 #Money
#Volatility
v1LC<-0.1100; v2LC<-0.2205
v1SC<-0.1445; v2SC<-0.2891
v1IE<-0.1259; v2IE<-0.2518
v1FI<-0.0313; v2FI<-0.0313
v1MN<-0.0065; v2MN<-0.0065
#Correlation
corr <- matrix(0L, nrow= 5, ncol = 5)
corr[1,2] <- 0.8068
corr[1,3] <- 0.7906
corr[1,4] <- -0.1028
corr[1,5] <- 0.0226
corr[2,3] <- 0.7025
corr[2,4] <- -0.1887
corr[2,5] <- -0.0215
corr[3,4] <- -0.1027
corr[3,5] <- -0.0007
corr[4,5] <- 0.1559
for (j in 1:4){
  for (i in j:5){
    corr[i,j] <- corr[j,i]
  }
}
for (i in 1:5){
  corr[i,i] <- 1
}
#Regime 1
diag1 <- diag(c(v1LC,v1SC,v1IE,v1FI,v1MN))
cov1 <- diag1%*%corr%*%diag1
#Regime 2
diag2 <- diag(c(v2LC,v2SC,v2IE,v2FI,v2MN))
cov2 <- diag2%*%corr%*%diag2


pi1=p21/(p12+p21)
pi2=p12/(p12+p21)

#Cholesky Decomposition
chol1 <- t(chol(cov1))
chol2 <- t(chol(cov2))

for (i in 1:numscen){
  #Uniform Random number u
  u <- runif(1, min = 0, max = 1)
  if (u<=pi1){
    rho <- 1
  } else{
    rho <- 2
  }
  for (j in 1:numstep){
    u <- runif(1, min = 0, max = 1)
    if (rho == 1 & u <= p12){
      rho = 2
    } else if (rho == 1 & u > p12){
      rho = 1
    } else if (rho == 2 & u <= p21){
      rho = 1
    } else{
      rho = 2
    }
    zvec <- rnorm(numindex) 
    if (rho ==1){
      mu1 <- c(mean1LC,mean1SC,mean1IE,mean1FI,mean1MN)
      Rvec <- mu1*delta+chol1%*%zvec*sqrt(delta)
    } else{
      mu2 <- c(mean2LC,mean2SC,mean2IE,mean2FI,mean2MN)
      Rvec <- mu2*delta+chol2%*%zvec*sqrt(delta)
    }
    Avec <- exp(Rvec)
    LC[i,j+1] <- Avec[1]
    SC[i,j+1] <- Avec[2]
    IE[i,j+1] <- Avec[3]
    FI[i,j+1] <- Avec[4]
    MN[i,j+1] <- Avec[5]
  }
}
write.table(LC,file = file_LargeCapEquity,sep=",",col.names = F, row.names = F)
write.table(SC,file = file_SmallCapEquity,sep=",",col.names = F, row.names = F)
write.table(IE,file = file_IntlEquity,sep=",",col.names = F, row.names = F)
write.table(FI,file = file_FixedIncome,sep=",",col.names = F, row.names = F)
write.table(MN,file = file_Money,sep=",",col.names = F, row.names = F)

