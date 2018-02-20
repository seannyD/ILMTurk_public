library(lme4)
library(infotheo)
library(lattice)
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


makeHeatMap = function(signals,titlex, folder='heatmaps/', grid=F){
  time.res = 10
  hz.res = 10
  
  tsamp = seq(0,100,length.out = time.res+1)
  hsamp = seq(-1,1001,length.out=hz.res+1)
  
  if(length(signals)==1){
    signals2 = list(as.numeric(strsplit(signals,"_")[[1]]))
  } else{
    signals2 = sapply(signals,function(X){as.numeric(strsplit(X,"_")[[1]])})
  }
  mx = matrix(0,nrow=hz.res,ncol=time.res)
  for(X in signals2){
    hcat = as.numeric(cut(X,hsamp))
    tcat = as.numeric(cut(1:length(X),tsamp))
    for(t in 1:length(tcat)){
      mx[hcat[t],tcat[t]] = mx[hcat[t],tcat[t]] + 1
    }
   # return(unlist(table(hsamp,exclude = F)))
  }
  mx = t(mx)
  pdf(paste("graphs/",folder,titlex,".pdf",sep=''))
  image(log(mx+1),xaxt='n',yaxt='n', main=titlex)
  if(grid){
    grid(time.res,hz.res, col=1, lty=1)
  }
  dev.off()
  
  return(entropy(as.vector(mx)))
  
}


sigent = data.frame(run=NA,curvature=NA,meaning=NA,ent= NA)
list.names = c("MT","SONA","Nij")
data.list = list(signals_MT,signals_SONA,signals_Nij)
for(i in 1:length(data.list)){
  sigx = data.list[[i]]
 for(curvx in sort(unique(sigx$curvature))){
   meaning = NA
   #for(meaning in 1:3){
     sigx2 = sigx[sigx$curvature==curvx,]
     ent = makeHeatMap(sigx2$physSignal, paste("AllGens",list.names[i],"Meaning",meaning,"Curvature =",curvx))
     
     sigent = rbind(sigent,c(list.names[i],curvx,meaning,ent))
   #}
 }
}
sigent$curvature = as.numeric(sigent$curvature)
sigent$ent = as.numeric(sigent$ent)

cor.test(sigent[sigent$run=='MT',]$ent,sigent[sigent$run=='MT',]$curvature)
plot(ent~curvature,data=sigent[sigent$run=='MT',])

plot(ent~curvature,data=sigent[sigent$run=='SONA',], xlab='Curvature', ylab='Entropy', type='b')


sigent.gen = data.frame(run=NA,curvature=NA,meaning=NA,gen=NA,ent= NA)

list.names = c("MT","SONA","Nij")
data.list = list(signals_MT,signals_SONA,signals_Nij)
for(i in 1:length(data.list)){
  sigx = data.list[[i]]
  sigx = sigx[sigx$chain2!="chain -174 log2.csv 0.4",]
  for(curvx in sort(unique(sigx$curvature))){
    meaning = NA
    for(meaning in 1:3){
      sigx2 = sigx[sigx$curvature==curvx & sigx$meaning==meaning,]
      for(gen in sort(unique(sigx2$gen))){
        sigx3 = sigx2[sigx2$gen==gen,]
      ent = makeHeatMap(sigx3$physSignal, paste(list.names[i],'Gen',gen,"Meaning",meaning,"Curvature =",curvx), folder='heatmaps_byGen/')
      
      sigent.gen = rbind(sigent.gen,c(list.names[i],curvx,meaning,gen,ent))
      }
    }
  }
}
sigent.gen$curvature = as.numeric(sigent.gen$curvature)
sigent.gen$ent = as.numeric(sigent.gen$ent)
sigent.gen$gen = as.numeric(sigent.gen$gen)
sigent.gen = sigent.gen[!is.na(sigent.gen$gen),]

pdf("graphs/summary/CrossChainEntropy_ByCurvature.pdf", width=5,height=4.5)
plotmeans(ent~curvature,data=sigent.gen[sigent.gen$run=='MT',], ylab='Entropy',xlab='Curvature')
dev.off()

plotmeans(ent~curvature,data=sigent.gen[sigent.gen$run=='MT' & sigent.gen$meaning==3,], ylab='Entropy',xlab='Curvature')

plotmeans(ent~curvature,data=sigent.gen[sigent.gen$run=='SONA' & sigent.gen$meaning==3,], ylab='Entropy',xlab='Curvature')

pdf("graphs/summary/CrossChainEntropy_ByGen.pdf", width=5,height=4.5)
plotmeans(ent~gen,data=sigent.gen[sigent.gen$run=='MT'& sigent.gen$ent < 1.5,], xlab='Generation', ylab= "Entropy", n.label=)
dev.off()

