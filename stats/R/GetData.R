
rm(list=ls())
library(dtw)
setwd("/Library/WebServer/Documents/ILMTurk/stats")

base = "../backup/June14_corrected/"

fdates = file.info(list.dirs("../backup/", recursive=F))
rownames(fdates) = gsub("//","/",rownames(fdates))
if(max(as.Date(fdates$mtime)) != as.Date(fdates[substr(base,1,nchar(base)-1),]$mtime)){
  print("\n\n\n\n\nWARNING: NOT LATEST BACKUPS\n\n\n\n\n")
}

loadLog = function(folder,fn){
  # Load all logs
  logAll = data.frame()
  
  fns = list.files(path = paste(folder,"log/",sep=''), "*.csv" )
  fns = fns[grepl("log",fns)]
  
  for(fx in fns ){
    if(file.size(paste(folder,"log/",fx,sep=''))>0){
    log = read.csv(paste(folder,"log/",fx,sep=''),header=F,stringsAsFactors = F)
    names(log) = c("chain","gen",'curvature','time','file','status',"X")
    
    log = log[log$status %in% c("ready","completed"),]
    
    log$genNum = sapply(log$gen,function(X){as.numeric(strsplit(X," ")[[1]][2])})
    
    log$logFile = fx
    
    logAll = rbind(logAll,log)
    }
  }
  return(logAll)
}

getAttempts = function(filename){
  
  if(file.exists((filename))){
    dx = read.table(filename,header=F,stringsAsFactors = F,sep='\t',fill=T)
    names(dx) = c("stage", "meaning",'Hz','time',"X2",'X3','phys','X4','X5','X6','X7')
    numLearningRounds = sum(dx$stage=="Learning")
    abortedReproductionAttempts = sum(dx$stage=="Reproduction")-3
    return(c(numLearningRounds,abortedReproductionAttempts))
  } else{
    return(c(NA,NA))
  }
}

getFiles = function(folder,filename){
  fn = paste(folder,"outputLanguages/",filename,sep='')
  if(file.exists((fn))){
  dx =read.table(fn,stringsAsFactors = F,header=F,sep='\t')
  sigs = sapply(dx[,1],function(X){sapply(strsplit(X,',')[[1]],as.numeric)})
  return(list(sigs=sigs,fn=fn))
  } else{
    print(paste("no data, retrieving from resutls: ",filename))
    fn = paste(folder,"results/",filename,sep='')
    dx = read.delim(fn, stringsAsFactors = F, header=F, sep='\t')
    names(dx) = c("stage", "meaning",'Hz','time',"X2",'X3','phys','X4','X5','X6','X7')
    dx = dx[nrow(dx):1,]
    dx = dx[dx$stage=="Reproduction" & !duplicated(dx$meaning),]
    sigs = sapply(dx$Hz,function(X){sapply(strsplit(X,','),as.numeric)})
    # order by meaning
    sigs = sigs[order(dx$meaning)]
    return(list(sigs=sigs,fn=fn))
  }
}

getResults = function(filename){
  if(file.exists((filename))){
  dx = read.table(filename,header=F,stringsAsFactors = F,sep='\t',fill=T)
  dx = dx[dx[,1] == "Reproduction",]
  # Get last produced signal for each meaning
  dx = dx[nrow(dx):1,]
  dx = dx[!duplicated(dx$V2),]
  # order by meaning
  physicalspace  = dx[order(dx$V2),]$V7
  
  return(sapply(physicalspace,function(X){as.numeric(strsplit(X,',')[[1]])}))  # physical space
  } else{
    return(data.frame(NA,NA,NA))
  }
}

# plotSigs = function(sigs,physicalSpace = T){
#   
#   lims = c(200,6000)
#   if(physicalSpace){
#     lims = c(0,1000)
#   }
#   
#   lens = max(sapply(sigs,length))
#   plot(c(1,lens),lims,type='n',xaxt='n',yaxt='n',xlab='',ylab='')
#   for(X in 1:length(sigs)){
#     col = hsv(X/3,1,1,alpha=0.6)
#     lines(1:length(sigs[[X]]),sigs[[X]], col=col, lwd=3,)
#   }
# }

