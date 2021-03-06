import 'package:flutter/material.dart';
import "dart:convert";
import "dart:io";

import 'package:string_center_client/data/tab.dart';
import 'package:string_center_client/views/viewtab.dart';
import 'package:string_center_client/util/globals.dart' as globals;
import 'package:string_center_client/communications/servercommunication.dart';

///ViewTabList is a StatefulWidget that lists all tabs for a user to select to view or edit
class ViewTabList extends StatefulWidget {
  @override
  _ViewTabListState createState() => new _ViewTabListState();
}

class _ViewTabListState extends State<ViewTabList> {
  bool _loaded = false;
  List<Tabb> _tabs = new List<Tabb>();
  List<Widget> _wl = new List<Widget>();

  @override
  void initState() {
    _getTabList().then((wl) {
      wl = _generateWidgets();
      setState(() {
        _wl = wl;
      });
    });
  }

  _getTabList() async {
    var url = 'http://proj-309-ss-5.cs.iastate.edu:3000/api/tab/findTabsByUser';
    try {
      //send request
      String responseBody = await getRequestAuthorization(url);
      //decode reponse
      Map js = json.decode(responseBody);
      print("decoded json map: " + js.toString());
      print("js['tabs'].length: " + js['tabs'].length.toString());
      //populate list of tabs from json
      for (int i = 0; i < js['tabs'].length; i++) {
        _tabs.add(new Tabb.fromJson(js['tabs'][i]));
      }
    } catch (exception) {
      print('exception viewtablist');
    }
  }

  List<Widget> _generateWidgets() {
    List<Widget> wl = new List<Widget>();
    print("_tabs.length: " + _tabs.length.toString());
    for (int i = 0; i < _tabs.length; i++) {
      wl.add(new Container(
        padding: new EdgeInsets.all(12.0),
        margin: new EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
        decoration:
        new BoxDecoration(border: Border.all(color: globals.themeColor)),
        constraints: new BoxConstraints(maxWidth: 128.0, maxHeight: 196.0),
        child: new MaterialButton(
          padding: new EdgeInsets.all(0.0),
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new ViewTab(_tabs[i])));
          },
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(_tabs[i].render(), style: new TextStyle(fontFamily: 'monospace')),
            ],
          ),
        ),
      ),);
      wl.add(new Padding(padding: new EdgeInsets.all(10.0)));
    }
    return wl;
  }

  @override
  Widget build(BuildContext context) {
    if (_wl == null) {
      return new Container();
    }
    print("tabs: " + _tabs.toString());
    print("widgets: " + _wl.toString());
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: globals.themeColor,
        title: new Text('My Tabs'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(28.0),
        child: new Center(
          child: new ListView(children: _wl),
        ),
      ),
    );
  }
}