par(mfrow=c(2,3))
for(i in sort(unique(sigent.gen$curvature))){
  plotmeans(ent~gen,data=sigent.gen[sigent.gen$run=='MT' & sigent.gen$curvature==i,], xlab='Generation', ylab= "Entropy", n.label=F, ylim=c(0.2,1))
}

xyplot(ent~gen,groups=curvature, data=sigent.gen[sigent.gen$run=='MT'& sigent.gen$ent < 1.5,], type='a', col=heat.colors(6))

selx = sigent.gen$run=='MT' 
cor.test(sigent.gen[selx,]$ent,sigent.gen[selx,]$curvature)

m0= lmer(ent~1 + (1| meaning), data= sigent.gen[selx,])
m1= lmer(ent~curvature + (1| meaning), data= sigent.gen[selx,])
m2= lmer(ent~curvature + gen +(1| meaning), data= sigent.gen[selx,])
m3= lmer(ent~curvature + I(curvature^2) + gen +(1| meaning), data= sigent.gen[selx,])
m4= lmer(ent~curvature*gen + I(curvature^2) +(1| meaning), data= sigent.gen[selx,])
m5= lmer(ent~curvature*gen + I(curvature^2)*gen +(1| meaning), data= sigent.gen[selx,])

anova(m0,m1,m2,m3,m4,m5)

m5a= lmer(ent~curvature*gen + I(curvature^2)*gen +(1 |meaning) + (0 + curvature|meaning) + (0 + gen|meaning)+ (0 + curvature:gen| meaning), data= sigent.gen[selx,])
m5b= lmer(ent~curvature*gen + I(curvature^2)*gen +(1 + curvature*gen| meaning), data= sigent.gen[selx,])
anova(m5a,m5b)


x = c(0,25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500,525,550,575,600,625,650,675,700,725,750,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775)
plot(x, type='l', lwd=3,xaxt='n',yaxt='n', bty='l',xlab='',ylab='',ylim=c(0,1000))
makeHeatMap(paste(x,collapse="_"),titlex="Meaning3_Gen0", grid=T)




#####
# ignore time dimension

getHistEntropy = function(signals){
  time.res = 10
  hz.res = 10
  if(length(signals)==1){
    signals2 = list(as.numeric(strsplit(signals,"_")[[1]]))
  } else{
    signals2 = sapply(signals,function(X){as.numeric(strsplit(X,"_")[[1]])})
  }
  mx = sapply(signals2, function(X){
    table(cut(X,breaks=hz.res+1),useNA='always')
  })
  return(entropy(as.vector(rowSums(mx))))
  
}

phys.ent.gen = data.frame(run=NA,curvature=NA,meaning=NA,gen=NA,ent= NA)

list.names = c("MT","SONA","Nij")
data.list = list(signals_MT,signals_SONA,signals_Nij)
for(i in 1:length(data.list)){
  sigx = data.list[[i]]
  sigx = sigx[sigx$chain2!="chain -174 log2.csv 0.4",]
  for(curvx in sort(unique(sigx$curvature))){
    meaning = NA
    for(meaning in 1:3){
      sigx2 = sigx[sigx$curvature==curvx & sigx$meaning==meaning,]
      for(gen in sort(unique(sigx2$gen))){
        sigx3 = sigx2[sigx2$gen==gen,]
        sigs = sigx3$physSignal
        
        ent = getHistEntropy(sigx3$physSignal)
        
        phys.ent.gen = rbind(phys.ent.gen,c(list.names[i],curvx,meaning,gen,ent))
      }
    }
  }
}
phys.ent.gen$curvature = as.numeric(phys.ent.gen$curvature)
phys.ent.gen$ent = as.numeric(phys.ent.gen$ent)
phys.ent.gen$gen = as.numeric(phys.ent.gen$gen)
phys.ent.gen = phys.ent.gen[!is.na(phys.ent.gen$gen),]

selx = phys.ent.gen$run=='MT' 
cor.test(phys.ent.gen[selx,]$ent,phys.ent.gen[selx,]$curvature)

m0= lmer(ent~1 + (1| meaning), data= phys.ent.gen[selx,])
m1= lmer(ent~curvature + (1| meaning), data= phys.ent.gen[selx,])
m2= lmer(ent~curvature + gen +(1| meaning), data= phys.ent.gen[selx,])
m3= lmer(ent~curvature*gen +(1| meaning), data= phys.ent.gen[selx,])

anova(m0,m1,m2,m3)
par(mfrow=c(1,1))
plotmeans(ent~curvature, data=phys.ent.gen[phys.ent.gen$run=="MT",], xlab='Curvature',ylab='Entropy')



######