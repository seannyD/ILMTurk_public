library(gplots)
library(lme4)
setwd("/Library/WebServer/Documents/ILMTurk/stats/R")

load("stability_withinChains.Rdat")

d = stability[stability$run!="Nij",]

# Plot data
plotmeans(d$dtw.dist~d$run)

plotmeans(d[d$run=="SONA",]$dtw.dist~ 
         d[d$run=="SONA",]$gen)

plotmeans(d[d$run=="MT",]$dtw.dist~ 
            d[d$run=="MT",]$gen, col=2,barcol=2,add=T)



# Normalise variables
d$chainID = paste(d$run, d$chain)
d$partID = paste(d$run, d$chain, d$gen)

d$dtw.dist = log(d$dtw.dist)
d$dtw.dist= d$dtw.dist-mean(d$dtw.dist)

# Test difference between runs

m0 = lmer(dtw.dist~ 1 + (1|chainID/partID), data=d)
m1 = lmer(dtw.dist~ run + (1|chainID/partID), data=d)
anova(m0,m1)
summary(m1)
#Chisq(1) = 2.56, p = 0.11

MTmean = mean(stability[stability$run=="MT",]$dtw.dist)
SONAmean = mean(stability[stability$run=="SONA",]$dtw.dist)
# Dynamic time warping distance is about 17% lower in the SONA data.

