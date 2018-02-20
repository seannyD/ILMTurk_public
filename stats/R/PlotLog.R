library(gplots)
library(lattice)
library(lme4)
library(party)
library(dtw)

setwd("/Library/WebServer/Documents/ILMTurk/stats")
source("R/graphCode.R")

nonlinearCurve = read.csv("/Library/WebServer/Documents/ILMTurk/offline/TestThereminResults.csv")
nonlinearCurve$hz = (nonlinearCurve$hz - min(nonlinearCurve$hz))
nonlinearCurve$hz = (nonlinearCurve$hz /max(nonlinearCurve$hz))

signals_Nij = read.csv("Data/Signals_Nij.csv",stringsAsFactors=F)
signals_MT = read.csv("Data/Signals_MT.csv",stringsAsFactors=F)
signals_SONA = read.csv("Data/Signals_SONA.csv",stringsAsFactors=F)

signals_MT$run = "MT"
signals_Nij$run = "Nij"
signals_SONA$run = "SONA"


####
# Signal plots

for(db in list(signals_MT,signals_Nij, signals_SONA)){
  for(ch in unique(db$chain2)){
    dx = db[db$chain2==ch,]
    gens = sort(unique(as.numeric(dx$gen)))

    pdf(file=paste('graphs/signalPlots/physSignals/',dx$run[1],"_",ch,'.pdf',sep=''), width=4,height = 3 * length(gens))
    par(mfrow=c(length(gens),1), mar=c(0.5,0.5,2,0.5))
    for(gen in gens){
      physSig = dx[dx$gen==gen,]$physSignal[order(dx[dx$gen==gen,]$meaning)]
      physSig = sapply(physSig,function(X){as.numeric(strsplit(X,"_")[[1]])})
      plotSigs(physSig)
      if(gen==1){
        title(paste("Physical space: ",dx$run[1],"_",ch))
      }
    }
    dev.off()
    
    
    pdf(file=paste('graphs/signalPlots/hzSignals/',dx$run[1],"_",ch,'.pdf',sep=''), width=4,height = 3 * length(gens))
    par(mfrow=c(length(gens),1), mar=c(0.5,0.5,2,0.5))
    for(gen in gens){
      hzSig = dx[dx$gen==gen,]$hzSignal[order(dx[dx$gen==gen,]$meaning)]
      hzSig = sapply(hzSig,function(X){as.numeric(strsplit(X,"_")[[1]])})
      plotSigs(hzSig, physicalSpace = F)
      if(gen==1){
        title(paste("Acoustic space: ",dx$run[1],"_",ch))
      }
    }
    dev.off()
    
  }
}


####

summaryGraphs(logs = list(signals_Nij,signals_MT,signals_SONA),logs.names = c("Nijmegen Data",'MTurk Data','SONA Data'))

summaryGraphsByMeaning(logs = list(signals_Nij,signals_MT,signals_SONA),logs.names = c("Nijmegen Data",'MTurk Data','SONA Data'))


# Signal distributions
original.signals = read.delim("../private/fluteilm/trainingData/trainingSignals.txt",header=F,sep='\t',stringsAsFactors = F)

original.signals = sapply(original.signals[,1],function(X){as.numeric(strsplit(X,",")[[1]])})


#######
# For every chain, for each meaning within that chain, draw a distribution curve of the signal
signalDistCurvePlots(signals_SONA, "graphs/summary/Distributions_SONA.pdf")
signalDistCurvePlots(signals_SONA, "graphs/summary/Distributions_MT.pdf")


# plot distribution in terms of plateau/steep section
pdf(file = 'graphs/summary/PlateauTime_SONA_meaning3.pdf')
plateauPlot(signals_SONA,ylimx = c(0,300),meaningx=3)
dev.off()

plateauPlot(signals_MT[signals_MT$gen>8,],ylimx = c(0,100),meaningx=3)

# MEANING 3
############

# for the plateau meaning, get the hz of the flat bit, and see how deviant it is from the training data
pdf(file="graphs/summary/SONA_Meaning3_byCurvature.pdf", width=12,height=7)
m3_SONA = meaning3PlateauDeviationGraph(signals_SONA)
dev.off()