# plotLog = function(folder,log, runName=""){
#   for(details in unique(paste(log$logFile,log$chain,log$curvature, sep='_'))){
#     logfilex = strsplit(details,'_')[[1]][1]
#     chainx = strsplit(details,'_')[[1]][2]
#     curvx = strsplit(details,'_')[[1]][3]
#     lx = log[log$logFile == logfilex & log$chain==chainx & log$curvature==curvx,]
#     
#     pdf(file=paste('graphs/signalPlots/',runName,"_",details,'.pdf',sep=''), width=4,height = 3 * nrow(lx))
#     par(mfrow=c(nrow(lx),1), mar=c(0.5,0.5,2,0.5))
#     for(i in 1:nrow(lx)){
#       #sigx = getFiles(folder,lx[i,]$file)
#       sigx = getResults(paste(folder,'results/',lx[i,]$file,sep=''))
#       plotSigs(sigx)
#       if(i == 1){
#         title(main=paste(runName,details))
#       }
#     }
#     dev.off()
#   }
# }

compareSignals = function(signals,physSpace=T){
  
  if(is.na(signals[[1]])){
    return(NA)
  }
  
  time.res = 10
  hz.res = 10
  
#  if(!is.null(dim(signals[[1]]))){
#    for(i in 1:length(signals)){
#      signals[[i]] = signals[[i]][,1]
#    }
#  }
  
  tsamp = seq(0,100,length.out = time.res+1)
  hsamp = seq(-1,1001,length.out=hz.res+1)
  if(!physSpace){
    hsamp = seq(199,6000,length.out=hz.res+1)
  }
  sigMatrices = list()
  for(X in signals){
    mx = matrix(0,nrow=hz.res,ncol=time.res)
    hcat = as.numeric(cut(X,hsamp))
    tcat = as.numeric(cut(1:length(X),tsamp))
    for(t in 1:length(tcat)){
      mx[hcat[t],tcat[t]] = mx[hcat[t],tcat[t]] + 1
    }
    sigMatrices[[length(sigMatrices)+1]] = mx
  }
  
  totDist = 0
  for(i in 1:2){
    for(j in (i+1):3){
      totDist = totDist + sum(abs(sigMatrices[[i]] - sigMatrices[[j]]))
    }
  }
  
  
  return(totDist)
}


