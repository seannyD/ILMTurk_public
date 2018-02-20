library(influence.ME)

dx = signals_SONA
dx = dx[!is.na(dx$prop.time.plateau),]
dx$gen = dx$gen - 5
dx$curvature.center = dx$curvature - 0.2
dx$steepness.sig.mean.max.norm = dx$steepness.sig.mean.max - mean(dx$steepness.sig.mean.max)

m3= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           (1| chain2) + 
           (1 | meaning), 
         data = dx)

inf.m3 = influence(m3, obs = T)
plot(inf.m3)
plot(cooks.distance(inf.m3))

# chain 1 log1.csv 0.5, Gen 5 has an outlying point.