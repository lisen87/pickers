import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pickers/CorpConfig.dart';

enum GalleryMode {
  ///选择图片
  image,

  ///选择视频
  video,
}

class Pickers {
  static const MethodChannel _channel = const MethodChannel('flutter/pickers');

  static Future<List<dynamic>> pickerPaths({
    GalleryMode galleryMode: GalleryMode.image,
    int selectCount: 1,
    bool showCamera: false,
    CorpConfig corpConfig,
    int compressSize : 500,
  }) async {
    String gMode = "image";
    if(galleryMode == GalleryMode.image){
      gMode = "image";
    }else if(galleryMode == GalleryMode.video){
      gMode = "video";
    }

    bool enableCrop = false;
    int width = 1;
    int height = 1;
    if(corpConfig != null){
      enableCrop = corpConfig.enableCrop;
      width = corpConfig.width;
      height = corpConfig.height;
    }

    final Map<String, dynamic> params = <String, dynamic>{
      'galleryMode': gMode,
      'selectCount': selectCount,
      'showCamera': showCamera,
      'enableCrop': enableCrop,
      'width': width,
      'height': height,
      'compressSize': compressSize,
    };
    print(_channel.name);
    final List<dynamic> paths = await _channel.invokeMethod('getPickerPaths',params);
    return paths;
  }
}
