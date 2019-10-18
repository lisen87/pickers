package com.leeson.pickers;

import android.app.Activity;
import android.content.Intent;

import com.leeson.pickers.activitys.PhotosActivity;
import com.leeson.pickers.activitys.SaveImageToGalleryActivity;
import com.leeson.pickers.activitys.SelectPicsActivity;
import com.leeson.pickers.activitys.VideoActivity;

import org.jetbrains.annotations.NotNull;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Created by lisen on 2019/10/16.
 *
 * @author lisen < 453354858@qq.com >
 */
@SuppressWarnings("all")
public class PickersPlugin implements MethodChannel.MethodCallHandler {

    private static final int SELECT = 102;
    private static final int SAVE_IMAGE = 103;

    private PluginRegistry.Registrar registrar;
    private MethodChannel.Result result;

    public PickersPlugin(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
        this.registrar.addActivityResultListener(new PluginRegistry.ActivityResultListener() {
            @Override
            public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
                if (requestCode == SELECT && resultCode == Activity.RESULT_OK) {
                    List<Map<String,String>> paths = (List<Map<String,String>>) intent.getSerializableExtra(SelectPicsActivity.COMPRESS_PATHS);
                    result.success(paths);
                    return true;
                }else if (requestCode == SAVE_IMAGE && resultCode == Activity.RESULT_OK){
                    String path = intent.getStringExtra(SaveImageToGalleryActivity.PATH);
                    result.success(path);
                }
                return false;
            }
        });
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter/pickers");
        channel.setMethodCallHandler(new PickersPlugin(registrar));
    }

    private String galleryMode;
    private Number selectCount;
    private Boolean showCamera;
    private Boolean enableCrop;
    private Number width;
    private Number height;
    private Number compressSize;

    private void openGallery() {
        Intent intent = new Intent(registrar.context(), SelectPicsActivity.class);
        intent.putExtra(SelectPicsActivity.GALLERY_MODE,galleryMode);
        intent.putExtra(SelectPicsActivity.SELECT_COUNT,selectCount);
        intent.putExtra(SelectPicsActivity.SHOW_CAMERA,showCamera);
        intent.putExtra(SelectPicsActivity.ENABLE_CROP,enableCrop);
        intent.putExtra(SelectPicsActivity.WIDTH,width);
        intent.putExtra(SelectPicsActivity.HEIGHT,height);
        intent.putExtra(SelectPicsActivity.COMPRESS_SIZE,compressSize);
        (registrar.activity()).startActivityForResult(intent, SELECT);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, @NotNull MethodChannel.Result result) {

        this.result = result;
        if ("getPickerPaths".equals(methodCall.method)) {
            galleryMode = methodCall.argument("galleryMode");
            selectCount = methodCall.argument("selectCount");
            showCamera = methodCall.argument("showCamera");
            enableCrop = methodCall.argument("enableCrop");
            width = methodCall.argument("width");
            height = methodCall.argument("height");
            compressSize = methodCall.argument("compressSize");

            openGallery();
        } else if ("previewImage".equals(methodCall.method)) {
            Intent intent = new Intent(registrar.context(), PhotosActivity.class);
            List<String> images = new ArrayList<>();
            images.add(methodCall.argument("path").toString());
            intent.putExtra(PhotosActivity.IMAGES, (Serializable) images);
            (registrar.activity()).startActivity(intent);
        }else if ("previewVideo".equals(methodCall.method)) {
            Intent intent = new Intent(registrar.context(), VideoActivity.class);
            intent.putExtra(VideoActivity.VIDEO_PATH, methodCall.argument("path").toString());
            intent.putExtra(VideoActivity.THUMB_PATH, methodCall.argument("thumbPath").toString());
            (registrar.activity()).startActivity(intent);
        }else if("saveImageToGallery".equals(methodCall.method)){
            Intent intent = new Intent(registrar.context(), SaveImageToGalleryActivity.class);
            intent.putExtra(SaveImageToGalleryActivity.PATH, methodCall.argument("path").toString());
            (registrar.activity()).startActivityForResult(intent,SAVE_IMAGE);
        }else{
            result.notImplemented();
        }
    }
}
