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

## Create Bark Scale variable

getSignalX =function(x){
  as.numeric(strsplit(x,"_")[[1]])
}

toBark = function(f){
  (26.81 / (1+ (1960/f))) - 0.53
}

signalToBark = function(signal){
  signal = getSignalX(signal)
  signal = toBark(signal)
  return(paste(signal, collapse='_'))
}

signals_MT$barkSignal = sapply(signals_MT$hzSignal,signalToBark)
signals_Nij$barkSignal = sapply(signals_Nij$hzSignal,signalToBark)
signals_SONA$barkSignal = sapply(signals_SONA$hzSignal,signalToBark)

######
# Stability

# Stability within chains
# Calculate distance between a meaning and its direct ancestor.
# e.g. Compare meaning 1 from gen 2 with meaning 1 from gen 1

stability = data.frame(run = NA, chain=NA,gen = NA,meaning=NA,dtw.dist = NA, dtw.dist.acoustic = NA, curvature=NA)
list.names = c("MT","SONA","Nij")
data.list = list(signals_MT,signals_SONA,signals_Nij)
# For each experiment
for(i in 1:length(data.list)){
  sigx = data.list[[i]]
  # for each chain
  for(chainx in unique(sigx$chain2)){
    # for each generation
    for(g in sort(unique(sigx[sigx$chain2==chainx & sigx$gen,]$gen))){
      dx = sigx[sigx$chain2==chainx & sigx$gen==g,]
      if(g >1){
        # get the previous generation in the chain
        dx.prev = sigx[sigx$chain2==chainx & sigx$gen==(g-1),]
        if(nrow(dx.prev)>0){
          # for each meaning
          for(meaningx in dx$meaning){
            if(sum(dx$meaning==meaningx)>0 & sum(dx.prev$meaning==meaningx)>0){
              # Physical signal
              sig1 = as.numeric(strsplit(dx[dx$meaning==meaningx,]$physSignal,"_")[[1]])
              sig2 = as.numeric(strsplit(dx.prev[dx.prev$meaning==meaningx,]$physSignal,"_")[[1]])
              dtwx =  dtw(sig1, sig2)
              #Acoustic signal
              sig1a = as.numeric(strsplit(dx[dx$meaning==meaningx,]$hzSignal,"_")[[1]])
              sig2a = as.numeric(strsplit(dx.prev[dx.prev$meaning==meaningx,]$hzSignal,"_")[[1]])
              dtwxa =  dtw(sig1a, sig2a)
              
              stability = rbind(stability,
                                c(list.names[[i]],
                                  chainx,g,meaningx,
                                  dtwx$normalizedDistance, 
                                  dtwxa$normalizedDistance,
                                  dx$curvature)              
              )
            }
          }
        }
      }
    }
  }
}
stability = stability[!is.na(stability$run),]
for(i in 3:ncol(stability)){
  try(stability[,i]<-as.numeric(stability[,i]))
}


dx = stability[stability$run=="MT",]
m0 = lmer(dtw.dist~1 + (1 | chain), data=dx)
m1 = lmer(dtw.dist~curvature + (1 | chain), data=dx)
m2 = lmer(dtw.dist~curvature + gen + (1 | chain), data=dx)
m3= lmer(dtw.dist~curvature*gen + (1 | chain), data=dx)
m4= lmer(dtw.dist~curvature*gen + meaning + (1 | chain), data=dx)

anova(m0,m1,m2,m3,m4)

library(lattice)
xyplot(dtw.dist~gen, groups=curvature, type='a',data=stability[stability$run=="SONA",], auto.key=T)
plotmeans(dtw.dist~curvature,data=stability[stability$run=="SONA",])
plotmeans(dtw.dist~curvature,data=stability[stability$run=="MT" & stability$meaning==1,])

save(stability, file= "R/stability_withinChains.Rdat")

#########################
# Stability across chains

getSignalX =function(x){
  as.numeric(strsplit(x,"_")[[1]])
}

