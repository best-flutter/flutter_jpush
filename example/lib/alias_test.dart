import 'package:flutter/material.dart';
import 'package:flutter_jpush/flutter_jpush.dart';

class AliasSet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _AliasSetState();
  }
}

class _AliasSetState extends State<AliasSet> {
  String _text = "Test alias";
  String _alias = "";

  void _onChanged(String text) {
    _text = text;
  }

  @override
  void initState() {
    getAlias();

    super.initState();
  }

  void getAlias() {
    FlutterJPush.getAlias().then((JPushResult r) {
      if (r.isOk) {
        setState(() {
          if (mounted) _text = r.result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Text("Device alias:"),
            new Expanded(child: new Text(_alias))
          ],
        ),
        new Row(
          children: <Widget>[
            new Text("Alias:"),
            new Expanded(
                child: new TextField(
              onChanged: _onChanged,
              controller: new TextEditingController(text: _text ?? ""),
            ))
          ],
        ),
        new RaisedButton(
          onPressed: () async {
            JPushResult result = await FlutterJPush.setAlias(_text);
            if (result.isOk) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text("提醒"),
                      content: new Text("设置成功,[${result.result}]"),
                    );
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text("提醒"),
                      content: new Text("设置失败"),
                    );
                  });
            }
          },
          color: Colors.blueAccent,
          textColor: Colors.white,
          child: new Text("Set alias"),
        ),
        new SizedBox(
          height: 8.0,
        ),
        new RaisedButton(
          onPressed: () async {
            JPushResult result = await FlutterJPush.getAlias();
            if (result.isOk) {
              setState(() {
                _alias = result.result;
              });

              showDialog(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text("提醒"),
                      content: new Text("获取成功,[${result.result}]"),
                    );
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text("提醒"),
                      content: new Text("获取失败"),
                    );
                  });
            }
          },
          color: Colors.blueAccent,
          textColor: Colors.white,
          child: new Text("Get alias"),
        ),
      ],
    );
  }
}
