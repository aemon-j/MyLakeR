init_mylake <- function(model = 'MyLake', wtemp_file, date, folder = '.'){
  
  setwd(folder)
  obs <- read.csv(wtemp_file)
  
  dat = which(obs[,1] == date)
  ndeps = length(dat)
  deps = obs[dat,2]
  tmp = obs[dat,3]
  deps <- signif(deps,4)
  tmp <- signif(tmp,4)
  
  if("MyLake" %in% model){
    
    if(!dir.exists('MyLake')){
      dir.create('MyLake')
    }
    
    load("./MyLake/mylake_config_final.Rdata")
    
    mylake_init <- list()
    
    deps_Az <- data.frame("Depth_meter"=mylake_config[["In.Z"]],
                          "Az"=mylake_config[["In.Az"]])
    
    temp_interp1 <- dplyr::full_join(deps_Az,
                                     data.frame("Depth_meter"=deps,
                                                "Water_Temperature_celsius"=tmp))
    temp_interp2 <- dplyr::arrange(temp_interp1,Depth_meter)
    temp_interp3 <- dplyr::mutate(temp_interp2,
                                  TempInterp=approx(x=Depth_meter,
                                                    y=Water_Temperature_celsius,
                                                    xout=Depth_meter,
                                                    yleft=dplyr::first(na.omit(Water_Temperature_celsius)),
                                                    yright=dplyr::last(na.omit(Water_Temperature_celsius)))$y)
    temp_interp <- dplyr::filter(temp_interp3, !is.na(Az))
    
    mylake_init[["In.Tz"]]=as.matrix(temp_interp$TempInterp)
    
    mylake_init[["In.Z"]]=as.matrix(temp_interp$Depth_meter)
    
    mylake_config[["Phys.par"]][1]=median(diff(mylake_init$In.Z))
    
    save(mylake_config,file=file.path(folder,"MyLake","mylake_config_final.Rdata"))
    
    save(mylake_init,file=file.path(folder,"MyLake","mylake_init.Rdata"))
    
  }
}