# =============================================================================
# R script for Executive summary figures and tables                      
# The script for the tables is in the order they appear in the document!
#                                                                       
# BELOW IS THE ORDER OF THE TABLES & FIGURES IN THIS SCRIPT              
# If you're looking for a particular figure/table to edit you can search by the number
#
# 1. Recent history of catches figure and tables (need to edit Exec_catch_for_figs.csv)
#      OR, you can comment this plot out, and just use the r4ss generated plot included
#      in the in the main R markdown document 
# 2. Spawning stock output and depletion
# 3. Recruitment
# 4. SPR and exploitation
# 5. Reference points
# 6. Management performance (need to edit Exec_mngmt_performance.csv and maybe table)
# 7. OFL projections
# 8. Decision tables  (need to edit DecisionTable_mod1.csv and other if multiple models)
# 9. Base model summary (need to edit)
#
# Melissa Monk, NMFS
# =============================================================================


# =============================================================================
# 1. Catch FIGURE(S) ----------------------------------------------------------
# Required: Read in CSV file, edit this section depending on # of plots!!
# # Read in executive summary catches figure file
# Exec_catch =  read.csv('./txt_files/Exec_catch_for_figs.csv')
# 
# # Assign column names
# colnames(Exec_catch) = c('Year',
#                          'Fleet 1',
#                          'Fleet 2',
#                          'Fleet 3',
#                          'Fleet 4',
#                          'Fleet5')
# 
# # Split catch by regions -retaning the colunns for each -you'll have to edit
# Exec_region1_catch = Exec_catch[,c(1:2)]
# Exec_region2_catch = Exec_catch[,c(1,3,4)]
# Exec_region3_catch = Exec_catch[,c(1,5,6)]
# 
# # Melt data so it can be plotted
# Exec_region1_catch = melt(Exec_region1_catch, id='Year')
# Exec_region2_catch = melt(Exec_region2_catch, id='Year')
# Exec_region3_catch = melt(Exec_region3_catch, id='Year')
# 
# # Reassign column names
# colnames(Exec_region1_catch) = c('Year','Fleet','Removals')
# colnames(Exec_region2_catch) = c('Year','Fleet','Removals')
# colnames(Exec_region3_catch) = c('Year','Fleet','Removals')
# 
# # Plot catches function
# Plot_catch = function(Catch_df) {
#   ggplot(Catch_df, aes(x=Year, y=Removals,fill=Fleet)) +
#     geom_area(position='stack') +
#     scale_fill_manual(values=c('lightsteelblue3','coral')) +
#     scale_x_continuous(breaks=seq(Dat_start_mod1, Dat_end_mod1, 20)) +
#     ylab('Landings (mt)')
# }
# 
# # -----------------------------------------------------------------------------
# # CATCH TABLE(S) --------------------------------------------------------------

# Read in executive summary catches table
Exec_catch_summary = read.csv('./txt_files/Exec_catch_summary.csv')

# Assign column names as they should appear in the table; change the alignment 
# to match number of columns +1
colnames(Exec_catch_summary) = c('Year', 
                                 'Landings')

# Make executive summary catch xtable
Exec_catch.table = xtable(Exec_catch_summary,
                          digits = c(0,0,1),
                          caption = c(paste('Recent ',spp,' landings (mt)', sep='')), 
                          label='tab:Exec_catch')

# Add alignment - you will have to adjust based on the number of columns you have
# and the desired width, remember to add one leading ghost column for row.names
align(Exec_catch.table) = c('l',
                            '>{\\centering}p{1in}',  
                            '>{\\centering}p{1in}')  


# =============================================================================
# Spawning output and Depletion -----------------------------------------------

