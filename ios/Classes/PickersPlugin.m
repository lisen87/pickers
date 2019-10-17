#import "PickersPlugin.h"
#import "TZImagePickerController.h"
#define Frame_rectStatus ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define Frame_rectNav (self.navigationController.navigationBar.frame.size.height)
#define Frame_NavAndStatus (self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height)
#define CXCHeightX   ( ([UIScreen mainScreen].bounds.size.height>=812.00)?([[UIScreen mainScreen] bounds].size.height-34):([[UIScreen mainScreen] bounds].size.height)/1.000)
#define CXCWeight   ( ([[UIScreen mainScreen] bounds].size.width)/1.000)

@class TZImagePickerController;

@interface PickersPlugin ()<TZImagePickerControllerDelegate>
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation PickersPlugin



static NSString *const CHANNEL_NAME = @"flutter/pickers";

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:CHANNEL_NAME
                                     binaryMessenger:[registrar messenger]];
    PickersPlugin *instance = [[PickersPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}
-(void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result{
    if([@"getPickerPaths" isEqualToString:call.method]) {

        NSDictionary *dic = call.arguments;

        NSLog(@"这是ios内部的了----开始调用%@",dic);
        NSInteger selectCount =[[dic objectForKey:@"selectCount"] integerValue];//最多多少个
        NSInteger compressSize =[[dic objectForKey:@"compressSize"] integerValue]*1024;//大小
        NSString *galleryMode =[NSString stringWithFormat:@"%@",[dic objectForKey:@"galleryMode"]];//图片还是视频image video
        BOOL enableCrop =[[dic objectForKey:@"enableCrop"] boolValue];//是否裁剪
        NSInteger height =[[dic objectForKey:@"height"] integerValue];//宽高比例
        NSInteger width =[[dic objectForKey:@"width"] integerValue];//宽高比例
        BOOL showCamera =[[dic objectForKey:@"showCamera"] boolValue];//显示摄像头

//        NSInteger selectCount =1;//最多多少个
//        BOOL enableCrop =1;//是否裁剪
//        float height = 1;//宽高比例
//        float width = 10;//宽高比例

        //创建、最多selectCount个
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:selectCount delegate:self];

        if([galleryMode isEqualToString:@"image"]){
            //如果是图片 不能选视频不能录视频 showCamera判断显示拍图片
            imagePickerVc.allowPickingVideo  =NO;
            imagePickerVc.allowPickingImage =YES;
            imagePickerVc.allowTakeVideo =NO;
            imagePickerVc.allowTakePicture =showCamera;

        }else{
            //如果是视频 不能选图片不能拍照片 showCamera判断显示拍视频
            imagePickerVc.allowPickingVideo  =YES;
            imagePickerVc.allowPickingImage =NO;
            imagePickerVc.allowTakePicture =NO;
            imagePickerVc.allowTakeVideo =showCamera;
        }

        if(selectCount==1){
            imagePickerVc.allowCrop =enableCrop;//是否裁剪
            if (enableCrop==YES) {

                if(height/width>CXCHeightX/CXCWeight){
                    //若裁剪根据竖
                    imagePickerVc.cropRect =CGRectMake((CXCWeight-(CXCHeightX*(width/height)))/2, 0,CXCHeightX*(width/height), CXCHeightX);
                }else{
                    //若裁剪根据横
                     imagePickerVc.cropRect =CGRectMake(0, (CXCHeightX-(CXCWeight*(height/width)))/2,CXCWeight, CXCWeight*(height/width));
                }                NSLog(@"%f---%f",imagePickerVc.cropRect.size.height,imagePickerVc.cropRect.size.width);

            }else
            {

            }
        }

        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {

            PHImageManager *manage =[[PHImageManager alloc]init];
            PHImageRequestOptions *option =[[PHImageRequestOptions alloc]init];
            NSMutableArray *arr =[[NSMutableArray alloc]init];
            for (PHAsset *asset  in assets) {

                [manage requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

                    NSLog(@"info==%@",info);
                    NSURL * path = [info objectForKey:@"PHImageFileURLKey"];
                    NSString *str =path.absoluteString;
                   NSString *subString = [str substringFromIndex:7];
                    if(enableCrop==YES){
                        //若裁剪需要裁剪后的图片，需要保存一下
                        //重命名
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        formatter.dateFormat = @"yyyyMMddHHmmss";
                        NSString *name = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],[str lastPathComponent]];
                        NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png",name]];
                        //保存到沙盒
                        [UIImageJPEGRepresentation(photos[0],1.0) writeToFile:jpgPath atomically:YES];
                        NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(),name];
                       //取出路径
                        [arr addObject:[NSString stringWithFormat:@"%@",aPath3]];

                    }else{
                         [arr addObject:[NSString stringWithFormat:@"%@",subString]];
                    }
                    NSLog(@"%@",arr);
                    NSMutableArray *urlArr =[[NSMutableArray alloc]init];

                    if (arr.count==assets.count) {
                        for (int i=0; i<arr.count; i++) {
                            NSData *data2=UIImageJPEGRepresentation(photos[i], 1.0);
                            if (data2.length>compressSize) {
                                //压缩
                                data2=UIImageJPEGRepresentation(photos[i], (float)(data2.length/compressSize));
                            }
                            UIImage *image =[UIImage imageWithData:data2];
                            //重命名并且保存
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            formatter.dateFormat = @"yyyyMMddHHmmss";
                            NSString*urlString =arr[i];
                            NSString *name = [NSString stringWithFormat:@"%@01%@",[formatter stringFromDate:[NSDate date]],[urlString lastPathComponent]];
                            NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png",name]];
                            //保存到沙盒
                            [UIImageJPEGRepresentation(image,1.0) writeToFile:jpgPath atomically:YES];
                            NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(),name];
                            NSDictionary *photoDic =@{
                                                      @"thumbPath":[NSString stringWithFormat:@"%@",aPath3],
                                                      @"path":[NSString stringWithFormat:@"%@",aPath3],
                                                      };
                            //取出路径
                            [urlArr addObject:photoDic];
                        }
                        result(urlArr);
                    }


                }];


            }



        }];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:imagePickerVc animated:YES completion:nil];

        NSLog(@"回调了");
    }



}
@end
