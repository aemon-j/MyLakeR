config_mylake <- function(config_file, model = 'MyLake', folder = '.'){
  
  setwd(folder)
  
  # Latitude
  lat <- gotmtools::get_yaml_value(config_file, "location", "latitude")
  # Longitude
  lon <- gotmtools::get_yaml_value(config_file, "location", "longitude")
  # Maximum Depth
  max_depth = gotmtools::get_yaml_value(config_file, "location", "depth")
  # Read in hypsograph data
  hyp <- read.csv(gotmtools::get_yaml_value(config_file, "location", "hypsograph"))
  # Start date
  start_date <- gotmtools::get_yaml_value(config_file, "time", "start")
  # Stop date
  stop_date <- gotmtools::get_yaml_value(config_file, "time", "stop")
  # Time step
  timestep <- gotmtools::get_yaml_value(config_file, "time", "timestep")
  # Met time step
  met_timestep <- gotmtools::get_yaml_value(config_file, "meteo", "timestep")
  # Output depths
  output_depths <- gotmtools::get_yaml_value(config_file, "model_settings", "output_depths")
  # Extinction coefficient (swa_b1)
  ext_coef <- gotmtools::get_yaml_value(config_file, "light", "Kw")
  # wind sheltering coefficient (C_shelter)
  c_shelter <- gotmtools::get_yaml_value(config_file, "MyLake", "C_shelter")
  # Use ice
  use_ice <- gotmtools::get_yaml_value(config_file, "ice", "use")
  # Use inflows
  use_inflows <- gotmtools::get_yaml_value(config_file, "inflows", "use")
  # Output
  out_tstep <- gotmtools::get_yaml_value(config_file, "output", "time_step")  

 
  if("MyLake" %in% model){
    
    if(!dir.exists('MyLake')){
      dir.create('MyLake')
    }
    
    if(is.na(as.numeric(c_shelter))){
      c_shelter <- 1.0-exp(-0.3*(hyp$Area_meterSquared[1]*1e-6))
    }
    
    
    mylake_path <- system.file(package="MyLakeR")

    load(file.path(mylake_path,"extdata","mylake_config_template.Rdata"))
    
    mylake_config[["M_start"]]=start_date
    
    mylake_config[["M_stop"]]=stop_date
    
    mylake_config[["Phys.par"]][5]=c_shelter
    
    mylake_config[["Phys.par"]][6]=lat
    
    mylake_config[["Phys.par"]][7]=lon
    
    mylake_config[["Bio.par"]][2]=ext_coef
    
    mylake_config[["In.Az"]]=as.matrix(hyp$Area_meterSquared)
    
    mylake_config[["In.Z"]]=as.matrix(hyp$Depth_meter)
    
    mylake_config[["In.FIM"]]=matrix(rep(0.92,nrow(hyp)),ncol=1)
    
    mylake_config[["In.Chlz.sed"]]=matrix(rep(196747,nrow(hyp)),ncol=1)
    
    mylake_config[["In.TPz.sed"]]=matrix(rep(756732,nrow(hyp)),ncol=1)
    
    mylake_config[["In.DOCz"]]=matrix(rep(3000,nrow(hyp)),ncol=1)
    
    mylake_config[["In.Chlz"]]=matrix(rep(7,nrow(hyp)),ncol=1)
    
    mylake_config[["In.DOPz"]]=matrix(rep(7,nrow(hyp)),ncol=1)
    
    mylake_config[["In.TPz"]]=matrix(rep(21,nrow(hyp)),ncol=1)
    
    mylake_config[["In.Sz"]]=matrix(rep(0,nrow(hyp)),ncol=1)
   
    mylake_config[["In.Cz"]]=matrix(rep(0,nrow(hyp)),ncol=1)
    
    if(!use_inflows){
      
      mylake_config[["Inflw"]]=matrix(rep(0,8*length(seq.Date(from=as.Date(start_date),to=as.Date(stop_date),by="day"))),
                                         ncol=8)
      
    }
    
    save(mylake_config,file=file.path(folder,"MyLake","mylake_config_final.Rdata"))
    
  }
   
}
