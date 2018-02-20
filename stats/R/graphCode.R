plotLog = function(folder,log, runName=""){
  # make signal plots
  for(details in unique(paste(log$logFile,log$chain,log$curvature, sep='_'))){
    logfilex = strsplit(details,'_')[[1]][1]
    chainx = strsplit(details,'_')[[1]][2]
    curvx = strsplit(details,'_')[[1]][3]
    lx = log[log$logFile == logfilex & log$chain==chainx & log$curvature==curvx,]
    
    pdf(file=paste('graphs/signalPlots/',runName,"_",details,'.pdf',sep=''), width=4,height = 3 * nrow(lx))
    par(mfrow=c(nrow(lx),1), mar=c(0.5,0.5,2,0.5))
    for(i in 1:nrow(lx)){
      #sigx = getFiles(folder,lx[i,]$file)
      sigx = getResults(paste(folder,'results/',lx[i,]$file,sep=''))
      plotSigs(sigx)
      if(i == 1){
        title(main=paste(runName,details))
      }
    }
    dev.off()
  }
}

plotSigs = function(sigs,physicalSpace = T){
  
  lims = c(200,6000)
  if(physicalSpace){
    lims = c(0,1000)
  }
  
  lens = max(sapply(sigs,length))
  plot(c(1,lens),lims,type='n',xaxt='n',yaxt='n',xlab='',ylab='')
  for(X in 1:length(sigs)){
    col = hsv(X/3,1,1,alpha=0.6)
    lines(1:length(sigs[[X]]),sigs[[X]], col=col, lwd=3,)
  }
}

plateauPlot = function(sigx,ylimx,meaningx = 3,hz.breaks = c(-1,100,300,500,700,1001)){
  # plot distribution in terms of plateau/steep section
  
  hz.scale = c(200,2000,4000,6000)
  hz.tick = (hz.scale/6000)*ylimx[2]
  
  
  
  par(bg='white', mfrow=c(2,3))
  
  for(cx in sort(unique(sigx$curvature))){
    x = as.numeric(unlist(strsplit(
      sigx[sigx$meaning == meaningx & sigx$curvature==cx,]$physSignal
      ,"_")))
    hist(x,breaks=hz.breaks,col=c('white','gray','white','gray','white'), main=paste("Curvature =",cx), ylim=ylimx, xlab='Physical position', freq=T)
    
    as.factor(as.character(cut(x,breaks = hz.breaks,labels=c('plateau','steep','plateau','steep','plateau'))))
    
    #curvex = nonlinearCurve[nonlinearCurve$curvature==cx,]
    #lines(curvex$physpos*1000,curvex$hz*ylimx[2])
    #axis(4,at=hz.tick, labels=hz.scale,)
    #mtext('Hz',4,line=1)
    #  points(seq(from=0,to=1000,length.out=length(original.signals[[meaningx]])),(original.signals[[meaningx]]/1000) * ylimx[2])
  }
  
}


signalDistCurvePlots = function(sigx, fn="graphs/summary/Distributions.pdf"){
  # For every chain, for each meaning within that chain, draw a distribution curve of the signal
  
  
  pdf(file=fn,width=12,height=24)
  par(mfrow=c(6,3),bg='light gray')
  for(chn in unique(sigx$chain2)){
    for(mng in 1:3){
      sigx2 = sigx[sigx$chain2==chn & sigx$meaning==mng,]
      plot(c(0,1000),c(0,0.004),type='n',main=paste(sigx$run[1],"Meaning",mng,",",chn))
      orig.dens = density(original.signals[[mng]])
      lines(orig.dens$x,orig.dens$y,col=1,lty=2)
      cols = heat.colors(length(sort(unique(sigx2$gen))))
      for(i in sort(unique(sigx2$gen))){
        x = as.numeric(unlist(strsplit(
          sigx2[sigx2$gen==i,]$physSignal
          ,"_")))
        #dx = hist(x,plot=F)
        #plot(dx,xlim=c(0,1000),main=cxs[i])
        dx = density(x)
        lines(dx$x,dx$y,col=cols[i])
        
        densy = dx$y
        maxy = which(densy == max(densy))
        
        text(dx$x[maxy],dx$y[maxy],i,col=cols[i])
      }
    }
  }
  dev.off()
}


summaryGraphs = function(logs,logs.names){
  pdf(file = 'graphs/summary/Summary.pdf')
  
  
  for(i in 1:length(logs)){
    logx = logs[[i]]
    
    plotmeans(prop.time.plateau~curvature,data = logx, main=logs.names[i],ylab='Proportion of time in plateaus')
    plotmeans(length~curvature, data=logx, main=logs.names[i], ylab='Signal Duration')
    plotmeans(averageSlope~curvature, data=logx, main=logs.names[i], ylab = 'Average slope change')
    plotmeans(slope.move~curvature, data=logx, main=logs.names[i],ylab = 'Average slope change (excluding zero)')
    plotmeans(propZero~curvature, data=logx, main=logs.names[i], ylab="Proportion of zero velocity")
    plotmeans(switches~curvature, data=logx, main=logs.names[i], ylab='Number of direction switches')
    plotmeans(maxslope/1000~curvature, ylab='Maximum Physical Position Change', data=logx, main=logs.names[i])
    plotmeans(jerkyness~curvature, ylab='Jerkyness (signal change sd)', data=logx, main=logs.names[i])
    plotmeans(steepness.sig.mean.max~curvature, ylab='Mean Steepness (normalised by max steepenss)', data=logx, main=logs.names[i])
  }
  dev.off()
}



