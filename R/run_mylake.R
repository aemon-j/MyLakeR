run_mylake <- function(sim_folder = ".") {
  
  mylake_path <- system.file(package="MyLakeR")

  # load required data:
  load(file.path(mylake_path,"extdata","albedot1.bin"),envir=.GlobalEnv)
  
  setwd(sim_folder)
  meteo<-read.table(file.path("MyLake","meteo_file.dat"))
  
  Wt<<-as.matrix(meteo[,2:8])
  tt<<-as.matrix(meteo[,1])
  
  load(file.path(sim_folder,"MyLake","mylake_init.Rdata"))
  
  In_Tz <<- mylake_init[["In.Tz"]]
  In_Z <<- mylake_init[["In.Z"]]
  
  load(file.path(sim_folder,"MyLake","mylake_config_final.Rdata"))
  
  M_start <<- floor(as.numeric(as.POSIXct(mylake_config[["M_start"]]))/86400+719529)
  M_stop <<- floor(as.numeric(as.POSIXct(mylake_config[["M_stop"]]))/86400+719529)
  
  Bio_par_names <<- mylake_config[["Bio.par.names"]]
  Bio_par_range <<- mylake_config[["Bio.par.range"]]
  Bio_par <<- mylake_config[["Bio.par"]]
  Phys_par_names <<- mylake_config[["Phys.par.names"]]
  Phys_par_range <<- mylake_config[["Phys.par.range"]]
  Phys_par <<- mylake_config[["Phys.par"]]
  Inflw <<- mylake_config[["Inflw"]]
  Ice0 <<- mylake_config[["Ice0"]]
  In_FIM <<- mylake_config[["In.FIM"]]
  In_Chlz_sed <<- mylake_config[["In.Chlz.sed"]]
  In_TPz_sed <<- mylake_config[["In.TPz.sed"]]
  In_DOCz <<- mylake_config[["In.DOCz"]]
  In_Chlz <<- mylake_config[["In.Chlz"]]
  In_DOPz <<- mylake_config[["In.DOPz"]]
  In_TPz <<- mylake_config[["In.TPz"]]
  In_Sz <<- mylake_config[["In.Sz"]]
  In_Cz <<- mylake_config[["In.Cz"]]
  In_Az <<- mylake_config[["In.Az"]]
  
  rm(meteo, mylake_init, mylake_config)
  
  
  # load required as_constants
  g           <<- 9.8;       # acceleration due to gravity [m/s^2]
  sigmaSB     <<- 5.6697e-8; # Stefan-Boltzmann constant [W/m^2/K^4]
  eps_air     <<- 0.62197;   # molecular weight ratio (water/air)
  gas_const_R <<- 287.04;    # gas constant for dry air [J/kg/K]
  CtoK        <<- 273.16;    # conversion factor for [C] to [K]
  
  # ------- meteorological constants
  kappa_val          <<- 0.4;    # von Karman's constant
  Charnock_alpha <<- 0.011;  # Charnock constant (for determining roughness length
  # at sea given friction velocity), used in Smith
  # formulas for drag coefficient and also in Fairall
  # and Edson.  use alpha=0.011 for open-ocean and 
  # alpha=0.018 for fetch-limited (coastal) regions. 
  R_roughness   <<- 0.11;    # limiting roughness Reynolds # for aerodynamically 
  # smooth flow         
  
  # ------ defaults suitable for boundary-layer studies
  cp            <<- 1004.7;   # heat capacity of air [J/kg/K]
  rho_air       <<- 1.22;     # air density (when required as constant) [kg/m^2]
  Ta_default    <<- 10;       # default air temperature [C]
  P_default     <<- 1020;     # default air pressure for Kinneret [mbars]
  psych_default <<- 'screen'; # default psychmometer type (see relhumid.m)
  Qsat_coeff    <<- 0.98;     # satur. specific humidity coefficient reduced 
  # by 2# over salt water
  
  # the following are useful in hfbulktc.m 
  #     (and are the default values used in Fairall et al, 1996)
  CVB_depth     <<- 600; # depth of convective boundary layer in atmosphere [m]
  min_gustiness <<- 0.5; # min. "gustiness" (i.e., unresolved fluctuations) [m/s]
  # should keep this strictly >0, otherwise bad stuff
  # might happen (divide by zero errors)
  beta_conv     <<- 1.25;# scaling constant for gustiness
  
  # ------ short-wave flux calculations
  Solar_const <<- 1368.0; # the solar constant [W/m^2] represents a 
  # mean of satellite measurements made over the 
  # last sunspot cycle (1979-1995) taken from 
  # Coffey et al (1995), Earth System Monitor, 6, 6-10.
  
  # ------ long-wave flux calculations
  emiss_lw <<- 0.985;     # long-wave emissivity of ocean from Dickey et al
  # (1994), J. Atmos. Oceanic Tech., 11, 1057-1076.
  
  bulkf_default <<- 'berliand';  # default bulk formula when downward long-wave
  # measurements are not made.
  ### RUN MODEL ###
  res<-Rlake_main(sim_folder, M_start, M_stop)
  
  # output of function: zz,Az,Vz,tt,Qst,Kzt,Tzt,Czt,Szt,Pzt,Chlzt,
  # PPzt,DOPzt,DOCzt,Qzt_sed,lambdazt, P3zt_sed,P3zt_sed_sc,
  # His,DoF,DoM,MixStat,Wt,w_chl_zt
  #
  # obtain results stored in 'res' by appending the object names on 'res'
  # example for water temperature:  res$Tzt
  
  setwd(sim_folder)
  
  if(!dir.exists('MyLake/output')){
    dir.create('MyLake/output')
  }
  
  save(res, file=file.path(sim_folder,"MyLake","output","output.RData"))
  
  rm(albedot1)
  
  rm(list=c("Wt","tt","In_Tz","In_Z","M_start","M_stop","Bio_par_names","Bio_par_range",
            "Bio_par","Phys_par_names","Phys_par_range","Phys_par","Inflw","Ice0","In_FIM",
            "In_Chlz_sed","In_TPz_sed","In_DOCz","In_Chlz","In_DOPz","In_TPz","In_Sz",
            "In_Cz","In_Az","g","sigmaSB","eps_air","gas_const_R","CtoK","kappa_val",
            "Charnock_alpha","R_roughness","cp","rho_air","Ta_default","P_default",
            "psych_default","Qsat_coeff","CVB_depth","min_gustiness","beta_conv",
            "Solar_const","emiss_lw","bulkf_default"),
     pos = ".GlobalEnv")
  
}