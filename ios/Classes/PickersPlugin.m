#import "PickersPlugin.h"
#import <ZLPhotoBrowser/ZLPhotoActionSheet.h>
#import <Photos/Photos.h>
#import <ZLPhotoBrowser/ZLShowBigImgViewController.h>
#import "AKGallery.h"
#import "PlayTheVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define Frame_rectStatus ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define Frame_rectNav (self.navigationController.navigationBar.frame.size.height)
#define Frame_NavAndStatus (self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height)
#define CXCHeightX   ( ([UIScreen mainScreen].bounds.size.height>=812.00)?([[UIScreen mainScreen] bounds].size.height-34):([[UIScreen mainScreen] bounds].size.height)/1.000)
#define CXCWeight   ( ([[UIScreen mainScreen] bounds].size.width)/1.000)


@interface PickersPlugin ()
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
    
    
    
    if([@"getPickerPaths" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        
        NSInteger selectCount =[[dic objectForKey:@"selectCount"] integerValue];//最多多少个
        NSInteger compressSize =[[dic objectForKey:@"compressSize"] integerValue]*1024;//大小
        NSString *galleryMode =[NSString stringWithFormat:@"%@",[dic objectForKey:@"galleryMode"]];//图片还是视频image video
        BOOL enableCrop =[[dic objectForKey:@"enableCrop"] boolValue];//是否裁剪
        NSInteger height =[[dic objectForKey:@"height"] integerValue];//宽高比例
        NSInteger width =[[dic objectForKey:@"width"] integerValue];//宽高比例
        BOOL showCamera =[[dic objectForKey:@"showCamera"] boolValue];//显示摄像头
        //测试的
        //               showCamera =YES;
        //                NSInteger selectCount =9;//最多多少个
        //                BOOL enableCrop =1;//是否裁剪
        //                float height = 1;//宽高比例
        //                float width = 10;//宽高比例
        //                NSString *galleryMode =@"video";
        ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];
        ac.configuration.maxSelectCount = selectCount;//最多选择多少张图
        ac.configuration.allowMixSelect = NO;//不允许混合选择
        ac.configuration.allowTakePhotoInLibrary =showCamera;//是否显示摄像头
        ac.configuration.allowSelectOriginal =NO;//不选择原图
        ac.configuration.allowEditImage =enableCrop;
        ac.configuration.hideClipRatiosToolBar =enableCrop;
        ac.configuration.clipRatios =@[@{
                                           @"value1":[NSNumber numberWithInt:width],//第一个是宽
                                           @"value2":[NSNumber numberWithInt:height],//第二个是高
                                           }];
        if ([galleryMode isEqualToString:@"image"]) {
            ac.configuration. allowSelectImage =YES;
            ac.configuration.allowSelectVideo =NO;
            
        }else{
            ac.configuration. allowSelectImage =NO;
            ac.configuration.allowSelectVideo =YES;
            
        }
        ac.configuration.shouldAnialysisAsset = YES;
        //框架语言
        ac.configuration.languageType = YES;
        //如调用的方法无sender参数，则该参数必传
        ac.sender = [UIApplication sharedApplication].delegate.window.rootViewController;
        ac.configuration.navBarColor =[UIColor whiteColor];
        ac.configuration.navTitleColor =[UIColor blackColor];
        [ac setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
            //your codes
            NSMutableArray *arr =[[NSMutableArray alloc]init];
            
            for (NSInteger i = 0; i < assets.count; i++) {
                // 获取一个资源（PHAsset）
                PHAsset *phAsset = assets[i];
                //视频
                if (phAsset.mediaType == PHAssetMediaTypeVideo) {
                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.version = PHImageRequestOptionsVersionCurrent;
                    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                    PHImageManager *manager = [PHImageManager defaultManager];
                    [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        
                        AVURLAsset *urlAsset = (AVURLAsset *)asset;
                        NSURL *url = urlAsset.URL;
                        NSString *subString = [url.absoluteString substringFromIndex:7];
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        formatter.dateFormat = @"yyyyMMddHHmmss";
                        int  x = arc4random() % 10000;
                        NSString *name = [NSString stringWithFormat:@"%@%d",[formatter stringFromDate:[NSDate date]],x];
                        NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
                        UIImage *img = [self getImage:subString]  ;
                        //保存到沙盒
                        [UIImageJPEGRepresentation(img,1.0) writeToFile:jpgPath atomically:YES];
                        NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
                        //取出路径
                        [arr addObject:@{
                                         @"thumbPath":[NSString stringWithFormat:@"%@",aPath3],
                                         @"path":[NSString stringWithFormat:@"%@",subString],
                                         }];
                        //NSLog(@"%@",arr);
                        if (arr.count==assets.count) {
                            result(arr);
                            
                        }
                        
                        
                        
                    }];
                }else{
                    
                    PHImageManager *manage =[[PHImageManager alloc]init];
                    PHImageRequestOptions *option =[[PHImageRequestOptions alloc]init];
                    NSMutableArray *arr =[[NSMutableArray alloc]init];
                    
                    for (int i=0; i<assets.count; i++) {
                        PHAsset *asset  =assets[i];
                        [manage requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            
                            UIImage *im =[UIImage imageWithData:imageData];
                            //NSLog(@"info==%@",info);
                            NSURL * path = [info objectForKey:@"PHImageFileURLKey"];
                            NSString *str =path.absoluteString;
                            NSString *subString = [str substringFromIndex:7];
                            if(enableCrop==YES){
                                //若裁剪需要裁剪后的图片，需要保存一下
                                //重命名
                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                formatter.dateFormat = @"yyyyMMddHHmmss";
                                NSString *name = [NSString stringWithFormat:@"%@%@",[formatter stringFromDate:[NSDate date]],[str lastPathComponent]];
                                NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
                                //保存到沙盒
                                [UIImageJPEGRepresentation(im,1.0) writeToFile:jpgPath atomically:YES];
                                NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
                                //取出路径
                                [arr addObject:[NSString stringWithFormat:@"%@",aPath3]];
                                
                            }else{
                                [arr addObject:[NSString stringWithFormat:@"%@",subString]];
                            }
                            
                            if (arr.count==assets.count) {
                                NSMutableArray *urlArr =[[NSMutableArray alloc]init];
                                
                                for (int i=0; i<arr.count; i++) {
                                    UIImage *imag =[UIImage imageWithContentsOfFile:arr[i]];
                                    NSData *data2=UIImageJPEGRepresentation(imag , 1.0);
                                    if (data2.length>compressSize) {
                                        //压缩
                                        data2=UIImageJPEGRepresentation(imag, (float)(data2.length/compressSize));
                                    }
                                    NSLog(@"_______%ld",data2.length);
                                    UIImage *image =[UIImage imageWithData:data2];
                                    //重命名并且保存
                                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                    formatter.dateFormat = @"yyyyMMddHHmmss";
                                    NSString*urlString =arr[i];
                                    NSString *name = [NSString stringWithFormat:@"%@01%@",[formatter stringFromDate:[NSDate date]],[urlString lastPathComponent]];
                                    NSString  *jpgPath = [NSHomeDirectory()     stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",name]];
                                    //保存到沙盒
                                    [UIImageJPEGRepresentation(image,1.0) writeToFile:jpgPath atomically:YES];
                                    NSString *aPath3=[NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),name];
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
                    
                    
                    
                }
                
            }
            
            //        [self zhuanhuanTupian];
            
        }];
        [ac showPhotoLibrary];
        
        
    }else if ([@"previewImage" isEqualToString:call.method]){

        
        
         NSDictionary *dic = call.arguments;
        NSMutableArray *arr =[[NSMutableArray alloc]init];

        if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]] containsString:@"http"]) {
            AKGalleryItem* item = [AKGalleryItem itemWithTitle:@"图片详情" url:[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]] img:nil];
            [arr addObject:item];
            AKGallery* gallery = AKGallery.new;
            gallery.items=arr;
            gallery.custUI=AKGalleryCustUI.new;
            gallery.selectIndex=0;
            gallery.completion=^{
                //NSLog(@"completion gallery");
            };
            //show gallery
            [[UIApplication sharedApplication].delegate.window.rootViewController presentAKGallery:gallery animated:YES completion:nil];
        }else if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]] containsString:@"var/"]){
            UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]]]];

            AKGalleryItem* item = [AKGalleryItem itemWithTitle:@"图片详情" url:nil img:image];
            [arr addObject:item];
            AKGallery* gallery = AKGallery.new;
            gallery.items=arr;
            gallery.modalPresentationStyle = 0;
            gallery.custUI=AKGalleryCustUI.new;
            gallery.selectIndex=0;
            gallery.completion=^{
                //NSLog(@"completion gallery");
            };
            //show gallery
            [[UIApplication sharedApplication].delegate.window.rootViewController presentAKGallery:gallery animated:YES completion:nil];
        }

    }else if ([@"previewVideo" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;
        PlayTheVideoVC *vc =[[PlayTheVideoVC alloc]init];
        vc.modalPresentationStyle=0;
        vc.videoUrl =[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:vc animated:YES completion:^{
        }];
    }else if([@"saveImageToGallery" isEqualToString:call.method]){
        NSDictionary *dic = call.arguments;

        UIImage *img =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]]]]];

        __block ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib writeImageToSavedPhotosAlbum:img.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
         {
            NSString *str =assetURL.absoluteString;
            NSString *string =@"://";
            NSRange range = [str rangeOfString:string];//匹配得到的下标
            if(range.location+range.length<str.length){
                str = [str substringFromIndex:range.location+range.length];
                //NSLog(@"%@",str);
                
                if (error) {
                    
                }else{
                    result([NSString stringWithFormat:@"/%@",str]);
                }
            }
           
            

        }];
        
        
        
        
        
        
     
        
    }
    
}
#pragma //mark 通过视频的URL，获得视频缩略图
-(UIImage *)getImage:(NSString *)videoURL
{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
}

@end
