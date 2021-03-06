library(jointseg)

## Load original data
if (FALSE) {
    dat <- loadCnRegionData(tumorFraction=0.7, dataSet="GSE29172")
    ## simplifying: remove CN probes (otherwise ASCAT gives an error because of its genotyping step)
    dat <- subset(dat, !is.na(b))    
} else {
    dat <- loadCnRegionData(tumorFraction=0.79, dataSet="GSE11976")
}

n <- 2e4 ## Length of simulated profile
K <- 20 ## Number of breakpoints

## Profile generation
sim <- getCopyNumberDataByResampling(n, K, regData=dat)
datS <- sim$profile

## ASCAT segmentation
system.time(res <- PSSeg(datS, method="ASCAT"))
res$bestBkp
plotSeg(datS, list(sim$bkp, res$bestBkp))

## Compare with RBS+DP
system.time(res2 <- PSSeg(datS, method="RBS", stat=c("c", "d"), K=100))
res2$bestBkp

## performance assessment as a function of tolerance
sapply(0:5, FUN=function(tol) getTpFp(res2$bestBkp, sim$bkp, tol=tol))
sapply(0:5, FUN=function(tol) getTpFp(res$bestBkp, sim$bkp, tol=tol))

## plot a ROC curve for a given tolerance value
tol <- 0
bkpList <- res$dpBkpList
bkpList2 <- res2$dpBkpList

roc <- sapply(bkpList, getTpFp, sim$bkp, tol)
roc2 <- sapply(bkpList2, getTpFp, sim$bkp, tol)

ylim <- c(0, max(roc["TP", ], roc2["TP", ]))

plot(roc["FP", ], roc["TP", ], t='s', ylim=ylim)
lines(roc2["FP", ], roc2["TP", ], t='s', col=2)