pdf(file="graphs/summary/MT_Meaning3_byCurvature.pdf", width=12,height=7)
m3_MT = meaning3PlateauDeviationGraph(signals_MT)
dev.off()

dx = m3_SONA[m3_SONA$curvature<0.5,]
m3.0 = lmer(meanSig.diff~ 1 + (1|chain2), data=dx)
m3.1 = lmer(meanSig.diff~ curvature + (1|chain2), data=dx)
m3.2 = lmer(meanSig.diff~ curvature+gen + (1|chain2), data=dx)
m3.3 = lmer(meanSig.diff~ curvature*gen + (1|chain2), data=dx)
anova(m3.0,m3.1,m3.2,m3.3)
summary(m3.3)

dx = m3_MT#[m3_MT$curvature<0.4,]
m3.0.mt = lmer(meanSig.diff~ 1 + (1|chain2), data=dx)
m3.1.mt = lmer(meanSig.diff~ curvature + (1|chain2), data=dx)
m3.2.mt = lmer(meanSig.diff~ curvature+gen + (1|chain2), data=dx)
m3.3.mt = lmer(meanSig.diff~ curvature*gen + (1|chain2), data=dx)
anova(m3.0.mt,m3.1.mt,m3.2.mt,m3.3.mt)
summary(m3.3.mt)

dxx = m3_MT[m3_MT$curvature < 0.3,]
interaction.plot(dxx$gen,dxx$curvature,dxx$meanSig.diff)

dx = signals_MT
dx = dx
# proportion of time in plateau
m0 = lmer(prop.time.plateau~1  + (1|chain2) + (1|meaning), data=dx)
m1 = lmer(prop.time.plateau~curvature + (1|chain2)  + (1|meaning), data=dx)
m2 = lmer(prop.time.plateau~curvature+gen + (1|chain2) + (1|meaning), data=dx)
m3 = lmer(prop.time.plateau~curvature*gen + (1|chain2) + (1|meaning), data=dx)

anova(m0,m1,m2,m3)
summary(m3)

pdf("graphs/summary/PlateauTime_GenByCurvature.pdf", width=7, height=4)
par(mfrow=c(1,2))
plotmeans(prop.time.plateau~curvature, data = signals_MT[signals_MT$gen<3 ,], xlab = "Curvature", ylab="Proportion of time in Plateau", ylim=c(0.35,0.75), n.label=F)
plotmeans(prop.time.plateau~curvature, data = signals_MT[signals_MT$gen>8,], xlab = "Curvature", ylab="Proportion of time in Plateau", ylim=c(0.35,0.75), n.label=F)
dev.off()


par(mfrow=c(3,3))
for(i in 1:9){
  plotmeans(prop.time.plateau~curvature, data=signals_MT[signals_MT$gen==i,],ylim=c(0.2,0.9))
}

par(mfrow=c(2,3))
for(i in unique(signals_MT$curvature)){
  plotmeans(prop.time.plateau~gen, data=signals_MT[signals_MT$curvature==i,],ylim=c(0.2,0.9))
}

pdf("graphs/summary/PlateauTimeByGenerationByCurvature.pdf")
par(mfrow=c(1,1), bg='gray')
dx = signals_MT[signals_MT$chain2!="chain -174 log2.csv 0.4" & signals_MT$curvature %in% c(0,0.2,0.5),]
plot(c(1,10),c(0.4,0.7),type='n', xlab='Generation',ylab='Proportion of time in Plateau')
curvs = sort(unique(dx$curvature))
cols = heat.colors(3)
for(i in 1:length(curvs)){
  dxx = dx[dx$curvature==curvs[i],]
  p = tapply(dxx$prop.time.plateau, dxx$gen,mean)  
  g = as.numeric(names(p))
  points(g,p,pch=16,col=cols[i])
  lmx = lm(p~g)
  abline(lmx, col = cols[i],lwd=3)
  text(1,predict(lmx)[1], curvs[i],cex=2,col=cols[i], pos=3)
}
dev.off()


