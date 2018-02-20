library(lme4)
library(infotheo)
library(lattice)
setwd("/Library/WebServer/Documents/ILMTurk/stats")
source("R/graphCode.R")

signals_Nij = read.csv("Data/Signals_Nij.csv",stringsAsFactors=F)
signals_MT = read.csv("Data/Signals_MT.csv",stringsAsFactors=F)
signals_SONA = read.csv("Data/Signals_SONA.csv",stringsAsFactors=F)

signals_MT$run = "MT"
signals_Nij$run = "Nij"
signals_SONA$run = "SONA"
library(gplots)


dx = signals_MT
pdf("graphs/summary/Steepness_MT.pdf")
plotmeans(steepness.sig.mean~curvature, data=dx, ylab="Mean signal steepness", xlab='Curvature')
dev.off()


#dx = signals_MT[signals_MT$meaning==2,]
#plotmeans(steepness.sig.mean~curvature, data=dx)


dx = signals_MT[signals_MT$curvature>0,]
# Null model
m0= lmer(steepness.sig.mean~1 + (1|chain2) + (1|meaning), data = dx)

# add curavture
m1= lmer(steepness.sig.mean~curvature + (1|chain2) + (1|meaning), data = dx)
# add generation
m2= lmer(steepness.sig.mean~curvature+gen + (1|chain2) + (1|meaning), data = dx)
# add interaction between curvature and generation
m3= lmer(steepness.sig.mean~curvature*gen + (1|chain2) + (1|meaning), data = dx)
# Quadratic term of curvature
m4= lmer(steepness.sig.mean~ I(curvature^2) + curvature*gen + (1|chain2) + (1|meaning), data = dx)
# Interaction between quadratic term of curvature and generation
m5= lmer(steepness.sig.mean~ I(curvature^2)*gen + curvature*gen + (1|chain2) + (1|meaning), data = dx)

anova(m0,m1,m2,m3,m4,m5)
