setwd("/Library/WebServer/Documents/ILMTurk/stats/upsid")

res = data.frame(position=NA,nLangs=NA,n=NA,p=NA)
for(i in list.files(".",'*.txt')){
  d = readLines(i)
  
  nLangs = strsplit(d[which(nchar(d)==0)[3]+1]," ")[[1]][2]
  
  d = d[nchar(d)>0]
  x = d[1]#grep("The '([a-zA-Z /]+)' sounds",d,value=T)
  position = strsplit(x,"'")[[1]][2]
  x2 = d[length(d)]
  x2 = strsplit(x2," ")[[1]]
  nSounds = as.numeric(x2[2])
  pSounds = as.numeric(gsub("%","",x2[5]))
  res = rbind(res,c(position,nLangs,nSounds,pSounds))
}
res$p = as.numeric(res$p)
res$n = as.numeric(res$n)
res$nLangs = as.numeric(res$nLangs)

res = res[!res$position%in%c("labial-palatal","labial-velar","velar-alveolar"),]

par(bg=rgb(0,0,0,0))
barplot(res$nLangs, col= 'red', ylab='',yaxt='n',border=NA)

res2 = res[res$position %in% c("bilabial","labiodental",'dental','alveolar','palatal','velar','uvular','pharyngeal','glottal'),]
svg("../upsid/BARS_Esling.svg")
par(bg=rgb(0,0,0,0))
barplot(res2$nLangs, col= 'red', ylab='',yaxt='n',border=NA)
dev.off()