processSignals = function(folder,log,runName =""){
  signals = data.frame()
  
  for(details in unique(paste(log$logFile,log$chain,log$curvature, sep='_'))){
    logfilex = strsplit(details,'_')[[1]][1]
    chainx = strsplit(details,'_')[[1]][2]
    curvx = strsplit(details,'_')[[1]][3]
    curvx2 = as.numeric(strsplit(curvx," ")[[1]][2])
    lx = log[log$logFile == logfilex & log$chain==chainx & log$curvature==curvx,]
    
   
    for(i in 1:nrow(lx)){
      physFile = paste(folder,'results/',lx[i,]$file,sep='')
      sigx = getResults(physFile)
      sigd = sapply(sigx,sigStats, curvature=curvx2)
      sigx.hzDAT = getFiles(folder,lx[i,]$file) # Hz space
      hzFile = sigx.hzDAT[[2]]
      sigx.hz = sapply(sigx.hzDAT[[1]],as.vector)
      sigd.hz = sapply(sigx.hz,sigStats,get.steepness=F)
      
      att = getAttempts(physFile)
      numLearningRounds = att[1]
      abortedReproductionAttempts = att[2]
      
      physSigDistinctiveness = compareSignals(sigx)
      hzSigDistinctiveness = compareSignals(sigx.hz,physSpace = F)
      
      colnames(sigd) = paste("X",1:ncol(sigd))
      colnames(sigd.hz) = paste("X",1:ncol(sigd.hz))
      dx = data.frame(cbind(t(sigd),t(sigd.hz),
                       rep(logfilex,ncol(sigd)),
                       rep(chainx,ncol(sigd)),
                       rep(curvx,ncol(sigd)),
                       rep(runName,ncol(sigd)),
                       rep(lx[i,]$genNum,ncol(sigd)),
                       1:ncol(sigd),
                       paste(sapply(sigx,paste,collapse='_')),
                       paste(sapply(sigx.hz,paste,collapse='_')),
                       numLearningRounds,
                       abortedReproductionAttempts,
                       physSigDistinctiveness,
                       hzSigDistinctiveness,
                       physFile,
                       hzFile
                       )
                      )
      signals = rbind(signals,dx)
    }
   
  }
  names(signals) = c(
    'length','averageSlope','propZero','switches','maxslope',
    'slope.move','jerkyness','prop.time.plateau',
    'switches.between.sections','steepness.sig.mean',
    'steepness.sig.mean.max','expressiveness.sig.mean.max',
    'length.hz','averageSlope.hz','propZero.hz','switches.hz',
    'maxslope.hz','slope.move.hz','jerkyness.hz',
    'prop.time.plateau.hz','switches.between.sections.hz','steepness.sig.mean.hz','steepness.sig.mean.max.hz','expressiveness.sig.mean.max.hz','logfile','chain','curvature','run','gen','meaning','physSignal','hzSignal','numLearningRounds','abortedReproductionAttempts','physSigDistinctiveness','hzSigDistinctiveness','dataFilePhysSignal',"dataFileHzSignal")
  signals$curvature = as.numeric(sapply(as.character(signals$curvature),function(X){strsplit(X," ")[[1]][2]}))
  
  signals$length = as.numeric((as.character(signals$length)))
  signals$maxslope = as.numeric((as.character(signals$maxslope)))
  signals$averageSlope= as.numeric((as.character(signals$averageSlope)))
  signals$propZero= as.numeric((as.character(signals$propZero)))
  signals$switches= as.numeric((as.character(signals$switches)))
  signals$slope.move= as.numeric((as.character(signals$slope.move)))
  signals$jerkyness = as.numeric(as.character(signals$jerkyness))
  signals$prop.time.plateau = as.numeric(as.character(signals$prop.time.plateau))
  signals$switches.between.sections = as.numeric(as.character(signals$switches.between.sections))
  signals$switches.between.sections[signals$switches.between.sections<0] = 0
  
  signals$steepness.sig.mean = as.numeric(as.character(signals$steepness.sig.mean))
  signals$steepness.sig.mean.max = as.numeric(as.character(signals$steepness.sig.mean.max))
  signals$expressiveness.sig.mean.max = as.numeric(as.character(signals$expressiveness.sig.mean.max))
  
  
  signals$length.hz = as.numeric((as.character(signals$length.hz)))
  signals$maxslope.hz = as.numeric((as.character(signals$maxslope.hz)))
  signals$averageSlope.hz= as.numeric((as.character(signals$averageSlope.hz)))
  signals$propZero.hz= as.numeric((as.character(signals$propZero.hz)))
  signals$switches.hz= as.numeric((as.character(signals$switches.hz)))
  signals$slope.move.hz= as.numeric((as.character(signals$slope.move.hz)))
  signals$jerkyness.hz = as.numeric(as.character(signals$jerkyness.hz))
  signals$prop.time.plateau.hz = as.numeric(as.character(signals$prop.time.plateau.hz))
  signals$switches.between.sections.hz = as.numeric(as.character(signals$switches.between.sections.hz))
  signals$steepness.sig.mean.hz = as.numeric(as.character(signals$steepness.sig.mean.hz))
  signals$steepness.sig.mean.max.hz = as.numeric(as.character(signals$steepness.sig.mean.max.hz))
  signals$expressiveness.sig.mean.max.hz = as.numeric(as.character(signals$expressiveness.sig.mean.max.hz))
  
  signals$physSignal = as.character(signals$physSignal)
  
  signals$gen= as.numeric((as.character(signals$gen)))
  signals$meaning= as.numeric((as.character(signals$meaning)))
  signals$chain2 = paste(signals$chain,signals$logfile,signals$curvature)
  
  for(cx in c("numLearningRounds","abortedReproductionAttempts","physSigDistinctiveness","hzSigDistinctiveness")){
    signals[,cx] = as.numeric(as.character(signals[,cx]))
  }
  
  return(signals)
}

