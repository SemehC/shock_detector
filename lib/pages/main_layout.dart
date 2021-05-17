import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:group_button/group_button.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:sensors/sensors.dart';
import 'package:shock_detector/model/location_manager.dart';
import 'package:shock_detector/model/shocks_manager.dart';
import 'package:shock_detector/pages/map_page.dart';
import 'package:shock_detector/pages/settings_page.dart';

class MainLayout extends StatefulWidget {
  MainLayout({Key key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  UserAccelerometerEvent accEvent;
  List<double> accXData = [];
  List<double> accYData = [];
  List<double> accZData = [];

  bool showXGraph = false;
  bool showYGraph = false;
  bool showZGraph = true;

  List<double> _accelData = List.filled(3, 0.0);
  StreamSubscription _accelSubscription;

  //
  double maxZValue = 12;
  double maxYValue = 12;
  double maxXValue = 12;
  bool registeredShock = false;

  @override
  void initState() {
    _checkAccelerometerStatus();
    LocationManager.initializeLocationManager();
    super.initState();
  }

  detectedShock({SensorEvent event}) async {
    Fluttertoast.showToast(msg: "Detected a shock !");
    registeredShock = true;
    ShocksManager.addShock(
        sensor: event, location: LocationManager.userLocation);

    Future.delayed(Duration(seconds: 2), () {
      registeredShock = false;
    });
  }

  void _checkAccelerometerStatus() async {
    await SensorManager()
        .isSensorAvailable(Sensors.ACCELEROMETER)
        .then((result) {
      print(result);

      if (result) {
        _startAccelerometer();
      }
    });
  }

  Future<void> _startAccelerometer() async {
    if (_accelSubscription != null) return;

    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.LINEAR_ACCELERATION,
      interval: Sensors.SENSOR_DELAY_GAME,
    );

    _accelSubscription = stream.listen((sensorEvent) {
      setState(() {
        if (sensorEvent.data[2] > maxZValue && !registeredShock)
          detectedShock(event: sensorEvent);
        if (sensorEvent.data[1] > maxYValue && !registeredShock)
          detectedShock(event: sensorEvent);
        if (sensorEvent.data[1] > maxXValue && !registeredShock)
          detectedShock(event: sensorEvent);

        if (accXData.length >= 300) {
          accXData.removeAt(0);
          accYData.removeAt(0);
          accZData.removeAt(0);
        }
        accXData.add(sensorEvent.data[0]);
        accYData.add(sensorEvent.data[1]);
        accZData.add(sensorEvent.data[2]);

        _accelData = sensorEvent.data;
      });
    });
  }

  buildGraphPageValues() {
    return Column(
      children: [
        Text(
          "Acceleration  data : ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text("X axis : ${_accelData[0].toStringAsFixed(6)}",
            style: TextStyle(
              fontSize: 20,
            )),
        Text("Y axis : ${_accelData[1].toStringAsFixed(6)}",
            style: TextStyle(
              fontSize: 20,
            )),
        Text("Z axis : ${_accelData[2].toStringAsFixed(6)}",
            style: TextStyle(
              fontSize: 20,
            )),
      ],
    );
  }

  buildOscilloscope({String label, List<double> data}) {
    return Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.grey,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 3.0,
      backgroundColor: Colors.transparent,
      traceColor: Colors.blue,
      yAxisMax: 30,
      yAxisMin: -30.0,
      dataSet: data,
    );
  }

  buildGraphXSelection() {
    var bts = ["show", "hide"];
    return Column(
      children: [
        Text("X axis graph"),
        GroupButton(
          isRadio: true,
          spacing: 10,
          selectedColor: Colors.blue,
          selectedButtons: [bts[!showXGraph ? 1 : 0]],
          onSelected: (index, isSelected) => {
            setState(() {
              index == 0 ? showXGraph = true : showXGraph = false;
            }),
          },
          buttons: bts,
        ),
      ],
    );
  }

  buildGraphYSelection() {
    var bts = ["show", "hide"];
    return Column(
      children: [
        Text("Y axis graph"),
        GroupButton(
          isRadio: true,
          selectedColor: Colors.blue,
          spacing: 10,
          selectedButtons: [bts[!showYGraph ? 1 : 0]],
          onSelected: (index, isSelected) => {
            setState(() {
              index == 0 ? showYGraph = true : showYGraph = false;
            }),
          },
          buttons: bts,
        ),
      ],
    );
  }

  buildGraphZSelection() {
    var bts = ["show", "hide"];
    return Column(
      children: [
        Text("Z axis graph"),
        GroupButton(
          isRadio: true,
          selectedColor: Colors.blue,
          spacing: 10,
          selectedButtons: [bts[!showZGraph ? 1 : 0]],
          onSelected: (index, isSelected) => {
            setState(() {
              index == 0 ? showZGraph = true : showZGraph = false;
            }),
          },
          buttons: bts,
        ),
      ],
    );
  }

  buildCurrentLocation() {
    return Column(
      children: [
        LocationManager.userLocation != null
            ? Text(
                "Current location (${LocationManager.userLocation.latitude},${LocationManager.userLocation.longitude})")
            : Text("Getting data"),
        LocationManager.addresses != null
            ? Text(
                "${LocationManager.addresses.first.featureName} ; ${LocationManager.addresses.first.adminArea} ; ${LocationManager.addresses.first.countryName}")
            : Text("Fetching data"),
      ],
    );
  }

  //Admin area sfax
  buildGraphPage() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        buildCurrentLocation(),
        Divider(),
        buildGraphPageValues(),
        Divider(),
        buildGraphXSelection(),
        buildGraphYSelection(),
        buildGraphZSelection(),
        Divider(),
        showXGraph ? Text("X axis") : Text(""),
        showXGraph
            ? Expanded(
                flex: 1,
                child: buildOscilloscope(label: "X axis", data: accXData),
              )
            : Text(""),
        showYGraph ? Text("Y axis") : Text(""),
        showYGraph
            ? Expanded(
                flex: 1,
                child: buildOscilloscope(label: "Y axis", data: accYData),
              )
            : Text(""),
        showZGraph ? Text("Z axis") : Text(""),
        showZGraph
            ? Expanded(
                flex: 1,
                child: buildOscilloscope(label: "Z axis", data: accZData),
              )
            : Text(""),
      ],
    );
  }

  buildTabsBar() {
    return AppBar(
      title: Text("Shock detector"),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.stacked_line_chart)),
          Tab(icon: Icon(Icons.map)),
          Tab(icon: Icon(Icons.settings)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: buildTabsBar(),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            buildGraphPage(),
            MapPage(),
            SettingsPage(),
          ],
        ),
      ),
    );
  }
}
