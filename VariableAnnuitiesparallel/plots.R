
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
library(ggplot2)

scenariofolder <-  "src/Result/inforcevaluation/RW10000/"
file_LargeCapEquity <-  paste(scenariofolder, "base/LargeCapEquity.csv", sep = "")
largeCapEquity <- read.csv(file = file_LargeCapEquity, header = FALSE)
largecap <- as.matrix(largeCapEquity[100,1:361])
largecap <- as.vector(largecap)
x <- seq(0,360)

 

df <- data.frame(time = x,
                 index = largecap)


p <- ggplot(df, aes(x=time, y=index)) +geom_line() +
  geom_point()+
  labs(x="Time", y="Index", title="Dynamics of large cap equity over 30 years")+ 
  theme(plot.title = element_text(hjust=0.5, size=15, face="bold"))+
  xlim(0, 360)+ylim(0.85,1.2)
p



times_basis <- seq(0,360,1)
knots <- c(seq(0,360,2))
n_knots <- length(knots)
n_order <- 4
n_basis <- n_knots+n_order-2
basis <- create.bspline.basis(c(min(times_basis),max(times_basis)),n_basis,n_order,knots)
basis <- create.fourier.basis(c(min(times_basis),max(times_basis)), nbasis=300)
largecapmat <- t(as.matrix(largecap))
time <- seq(0,360,1)
largecapfd <- smooth.basis(argvals = time,y=largecap,fdParobj=basis)$fd

plot(x,largecap,xlim=range(c(0,360)),ylim=range(c(0.85,1.2)),type = "l",
     xlab="Time Step", ylab="Large Cap Equity",
     main="30-year movements of index")
par(new=TRUE) 
plot(largecapfd,col="red",xlim=range(c(0,360)),ylim=range(c(0.85,1.2)),
     xlab="Time Step", ylab="Large Cap Equity")