sigStats = function(sig, curvature = 0,phys.breaks = c(-1,100,300,500,700,1001),get.steepness=T){
  
  if(sum(!is.na(sig))==0){
    return(rep(NA,11))
  }
  
  #- duration
  lx = length(sig)
  
  diffx = diff(sig)
  # average slope change
  slope = mean(abs(diffx))
  slope.sd = sd(abs(diffx))
  
  # average slope change excluding zero
  slope.move = mean(abs(diffx[abs(diffx)>=5]))
  if(is.nan(slope.move)){
    slope.move = 0
  }
  
  # max slope change
  maxslope = max(abs(diffx))
  # proportion of signal with zero velocity
  propzero = sum(diffx<5) / lx
  # numer of direction changes
  switchDirection = sum(abs((diff(diffx>=0))))
  
  if(sum(!is.na(sig))==0){
    prop.time.plateau = -1
    switches.between.sections = -1
    steepness.sig.mean = -1
    expressiveness.sig.max.mean = -1
  } else{
    segment.times = as.factor(as.character(cut(sig,breaks = phys.breaks,labels=c('plateau','steep','plateau','steep','plateau'))))
    prop.time.plateau = sum(segment.times=='plateau')/length(segment.times)
    
    sections =  paste(as.character(cut(sig,breaks = phys.breaks,labels=c('a','','c','','e'))), collapse='')
    contiguous.sections = gsub("([aec])\\1+","\\1",sections)
    switches.between.sections = nchar(contiguous.sections)-1
    
    steepness.sig.mean = -1
    steepness.sig.mean.max = -1
    expressiveness.sig.max.mean = -1
    if(get.steepness){
      # work out mean signal steepness
      steepness.x = steepness[[1 + (curvature*10)]]
      steepness.sig = steepness.x[sig]
      steepness.sig.mean = mean(steepness.sig,na.rm=T)
      
      # Work out mean signal steepness, with steepenss 
      #  defined as the maximum curvature steepenss
      #  (to normalise the measure over curvatures)
      steepness.x.max = steepness[[length(steepness)]]
      steepness.sig.max = steepness.x.max[sig]
      steepness.sig.mean.max = mean(steepness.sig.max,na.rm=T)
      
      # Work out expressiveness
      expressiveness.sig.max = (0.5- abs(0.5-(steepness[[length(steepness)]])))[sig]
      expressiveness.sig.max.mean = mean(expressiveness.sig.max)
    }
  }
  
  
  return(c(lx,slope,propzero,switchDirection,maxslope,slope.move,slope.sd,prop.time.plateau,switches.between.sections,steepness.sig.mean,steepness.sig.mean.max, expressiveness.sig.max.mean))
}

# A file containing the mapping between physical space and hz space
#  for different curvature values.  The sampling was done at 3 times
#  the resolution of the recording resolution.
nonlinearCurve = read.csv("/Library/WebServer/Documents/ILMTurk/offline/TestThereminResults2.csv")

# Old Method
## For each value of curvature (0,0.1,0.2,0.3,0.4,0.5)
#for(i in 1:length(cxs)){
#  # get the difference in hz between each point in physical space
#  sx = diff(nonlinearCurve[nonlinearCurve$curvature==cxs[i],]$hz)
#  # noramlise between 0 and 1
#  sx = sx- min(sx)
#  sx = sx/ max(sx)
#  
#  # resample to the recoridng resolution:
#  # there are always 3 samples for each minimum unit of 
#  # recording resolution, so mean or sum return eqivalent measures
#  lx = cut(1:length(sx),breaks=seq(0,length(sx)+1,length.out=1001))
#  sx2 = tapply(sx,lx,mean)
#  steepness[[i]] = sx2
#}

