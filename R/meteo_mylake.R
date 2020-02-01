meteo_mylake <- function(meteo_file, config_file=NA, folder = '.', model = "MyLake"){
  
  setwd(folder)
  
  met <- read.csv(meteo_file,header=T)
  
  colname_time = "datetime"
  colname_wind_speed = "Ten_Meter_Elevation_Wind_Speed_meterPerSecond"
  colname_wind_direction = "Ten_Meter_Elevation_Wind_Direction_degree"
  colname_air_temperature = "Air_Temperature_celsius"
  colname_dewpoint_temperature = "Dewpoint_Temperature_celsius"
  colname_relative_humidity = "Relative_Humidity_percent"
  colname_solar_radiation = "Shortwave_Radiation_Downwelling_wattPerMeterSquared"
  colname_longwave_radiation = "Longwave_Radiation_Downwelling_wattPerMeterSquared"
  colname_surface_pressure = "Surface_Level_Barometric_Pressure_pascal"
  colname_precipitation = "Precipitation_meterPerSecond"
  colname_snow = "Snowfall_meterPerDay"
  colname_vapour_pressure = "Vapor_Pressure_milliBar"
  colname_cloud_cover = "Cloud_Cover_decimalFraction"
  
  ### Check what met data is available, as this determines what model forcing option to use (in the simstrat config file)
  datetime = colname_time %in% colnames(met)
  wind_speed = colname_wind_speed %in% colnames(met)
  wind_direction = colname_wind_direction %in% colnames(met)
  air_temperature = colname_air_temperature %in% colnames(met)
  solar_radiation = colname_solar_radiation %in% colnames(met)
  vapour_pressure = colname_vapour_pressure %in% colnames(met)
  relative_humidity = colname_relative_humidity %in% colnames(met)
  longwave_radiation = colname_longwave_radiation %in% colnames(met)
  cloud_cover = colname_cloud_cover %in% colnames(met)
  # Availability of precipitation data only used for snow module
  precipitation = colname_precipitation %in% colnames(met)
  snowfall = colname_snow %in% colnames(met)
  
  met_outfile <- 'meteo_file.dat'
  
  if('MyLake' %in% model){
    
    if(!dir.exists('MyLake')){
      dir.create('MyLake')
    }
    
    mylake_met <- met
    
    if(!cloud_cover){
      
      # Latitude
      lat <- gotmtools::get_yaml_value(config_file, "location", "latitude")
      # Longitude
      lon <- gotmtools::get_yaml_value(config_file, "location", "longitude")
      
      mylake_met[colname_cloud_cover] <- gotmtools::calc_cc(date = as.POSIXct(mylake_met$datetime),
                                                 airt = mylake_met$Air_Temperature_celsius,
                                                 relh = mylake_met$Relative_Humidity_percent,
                                                 swr = mylake_met$Shortwave_Radiation_Downwelling_wattPerMeterSquared,
                                                 lat = lat,
                                                 lon = lon,
                                                 elev = 14, # Needs to be added dynamically
                                                 daily = T)

    }
    
    if(!solar_radiation){
      mylake_met$Shortwave_Radiation_Downwelling_wattPerMeterSquared <- 0
    }
    
    mylake_met <- mylake_met[,c(colname_time,
                                colname_solar_radiation,
                                colname_cloud_cover,
                                colname_air_temperature,
                                colname_relative_humidity,
                                colname_surface_pressure,
                                colname_wind_speed,
                                colname_precipitation)]
    
    mylake_met$Shortwave_Radiation_Downwelling_wattPerMeterSquared <- mylake_met$Shortwave_Radiation_Downwelling_wattPerMeterSquared*0.0864
    
    mylake_met$Surface_Level_Barometric_Pressure_pascal <- mylake_met$Surface_Level_Barometric_Pressure_pascal*0.01
    
    mylake_met$Precipitation_meterPerSecond <- mylake_met$Precipitation_meterPerSecond*86400000
    
    mylake_met$datetime <- as.matrix(floor((as.numeric(as.POSIXct(mylake_met$datetime))/86400)+719529))
    
    write.table(mylake_met, file.path(folder,'MyLake',met_outfile), col.names = FALSE,row.names = FALSE)
  }
}