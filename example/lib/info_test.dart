import 'package:flutter_jpush/flutter_jpush.dart';
import 'package:flutter/material.dart';

class Info extends StatefulWidget{
  final bool isConnected;
  final String registrationId;
  final List<JPushNotification> notificationList;

  Info({
    this.isConnected,
    this.registrationId,
    this.notificationList
});

  @override
  State<StatefulWidget> createState() {
    return new _InfoState();
  }
}

class _InfoState extends State<Info>{




  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Text("Connection State: "),
            new Text(widget.isConnected ? "连接" : "未连接" )
          ],
        ),

        new Row(
          children: <Widget>[
            new Text("RegistrationId: "),
            new Text( widget.registrationId ?? "" )
          ],
        ),

        new Padding(padding: new EdgeInsets.all(10.0),
          child: new Text("Push history:"),),

        new Expanded(child: new ListView.builder(itemBuilder: (context,int index){
          JPushNotification notification = widget.notificationList[index];
          return new Padding(padding: new EdgeInsets.all(10.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Text("id:"),
                    new Text(notification.id.toString())
                  ],
                ),
                new Row(
                  children: <Widget>[
                    new Text("内容:"),
                    new Text(notification.content)
                  ],
                ),
              ],
            ),);

        },itemCount: widget.notificationList.length,))
      ],
    );
  }

}