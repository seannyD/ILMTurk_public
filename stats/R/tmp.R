## Steepness measure

Build a series of lmer models predicting the average steepness of signals (normalised using the maximum steepenss values) by curvature and generation.  We add a random effect for chain and meaning, with random slopes for curature and generation by chain.

Plot mean steepenss by curvature.

```{r}
plotmeans(steepness.sig.mean.max~curvature, data=dx, ylab="Mean signal steepness", xlab='Curvature')
```

Normalise variables:
  
  ```{r}
dx$steepness.sig.mean.max.norm = dx$steepness.sig.mean - mean(dx$steepness.sig.mean)
```

Choose random effects:
  
  
  ```{r}
m0= lmer(steepness.sig.mean.max.norm~
           1 + 
           (1 | chain2) + 
           (1 | meaning), 
         data = dx)

m1= lmer(steepness.sig.mean.max.norm~
           1 + 
           (1 + curvature.center | chain2) + 
           (1 | meaning), 
         data = dx)

anova(m0,m1)
# Significant difference


m2= lmer(steepness.sig.mean.max.norm~
           1 + 
           (1 + curvature.center + gen | chain2) + 
           (1 | meaning), 
         data = dx)

anova(m1,m2)

# Marginal, let's keep it

m3= lmer(prop.time.plateau.norm~
           1 + 
           (1 + curvature.center + gen | chain2) + 
           (1 + curvature.center| meaning), 
         data = dx)

anova(m2,m3)

# No significant improvement

m4= lmer(prop.time.plateau.norm~
           1 + 
           (1 + curvature.center + gen | chain2) + 
           (1 + gen | meaning), 
         data = dx)
anova(m2,m4)

# No significant difference
```

Keep only a random slope by curvature and gen for chain.

```{r}
# Null model
m0= lmer(steepness.sig.mean.max.norm~
           1 + 
           (1 + curvature.center + gen | chain2) + 
           (1 | meaning), 
         data = dx)

# add curavture
m1= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           (1 + curvature.center + gen | chain2) + 
           (1 | meaning), 
         data = dx)
# add generation
m2= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           (1 + curvature.center + gen | chain2) + 
           (1 | meaning), 
         data = dx)
# add interaction between curvature and generation
m3= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           (1 + curvature.center + gen | chain2) + 
           (1 | meaning), 
         data = dx)
# Quadratic term of curvature
m4= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           I(curvature^2) +
           (1 + curvature.center + gen | chain2) + 
           (1 | meaning), 
         data = dx)

# Interaction between quadratic term of curvature and generation
m5= lmer(steepness.sig.mean.max.norm~
           1 + 
           curvature.center +
           gen +
           curvature : gen +
           I(curvature^2) +
           I(curvature^2):gen +
           (1 + curvature.center + gen | chain2) + 
           (1 | meaning), 
         data = dx)
```

Use model comparison to test the effect of each variable.

```{r}
anova(m0,m1,m2,m3,m4,m5)
```