# Retreive data on spawning output and depletion
for (model in 1:n_models) {
  if (model==1) {
    mod=mod1
    mod_area='mod1'
  } else {
    
    if (model==2) {
      mod=mod2
      mod_area='mod2'
    } else {
      
      mod=mod3
      mod_area='mod3'
    }}
  
  # Extract biomass/output  
  SpawningB = mod$derived_quants[grep('SSB', mod$derived_quants$Label), ]
  SpawningB = SpawningB[c(-1, -2), ]
  
  
  # Spawning biomass and std.dev data, calculate lower and upper 95% CI                 
  SpawningByrs = SpawningB[SpawningB$Label >= paste('SSB_', FirstYR+1,sep='') 
                           & SpawningB$Label <= paste('SSB_', LastYR+1,sep=''), ]     
  
  SpawningByrs$YEAR = seq(FirstYR+1, LastYR+1)

  digits <- 1
  SpawningByrs$lowerCI = round(SpawningByrs$Value + 
                                 qnorm(0.025) * SpawningByrs$StdDev, 
                               digits = digits)
  
  SpawningByrs$upperCI = round(SpawningByrs$Value - 
                                 qnorm(0.025) * SpawningByrs$StdDev, 
                               digits = digits)
  
  # Save individual depletion table before CI combined to character
  assign(paste('SpawnB_', mod_area, sep = ''), SpawningByrs)
  SpawnB = SpawningByrs  
  
  # Calculate confidence intervals
  SpawningByrs$CI = paste('(', SpawningByrs$lowerCI, '-', SpawningByrs$upperCI, ')', 
                          sep = '')
  SpawningBtab = subset(SpawningByrs, select = c('YEAR', 'Value', 'CI'))
  
  # Assign column names
  colnames(SpawningBtab) = c('Year', paste('Spawning Biomass (', fecund_unit,')', 
                                           sep=''), '~ 95% confidence interval')
  
  
  
  
  # Extract Depletion values  
  Depletion = mod$derived_quants[grep('Bratio', mod$derived_quants$Label), ]
  Depletion = Depletion[c(-1, -2), ]
  
  # Estimated depletion, pull out correct years, list years, and estimate 95% CI
  Depletionyrs = Depletion[Depletion$Label >= paste('Bratio_', FirstYR+1,sep='') &
                             Depletion$Label <= paste('Bratio_', LastYR+1,sep=''), ]     
  
  Depletionyrs$YEAR = seq(FirstYR+1, LastYR+1)
  
  Depletionyrs$Value = round(Depletionyrs$Value, digits=3)
  
  Depletionyrs$lowerCI = round(Depletionyrs$Value + 
                                 qnorm(0.025)*Depletionyrs$StdDev, digits=3)
  
  Depletionyrs$upperCI = round(Depletionyrs$Value - 
                                 qnorm(0.025)*Depletionyrs$StdDev, digits=3)
  
  # Save individual depletion tables
  assign(paste('Deplete_', mod_area, sep=''), Depletionyrs)
  Deplete = Depletionyrs     
  
  Depletionyrs$CI = paste('(', Depletionyrs$lowerCI, '-', Depletionyrs$upperCI, ')', 
                          sep = '')
  
  Depletiontab = subset(Depletionyrs, select=c('Value', 'CI'))
  
  colnames(Depletiontab) = c('Fraction Unfished', '~ 95% confidence interval')
  
  # Bind the spawning biomass and depletion data together 
  Spawn_Deplete = cbind(SpawningBtab, Depletiontab)
  
  colnames(Spawn_Deplete) = c('Year', 
                              paste('Spawning Biomass (', fecund_unit, ')', sep = ''), 
                              '~ 95% confidence interval',
                              'Fraction Unfished',
                              '~ 95% confidence interval')
  
  # Assign a model number to the Spawn_deplete table, if you do cbind within this step
  assign(paste('SpawnDeplete_',mod_area,sep=''), Spawn_Deplete)
  
  # 9.1.15 R now won't read the file with any underscores for xtable,
  # so use SpawnDeplete without spaces for that  
  assign(paste('SpawnDeplete',mod_area, sep=''), Spawn_Deplete)
  
  assign(paste('Depl_',mod_area, sep=''), percent(Deplete[nrow(Deplete), 2]))
  
  assign(paste('Depl_',mod_area,'_CI',sep=''), 
         paste(percent(Deplete[nrow(Deplete), 7]), '-', 
               percent(Deplete[nrow(Deplete), 8]), sep=''))
  
  assign(paste('Spawn_', mod_area, sep=''), SpawnB[nrow(SpawnB), 2])
  
  assign(paste('Spawn_',mod_area,'_CI',sep=''), 
         paste(round(SpawnB[nrow(SpawnB), 7]), '-',
               round(SpawnB[nrow(SpawnB), 8]), sep=''))
  
} # end model for loop for spawning biomass and depletion


# =============================================================================
# =============================================================================
# Create Spawning/Depletion tables for the correct number of models
# Model 1 table ---------------------------------------------------------------
Spawn_Deplete_mod1.table <- xtable(SpawnDepletemod1,
                                   caption = 'Recent trend in beginning of the 
                                      year spawning biomass and fraction unfished
                                      (spawning biomass relative to unfished
                                      equilibrum spawning biomass)', 
                                   label='tab:SpawningDeplete_mod1',
                                   digits = c(0,0,1,0,3,0))


