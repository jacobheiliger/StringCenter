import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:ss_5/util/util.dart';
import 'package:ss_5/communications/servercommunication.dart';
import 'package:ss_5/data/post.dart';
import 'package:ss_5/views/view_post.dart';
import 'package:ss_5/views/followers.dart';
import 'package:ss_5/util/globals.dart' as globals;
import 'package:ss_5/data/user.dart';
import 'package:ss_5/views/following.dart';

///ViewUser is a StatefulWidget that displays a user's page
///Takes in a [_givenUserName] in order to determine which user to display
class ViewUser extends StatefulWidget {
  String _givenUserName;
  String _followingUser;
  ViewUser(String givenUserName, [String followingUser = '']) {
    _givenUserName = givenUserName;
    _followingUser = followingUser;
  }

  @override
  _ViewUserState createState() => new _ViewUserState(_givenUserName, _followingUser);
}

class _ViewUserState extends State<ViewUser> {
  String _userName;
  String _followingUser;
  User _user;
  bool _isFollowing = false;
  Image i = new Image.asset('einstein.jpg');
  List<Widget> _widgetList = new List<Widget>();
  List<Post> _postList = new List<Post>();

  _ViewUserState(String givenUserName, [String followingUser = '']) {
    _followingUser = followingUser;
    _userName = givenUserName;
  }

  _getPostList() async {
    try {
      //getting postlist
      var url = "http://proj-309-ss-5.cs.iastate.edu:3000/api/get-post/by-user/by-name/$_userName";
      String responseBody =
          await getRequestTokenAuthorization(url, globals.token);
      print(responseBody);
      Map posts = json.decode(responseBody);
      //create current user object
      url =
          "http://proj-309-ss-5.cs.iastate.edu:3000/api/get-user/info/$_userName";
      responseBody = await getRequestTokenAuthorization(url, globals.token);
      Map uInfo = json.decode(responseBody);
      _user = new User(uInfo['username'], uInfo['_id'], uInfo['description']);
      if (posts['posts'] != null) {
        print("posts.length: " + posts['posts'].length.toString());

        for (int i = 0; i < posts['posts'].length; i++) {
          if (posts['posts'][i]['tabId'] != null) {
            _postList.add(new Post(
                posts['posts'][i]["content"], posts['posts'][i]['tabId']));
          } else {
            _postList.add(new Post(posts['posts'][i]["content"]));
          }
        }
      }
    } catch (exception) {
      print("profilepage exception: " + exception.toString());
    }
  }

  @override
  void initState() {
    _getPostList().then((widgetList) {
      widgetList = _generateWidgets();
      _checkFollowing().then((isFollowing) {
        setState(() {
          _isFollowing = isFollowing;
          _widgetList = widgetList;
        });
      });
    });
  }

  List<Widget> _generateWidgets() {
    List<Widget> widgetList = new List<Widget>();
    widgetList.add(new Row(
        children: <Widget>[
          new Text(
            'About:',
            textAlign: TextAlign.left,
            style: new TextStyle(fontSize: 20.0),
          ),
          new Padding(padding: new EdgeInsets.only(right: 25.0)),
          new RaisedButton(
            color: globals.themeColor,
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new Followers(_userName)));
            },
            child: new Text('Followers'), textColor: Colors.white,),
          new Padding(padding: new EdgeInsets.only(right: 15.0)),
          new RaisedButton(
            color: globals.themeColor,
            onPressed: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new Following(_userName)));
            },
            child: new Text('Following'), textColor: Colors.white,),
        ]
    ));
    widgetList.add(
      new Container(
          margin: new EdgeInsets.all(12.0),
          padding: new EdgeInsets.all(12.0),
          decoration: new BoxDecoration(
            border: new Border.all(color: globals.themeColor, width: 2.0),
            borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
          ),
          child: new Text(_user.description)),
    );
    for (int i = 0; i < _postList.length; i++) {
      widgetList.add(new MaterialButton(
        onPressed: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => new ViewPost(_postList[i]),
              ));
        },
        child: new Text(_postList[i].content),
      ));
    }
    return widgetList;
  }

  _follow() async {
    Map m = new Map();
    try {
      postRequestWriteAuthorization(
          'http://proj-309-ss-5.cs.iastate.edu:3000/api/follow-user/$_userName',
          json.encode(m));
    } catch (exception) {
      print('follow error' + exception.toString());
    }
    setState(() {
      _isFollowing = true;
    });
  }

  _unfollow() async {
    Map m = new Map();
    try {
      deleteRequestWriteAuthorization(
          'http://proj-309-ss-5.cs.iastate.edu:3000/api/unfollow-user/$_userName',
          json.encode(m));
    } catch (exception) {
      print('follow error' + exception.toString());
    }
    setState(() {
      _isFollowing = false;
    });
  }

  Future<List> _getFollowingList() async {
    List<String> userList = new List<String>();
    var url =
        "http://proj-309-ss-5.cs.iastate.edu:3000/api/get-follower/following/${globals.user.username}";
    try {
      String responseBody = await getRequestAuthorization(url);
      Map js = json.decode(responseBody);
      print("decoded json map: " + js.toString());
      print("js['following'].length: " + js['following'].length.toString());
      for (int i = 0; i < js['following'].length; i++) {
        userList.add(js['following'][i]);
      }
    } catch (exception) {
      print("exception following");
    }
    return userList;
  }

  Future<bool>_checkFollowing() async {
    List<String> userList = await _getFollowingList();
    return userList.contains(_userName);
  }

  RaisedButton _generateFollowButton() {
    if (_isFollowing) {
      return new RaisedButton(
        onPressed: _unfollow,
        child: new Text('Unfollow'),
      );
    } else {
      return new RaisedButton(
        onPressed: _follow,
        child: new Text('Follow'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading:
        new IconButton(icon: new Icon(Icons.arrow_back_ios),
        onPressed: () {
          if(_followingUser != '')
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (BuildContext context) => new Following(_followingUser)),
                  (Route<dynamic> route) => false);
          else
            Navigator.of(context).pop();
        }),
        /*new Image.asset(
          'images/einstein.jpg',
          fit: BoxFit.scaleDown,
        ),*/
        title: new Text(_userName),
        actions: <Widget>[
          _generateFollowButton(),
          new IconButton(
              icon: new Icon(Icons.home),
              onPressed: () {
                goHome(context);
              }),
        ],
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