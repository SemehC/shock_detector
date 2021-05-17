import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:shock_detector/model/location_manager.dart';
import 'package:shock_detector/model/sms_manager.dart';

import 'shock.dart';

class ShocksManager {
  static double maxZValue = 12;
  static double maxYValue = 12;
  static double maxXValue = 12;
  static List<Shock> shocks = new List<Shock>();

  static addShock({SensorEvent sensor, LocationData location}) {
    Fluttertoast.showToast(msg: "Sending sms");
    SmsManager.SendAlert(
        "Shock detected : location (${location.latitude},${location.longitude} \nAddress ${LocationManager.addresses.first.featureName} ; ${LocationManager.addresses.first.adminArea} ; ${LocationManager.addresses.first.countryName} \n Time : ${DateTime.now()}");
    Shock s = new Shock(
      accX: sensor.data[0],
      accY: sensor.data[1],
      accZ: sensor.data[2],
      lat: location.latitude,
      long: location.longitude,
    );
    shocks.add(s);
  }
}
