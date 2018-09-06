import 'package:flutter/material.dart';
import 'package:flutter_jpush/flutter_jpush.dart';

class TagSet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _TagSetState();
  }
}

class _TagSetState extends State<TagSet> {
  List<dynamic> _tags = [];
  String _text = "TestTag";
  void _onChanged(String text) {
    _text = text;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text("Device tags:"),
        new Wrap(
          children: _tags.map((tag) {
            return new Padding(
              padding: new EdgeInsets.all(5.0),
              child: new Text(tag),
            );
          }).toList(),
        ),
        new Row(
          children: <Widget>[
            new Text("Tag:"),
            new Expanded(
                child: new TextField(
              onChanged: _onChanged,
              controller: new TextEditingController(text: _text ?? ""),
            ))
          ],
        ),
        new RaisedButton(
          onPressed: () async {
            JPushResult result = await FlutterJPush.addTags([_text]);
            if (result.isOk) {
              setState(() {
                for (var t in result.result) {
                  if (_tags.indexOf(t) < 0) _tags.add(t);
                }
              });
              showDialog(
                  context: context,
                  builder: (context) {
                    return new AlertDialog(
                      title: new Text("提醒"),
                      content: new Text("增加tag成功,[${result.result}]"),
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
          child: new Text("Add tag"),
        ),
        new SizedBox(
          height: 8.0,
        ),
        new RaisedButton(
          onPressed: () async {
            JPushResult result = await FlutterJPush.getAllTags();
            if (result.isOk) {
              setState(() {
                _tags = [];
                _tags.addAll(result.result);
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
          child: new Text("Get all tags"),
        ),
      ],
    );
  }
}
