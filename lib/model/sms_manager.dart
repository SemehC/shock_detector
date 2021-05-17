import 'package:fluttertoast/fluttertoast.dart';
import 'package:sms/sms.dart';

class SmsManager {
  static bool canSend = false;
  static List<String> recipents = new List<String>();

  static AddRecipents({String rec}) {
    if (recipents.contains(rec)) {
      Fluttertoast.showToast(msg: "Already added this number");
    } else {
      recipents.add(rec);
    }
  }

  static RemoveRecipents({String rec}) {
    recipents.remove(rec);
  }

  static SendAlert(String message) async {
    if (canSend) {
      if (recipents.length == 0) {
        Fluttertoast.showToast(msg: "Add recipients first");
      } else {
        SmsSender sender = new SmsSender();
        String address = recipents.first;
        SmsMessage smsMessage = new SmsMessage(address, message);
        smsMessage.onStateChanged.listen((state) {
          if (state == SmsMessageState.Sent) {
            Fluttertoast.showToast(msg: "Alert sent ");
          } else if (state == SmsMessageState.Delivered) {
            print("SMS is delivered!");
          }
        });
        sender.sendSms(smsMessage);
      }
    } else {
      Fluttertoast.showToast(msg: "Sending sms is disabled");
    }
  }
}
