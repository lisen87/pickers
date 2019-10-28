# [pickers](https://github.com/lisen87/pickers.git)

pickers 支持本地图片多选，本地视频多选，支持将网络图片保存到相册，支持预览视频和预览图片功能

pickers Support picture selection, video multiple selection, support to save network pictures to albums, support preview video and preview picture function

> Supported  Platforms
> * Android
> * iOS

## 
此插件(pickers)将不再更新，请查看 `image_pickers` [image_pickers](https://pub.dev/packages/image_pickers)

# [image_pickers](https://pub.dev/packages/image_pickers)


## pickers How to Use

```yaml
# add this line to your dependencies
pickers: ^1.0.2
```

```dart
import 'package:pickers/pickers.dart';
import 'package:pickers/CorpConfig.dart';
import 'package:pickers/Media.dart';
```
```dart

///选择图片 select images
Future<void> selectImages() async {
    List<Media> _listImagePaths = await Pickers.pickerPaths(
              galleryMode: GalleryMode.image,
              selectCount: 2,
              showCamera: true,
              compressSize: 300,
              corpConfig: CorpConfig(enableCrop: true, width: 2, height: 1));
  }

```
```dart
///选择视频 select Videos
Future<void> selectVideos() async {
   List<Media> _listVideoPaths = await Pickers.pickerPaths(
          galleryMode: GalleryMode.video,
          selectCount: 5,
        );
  }
```

```dart
///预览图片 preview picture
Pickers.previewImage(_listImagePaths[index].path);

///预览视频 Preview video
Pickers.previewVideo(_listVideoPaths[index].path);
```
```dart
///保存图片到图库 Save image to gallery
Pickers.saveImageToGallery("http://i1.sinaimg.cn/ent/d/2008-06-04/U105P28T3D2048907F326DT20080604225106.jpg");
```

