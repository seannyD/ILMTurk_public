dx$jerkyness.log = log(dx$jerkyness+1)

plotmeans(jerkyness.log~curvature, data=dx)

m0= lmer(jerkyness.log~
           1 + 
           (1 | chain2) + 
           
           (1 | meaning), 
         data = dx)

# add curavture
m1= lmer(jerkyness.log~
           1 + 
           curvature.center +
           (1 | chain2) + 
           
           (1 | meaning), 
         data = dx)
# add generation
m2= lmer(jerkyness.log~
           1 + 
           curvature.center +
           gen +
           (1 | chain2) + 
           
           (1 | meaning), 
         data = dx)
# add interaction between curvature and generation
m3= lmer(jerkyness.log~
           1 + 
           curvature.center +
           gen +
           curvature.center : gen +
           (1 | chain2) + 
           
           (1 | meaning), 
         data = dx)

anova(m0,m1,m2,m3)