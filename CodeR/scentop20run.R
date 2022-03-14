load(file="PCA500/finaldata.Rdata")
load(file="payoffallscen.Rdata")
scentop20_payoff <- payoffallscen[scentop20]
scentop20_payoff_sort <- sort(scentop20_payoff,decreasing = TRUE)
payoffallscen_sort <- sort(payoffallscen,decreasing = TRUE)
#80%
scentop20_quant80 <- scentop20_payoff_sort[2000]
scentop20_CTE80 <- mean(scentop20_payoff_sort[1:2000])
quant80 <- payoffallscen_sort[2000]
CTE80 <- mean(payoffallscen_sort[1:2000])

#85%
scentop20_quant85 <- scentop20_payoff_sort[1500]
scentop20_CTE85 <- mean(scentop20_payoff_sort[1:1500])
quant85 <- payoffallscen_sort[1500]
CTE85 <- mean(payoffallscen_sort[1:1500])
#90%
scentop20_quant90 <- scentop20_payoff_sort[1000]
scentop20_CTE90 <- mean(scentop20_payoff_sort[1:1000])
quant90 <- payoffallscen_sort[1000]
CTE90 <- mean(payoffallscen_sort[1:1000])
#95%
scentop20_quant95 <- scentop20_payoff_sort[500]
scentop20_CTE95 <- mean(scentop20_payoff_sort[1:500])
quant95 <- payoffallscen_sort[500]
CTE95 <- mean(payoffallscen_sort[1:500])
#99.5%
scentop20_quant995 <- scentop20_payoff_sort[50]
scentop20_CTE995 <- mean(scentop20_payoff_sort[1:50])
quant995 <- payoffallscen_sort[50]
CTE995 <- mean(payoffallscen_sort[1:50])