getSimilarityAcrossChains.straight = function(d1,d2){
  # calculate dtw distance for all pairs of signals
  # work out the pairing of signals that minimises the distance
  
  if(sum(is.na(d2))>1 | sum(is.na(d1))>1 | length(d1)==0 | length(d2)==0){
    return(NA)
  }
  d1.s = sapply(d1,getSignalX)
  d2.s = sapply(d2,getSignalX)
  if(length(d1.s)==3 & length(d2.s)==3){
  for(i in 1:3){
    dist = dtw(d1.s[[i]],d2.s[[j]],distance.only = T)
    return(dist$distance )#/ max(c(length(d1.s[[i]]),length(d2.s[[j]]))))
  }
  } else{
    return(NA)
  }
}

getSimilarityAcrossChains = function(d1,d2){
  if(sum(is.na(d2))>1 | sum(is.na(d1))>1 | length(d1)==0 | length(d2)==0){
    return(NA)
  }
  d1.s = sapply(d1,getSignalX)
  d2.s = sapply(d2,getSignalX)
  dist = matrix(nrow=length(d1.s),ncol=length(d2.s))
  for(i in 1:length(d1.s)){
    for(j in 1:length(d2.s)){
      distx = c(distance=Inf)
      try(distx<-dtw(d1.s[[i]],d2.s[[j]], distance.only=T))
      # normalise by length of longest signal
      dist[i,j] = distx$distance #/ max(c(length(d1.s[[i]]),length(d2.s[[j]])))
    }
  }
  if(sum(duplicated(dist))>0){
    dist = dist + rnorm()*0.001
  }
  #apply(dist,1,function(X){which(X==min(X))})
  # find minimal matches with greedy algorithm
  foundMatches.d1 = c()
  foundMatches.d2 = c()
  #matches= matrix(nrow=nrow(dist),ncol=2)
  return.distances = c()
  xx = 1
  for(dist.val in sort(dist)){
    mx = which(dist==dist.val,arr.ind=T)
    #if(mx[1]!=mx[2]){
    if(!mx[1] %in% foundMatches.d1 & !mx[2] %in% foundMatches.d2){
      foundMatches.d1 = c(foundMatches.d1,mx[1])
      foundMatches.d2 = c(foundMatches.d2,mx[2])
      #matches[xx,] = mx
      #xx = xx+1
      return.distances = c(return.distances,dist.val)
    }
    #}
  }
  #for(i in 1:nrow(matches)){
  #  dist[matches[i,1],matches[i,2]]
  #}
  return(return.distances)
}

stability.accross.chains = data.frame(run=NA,gen=NA,curvature=NA,chainA=NA,chainB=NA,distance=NA, acousticDistance = NA)
list.names = c("MT","SONA","Nij")
data.list = list(signals_MT,signals_SONA,signals_Nij)
for(i in 1:length(data.list)){
  sigx = data.list[[i]]
  for(curvx in sort(unique(sigx$curvature))){
    sigx2 = sigx[sigx$curvature==curvx,]
    for(gen in sort(unique(sigx2$gen))){
      sigx3 = sigx2[sigx2$gen==gen,]
      chains = unique(sigx3$chain2)
      if(length(chains)>1){
      for(chA in 1:(length(chains)-1)){
        for(chB in (chA+1):length(chains)){
          # Physical signal
          d1 = sigx3[ sigx3$chain2==chains[chA],]$physSignal
          d2 = sigx3[ sigx3$chain2==chains[chB],]$physSignal
          sx = getSimilarityAcrossChains(d1,d2)
          # Acoustic signal
          # USING BARK!!!
          d1a = sigx3[ sigx3$chain2==chains[chA],]$barkSignal
          d2a = sigx3[ sigx3$chain2==chains[chB],]$barkSignal
          sxa = getSimilarityAcrossChains(d1a,d2a)         
          
          stability.accross.chains = 
            rbind(stability.accross.chains,
                  c(list.names[[i]], 
                    gen,curvx, chains[chA],chains[chB],
                    sum(sx), sum(sxa)))
        }
      }
      }
    }
  }
}
stability.accross.chains = stability.accross.chains[!is.na(stability.accross.chains$gen),]
stability.accross.chains$gen = as.numeric(stability.accross.chains$gen)
stability.accross.chains$distance = as.numeric(stability.accross.chains$distance)
stability.accross.chains$acousticDistance = as.numeric(stability.accross.chains$acousticDistance)
stability.accross.chains$curvature = as.numeric(stability.accross.chains$curvature)

save(stability.accross.chains, file = "R/stabilityAcrossChains.Rdat")

#######################
# Signal distance within participants