# Meaning 1 & 2- prediction: more steady sections with higher curvature
dx = signals_SONA
dx = dx[dx$meaning!=3,]
m0.zero = lmer(propZero~1  + (1|chain2) + (1|meaning), data=dx)
m1.zero = lmer(propZero~curvature + (1|chain2)+ (1|meaning), data=dx)
m2.zero = lmer(propZero~curvature+gen + (1|chain2)+ (1|meaning), data=dx)
m3.zero = lmer(propZero~curvature*gen + (1|chain2)+ (1|meaning), data=dx)

anova(m0.zero,m1.zero,m2.zero,m3.zero)
summary(m3.zero)

dx = signals_MT
dx = dx[dx$meaning!=3 & dx$curvature<0.4,]
m0.zero.mt = lmer(propZero~1  + (1|chain2)+ (1|meaning), data=dx)
m1.zero.mt = lmer(propZero~curvature + (1|chain2)+ (1|meaning), data=dx)
m2.zero.mt = lmer(propZero~curvature+gen + (1|chain2)+ (1|meaning), data=dx)
m3.zero.mt = lmer(propZero~curvature*gen + (1|chain2)+ (1|meaning), data=dx)

anova(m0.zero.mt,m1.zero.mt,m2.zero.mt,m3.zero.mt)
summary(m3.zero.mt)


###
dx = signals_MT
dx = dx[dx$meaning!=3,]
m0.plat = lmer(prop.time.plateau~1  + (1|chain2) + (1|meaning), data=dx)
m1.plat = lmer(prop.time.plateau~curvature + (1|chain2)+ (1|meaning), data=dx)
m2.plat = lmer(prop.time.plateau~curvature+gen + (1|chain2)+ (1|meaning), data=dx)
m3.plat = lmer(prop.time.plateau~curvature*gen + (1|chain2)+ (1|meaning), data=dx)

anova(m0.plat,m1.plat,m2.plat,m3.plat)


dx = signals_MT#[signals_MT$chain2!="chain -174 log2.csv 0.4",]
dx = dx
m0.plat = lmer(switches~1  + (1|chain2) , data=dx)
m1.plat = lmer(switches~I(log(curvature+0.1)) + (1|chain2), data=dx)
m2.plat = lmer(switches~I(log(curvature+0.1))+gen + (1|chain2), data=dx)
m3.plat = lmer(switches~I(log(curvature+0.1))*gen + (1|chain2), data=dx)

anova(m0.plat,m1.plat,m2.plat,m3.plat)
summary(m3.plat)

par(mfrow=c(2,3))
for(i in sort(unique(dx$curvature))){
  plotmeans(switches~gen,data=dx[dx$curvature==i,],ylim=c(0,12))
}

par(mfrow=c(1,1))
pdf("graphs/summary/SwitchesByCurvature.pdf")
plotmeans(switches~curvature,data=dx,xlab='Curvature',ylab='Number of direction switches')
dev.off()

pdf("graphs/summary/SwitchesByCurvature_Gen1.pdf")
plotmeans(switches~curvature,data=dx[dx$gen==1,],xlab='Curvature',ylab='Number of direction switches',ylim=c(0,13))
dev.off()

pdf("graphs/summary/SwitchesByCurvature_Gen9.pdf")
plotmeans(switches~curvature,data=dx[dx$gen==9,],xlab='Curvature',ylab='Number of direction switches',ylim=c(0,13))
dev.off()

m0= lmer(switches.between.sections ~ 1 + (1|chain2) + (1 | meaning), data = dx)
m1= lmer(switches.between.sections ~ curvature + (1|chain2) + (1 | meaning), data = dx)
m2= lmer(switches.between.sections ~ curvature+gen + (1|chain2) + (1 | meaning), data = dx)
m3= lmer(switches.between.sections ~ curvature*gen + (1|chain2) + (1 | meaning), data = dx)
anova(m0,m1,m2,m3)





# CTree exploration
allData = rbind(signals_MT,signals_SONA)
for(m in 1:3){
  allData = allData[allData$meaning==m,]
  allData = allData[,c("length","averageSlope","propZero",'switches','maxslope','slope.move','jerkyness','curvature','gen','meaning','run','prop.time.plateau')]
  allData$run = as.factor(allData$run)
  allData$meaning = as.factor(allData$meaning)
  
  ctx = ctree(curvature ~ ., data=allData, controls=ctree_control(mincriterion = 0.7))
  plot(ctx, terminal_panel=node_barplot)
}