meaning3PlateauDeviationGraph = function(sigx){
  # plots 2 graphs, showing positions of plateaus in meaning 3 signal
  par(mfrow=c(1,6), mar=c(5, 1, 4, 0) + 0.1)
  sigx = sigx[sigx$meaning==3,]
  
  meaning3 = data.frame(chain2=NA,curvature=0,run=0,gen=0,meanSig=0)
  cxs = sort(unique(sigx$curvature))
  for(cx in cxs){
    sx = sigx[sigx$curvature==cx,]
    
    #ylab = 'Physical space'
    #yaxt = "s"
   # if(cx != cxs[1]){
      ylab=''
      yaxt='n'
    #}
    
    plot(c(0,1000)~c(0,1), main=paste("Curvature",cx),type='n', ylab=ylab, yaxt=yaxt, xlab='time')
    rect(0,0,1,1000,col='light gray')
    for(i in 1:nrow(sx)){
      xAll = as.numeric(strsplit(sx[i,]$physSignal,"_")[[1]])
      x = xAll[((length(xAll)/5) *4):length(xAll)]
      gen = sx[i,]$gen
      if(diff(range(x))<100 & length(x)>4 & mean(x)>300){
        
        points(seq(from=0,to=1,length.out=length(xAll)),xAll, type='l',col=heat.colors(10, alpha=0.8)[gen],lwd=2)
        
        meaning3 = rbind(meaning3,c(sx$chain2[i], sx$curvature[i], sx$run[i], sx$gen[i], meanSig = mean(x)))
      }
    }
    meaning3 = meaning3[2:nrow(meaning3),]
    meaning3$curvature = as.numeric(meaning3$curvature)
    meaning3$gen = as.numeric(meaning3$gen)
    meaning3$meanSig = as.numeric(meaning3$meanSig)
    meaning3$meanSig.diff = abs(meaning3$meanSig-775)
  }
  par(mfrow=c(1,1), mar = c(5, 4, 4, 2) + 0.1)
  
  xpos = meaning3$curvature + (0.05 * (meaning3$gen/10))
  plot(meaning3$meanSig~xpos, pch=16, col = rgb(0,0,0,0.3), xlab='Curvature', ylab = "Mean Plateau (Physical space)")
  abline(h=775, col='red')
  
  return(meaning3)
  
}



meaning3DistributionGraph = function(sigx){
  par(bg='gray')
  plot(c(0,1000),c(0,0.0022),type='n',main="Meaning 3 (plateau)")
  orig.dens = density(original.signals[[3]])
  lines(orig.dens$x,orig.dens$y,col=1,lty=2)
  cxs = sort(unique(sigx$curvature))[1:6]
  cols = heat.colors(length(cxs))
  #par(mfrow=c(length(cxs),1))
  for(i in 1:length(cxs)){
    x = as.numeric(unlist(strsplit(
      sigx[sigx$curvature==cxs[i] & sigx$meaning==3,]$physSignal
      ,"_")))
    #dx = hist(x,plot=F)
    #plot(dx,xlim=c(0,1000),main=cxs[i])
    dx = density(x)
    lines(dx$x,dx$y,col=cols[i])
    
    densy = dx$y
    maxy = which(densy == max(densy))
    
    text(dx$x[maxy],dx$y[maxy],cxs[i],col=cols[i])
  }
  
}



summaryGraphsByMeaning = function(logs,logs.names){
  for(meaningX in c(1,2,3)){
  pdf(file = paste('graphs/summary/Summary_meaning_',meaningX,'.pdf'))
  
  
  for(i in 1:length(logs)){
    logx = logs[[i]]
    logx = logx[logx$meaning==meaningX,]
    plotmeans(prop.time.plateau~curvature,data = logx, main=logs.names[i],ylab='Proportion of time in plateaus')
    plotmeans(length~curvature, data=logx, main=logs.names[i], ylab='Signal Duration')
    plotmeans(averageSlope~curvature, data=logx, main=logs.names[i], ylab = 'Average slope change')
    plotmeans(slope.move~curvature, data=logx, main=logs.names[i],ylab = 'Average slope change (excluding zero)')
    plotmeans(propZero~curvature, data=logx, main=logs.names[i], ylab="Proportion of zero velocity")
    plotmeans(switches~curvature, data=logx, main=logs.names[i], ylab='Number of direction switches')
    plotmeans(maxslope/1000~curvature, ylab='Maximum Physical Position Change', data=logx, main=logs.names[i])
    plotmeans(jerkyness~curvature, ylab='Jerkyness (signal change sd)', data=logx, main=logs.names[i])
    plotmeans(steepness.sig.mean.max~curvature, ylab='Mean Steepness (normalised by max steepenss)', data=logx, main=logs.names[i])
  }
  dev.off()
  }
}
