
meaning1.start = c(0,25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500,525,550,575,600,625,650,675,700,725,750,775,800,825,850,875,900,925,950,975,1000)

meaning2.start = c(0,25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500,525,550,575,600,625,650,675,700,725,750,775,800,825,850,875,900,925,950,975,1000,975,950,925,900,875,850,825,800,775,750,725,700,675,650,625,600,575,550,525,500,475,450,425,400,375,350,325,300,275,250,225,200,175,150,125,100,75,50,25,0)

meaning3.start = c(0,25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500,525,550,575,600,625,650,675,700,725,750,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775,775)

meaning1.startS = paste(meaning1.start,collapse='_')
meaning2.startS = paste(meaning2.start,collapse='_')
meaning3.startS = paste(meaning3.start,collapse='_')

nonlinearCurve = read.csv("/Library/WebServer/Documents/ILMTurk/offline/TestThereminResults.csv")

curve = nonlinearCurve[nonlinearCurve$curvature==0.5,]$hz
steepness = diff(curve)
steepness = steepness- min(steepness)
steepness = steepness/ max(steepness)
steepness = 1-steepness

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

convertHz = function(x){
  1000*((x - 200) / (6000-200))
}

plotSignal = function(signals, hz=F){
  
  #breaks = c(-1,100,300,500,700,1001)
  rect.hz = list(c(0,100),c(300,500),c(700,1000))
  
  
  
  if(length(signals)==1){
    signals2 = list(as.numeric(strsplit(signals,"_")[[1]]))
  } else{
    signals2 = sapply(signals,function(X){as.numeric(strsplit(X,"_")[[1]])})
  }
  for(sig.i in 1:length(signals2)){
    sig = signals2[[sig.i]]
    if(hz & sig.i>1){
      sig = convertHz(sig)
    }
    xlims = c(0,1)
    plot(xlims,c(0,1000),type='n',xlab='',ylab='',xaxt='n',yaxt='n',bty='n',ylim=c(0,1000), xaxs="i",yaxs="i")
  #  for(i in 1:length(rect.hz)){
  #    rx = rect.hz[[i]]
  #    print(rx)
  #    rect(0,rx[1],1,rx[2], col='gray', border=F)
   # }
    for(i in 1:length(steepness)){
      rect(-1,i * (1/length(steepness))*1000,2,(i+1) * (1/length(steepness))*1000, col=gray(steepness[i]), border=NA)
    }
    lines(seq(0,1,length.out=length(sig)),sig, col='red',lwd=2)
    box()
    
  }
}

#MTurk_log1.csv_chain 1_curvature 0.3.pdf
ex1 = signals_MT[signals_MT$chain2 == "chain 1 log1.csv 0.3" & signals_MT$meaning==2,]
pdf('graphs/signalExamples/MTurk_log1.csv_chain 1_curvature 0.3_meaning2.pdf', width=12,height=4)
par(mfrow=c(1,5), mar=c(2,2,2,2))
plotSignal(c(meaning2.startS,ex1$physSignal[1:4]))
dev.off()

pdf('graphs/signalExamples/MTurk_log1.csv_chain 1_curvature 0.3_meaning2_HzSpace.pdf', width=12,height=4)
par(mfrow=c(1,5), mar=c(2,2,2,2))
plotSignal(c(meaning2.startS,ex1$hzSignal[1:4]), hz=T)
dev.off()


# #MTurk_log3.csv_chain -107_curvature 0.4.pdf
# ex2 = signals_MT[signals_MT$chain2 == "chain -107 log3.csv 0.4" & signals_MT$meaning==2,]
# pdf('graphs/signalExamples/MTurk_log3.csv_chain -107_curvature 0.4_meaning2.pdf', width=12,height=4)
# par(mfrow=c(1,5), mar=c(2,2,2,2))
# plotSignal(c(meaning2.startS,ex2$physSignal[1:4]))
# dev.off()
# 
# pdf('graphs/signalExamples/MTurk_log3.csv_chain -107_curvature 0.4_meaning2_HzSpace.pdf', width=12,height=4)
# par(mfrow=c(1,5), mar=c(2,2,2,2))
# plotSignal(c(meaning2.startS,ex2$hzSignal[1:4]), hz=T)
# dev.off()

#Very good transmission chain:
#  SONA_log1.csv_chain 1_curvature 0.2.pdf
ex3 = signals_SONA[signals_SONA$chain2 == "chain 1 log1.csv 0.2" & signals_SONA$meaning==2,]
pdf('graphs/signalExamples/SONA_log1.csv_chain 1_curvature 0.2_meaning2.pdf', width=12,height=4)
par(mfrow=c(1,5), mar=c(2,2,2,2))
plotSignal(c(meaning2.startS,ex3$physSignal[1:4]))
dev.off()

pdf('graphs/signalExamples/SONA_log1.csv_chain 1_curvature 0.2_meaning2_hzSpace.pdf', width=12,height=4)
par(mfrow=c(1,5), mar=c(2,2,2,2))
plotSignal(c(meaning2.startS,ex3$hzSignal[1:4]), hz=T)
dev.off()


#SONA_log1.csv_chain 1_curvature 0.5.pdf
ex5 = signals_SONA[signals_SONA$chain2 == "chain 1 log1.csv 0.5" & signals_SONA$meaning==2,]
pdf('graphs/signalExamples/SONA_log1.csv_chain 1_curvature 0.5_meaning2.pdf', width=12,height=4)
par(mfrow=c(1,6), mar=c(2,2,2,2))
plotSignal(c(meaning2.startS,ex5$physSignal[1:5]))
dev.off()


pdf('graphs/signalExamples/SONA_log1.csv_chain 1_curvature 0.5_meaning2_hzSpace.pdf', width=12,height=4)
par(mfrow=c(1,6), mar=c(2,2,2,2))
plotSignal(c(meaning2.startS,ex5$hzSignal[1:5]), hz=T)
dev.off()


####
dx = signals_SONA
label = "SONA"
for(ch in unique(dx$chain2)){
  for(mn in unique(dx[dx$chain2==ch,]$meaning)){
    
    start = meaning1.startS
    if(mn==2){
      start = meaning2.startS
    }
    if(mn==3){
      start = meaning3.startS
    }
    
    ex3 = dx[dx$chain2 == ch & dx$meaning==mn,]
    filename1 = paste0('graphs/signalExamples/',label," ",ch,"_meaning",mn,'_Hz.pdf')
    filename2 = paste0('graphs/signalExamples/',label," ",ch,"_meaning",mn,'_Physical.pdf')
    
    pdf(filename1, width=1+(3*nrow(ex3)),height=4)
    par(mfrow=c(1,1+nrow(ex3)), mar=c(2,2,2,2))
    plotSignal(c(start,ex3$hzSignal), 
               hz=T)
    dev.off()
    
    pdf(filename2, width=1+(3*nrow(ex3)),height=4)
    par(mfrow=c(1,1+nrow(ex3)), mar=c(2,2,2,2))
    plotSignal(c(start,ex3$physSignal),
               hz = F)
    dev.off()

  }
}