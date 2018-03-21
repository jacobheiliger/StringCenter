import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'dart:convert';
import 'servercommunication.dart';
import 'post.dart';


import 'globals.dart' as globals;

class Profile extends StatefulWidget {
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<Profile> {

  Image i = new Image.asset('einstein.jpg');
  List<Widget> _widgetList;
  List<Post> _postList;


  _getPostList() async {
    var url ="http://proj-309-ss-5.cs.iastate.edu:3000/api/get-post/by-user";
    try {
      String responseBody = await getRequestToken(url, globals.token);
      List posts = json.decode(responseBody);

      print("posts.length: "+ posts.length.toString());
      for(int i = 0; i < posts[0].length; i++) {
        _postList.add(new Post(posts[0][i]["title"], posts[0][i]["content"]));
      }
    } catch(exception) {
      print("profilepage exception: " + exception.toString());
    }
  }

  @override
  void initState() {
    _getPostList().then((widgetList) {
      widgetList = _generateWidgets();
      setState(() {
        _widgetList = widgetList;
      });
    });
  }

  List<Widget> _generateWidgets() {
    _widgetList.add( new Container(
        margin: new EdgeInsets.all(24.0),
        padding: new EdgeInsets.all(12.0),
        decoration: new BoxDecoration(
          border: new Border.all(color: Colors.blue, width: 2.0),
          borderRadius: new BorderRadius.all(new Radius.circular(6.0)),

        ),
        child: new Text("new group description test test description new new test "
            "new description new new test description new test new test")
    ),
    );
    _widgetList.add(new Container(
      child: new MaterialButton(
          minWidth: 128.0,
          height: 32.0,
          child: new Text("Create Post", style: new TextStyle(color: Colors.white, fontSize: 16.0),),
          onPressed: () {
            Navigator.push(context, new MaterialPageRoute(builder:(BuildContext context) => new Scaffold(
              body: new Text("Post Creation Screen"),
            )));
          }
      ),
      margin: new EdgeInsets.all(24.0),
      decoration: new BoxDecoration(
        border: new Border.all(color: Colors.red),
        borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
        color: Colors.red,
      ),
    ));
    for (int i = 0; i < _postList.length; i++) {
      _widgetList.add(new MaterialButton(onPressed: () {
        Navigator.push(context, new MaterialPageRoute(builder:(BuildContext context) => new Scaffold(
          body: new Text(_postList[i].content),
        )));
      },
        child: new Text(_postList[i].title),
      )
      );
    }
    return _widgetList;
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        leading: new Image.asset('images/einstein.jpg', fit: BoxFit.scaleDown,),
        title: new Text(globals.username),
      ),
      body: new Container(
        alignment: Alignment.center,
        padding: new EdgeInsets.all(20.0),
          child: new ListView(
            children: _widgetList,
          ),
        ),
    );
  }
}