# Add column spacing    
align(Spawn_Deplete_mod1.table) = c('l', 'l', 
                                    '>{\\centering}p{1.3in}', 
                                    '>{\\centering}p{1.2in}', 
                                    '>{\\centering}p{1in}', 
                                    '>{\\centering}p{1.2in}')  

# =============================================================================
# Recruitment =================================================================

# Extract recruitment values
for (model in 1:n_models) {
  if (model==1) {
    mod=mod1
    mod_area='mod1'
  } else {
    if (model==2) {
      mod=mod2
      mod_area='mod2'
    } else {
      mod=mod3
      mod_area='mod3'
    }}

  digits <- 0
  
  # Pull out recuitment  
  Recruit = mod$derived_quants[grep('Recr',mod$derived_quants$Label),]
  Recruit = Recruit[c(-1,-2),]
  
  # Recruitment and std.dev data, calculate lower and upper 95% CI                 
  Recruityrs = Recruit[Recruit$Label >= paste('Recr_', FirstYR+1, sep = '') &  
                         Recruit$Label <= paste('Recr_', LastYR+1, sep = ''), ]     
  
  Recruityrs$YEAR = seq(FirstYR+1, LastYR+1)
  
  # assume recruitments have log-normal distribution 
  # from first principals (multiplicative survival probabilities)
  Recruityrs$logint <- sqrt(log(1+(Recruityrs$StdDev/Recruityrs$Value)^2))
  Recruityrs$lowerCI <- exp(log(Recruityrs$Value) + qnorm(0.025)*Recruityrs$logint)
  Recruityrs$upperCI <- exp(log(Recruityrs$Value) + qnorm(0.975)*Recruityrs$logint)
  
  Recruit_units <- "1,000s"
  if(mean(Recruityrs$Value) > 10000){
    Recruit_units <- "millions"
    Recruityrs$Value <- Recruityrs$Value/1000
    Recruityrs$lowerCI <- Recruityrs$lowerCI/1000
    Recruityrs$upperCI <- Recruityrs$upperCI/1000
  }
  
  Recruityrs$CI = paste('(', round(Recruityrs$lowerCI, digits = digits), 
                        ' - ', round(Recruityrs$upperCI, digits = digits), ')', sep='')
  
  Recruityrs$Value = round(Recruityrs$Value, digits = digits)
  
  Recruittab=subset(Recruityrs, select = c('YEAR', 'Value', 'CI'))
  
  colnames(Recruittab) = c('Year',
                           paste0('Estimated Recruitment (',Recruit_units,')'),
                           '~ 95% confidence interval')
  
  assign(paste('Recruittab_',mod_area,sep=''), Recruittab)
  
} # end model loop for recruitment


# -----------------------------------------------------------------------------
# Create recruitment tables

# Model 1 table
Recruit_mod1.table = xtable(Recruittab_mod1, 
                            caption = c(paste('Recent recruitment for the ', 
                                              mod1_label, '.', sep='')),
                            label = 'tab:Recruit_mod1', digits = digits)   

align(Recruit_mod1.table) = c('l',
                              '>{\\centering}p{.8in}',
                              '>{\\centering}p{1.6in}',
                              '>{\\centering}p{2in}')


# =============================================================================
# Exploitation data -----------------------------------------------------------

