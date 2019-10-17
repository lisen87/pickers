import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pickers/pickers.dart';
import 'package:pickers/CorpConfig.dart';
import 'package:video_player/video_player.dart';
import 'package:pickers/Media.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GalleryMode _galleryMode = GalleryMode.image;

  @override
  void initState() {
    super.initState();
  }

  List<Media> _listImagePaths = List();
  List<Media> _listVideoPaths = List();

  Future<void> selectImages() async {
    try {
      _galleryMode = GalleryMode.image;
      _listImagePaths = await Pickers.pickerPaths(
          galleryMode: _galleryMode,
          selectCount: 9,
          showCamera: true,
          compressSize: 100,
          corpConfig: CorpConfig(enableCrop: false, width: 0, height: 0));
      print(_listImagePaths.toString());
      setState(() {

      });
    } on PlatformException {}
  }

  Future<void> selectVideos() async {
    try {
      _galleryMode = GalleryMode.video;
      _listVideoPaths = await Pickers.pickerPaths(
        galleryMode: _galleryMode,
        selectCount: 5,
        showCamera: true,
      );
      setState(() {

      });
      print(_listVideoPaths);
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                  itemCount: _listImagePaths == null ? 0 : _listImagePaths.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Image.file(
                            File(
                              _listImagePaths[index].path,
                            ),
                            fit: BoxFit.cover,
                          );
                  }),
              RaisedButton(
                onPressed: () {
                  selectImages();
                },
                child: Text("选择图片"),
              ),
              GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _listVideoPaths == null ? 0 : _listVideoPaths.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Image.file(
                      File(
                        _listVideoPaths[index].thumbPath,
                      ),
                      fit: BoxFit.cover,
                    );
                  }),
              RaisedButton(
                onPressed: () {
                  selectVideos();
                },
                child: Text("选择视频"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
