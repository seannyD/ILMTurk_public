# Expressiveness measure

dx = signals_MT

# remove cases without values
dx = dx[!is.na(dx$prop.time.plateau),]

# remove chains with only one generaion
numOfGensPerChain = tapply(dx$gen,dx$chain2,function(X){length(unique(X))})

dx = dx[!dx$chain2 %in%
          names(numOfGensPerChain)[
            which(numOfGensPerChain==1)],]

dx$gen = dx$gen - 5
dx$curvature.center = dx$curvature - 0.2

dx$participant = paste(dx$chain2, dx$gen)

dx$expressiveness.sig.mean.max.norm = dx$expressiveness.sig.mean.max - mean(dx$expressiveness.sig.mean.max)

m0 = blmer(expressiveness.sig.mean.max.norm ~
            1+
            (1 | chain2) + 
            (1 | participant) +
            (1 | meaning),
          data = dx,
          control = bcontrol)

m1 = blmer(expressiveness.sig.mean.max.norm ~
            curvature.center+
            (1 | chain2) + 
            (1 | participant) +
            (1 | meaning),
          data = dx,
          control = bcontrol)

m2 = blmer(expressiveness.sig.mean.max.norm ~
             gen + curvature.center+
             (1 | chain2) + 
             (1 | participant) +
             (1 | meaning),
           data = dx,
           control = bcontrol)

m3 = blmer(expressiveness.sig.mean.max.norm ~
             gen * curvature.center+
             (1 | chain2) + 
             (1 | participant) +
             (1 | meaning),
           data = dx,
           control = bcontrol)



anova(m0,m1,m2,m3)

plotmeans(expressiveness.sig.mean.max ~ curvature, dx)
