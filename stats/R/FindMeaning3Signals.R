library(lme4)
library(blme)

# I ran an analysis on signals that matched the meaning 3 template.  This is the template that is a rise, then a plateau in the middle of the steep region.  
# We predicted that high curvatures would drift away from this onto the flat regions.  
# Because the transmission of signals is very noisy, we can't just take all signals where the meaning == 3.  
# Instead, I automatically detected signals that matched the template.  
# I ran blmer models on this, predicting steepness by curvature and generation (and the interaction), but there were no significant effects.


setwd("/Library/WebServer/Documents/ILMTurk/stats/R")

numDirectionChanges = function(sigx){
  sig = as.numeric(strsplit(sigx,"_")[[1]])
  sum(abs(diff(
    sig[1:(length(sig)-1)] < 5 + sig[2:(length(sig))])))
}

# Meaning 3 starts low, has a flat end, does not overshoot too much
# and does not change direction too often
isMeaning3 = function(sigx){
  sig = as.numeric(strsplit(sigx,"_")[[1]])
  firstValue.good = sig[1] < 200
  beginning = head(sig, length(sig)/6)
  beginning.good = all(beginning < 500)
  # final 5th is flat
  end = tail(sig, length(sig)*0.25)
  flatEnding = diff(range(end)) < 50
  end.length.good = length(end)>6
  
  no.overshoot = (abs(mean(end) - max(sig))) < 500
  # Number of direction changes
  # difference between consecutive measurements is less than 5
  directionChanges = numDirectionChanges(sigx)
  #plot(sig[2:(length(sig))], col= 1+(abs(diff(sig[1:(length(sig)-1)] < 5 + sig[2:(length(sig))]))))
  
  return(
    firstValue.good &
      beginning.good &
      flatEnding & 
      end.length.good &
      directionChanges < 4 & 
      no.overshoot
  )
  
}


# Load data

signals_MT = read.csv("../Data/Signals_MT.csv",stringsAsFactors=F)
signals_SONA = read.csv("../Data/Signals_SONA.csv",stringsAsFactors=F)

signals_MT$run = "MT"
signals_SONA$run = "SONA"

for(dx in list(signals_MT, signals_SONA)){
    
    # remove cases without values
    dx = dx[!is.na(dx$prop.time.plateau),]
    
    # remove chains with only one generaion
    numOfGensPerChain = tapply(dx$gen,dx$chain2,function(X){length(unique(X))})
    
    dx = dx[!dx$chain2 %in%
              names(numOfGensPerChain)[
                which(numOfGensPerChain==1)],]
    
    # normalise
    dx$prop.time.plateau.norm = dx$prop.time.plateau - mean(dx$prop.time.plateau)
    dx$steepness.sig.mean.max.norm = dx$steepness.sig.mean.max - mean(dx$steepness.sig.mean.max)
    dx$gen = dx$gen - 5
    dx$curvature.center = dx$curvature - 0.2
    dx$participant = paste(dx$chain2, dx$gen)
    dx$numDirectionChanges = sapply(dx$physSignal,numDirectionChanges)
    
    # Find plateau signals
    dx$isMeaning3Template = sapply(dx$physSignal, isMeaning3)
    sum(dx$isMeaning3Template)
    
    col=rainbow(sum(dx$isMeaning3Template))
    plot(0:1,c(0,1000), type='n')
    for(i in 1:sum(dx$isMeaning3Template)){
      ix = which(dx$isMeaning3Template)[i]
      sig = as.numeric(strsplit(dx[ix,]$physSignal,"_")[[1]])
      lines(seq(0,1,length.out=length(sig)), sig, col=col[i])
    }
    
    # get rid of other signals
    dx = dx[dx$isMeaning3Template,]
    
    bcontrol = lmerControl(optimizer = 'Nelder_Mead')
    
    m0= blmer(steepness.sig.mean.max.norm~
                1 + 
                (1 | chain2) + 
                (1 | participant), 
              data = dx,
              control = bcontrol)
    
    # add curavture
    m1= blmer(steepness.sig.mean.max.norm~
                1 + 
                curvature.center +
                (1 | chain2) +
                (1 | participant), 
              data = dx,
              control = bcontrol)
    # add generation
    m2= blmer(steepness.sig.mean.max.norm~
                1 + 
                curvature.center +
                gen +
                (1 | chain2) + 
                (1 | participant), 
              data = dx,
              control = bcontrol)
    # add interaction between curvature and generation
    m3= blmer(steepness.sig.mean.max.norm~
                1 + 
                curvature.center +
                gen +
                curvature.center : gen +
                (1 | chain2) + 
                (1 | participant), 
              data = dx,
              control = bcontrol)
    
    print(anova(m0,m1,m2,m3))
}