# Extract exploitation values
for (model in 1:n_models) {
  if (model == 1) {
    mod = mod1
    mod_area = 'mod1'
  } else {
    if (model == 2){
      mod = mod2
      mod_area = 'mod2'
    } else {
      mod = mod3
      mod_area = 'mod3'
    }}  

  digits <- 3
  
  # Extract exploitation and SPR ratio values from r4SS output
  Exploit = mod$derived_quants[grep('F',mod$derived_quants$Label),]
  Exploit = Exploit[c(-1,-2),]
  
  SPRratio = mod$derived_quants[grep('SPRratio',mod$derived_quants$Label),]
  SPRratio = SPRratio[c(-1,-2),]
  
  # Exploitation and calculate lower and upper 95% CI                 
  Exploityrs = Exploit[Exploit$Label >= paste('F_', FirstYR, sep='') &
                         Exploit$Label <= paste('F_', LastYR, sep=''), ]     
  
  Exploityrs$YEAR = seq(FirstYR, LastYR)
  
  Exploityrs$lowerCI = round(Exploityrs$Value +
                               qnorm(0.025) * Exploityrs$StdDev, digits = digits)
  
  Exploityrs$upperCI = round(Exploityrs$Value -
                               qnorm(0.025) * Exploityrs$StdDev, digits = digits)
  
  Exploityrs$CI = paste('(', Exploityrs$lowerCI, '-', Exploityrs$upperCI, ')', sep='')
  
  Exploittab = subset(Exploityrs, select=c('Value', 'CI'))
  
  colnames(Exploittab) = c('Exploitation rate', '~ 95% confidence interval')
  
  
  # Spawning potential ratio and calculate lower and upper 95% CI  
  SPRratioyrs = SPRratio[SPRratio$Label >= paste('SPRratio_', FirstYR, sep='') 
                         & SPRratio$Label <= paste('SPRratio_', LastYR, sep=''), ]     
  
  SPRratioyrs$Year = seq(FirstYR, LastYR)
  
  SPRratioyrs$lowerCI = round(SPRratioyrs$Value +
                                qnorm(0.025) * SPRratioyrs$StdDev, digits = digits)
  
  SPRratioyrs$upperCI = round(SPRratioyrs$Value -
                                qnorm(0.025) * SPRratioyrs$StdDev, digits = digits)
  
  SPRratioyrs$CI = paste('(', SPRratioyrs$lowerCI, '-', SPRratioyrs$upperCI, ')', sep='')
  
  SPRratiotab = subset(SPRratioyrs, select = c('Year', 'Value', 'CI'))
  
  SPRratiotab$Year = as.factor(SPRratiotab$Year)
  
  colnames(SPRratiotab) = c('Year', 'Relative fishing intensity', '~ 95% confidence interval')
  
  assign(paste('SPRratio_Exploit_', mod_area, sep=''), cbind(SPRratiotab, Exploittab))
  
} # end for loop for SPR ratio and exploitation

# =============================================================================
# Create the three tables for SPR Ratio and Exploitation

