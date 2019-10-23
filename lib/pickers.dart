import 'dart:async';

import 'package:flutter/services.dart';
import 'package:pickers/CorpConfig.dart';
import 'package:pickers/Media.dart';

enum GalleryMode {
  ///选择图片
  image,

  ///选择视频
  video,
}

class Pickers {
  static const MethodChannel _channel = const MethodChannel('flutter/pickers');

  static Future<List<Media>> pickerPaths({
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
      width = corpConfig.width <= 0 ? 1 : corpConfig.width;
      height = corpConfig.height <= 0 ? 1 : corpConfig.height;
    }

    final Map<String, dynamic> params = <String, dynamic>{
      'galleryMode': gMode,
      'selectCount': selectCount,
      'showCamera': showCamera,
      'enableCrop': enableCrop,
      'width': width,
      'height': height,
      'compressSize': compressSize < 50 ? 50 : compressSize,
    };
    final List<dynamic> paths = await _channel.invokeMethod('getPickerPaths',params);
    List<Media> medias = List();
    paths.forEach((data){
      Media media = Media();
      media.thumbPath = data["thumbPath"];
      media.path = data["path"];
      media.galleryMode = galleryMode;
      medias.add(media);
    });
    return medias;
  }

  static previewImage(String imagePath) {
    final Map<String, dynamic> params = <String, dynamic>{
      'path': imagePath,
    };
    _channel.invokeMethod('previewImage',params);
  }
  static previewVideo(String videoPath,{String thumbPath : ""}) {
    final Map<String, dynamic> params = <String, dynamic>{
      'path': videoPath,
      'thumbPath': thumbPath,
    };
    _channel.invokeMethod('previewVideo',params);
  }

  static Future<String> saveImageToGallery(String imageUrl) async {
    final Map<String, dynamic> params = <String, dynamic>{
      'path': imageUrl,
    };
    String path = await _channel.invokeMethod('saveImageToGallery',params);
    return path;
  }
}