# New method: scale according to global max steepness 

# Convert from hz to bark scale
toBark = function(f){
  (26.81 / (1+ (1960/f))) - 0.53
}
nonlinearCurve$bark = toBark(nonlinearCurve$hz)

steepness = list()
cxs = sort(unique(nonlinearCurve$curvature))


for(i in 1:length(cxs)){
  # get the difference in hz between each point in physical space
  sx = diff(nonlinearCurve[nonlinearCurve$curvature==cxs[i],]$bark)

    # resample to the recoridng resolution:
  # there are always 3 samples for each minimum unit of 
  # recording resolution, so mean or sum return eqivalent measures
  if(i>1){
    lx = cut(1:length(sx),breaks=seq(0,length(sx)+1,length.out=1001))
    sx2 = tapply(sx,lx,mean)
  } else {
    # The changes when steepenss == 0 are quite different, causing weird
    # jumps in the scale. So smooth.
    lx = cut(1:length(sx),breaks=seq(0,length(sx)+1,length.out=1001))
    sx2 = tapply(sx,lx,mean)
    tx = table(round(sx2,4))
    est = as.numeric(names(tx)[which(tx==max(tx))])
    sx2 = rep(est,1000)
  }
  steepness[[i]] = sx2
}

# Normalise by global maximum steepness
maxsteepnes = max(unlist(steepness))
for(i in 1:length(steepness)){
  steepness[[i]]  = steepness[[i]]/maxsteepnes
}

# Plot the steepnesses for each curvature
pdf("graphs/summary/SteepnessByCurvature.pdf",
    height=10)
par(mfrow=c(3,2))
for(i in 1:length(steepness)){
  plot(steepness[[i]],ylim=c(0,1), 
       type = 'l',
       xlab='Physical position',
       ylab = 'Steepness',
       main = paste("alpha =",(i-1)/10)
       )
}
dev.off()

# Plot expressivity

exprx = (0.5- abs(0.5-(steepness[[length(steepness)]])))
pdf("graphs/summary/ExpressivityByPhysicalPosition.pdf")
plot(exprx, type='l', xlab='Physical position', ylab='Expressivity')
dev.off()

######################


log_Nij = loadLog(paste(base,"fluteilm_NIJMEGEN/",sep=''),"log/log1.csv")
#plotLog(paste(base,"fluteilm_NIJMEGEN/",sep=''),log_Nij,"Facebook")
signals_Nij = processSignals(paste(base,"fluteilm_NIJMEGEN/",sep=''), log_Nij)
signals_Nij = signals_Nij[complete.cases(signals_Nij[,-which(names(signals_Nij)%in%c("prop.time.plateau.hz",'slope.move.hz'))]),]

log_MT = loadLog(paste(base,"fluteilm/",sep=''),"log/log1.csv")
#plotLog(paste(base,"fluteilm/",sep=''),log_MT,"MTurk")
signals_MT = processSignals(paste(base,"fluteilm/",sep=''),log_MT)
#signals_MT = signals_MT[complete.cases(signals_MT[,-which(names(signals_MT)%in%c("prop.time.plateau.hz",'slope.move.hz'))]),]


#######
# One of the generations in MT has no physical signal.
# The code above finds the hz signal, but does not calcualte all the stats
# So below we synthesise an output file, then re-run the stats

