
signals_MT = read.csv("../Data/Signals_MT.csv",stringsAsFactors=F)
signals_SONA = read.csv("../Data/Signals_SONA.csv",stringsAsFactors=F)

signals_MT$run = "MT"
signals_SONA$run = "SONA"

dx = rbind(signals_MT,signals_SONA)
dx$run = relevel(as.factor(dx$run),"SONA")

dx$chain2 = paste(dx$run,dx$chain2)

plotmeans(prop.time.plateau~curvature, data=dx, ylab="Proporiton of time on the plateau", xlab='Curvature')

dx = dx[!is.na(dx$prop.time.plateau),]

dx$prop.time.plateau.norm = dx$prop.time.plateau - mean(dx$prop.time.plateau)
dx$gen = dx$gen - 5
dx$curvature.center = dx$curvature - 0.2

dx$steepness.sig.mean.max.norm = dx$steepness.sig.mean.max - mean(dx$steepness.sig.mean.max)




m0= lmer(prop.time.plateau.norm~
           1 + 
           (1 | chain2) + 
      (1 | meaning) +     (1  + curvature| run), 
         data = dx)

# add curavture
m1= lmer(prop.time.plateau.norm~
           1 + 
           curvature.center +
           (1 | chain2) + 
      (1 | meaning) +     (1  + curvature| run), 
         data = dx)
# add generation
m2= lmer(prop.time.plateau.norm~
           1 + 
           curvature.center +
           gen +
           (1 | chain2) + 
      (1 | meaning) +     (1  + curvature| run), 
         data = dx,
         control = lmerControl(optimizer = "Nelder_Mead", optCtrl = list(maxfun=500000)))
# add interaction between curvature and generation
m3= lmer(prop.time.plateau.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           (1 | chain2) + 
      (1 | meaning) +     (1  + curvature| run), 
         data = dx)
# Quadratic term of curvature
m4= lmer(prop.time.plateau.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           I(curvature^2) +
           (1 | chain2) + 
      (1 | meaning) +     (1  + curvature| run), 
         data = dx)
# Interaction between quadratic term of curvature and generation
m5= lmer(prop.time.plateau.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           I(curvature^2) +
           I(curvature^2):gen +
           (1 | chain2) + 
      (1 | meaning) +     (1  + curvature| run), 
         data = dx)

anova(m0,m1,m2,m3,m4,m5)

##########
####################
##########
##########


# Null model
m0= lmer(steepness.sig.mean.max.norm~
           1 + 
           (1 + gen | chain2) + 
           (1 | meaning) + (1 + curvature| run), 
         data = dx)

# add curavture
m1= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           (1 + gen | chain2) + 
           (1 | meaning) + (1 + curvature| run), 
         data = dx)
# add generation
m2= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           (1 + gen | chain2) + 
           (1 | meaning) + (1 + curvature| run), 
         data = dx)
# add interaction between curvature and generation
m3= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           (1 + gen | chain2) + 
           (1 | meaning) + (1 + curvature| run), 
         data = dx)
# Quadratic term of curvature
m4= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           I(curvature^2) +
           (1 + gen | chain2) + 
           (1 | meaning) + (1 + curvature| run), 
         data = dx)

# Interaction between quadratic term of curvature and generation
m5= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           I(curvature^2) +
           I(curvature^2):gen +
           (1 + gen | chain2) + 
           (1 | meaning) + (1 + curvature| run), 
         data = dx)

anova(m0,m1,m2,m3,m4,m5)
