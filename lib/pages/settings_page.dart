import 'package:flutter/material.dart';
import 'package:shock_detector/model/sms_manager.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String nbr;
  buildSettingsPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Column(
          children: [
            ListTile(
              title: Text("Send sms"),
              leading: Switch(
                value: SmsManager.canSend,
                onChanged: (value) {
                  SmsManager.canSend = value;
                },
              ),
            ),
            TextFormField(
              onChanged: (value) => nbr = value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Sms number",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                SmsManager.AddRecipents(rec: nbr);
              },
              icon: Icon(Icons.add, size: 18),
              label: Text("Add number"),
            )
          ],
        ),
      ),
    );
  }

  buildNumber({String nbr}) {
    return ListTile(
      title: Text(nbr),
      leading: IconButton(
        icon: Icon(Icons.remove),
        onPressed: () {
          SmsManager.RemoveRecipents(rec: nbr);
        },
      ),
    );
  }

  buildAllNumbers() {
    List<Widget> children = List<Widget>();
    SmsManager.recipents.forEach((element) {
      children.add(buildNumber(nbr: element));
    });
    return Column(
      children: children,
    );
  }

  buildBottomText() {
    return Text(
      "Semeh Chriha , GI2-S3",
      style: TextStyle(fontSize: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildSettingsPage(),
        Container(
          child: buildAllNumbers(),
        ),
        buildBottomText(),
      ],
    );
  }
}
