run_mylake <- function(sim_folder = ".") {
  
  load(file.path(sim_folder,"MyLake","mylake_config_final.Rdata"))
  
  M_start <- floor(as.numeric(as.POSIXct(mylake_config[["M_start"]]))/86400+719529)
  M_stop <- floor(as.numeric(as.POSIXct(mylake_config[["M_stop"]]))/86400+719529)
  
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
  
  #rm("albedot1", pos = ".GlobalEnv")
  
  rm(list=c("albedot1","Wt","tt","In_Tz","In_Z","M_start","M_stop","Bio_par_names","Bio_par_range",
            "Bio_par","Phys_par_names","Phys_par_range","Phys_par","Inflw","Ice0","In_FIM",
            "In_Chlz_sed","In_TPz_sed","In_DOCz","In_Chlz","In_DOPz","In_TPz","In_Sz",
            "In_Cz","In_Az","g","sigmaSB","eps_air","gas_const_R","CtoK","kappa_val",
            "Charnock_alpha","R_roughness","cp","rho_air","Ta_default","P_default",
            "psych_default","Qsat_coeff","CVB_depth","min_gustiness","beta_conv",
            "Solar_const","emiss_lw","bulkf_default"))
  
}