import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:ndialog/ndialog.dart';
import 'package:shock_detector/model/location_manager.dart';
import 'package:shock_detector/model/shocks_manager.dart';

import '../model/shock.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markers = HashSet<Marker>();
  MapType currentMapType = MapType.normal;
  GoogleMapController mapController;
  @override
  void initState() {
    super.initState();
    setMarkers();
  }

  setMarkers() {
    _markers.add(
      Marker(
        position: LatLng(LocationManager.userLocation.latitude,
            LocationManager.userLocation.longitude),
        infoWindow: InfoWindow(title: "Current Position"),
        markerId: MarkerId("position"),
      ),
    );
  }

  buildGMaps() {
    return GoogleMap(
      onMapCreated: (controller) => mapController = controller,
      buildingsEnabled: true,
      initialCameraPosition: CameraPosition(
        target: LatLng(LocationManager.userLocation.latitude,
            LocationManager.userLocation.longitude),
        zoom: 16,
      ),
      mapType: currentMapType,
      markers: _markers,
    );
  }

  buildMapsHeader() {
    return Column(
      children: [
        Text("Current location : "),
        LocationManager.addresses != null
            ? Text(
                "${LocationManager.addresses.first.featureName} ; ${LocationManager.addresses.first.adminArea} ; ${LocationManager.addresses.first.countryName}")
            : Text("Fetching data"),
        Text(
            "Number of shocks since app start : ${ShocksManager.shocks.length}"),
      ],
    );
  }

  changeMapPostition({LatLng newPos}) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: newPos, zoom: 20.0),
      ),
    );
  }

  buildShockItem({Shock shock, int id}) {
    return ElevatedButton(
      onPressed: () {
        _markers.clear();
        _markers.add(
          Marker(
            position: LatLng(LocationManager.userLocation.latitude,
                LocationManager.userLocation.longitude),
            infoWindow: InfoWindow(title: "Shock $id Postition"),
            markerId: MarkerId("shock$id"),
          ),
        );
        changeMapPostition(newPos: LatLng(shock.lat, shock.long));
        Navigator.pop(context);
      },
      child: Text("Shock $id"),
    );
  }

  buildShocks() async {
    List<Widget> children = List<Widget>();
    int id = 1;
    ShocksManager.shocks.forEach((element) {
      children.add(buildShockItem(shock: element, id: id));
      id++;
    });
    await NDialog(
      dialogStyle: DialogStyle(titleDivider: true),
      title: Text("Shocks"),
      content: Container(
        height: 200,
        child: SingleChildScrollView(
          child: Column(
            children: children,
          ),
        ),
      ),
    ).show(context, transitionType: DialogTransitionType.Bubble);
  }

  buildBottomText() {
    return Text(
      "Semeh Chriha , GI2-S3",
      style: TextStyle(fontSize: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LocationManager.userLocation != null ? buildMapsHeader() : Text(""),
          LocationManager.userLocation != null
              ? Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  child: buildGMaps(),
                )
              : Text("No location data ! "),
          buildBottomText(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          buildShocks();
        },
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
