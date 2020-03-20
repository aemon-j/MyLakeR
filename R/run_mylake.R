run_mylake <- function(sim_folder = ".", init_dat = "mylake_init.Rdata",
                       config_dat = "mylake_config_final.Rdata") {
  
  ##############
  ## move input data and parameter values (moved from "run_mylake.R")
  mylake_path <- system.file(package="MyLakeR")
  
  # load required data:
  load(file.path(mylake_path,"extdata","albedot1.bin"),envir=.GlobalEnv)
  
  setwd(sim_folder)
  meteo<-read.table(file.path("MyLake","meteo_file.dat"))
  
  assign("Wt", as.matrix(meteo[,2:8]), envir=.GlobalEnv)
  assign("tt", as.matrix(meteo[,1]), envir=.GlobalEnv)
  
  load(file.path(sim_folder,"MyLake", init_dat))
  
  assign("In_Tz", mylake_init[["In.Tz"]], envir=.GlobalEnv)
  assign("In_Z", mylake_init[["In.Z"]], envir=.GlobalEnv)
  
  load(file.path(sim_folder,"MyLake", config_dat))
  
  assign("M_start", floor(as.numeric(as.POSIXct(mylake_config[["M_start"]]))/86400+719529), envir=.GlobalEnv)
  assign("M_stop", floor(as.numeric(as.POSIXct(mylake_config[["M_stop"]]))/86400+719529), envir=.GlobalEnv)
  
  assign("Bio_par_names", mylake_config[["Bio.par.names"]], envir=.GlobalEnv)
  assign("Bio_par_range", mylake_config[["Bio.par.range"]], envir=.GlobalEnv)
  assign("Bio_par", mylake_config[["Bio.par"]], envir=.GlobalEnv)
  assign("Phys_par_names", mylake_config[["Phys.par.names"]], envir=.GlobalEnv)
  assign("Phys_par_range", mylake_config[["Phys.par.range"]], envir=.GlobalEnv)
  assign("Phys_par", mylake_config[["Phys.par"]], envir=.GlobalEnv)
  assign("Inflw", mylake_config[["Inflw"]], envir=.GlobalEnv)
  assign("Ice0", mylake_config[["Ice0"]], envir=.GlobalEnv)
  assign("In_FIM", mylake_config[["In.FIM"]], envir=.GlobalEnv)
  assign("In_Chlz_sed", mylake_config[["In.Chlz.sed"]], envir=.GlobalEnv)
  assign("In_TPz_sed", mylake_config[["In.TPz.sed"]], envir=.GlobalEnv)
  assign("In_DOCz", mylake_config[["In.DOCz"]], envir=.GlobalEnv)
  assign("In_Chlz", mylake_config[["In.Chlz"]], envir=.GlobalEnv)
  assign("In_DOPz", mylake_config[["In.DOPz"]], envir=.GlobalEnv)
  assign("In_TPz", mylake_config[["In.TPz"]], envir=.GlobalEnv)
  assign("In_Sz", mylake_config[["In.Sz"]], envir=.GlobalEnv)
  assign("In_Cz", mylake_config[["In.Cz"]], envir=.GlobalEnv)
  assign("In_Az", mylake_config[["In.Az"]], envir=.GlobalEnv)
  
  rm(meteo, mylake_init, mylake_config)
  
  
  # load required as_constants
  assign("g", 9.8, envir=.GlobalEnv)       # acceleration due to gravity [m/s^2]
  assign("sigmaSB", 5.6697e-8, envir=.GlobalEnv) # Stefan-Boltzmann constant [W/m^2/K^4]
  assign("eps_air", 0.62197, envir=.GlobalEnv)   # molecular weight ratio (water/air)
  assign("gas_const_R", 287.04, envir=.GlobalEnv)    # gas constant for dry air [J/kg/K]
  assign("CtoK", 273.16, envir=.GlobalEnv)    # conversion factor for [C] to [K]
  
  # ------- meteorological constants
  assign("kappa_val", 0.4, envir=.GlobalEnv)    # von Karman's constant
  assign("Charnock_alpha", 0.011, envir=.GlobalEnv)  # Charnock constant (for determining roughness length
  # at sea given friction velocity), used in Smith
  # formulas for drag coefficient and also in Fairall
  # and Edson.  use alpha=0.011 for open-ocean and 
  # alpha=0.018 for fetch-limited (coastal) regions. 
  assign("R_roughness", 0.11, envir=.GlobalEnv)    # limiting roughness Reynolds # for aerodynamically 
  # smooth flow         
  
  # ------ defaults suitable for boundary-layer studies
  assign("cp", 1004.7, envir=.GlobalEnv)   # heat capacity of air [J/kg/K]
  assign("rho_air", 1.22, envir=.GlobalEnv)     # air density (when required as constant) [kg/m^2]
  assign("Ta_default", 10, envir=.GlobalEnv)       # default air temperature [C]
  assign("P_default", 1020, envir=.GlobalEnv)     # default air pressure for Kinneret [mbars]
  assign("psych_default", 'screen', envir=.GlobalEnv) # default psychmometer type (see relhumid.m)
  assign("Qsat_coeff", 0.98, envir=.GlobalEnv)     # satur. specific humidity coefficient reduced 
  # by 2# over salt water
  
  # the following are useful in hfbulktc.m 
  #     (and are the default values used in Fairall et al, 1996)
  assign("CVB_depth", 600, envir=.GlobalEnv) # depth of convective boundary layer in atmosphere [m]
  assign("min_gustiness", 0.5, envir=.GlobalEnv) # min. "gustiness" (i.e., unresolved fluctuations) [m/s]
  # should keep this strictly >0, otherwise bad stuff
  # might happen (divide by zero errors)
  assign("beta_conv", 1.25, envir=.GlobalEnv)# scaling constant for gustiness
  
  # ------ short-wave flux calculations
  assign("Solar_const", 1368.0, envir=.GlobalEnv) # the solar constant [W/m^2] represents a 
  # mean of satellite measurements made over the 
  # last sunspot cycle (1979-1995) taken from 
  # Coffey et al (1995), Earth System Monitor, 6, 6-10.
  
  # ------ long-wave flux calculations
  assign("emiss_lw", 0.985, envir=.GlobalEnv)     # long-wave emissivity of ocean from Dickey et al
  # (1994), J. Atmos. Oceanic Tech., 11, 1057-1076.
  
  assign("bulkf_default", 'berliand', envir=.GlobalEnv)  # default bulk formula when downward long-wave
  # measurements are not made.
  
  # assign(x=c("beta_conv",
  #            "Bio_par",
  #            "Bio_par_names",
  #            "Bio_par_range",
  #            "bulkf_default",
  #            "Charnock_alpha",
  #            "cp",
  #            "CtoK",
  #            "CVB_depth",
  #            "emiss_lw",
  #            "eps_air",
  #            "g",
  #            "gas_const_R",
  #            "Ice0",
  #            "In_Az",
  #            "In_Chlz",
  #            "In_Chlz_sed",
  #            "In_Cz",
  #            "In_DOCz",
  #            "In_DOPz",
  #            "In_FIM",
  #            "In_Sz",
  #            "In_TPz",
  #            "In_TPz_sed",
  #            "In_Tz",
  #            "In_Z",
  #            "Inflw",
  #            "kappa_val",
  #            "M_start",
  #            "M_stop",
  #            "min_gustiness",
  #            "P_default",
  #            "Phys_par",
  #            "Phys_par_names",
  #            "Phys_par_range",
  #            "psych_default",
  #            "Qsat_coeff",
  #            "R_roughness",
  #            "rho_air",
  #            "sigmaSB",
  #            "Solar_const",
  #            "Ta_default",
  #            "tt",
  #            "Wt"),
  #        value=list(beta_conv,
  #                   Bio_par,
  #                   Bio_par_names,
  #                   Bio_par_range,
  #                   bulkf_default,
  #                   Charnock_alpha,
  #                   cp,
  #                   CtoK,
  #                   CVB_depth,
  #                   emiss_lw,
  #                   eps_air,
  #                   g,
  #                   gas_const_R,
  #                   Ice0,
  #                   In_Az,
  #                   In_Chlz,
  #                   In_Chlz_sed,
  #                   In_Cz,
  #                   In_DOCz,
  #                   In_DOPz,
  #                   In_FIM,
  #                   In_Sz,
  #                   In_TPz,
  #                   In_TPz_sed,
  #                   In_Tz,
  #                   In_Z,
  #                   Inflw,
  #                   kappa_val,
  #                   M_start,
  #                   M_stop,
  #                   min_gustiness,
  #                   P_default,
  #                   Phys_par,
  #                   Phys_par_names,
  #                   Phys_par_range,
  #                   psych_default,
  #                   Qsat_coeff,
  #                   R_roughness,
  #                   rho_air,
  #                   sigmaSB,
  #                   Solar_const,
  #                   Ta_default,
  #                   tt,
  #                   Wt),
  #        envir=.GlobalEnv)
  
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
  
  rm(list=c("albedot1","Wt","tt","In_Tz","In_Z","M_start","M_stop","Bio_par_names","Bio_par_range",
            "Bio_par","Phys_par_names","Phys_par_range","Phys_par","Inflw","Ice0","In_FIM",
            "In_Chlz_sed","In_TPz_sed","In_DOCz","In_Chlz","In_DOPz","In_TPz","In_Sz",
            "In_Cz","In_Az","g","sigmaSB","eps_air","gas_const_R","CtoK","kappa_val",
            "Charnock_alpha","R_roughness","cp","rho_air","Ta_default","P_default",
            "psych_default","Qsat_coeff","CVB_depth","min_gustiness","beta_conv",
            "Solar_const","emiss_lw","bulkf_default"),
     pos = ".GlobalEnv")
  
}