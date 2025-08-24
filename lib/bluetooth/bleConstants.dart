class BleConstants {
  static String fullUUID = "0000****-0000-1000-8000-00805f9b34fb";
  //heart rate
  static String heartRateServiceUUID = "180D";
  static String heartRateMeasurementUUID = "2A37";
  //cycling speed and cadence
  static String cscServiceUUID = "1816";
  static String cscMeasurementUUID = "2A5B";
  static String cscFeatureUUID = "2A5C";
  static String cscCpUUID = "2A55";
  //cycling power
  static String cyclingPowerServiceUUID = "1818";
  static String cyclingPowerMeasurementUUID = "2A63";
  //https://www.bluetooth.com/wp-content/uploads/Sitecore-Media-Library/Gatt/Xml/Characteristics/org.bluetooth.characteristic.cycling_power_measurement.xml
  static String cyclingPowerFeatureUUID = "2A65";
  static String cyclingPowerCpUUID = "2A66";

  //Tacx FE-C service and characteristics
  static String tacxFECPriServiceUUID = "6E40FEC1-B5A3-F393-E0A9-E50E24DCCA9E";
  //Pour détecter le Vortex
  static String tacxVortexPriServiceUUID =
      "669AA305-0C08-969E-E211-86AD5062675F";
  static String tacxFECReadCharacteristicUUID =
      "6E40FEC2-B5A3-F393-E0A9-E50E24DCCA9E";
  static String tacxFECWriteCharacterisitcUUID =
      "6E40FEC3-B5A3-F393-E0A9-E50E24DCCA9E";
  static String tacxVortexCharacteristicUUID =
      "669AAB01-0C08-969E-E211-86AD5062675F";

  //fitness machine
  static String ftmsServiceUUID = "1826";
  static String ftmsIndoorBikeDataCharacteristicUUID = "2AD2";
  //https://www.bluetooth.com/wp-content/uploads/Sitecore-Media-Library/Gatt/Xml/Characteristics/org.bluetooth.characteristic.indoor_bike_data.xml
  //https://github.com/erikboto/ftms-example/blob/master/ftmsdevice.cpp
  //https://ftredblog.wordpress.com/tag/ble/ & https://forums.ni.com/t5/LabVIEW/Bluetooth-Low-Energy-Bike-Trainer-Data-Issues/td-p/4097698?profile.language=en
  //https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.indoor_bike_data.xml
  static String ftmsPowerRangeCharacteristicUUID = "2AD8";
  static String ftmsResistanceRangeCharacteristicUUID = "2AD6";
  //https://github.com/oesmith/gatt-xml/blob/master/org.bluetooth.characteristic.supported_resistance_level_range.xml
  static String ftmsFeatureCharacteristicUUID = "2ACC";
  static String ftmsCpCharacteristicUUID = "2AD9";
  //0x00 request control, 0x01 reset, 0x04 setResistance, 0x05 setPower, 0x11 setindoorbikeSim, 0x13 spindown
  static String ftmsStatusCharacteristicUUID = "2ADA";
}
