import 'package:flutter/material.dart';
import 'viewtablist.dart';
import 'tab.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'log_in.dart';
import 'globals.dart' as globals;
class Home extends StatefulWidget {
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  String _message;
  bool _loaded = false;
  Widget _page = new Scaffold();

  _HomeState() {
    _message = '';
  }

  _HomeState.withMessage(String message) {
    _message = message;
  }

  requestUser() async {

    String url = 'http://proj-309-ss-5.cs.iastate.edu:3000/api/get-user/info/';


    var httpClient = new HttpClient();

    try {
      String dir = (await getApplicationDocumentsDirectory()).path;
      File f = new File('$dir/token.txt');

      var request = await httpClient.getUrl(Uri.parse(url));
      print(Uri.parse(url));
      String token = await f.readAsString();

      request.headers.contentType = new ContentType("application", "json", charset: "utf-8");
      request.headers.add("authorization", "bearer $token");

      var response = await request.close();
      var responseBody = await response.transform(UTF8.decoder).join();

      print('BODY: $responseBody'); // fields are in quotes except the last is "__v":0
      //TODO (if success result = success)

      //Save token into token.txt

      if (responseBody == "Unauthorized") {
      }
      else {
        globals.isLoggedIn = true;
        Map m = JSON.decode(responseBody);
        globals.username = m['username'];
        globals.token = token;
      }
      print(globals.isLoggedIn);
      generateWidgets();
      setState((){

      });
    } catch (exception) {
      print(exception);
      _page = new Login();
      setState((){});
    }

  }


  generateWidgets() {
    if(!globals.isLoggedIn) _page = new Login();
    else
      _page = new Scaffold(
        appBar: new AppBar(
          title: new Text('Home'),
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.exit_to_app), onPressed: () async {
              String dir = (await getApplicationDocumentsDirectory()).path;
              File f = new File('$dir/token.txt');
              f.delete();
              globals.isLoggedIn = false;
              globals.username = "";
              Navigator.of(context).pushNamedAndRemoveUntil('home', (Route<dynamic> route) => false);
            })
          ],
        ),
        body: new Container(
          padding: new EdgeInsets.all(32.0),
          child: new Center(
            child: new Column(
              children: <Widget>[
//              new RaisedButton(
//                child: new Text("Login"),
//                onPressed: () {
//                  Navigator.of(context).pushNamed('login');
//                },
//             ),
                new Padding(padding: new EdgeInsets.all(16.0)),
                new RaisedButton(
                  child: new Text("View Tabs"),
                  onPressed: () {
                    Navigator.push(context, new MaterialPageRoute(
                      builder:(BuildContext context) => new viewTabList(),
                    ));
                  },
                ),
                new Padding(padding: new EdgeInsets.all(16.0)),
                new RaisedButton(
                  child: new Text("Create Tab"),
                  onPressed: () {
                    Navigator.of(context).pushNamed('tabOptions');
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }
  
  @override
  Widget build(BuildContext context) {
    if(_loaded == false) {
      _loaded = true;
      requestUser();
      print(globals.isLoggedIn);
    }
    //check();
    print(globals.isLoggedIn);
    return _page;

  }
}