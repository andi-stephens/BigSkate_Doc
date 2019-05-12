### notes on retros, doing jitters, and making associated plots
### for 2019 Big Skate assessment

#stop("\n  This file should not be sourced!") # note to stop Ian from accidental sourcing

# define directory on a specific computer
if(Sys.info()["user"] == "Ian.Taylor"){
  dir.outer <- c('c:/SS/skates/models')
}

require(r4ss)
require(SSutils) # package with functions for copying SS input files
#devtools::install_github('r4ss/SSutils')

# load model output into R
# read base model from each area
mod <- 'bigskate72_share_dome'
dir.mod <- file.path(dir.outer, mod)

# run retrospectives
# (default is to create a new directory "retrospectives" within masterdir
# and then fill that fill directorys with names like "retro-2")
SS_doRetro(masterdir = dir.mod, oldsubdir = "")

# make retro plot
legendlabels <- c("Base Model", paste("Data",-1:-5,"years"))

# retro North
# make time-series plots
retro.mods <- SSgetoutput(dirvec=file.path(dir.mod, 'retrospectives',
                             paste0("retro",0:-5)))
# replace one that had a bad Hessian
## retroMods.N[[6]] <- SS_output(file.path(YTdir.mods,
##                                         'retrospectives/retro.N/retro-5_nohess'))
retro.summary <- SSsummarize(retro.mods)
endyrvec <- retro.summary$endyrs + 0:-5
# general timeseries plots
SSplotComparisons(retro.summary, endyrvec=endyrvec, png=TRUE, indexUncertainty=TRUE,
                  legendloc=c(0,0.4), spacepoints=10000,
                  plotdir=file.path(dir.mod, 'retrospectives'),
                  filenameprefix="retro_", 
                  legendlabels=paste("Data",0:-5,"years"))
# fits to indices
for(index in unique(retro.summary$indices$Fleet)){
  #index <- 5
  SSplotComparisons(retro.summary, endyrvec=endyrvec, png=TRUE, indexUncertainty=TRUE,
                    plotdir=file.path(dir.mod, 'retrospectives'),
                    subplot=11:12,indexfleets=index,
                    #indexPlotEach=TRUE,
                    legendloc='top',
                    filenameprefix="retro_", 
                    legendlabels=paste("Data",0:-5,"years"))
}

dir.jit <- file.path(dir.mod, "jitter")
copy_SS_inputs(dir.old = dir.mod,
               dir.new = dir.jit,
               use_ss_new = TRUE,
               copy_exe = TRUE,
               copy_par = TRUE)

# run jitter
SS_RunJitter(dir.jit, Njitter=100)