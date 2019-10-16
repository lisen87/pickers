import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pickers/pickers.dart';
import 'package:pickers/CorpConfig.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  List<dynamic> list;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      list = await Pickers.pickerPaths(
          galleryMode: GalleryMode.image,
          selectCount: 9,
          showCamera: false,
          compressSize: 1000,
          corpConfig: CorpConfig(enableCrop: false, width: 1, height: 1));
      print(list.toString());
      setState(() {});
    } on PlatformException {
      print("PlatformExceptionPlatformExceptionPlatformException");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(

          children: <Widget>[
            GridView.builder(
                itemCount: list == null ? 0 : list.length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //横轴元素个数
                    crossAxisCount: 3,
                    //纵轴间距
                    mainAxisSpacing: 20.0,
                    //横轴间距
                    crossAxisSpacing: 10.0,
                    //子组件宽高长度比例
                    childAspectRatio: 1.0),
                itemBuilder: (BuildContext context, int index) {
                  //Widget Function(BuildContext context, int index)
                  return Image.file(File(list[index],),fit: BoxFit.cover,);
                }),
            RaisedButton(onPressed: (){
              initPlatformState();
            },child: Text("选择图片"),)
          ],
        ),
      ),
    );
  }
}
