import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

class LocationManager {
  //Location data
  static Location location = new Location();
  static bool _serviceEnabled;
  static PermissionStatus _permissionGranted;
  static LocationData userLocation;
  static List<Address> addresses;

  static initializeLocationManager() async {
    await askForLocationPermissions();
    registerLocationListener();
  }

  static registerLocationListener() {
    location.onLocationChanged.listen((LocationData currentLocation) async {
      userLocation = currentLocation;
      addresses = await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(currentLocation.latitude, currentLocation.longitude));
    });
  }

  static askForLocationPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}