if(!file.exists("../backup/June14_corrected/fluteilm/results/output_19042016042524.txt")){
  print("Missing data, resynthesising from hz signal")
  selx = which(signals_MT$physSignal=="NA")
  newdata=data.frame(V1=rep("Reproduction",3), V2=1:3, 
                     V3=NA, V4=NA, V5=NA,V6=NA,
                     V7 = NA, V8 = NA, V9 = NA, V10 = NA, V11="")
  for(i in 1:length(selx)){
    curvpoint3 = nonlinearCurve[nonlinearCurve$curvature==
                                  signals_MT[selx[i],]$curvature ,]
    
    meaningx = signals_MT[selx[i],]$meaning
    hzsig1 = as.character(signals_MT[selx[i],]$hzSignal)
    hzsig = as.numeric(strsplit(hzsig1,"_")[[1]])
    # Use the curvature mapping to convert hz signal into physical signal
    physSig = sapply(hzsig, function(X){
      curvpoint3[which(abs(curvpoint3$hz-X)==min(abs(curvpoint3$hz-X))),]$physpos
    })
    physSig = round(physSig * 1000)
    physSig = paste(physSig,collapse=',')
    #signals_MT[selx[i],]$physSignal == physSig
    newdata[newdata$V2==meaningx,]$V7= physSig
    newdata[newdata$V2==meaningx,]$V3 = paste(hzsig,collapse=',')
  }
  write.table(newdata, "../backup/June14_corrected/fluteilm/results/output_19042016042524.txt", col.names =F, row.names= F, sep='\t', quote=F)
  
  # Now get the stats again:
  signals_MT = processSignals(paste(base,"fluteilm/",sep=''),log_MT)
}



tapply(log_MT$genNum,paste(log_MT$logFile,log_MT$chain,log_MT$curvature), max)

table(log_MT$genNum,log_MT$curvature)
sum(table(log_MT$genNum,log_MT$curvature))

plotExampleSteepenss = function(i){
  tsignal = dx[i,]$physSignal
  sig = as.numeric(strsplit(tsignal,'_')[[1]])
  plot(sig,type='l', xlab='time',ylab='Physical position',ylim=c(0,1000),
       main=paste("Curvature =",
                  dx[i,]$curvature,
                  "\nSteepness =",
                  round(dx[i,]$steepness.sig.mean.max,3)))
  #abline(h=c(-1,100,300,500,700,1001))
  rect(0, 100, length(sig), 300, col=rgb(1,0,0,0.3))
  rect(0, 500, length(sig), 700, col=rgb(1,0,0,0.3))
  #hist(sig,main=paste("Steepness =",
  #                   round(dx[i,]$steepness.sig.mean.max,3)))
  
  
}

dx = signals_MT
pdf("graphs/signalExamples/SteepnessExamples.pdf",
    height=20)
par(mfrow=c(6,3))
ix = sample(nrow(dx),3*6)
ix = ix[order(dx[ix,]$steepness.sig.mean.max)]
for(p in 1:(3*6)){
  plotExampleSteepenss(ix[p])
}
dev.off()

####


log_SONA = loadLog(paste(base,"fluteilm_SONA/",sep=''),"log/log1.csv")
#plotLog(paste(base,"fluteilm_SONA/",sep=''),log_SONA,"SONA")
signals_SONA = processSignals(paste(base,"fluteilm_SONA/",sep=''), log_SONA)
signals_SONA = signals_SONA[complete.cases(signals_SONA[,-which(names(signals_SONA)%in%c("prop.time.plateau.hz",'slope.move.hz'))]),]

table(log_SONA$genNum,log_SONA$curvature)

signals_MT$prop.time.plateau[signals_MT$prop.time.plateau==-1]  = NA
signals_SONA$prop.time.plateau[signals_SONA$prop.time.plateau==-1]  = NA
signals_Nij$prop.time.plateau[signals_Nij$prop.time.plateau==-1]  = NA

signals_MT$steepness.sig.mean[signals_MT$steepness.sig.mean==-1]  = NA
signals_SONA$steepness.sig.mean[signals_SONA$steepness.sig.mean==-1]  = NA
signals_Nij$steepness.sig.mean[signals_Nij$steepness.sig.mean==-1]  = NA

signals_MT$rawDataSource = base
signals_SONA$rawDataSource = base
signals_Nij$rawDataSource = base


write.csv(signals_Nij,"Data/Signals_Nij.csv",row.names=F)
write.csv(signals_MT,"Data/Signals_MT.csv",row.names=F)
write.csv(signals_SONA,"Data/Signals_SONA.csv",row.names=F)