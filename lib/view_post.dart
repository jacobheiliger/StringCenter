import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'dart:convert';
import 'servercommunication.dart';
import 'dart:async';
import 'tab.dart';
import 'post.dart';


import 'globals.dart' as globals;

class ViewPost extends StatefulWidget {
  Post _givenPost;

  ViewPost(Post givenPost){
    _givenPost = givenPost;
  }

  @override
  _ViewPostState createState() =>
      new _ViewPostState(_givenPost);
}

class _ViewPostState extends State<ViewPost> {
  Post _post;
  Tabb _t;
  _ViewPostState(Post givenPost) {
    _post = givenPost;
  }

  @override
  void initState() {
    _getTab();
    setState(() {
    });
  }

  _getTab() async{
    try {
    String response = await getRequestAuthorization("http://proj-309-ss-5.cs.iastate.edu:3000/api/tab/findTabById/${_post.tabID}");
    _t = new Tabb.fromJson(json.decode(response));
    }catch (exception){
      print('get tab by id exception' + exception.toString());
    }
  }

  Widget _showTab(){
    if(_t != null){
      return new Text(_t.tabToString());
    }else
      return new Text('');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: new Image.asset('images/einstein.jpg', fit: BoxFit.scaleDown,),
        title: new Text(_post.authorUsername),
      ),
      body: new Container(
        alignment: Alignment.center,
        padding: new EdgeInsets.all(20.0),
        child: new Column(
          children: <Widget>[
            new Text(_post.content),
            _showTab(),
          ],
        ),
      ),
    );
  }
}