# Model 1 
SPRratio_Exploit_mod1.table <- xtable(SPRratio_Exploit_mod1, 
                                      caption=c(paste('Recent trend in spawning potential 
                                        ratio and exploitation for ', spp, ' in the ', 
                                          mod1_label, '.  Relative fishing intensity is (1-SPR) 
                                        divided by 50\\% (the SPR target) and exploitation 
                                        is catch divided by age 2+ biomass.', sep='')), 
                                      label='tab:SPR_Exploit_mod1',
                                      digits = c(0,0,3,0,3,0))  

align(SPRratio_Exploit_mod1.table) = c('l','l',
                                       '>{\\centering}p{1in}',
                                       '>{\\centering}p{1.2in}',
                                       '>{\\centering}p{1in}',
                                       '>{\\centering}p{1.2in}') 

# =============================================================================
# Reference points ------------------------------------------------------------

# Extract reference points table data
for (model in 1:n_models) {
  if (model == 1){
    mod = mod1
    mod_area = 'mod1'
  } else {
    if(model == 2) {
      mod = mod2
      mod_area = 'mod2'
    } else {
      mod = mod3
      mod_area = 'mod3'
    }}
  
  
  # Rbind all of the data for the big summary reference table  
  Ref_pts = rbind (
    SSB_Unfished    = mod$derived_quants[grep('SSB_I', mod$derived_quants$Label), ],
    SmryBio_Unfished = mod$derived_quants[grep('SmryBio', mod$derived_quants$Label, ignore.case=TRUE), ],
    Recr_Unfished   = mod$derived_quants[grep('Recr_I', mod$derived_quants$Label), ],
    SSB_lastyr      = mod$derived_quants[grep(paste0('SSB_', LastYR+1), mod$derived_quants$Label), ],
    Depletion_lastyr= mod$derived_quants[grep(paste0('Bratio_', LastYR+1), mod$derived_quants$Label), ],
    Refpt_sB        = c(NA, NA, NA),
    SSB_Btgt        = mod$derived_quants[grep('SSB_Btgt', mod$derived_quants$Label), ],
    SPR_Btgt        = mod$derived_quants[grep('SPR_Btgt', mod$derived_quants$Label), ],
    Fstd_Btgt       = mod$derived_quants[grep('Fstd_Btgt', mod$derived_quants$Label), ],
    TotYield_Btgt   = mod$derived_quants[grep('Dead_Catch_B', mod$derived_quants$Label), ],  #changed 4/29/2019 from TotYield_Btgt
    Refpt_SPR       = c(NA, NA, NA),
    SSB_SPRtgt      = mod$derived_quants[grep('SSB_SPR', mod$derived_quants$Label), ],
    SPR_proxy       = c('SPR_proxy', .5, NA),
    Fstd_SPRtgt     = mod$derived_quants[grep('Fstd_SPR', mod$derived_quants$Label), ],
    TotYield_SPRtgt = mod$derived_quants[grep('Dead_Catch_SPR', mod$derived_quants$Label), ], #changed 4/29/2019 from TotYield_SPRtgt
    Refpts_MSY      = c(NA, NA, NA),
    SSB_MSY         = mod$derived_quants[grep('SSB_MSY', mod$derived_quants$Label), ],
    SPR_MSY         = mod$derived_quants[grep('SPR_MSY', mod$derived_quants$Label), ],
    Fstd_MSY        = mod$derived_quants[grep('Fstd_MSY', mod$derived_quants$Label), ],
    DeadYield_MSY    = mod$derived_quants[grep('Dead_Catch_MSY', mod$derived_quants$Label), ], #changed 4/29/2019 from TotYield_MSY
    RetYield_MSY    = mod$derived_quants[grep('Ret_Catch_MSY', mod$derived_quants$Label), ]) #changed 4/29/2019 and added as TotYield is now separated 
  Ref_pts         = Ref_pts[, 1:3]
  Ref_pts$Value   = as.numeric(Ref_pts$Value)
  Ref_pts$StdDev  = as.numeric(Ref_pts$StdDev)
  
  
  Ref_pts$places  = ifelse(Ref_pts$Value >= 1, 
                           nchar(round(Ref_pts$Value)), NA) 
  
  Ref_pts$Value1  = ifelse((Ref_pts$Value >= 1 & Ref_pts$Label !='SmryBio_unfished'), 
                           comma(ifelse(nchar(round(Ref_pts$Value))>5, 
                                        Ref_pts$Value/10^(nchar(round(Ref_pts$Value))-4), Ref_pts$Value), big.mark=','), 
                           ifelse(Ref_pts$Label == 'SmryBio_unfished', comma(Ref_pts$Value, big.mark=','), 
                                  round(Ref_pts$Value, 3)))  
  
  
  Ref_pts$lowerCI  = round(Ref_pts$Value + qnorm(0.025) * Ref_pts$StdDev, digits = 3)
  
  Ref_pts$upperCI  = round(Ref_pts$Value - qnorm(0.025) * Ref_pts$StdDev, digits = 3)
  
  
  Ref_pts$lowerCI1 = ifelse((abs(Ref_pts$lowerCI) >= 1 & Ref_pts$Label !='SmryBio_unfished'), 
                            comma(ifelse(nchar(round(Ref_pts$lowerCI))>5, 
                                         Ref_pts$lowerCI/10^(nchar(round(Ref_pts$lowerCI))-4), Ref_pts$lowerCI), big.mark=','), 
                            ifelse(Ref_pts$Label == 'SmryBio_unfished', comma(Ref_pts$lowerCI, big.mark=','), 
                                   round(Ref_pts$lowerCI, 3)))  
  
  Ref_pts$upperCI1 = ifelse((Ref_pts$upperCI >= 1 & Ref_pts$Label !='SmryBio_unfished'), 
                            comma(ifelse(nchar(round(Ref_pts$upperCI))>5, 
                                         Ref_pts$upperCI/10^(nchar(round(Ref_pts$upperCI))-4), Ref_pts$upperCI), big.mark=','), 
                            ifelse(Ref_pts$Label == 'SmryBio_unfished', comma(Ref_pts$upperCI, big.mark=','), 
                                   round(Ref_pts$upperCI, 3)))  
  
  
  
  
  
  
  
  Quantity = c(paste('Unfished spawning biomass (', fecund_unit, ')', sep = ''),
               paste('Unfished age ', min_age, ' biomass (mt)', sep = ''),
               'Unfished recruitment ($R_{0}$, thousands)',
               paste('Spawning biomass (', LastYR+1, ' ', fecund_unit, ')', sep = ''),
               paste('Fraction unfished (', LastYR+1,')',sep=''),
               '\\textbf{$\\text{Reference points based on } \\mathbf{B_{40\\%}}$}',
               'Spawning biomass ($B_{40\\%}$)',
               'SPR resulting in $B_{40\\%}$ ($SPR_{B40\\%}$)',
               'Exploitation rate resulting in $B_{40\\%}$',
               'Yield with $SPR_{B40\\%}$ at $B_{40\\%}$ (mt)',
               '\\textbf{\\textit{Reference points based on $SPR=50\\%$ proxy for MSY}}',
               'Spawning biomass (mt)',
               '$SPR_{proxy}$',
               'Exploitation rate corresponding to $SPR=50\\%$',
               'Yield with $SPR=50\\%$ at $B_{SPR=50\\%}$ (mt)',
               '\\textbf{\\textit{Reference points based on estimated MSY values}}',
               'Spawning biomass at $MSY$ ($B_{MSY}$)',
               '$SPR_{MSY}$',
               'Exploitation rate at $MSY$',
               'Dead Catch $MSY$ (mt)',
               'Retained Catch $MSY$ (mt)'  )
  
  Ref_pts = cbind(Quantity, Ref_pts[, c(5, 8, 9)])
  Ref_pts[c(6, 11, 13, 16), 3] = ''
  Ref_pts[c(6, 11, 16), 2] = ''
  colnames(Ref_pts) = c('\\textbf{Quantity}', '\\textbf{Estimate}', 
                        '\\textbf{Low 2.5\\%  limit}',
                        '\\textbf{High 2.5\\%  limit}')
  assign(paste('Ref_pts_', mod_area, sep = ''), Ref_pts)
  
} # end for loop for n models for reference points table

# =============================================================================
# Create reference point table(s)----------------------------------------------

# Model 1 
Ref_pts_mod1.table = xtable(Ref_pts_mod1, 
                            caption=c(paste0('Summary of reference 
                                      points and management quantities for the 
                                      base case model.
                                      Reference points were calculated using the
                                      estimated selectivities, retention rates, and
                                      catch distribution among fleets in 2018.')), 
                            label='tab:Ref_pts_mod1')  
# Add alignment      
align(Ref_pts_mod1.table) = c('l',
                              '>{\\raggedright}p{4.1in}',
                              '>{\\raggedleft}p{.62in}',
                              '>{\\raggedleft}p{.62in}',
                              '>{\\raggedleft}p{.62in}')  



# =============================================================================
# Management performance ------------------------------------------------------
# Required: EDIT and READ IN Exec_mngmt_performance.csv FILE ------------------
# Read in the management performance table - get from John Devore
# Will have to change the column names, caption, and the alignment

mngmnt = read.csv('./txt_files/Exec_mngmt_performance.csv')

colnames(mngmnt) = c('Year',
                     'OFL (mt; ABC prior to 2011)',  
                     'ABC (mt)', 
                     'ACL (mt; OY prior to 2011)',
                     'Landings (mt)',
                     'Estimated total fishing mortality (mt)')

# Create the management performance table
mngmnt.table = xtable(mngmnt, 
                      caption=c('Recent trend in total catch (mt) relative to the 
                              management guidelines. Big skate was
                              managed in the Other Species complex in 2013 and 2014,
                              designated an Ecosystem Component species in 2015 and
                              2016, and managed with stock-specific harvest
                              specifications since 2017. Estimated total mortality
                              includes dead discards estimated in the model
                              (assuming a discard mortality rate of 50\\%).'),
                      label='tab:mnmgt_perform',
                      digits = c(0,0,1,1,1,1,1))  
# Add alignment
align(mngmnt.table) = c('l','l',
                        '>{\\centering}p{1.2in}',
                        '>{\\centering}p{.8in}',
                        '>{\\centering}p{1.2in}', 
                        '>{\\centering}p{.8in}', 
                        '>{\\centering}p{1.6in}')  


# =============================================================================
# OFL projection --------------------------------------------------------------

project = read.csv('./txt_files/Exec_basemodel_summary.csv')

colnames(project) = c('Year',
            'Landings (mt)',  
            'Estimated total mortality (mt)', 
            'OFL (mt)', 
            'ACL (mt)')
project$Buffer <- c(NA, NA, 0.874, 0.865, 0.857, 0.849,
                    0.841, 0.833, 0.826, 0.818, 0.810, 0.803)
OFL.table = xtable(project,
    caption=c('Projections of landings, total mortality, OFL, and ACL values.
               Total mortality is the sum of landings and dead discards.
               For 2019 and 2020, mortality estimates were provided by the
               Groundfish Management Team based on recent trends in catch.
               For 2021 and beyond, estimated total mortality is assumed
               equal to the ACL in each year.'),
    label = 'tab:OFL_projection_Exec',
    digits = c(0,0,1,1,1,1,3)) 

align(OFL.table) = c('l', 'l',
                       '>{\\centering}p{0.8in}',
                       '>{\\centering}p{1.2in}',
                       '>{\\centering}p{0.8in}',
                       '>{\\centering}p{0.8in}',
                       '>{\\centering}p{0.8in}')


##   OFL.table = xtable(OFL, caption=c('Projections of potential OFL (mt) for 
##                                         each model, using the base model forecast.'),
##                      label = 'tab:OFL_projection')

## #For 1 model:
## if (n_models == 1) {
##   # Extract OFLs for next 10 years for each model
##   OFL_mod1 = mod1$derived_quants[grep('OFLCatch',mod1$derived_quants$Label),]
##   OFL_mod1 = OFL_mod1[, 2]    
  
##   #Turn into a dataframe and get the total
##   OFL = as.data.frame(OFL_mod1)
##   OFL$Year=seq(Project_firstyr,Project_lastyr, 1)
##   OFL$Year = as.factor(OFL$Year)
##   OFL = OFL[,c(2, 1)]
##   colnames(OFL) = c('Year','OFL') 
  
##   # Create the table
##   OFL.table = xtable(OFL, caption=c('Projections of potential OFL (mt) for 
##                                         each model, using the base model forecast.'),
##                      label = 'tab:OFL_projection')
## }


# =============================================================================
# Decision Table(s) -----------------------------------------------------------
# Required: READ in the DecisionTable_mod CSV files ---------------------------

# Model 1
# Read in decision table file
decision_mod1 = read.csv('./txt_files/DecisionTable_mod1.csv')
colnames(decision_mod1) = c('', 
                            'Year',  
                            'Catch',	
                            'Spawning Biomass',	
                            'Fraction Unfished', 
                            'Spawning Biomass',	
                            'Fraction Unfished',	
                            'Spawning Biomass',	
                            'Fraction Unfished')

decision_mod1.table = xtable(decision_mod1, 
    caption = c(paste0('Summary of 12-year projections beginning in 2019',
        ' for alternate states of nature based the axis of uncertainty for the model.',
        ' Columns range over low, mid, and high states of nature associated with',
        ' WCGBT Survey catchability values of 0.960 for the low state,',
        ' 0.668 for the base state, and 0.465 for the high state',
        ' (where higher catchability is associated with lower stock size).',
        ' Rows range over different', 
        ' assumptions of catch levels.')),
    digits = c(0,0,0,1,0,3,0,3,0,3),
    label='tab:Decision_table_mod1')

# Assign alignment and add the header columns
align(decision_mod1.table) = c('l','l|','c','c|','>{\\centering}p{.6in}','>{\\centering}p{.7in}|','>{\\centering}p{.6in}','>{\\centering}p{.7in}|','>{\\centering}p{.6in}','>{\\centering}p{.7in}') 


addtorow <- list()
addtorow$pos <- list()
addtorow$pos[[1]] <- -1
addtorow$pos[[2]] <- -1
addtorow$pos[[3]] <- -1
addtorow$command <- c( ' \\hline\n', ' \\multicolumn{3}{c}{}  &  \\multicolumn{2}{c}{}
                               & \\multicolumn{2}{c}{\\textbf{States of nature}}
                               & \\multicolumn{2}{c}{} \\\\\n',
                       ' \\multicolumn{3}{c}{}  &  \\multicolumn{2}{c}{Low State (q=0.960)}
                               & \\multicolumn{2}{c}{Base State (q=0.668)}
                                &  \\multicolumn{2}{c}{High State (q=0.465)} \\\\\n')




# =============================================================================
# Base case summary table -----------------------------------------------------
# Required: PARTIALLY READS CSV FILE ------------------------------------------

# Collect the data from all the tables
# Read in the management table
mngmt = read.csv('./txt_files/Exec_basemodel_summary.csv')
mngmt = mngmt[1:10,]

mngmt = mngmt[,-1]
mngmt <- round(mngmt, 1)

# Model 1
# SPR ratio and exploitation
SPRratio_Exploit_mod1 = SPRratio_Exploit_mod1[2:nrow(SPRratio_Exploit_mod1),c(2,4)]
SPRratio_Exploit_mod1[,c(1,2)] = round(SPRratio_Exploit_mod1[,c(1,2)],2)

# SPR blanks for the last year
blanks = c(NA,NA)
SPRratio_Exploit_mod1 = rbind(SPRratio_Exploit_mod1,blanks)
rownames(SPRratio_Exploit_mod1)[10]='Lastyear'

# Age 5+ biomass
Age5biomass_mod1 = mod1$timeseries[,c('Yr','Bio_smry')]
Age5biomassyrs_mod1 = subset(Age5biomass_mod1, Yr>=(FirstYR) & Yr<=(LastYR))
Age5biomassyrs_mod1 = Age5biomassyrs_mod1[,2]
Age5biomassyrs_mod1 = round(Age5biomassyrs_mod1,2)

# Spawning biomass and depltion
SpawnDeplete_mod1 = SpawnDeplete_mod1[,c(2:5)]
SpawnDeplete_mod1[,1] = round(SpawnDeplete_mod1[,1],1)
SpawnDeplete_mod1[,3] = round(SpawnDeplete_mod1[,3],1)

# Recruitment
Recruittab_mod1 = Recruittab_mod1[,c(2,3)]
Recruittab_mod1[,2] = Recruittab_mod1[,2]

# BIND ALL DATA TOGETHER
mod1_summary = cbind(SPRratio_Exploit_mod1,
                     Age5biomassyrs_mod1,
                     SpawnDeplete_mod1,
                     Recruittab_mod1)


# -----------------------------------------------------------------------------    
# CREATE TABLES BASED ON HOW MANY MODELS AND MANAGEMENT AREAS YOU HAVE

# ONE MODEL
if (n_models == 1) {
  # Bind data from all three models together
  base_summary1 = as.data.frame(cbind(mngmt,mod1_summary))
  
  # Transpose the dataframe to create the table and create data labels  
  base_summary = as.data.frame(t(base_summary1))
  base_summary$names=c('Landings (mt)',
                       'Total Est. Catch (mt)',
                       'OFL (mt)', 
                       'ACL (mt)',
                       
                       '(1-$SPR$)(1-$SPR_{50\\%}$)',
                       'Exploitation rate',
                       paste('Age ',min_age,' biomass (mt)',sep=''),
                       'Spawning Biomass',
                       '~95\\% CI',
                       'Fraction Unfished',
                       '~95\\% CI',
                       'Recruits',
                       '~95\\% CI')
  
  base_summary = base_summary[,c(ncol(base_summary),1:(ncol(base_summary)-1))]
  colnames(base_summary) = c('Quantity',seq(FirstYR+1,LastYR+1))
  
  # # Create the table``
  base_summary.table = xtable(base_summary, caption=c('Base case results summary.'),
                              label='tab:base_summary',digits=0)
  # # Add alignment   
  align(base_summary.table) = c('l',
                                'r',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}',
                                '>{\\centering}p{1.1in}')
}


################################################################################################################################################################
# Executive summary values
################################################################################################################################################################

# Lowest four recruitment years 
RecDevs.all = mod1$recruitpars[grep('Late_RecrDev_', rownames(mod1$recruitpars)), c("Value", "Parm_StDev")]
ind = sort(RecDevs.all[, "Value"], index.return = TRUE)$ix[1:4]
find.yr = rownames(mod1$recruitpars[grep('Late_RecrDev', rownames(mod1$recruitpars)), ])
temp = substring(find.yr,14)
recdev.lowest = temp[ind]

# Lowest SB
find.sb = mod$derived_quants[grep('SSB', mod$derived_quants$Label), ]
temp = find.sb[find.sb$Label >= paste('SSB_', Dat_start_mod1, sep='') & find.sb$Label <= paste('SSB_', Dat_end_mod1,  sep=''), ]  
ind = sort(temp$Value, index.return = TRUE)$ix[1]
ssb.yr = substring(temp$Label, 5)
low.ssb = ssb.yr[ind]

low.dep.value = paste0( round(100*mod$derived_quants[mod$derived_quants$Label == paste0("SSB_", low.ssb), 'Value'] / 
                                mod$derived_quants[mod$derived_quants$Label == "SSB_Virgin", 'Value'],1), "%")

Tot.catch = aggregate(ret_bio ~ Yr, FUN = sum, mod1$catch)$ret_bio
#
# Andi mod for Big Skate
#
Tot.catch = Tot.catch[-1]
#
#
Tot.catch.df = cbind(Dat_start_mod1:Dat_end_mod1, Tot.catch)
temp = sort(Tot.catch.df[,2], index.return = TRUE)$ix
max.catch.5 = Tot.catch.df[(temp[length(temp)]-5):temp[length(temp)],]

Tot.catch.df = as.data.frame(Tot.catch.df)
colnames(Tot.catch.df)<-c("Year", "Catch")
