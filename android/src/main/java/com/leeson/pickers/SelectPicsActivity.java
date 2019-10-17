package com.leeson.pickers;

import android.content.Intent;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.os.Bundle;
import android.provider.MediaStore;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.entity.LocalMedia;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import top.zibin.luban.Luban;
import top.zibin.luban.OnCompressListener;
import top.zibin.luban.OnRenameListener;


/**
 * Created by lisen on 2018-09-11.
 *  只选择多张图片，
 * @author lisen < 453354858@qq.com >
 */
@SuppressWarnings("all")
public class SelectPicsActivity extends BaseActivity {

    public static final String GALLERY_MODE = "GALLERY_MODE";
    public static final String SHOW_CAMERA = "SHOW_CAMERA";
    public static final String ENABLE_CROP = "ENABLE_CROP";
    public static final String WIDTH = "WIDTH";
    public static final String HEIGHT = "HEIGHT";
    public static final String COMPRESS_SIZE = "COMPRESS_SIZE";

    public static final String SELECT_COUNT = "SELECT_COUNT";//可选择的数量

    public static final String COMPRESS_PATHS = "COMPRESS_PATHS";//压缩的画
    private Number compressSize;
    private int compressCount = 0;
    private String mode;

    @Override
    public void onCreate(@androidx.annotation.Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_pics);
        mode = getIntent().getStringExtra(GALLERY_MODE);
        Number selectCount = getIntent().getIntExtra(SELECT_COUNT,9);
        boolean showCamera = getIntent().getBooleanExtra(SHOW_CAMERA,false);
        boolean enableCrop = getIntent().getBooleanExtra(ENABLE_CROP,false);
        Number width = getIntent().getIntExtra(WIDTH,1);
        Number height = getIntent().getIntExtra(HEIGHT,1);
        compressSize = getIntent().getIntExtra(COMPRESS_SIZE,500);

        //添加图片
        PictureSelector.create(this)
                .openGallery("image".equals(mode) ? PictureMimeType.ofImage() : PictureMimeType.ofVideo())
                .isCamera(showCamera)
                .maxSelectNum(selectCount.intValue())
                .withAspectRatio(width.intValue(),height.intValue())
                .imageSpanCount(3)// 每行显示个数 int
                .selectionMode(selectCount.intValue() == 1 ? PictureConfig.SINGLE : PictureConfig.MULTIPLE)// 多选 or 单选 PictureConfig.MULTIPLE or PictureConfig.SINGLE
                .previewImage(true)// 是否可预览图片 true or false
                .enableCrop(enableCrop)// 是否裁剪 true or false
                .compress(false)// 是否压缩 true or false
//                .minimumCompressSize(compressSize.intValue())// 小于100kb的图片不压缩
                .compressSavePath(getPath())//压缩图片保存地址
                .forResult(PictureConfig.CHOOSE_REQUEST);
    }

    private String getPath() {
        String path = new AppPath(this).getImgPath();
        File file = new File(path);
        if (file.mkdirs()) {
            createNomedia(path);
            return path;
        }
        createNomedia(path);
        return path;
    }
    private void createNomedia(String path) {
        File nomedia = new File(path,".nomedia");
        if (!nomedia.exists()){
            try {
                nomedia.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK) {
            switch (requestCode) {
                case PictureConfig.CHOOSE_REQUEST:
                    // 图片、视频、音频选择结果回调
                    List<LocalMedia> selectList = PictureSelector.obtainMultipleResult(data);
                    // 例如 LocalMedia 里面返回三种path
                    // 1.media.getPath(); 为原图path
                    // 2.media.getCutPath();为裁剪后path，需判断media.isCut();是否为true  注意：音视频除外
                    // 3.media.getCompressPath();为压缩后path，需判断media.isCompressed();是否为true  注意：音视频除外
                    // 如果裁剪并压缩了，以取压缩路径为准，因为是先裁剪后压缩的

                    List<String> paths = new ArrayList<>();
                    for (int i = 0; i < selectList.size(); i++) {
                        LocalMedia localMedia = selectList.get(i);
                        if (localMedia.isCut()){
                            paths.add(localMedia.getCutPath());
                        }else{
                            paths.add(localMedia.getPath());
                        }
                    }
                    if ("image".equals(mode)){
                        lubanCompress(paths);
                    }else{
                        resolveVideoPath(paths);
                    }

                    break;
            }
        }else{
            finish();
        }
    }

    private void resolveVideoPath(List<String> paths){

        List<Map<String,String>> thumbPaths = new ArrayList<>();
        for (int i = 0; i < paths.size(); i++) {
            String path = paths.get(i);
            Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(path, MediaStore.Video.Thumbnails.FULL_SCREEN_KIND);
            String thumbPath = saveBitmap(bitmap);
            Map<String,String> map = new HashMap<>();
            map.put("thumbPath",thumbPath);
            map.put("path",path);
            thumbPaths.add(map);
        }
        Intent intent = new Intent();
        intent.putExtra(COMPRESS_PATHS, (Serializable) thumbPaths);
        setResult(RESULT_OK,intent);
        finish();
    }

    public String saveBitmap(Bitmap bitmap){
        try {
            File file = new File(new AppPath(this).getImgPath());
            if (!file.exists()){
                file.mkdirs();
            }
            File tempBitmap = new File(file,System.currentTimeMillis()+".png");
            if (tempBitmap.exists()){
                tempBitmap.delete();
                tempBitmap.createNewFile();
            }
            FileOutputStream out = new FileOutputStream(tempBitmap,false);
            if(bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)){
                out.flush();
                out.close();
            }
            return tempBitmap.getAbsolutePath();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }


    private void lubanCompress(final List<String> paths){
        final List<Map<String,String>> lubanCompressPaths = new ArrayList<>();
        Luban.with(this)
                .load(paths)
                .ignoreBy(compressSize.intValue())
                .setTargetDir(getPath())
                .setRenameListener(new OnRenameListener() {
                    @Override
                    public String rename(String filePath) {
                        return filePath.substring(filePath.lastIndexOf("/"));
                    }
                })
                .setCompressListener(new OnCompressListener() {
                    @Override
                    public void onStart() {
                    }

                    @Override
                    public void onSuccess(File file) {
                        // 压缩成功后调用，返回压缩后的图片文件
                        Map<String,String> map = new HashMap<>();
                        map.put("thumbPath",file.getAbsolutePath());
                        map.put("path",file.getAbsolutePath());
                        lubanCompressPaths.add(map);
                        compressCount++;
                        compressFinish(paths,lubanCompressPaths);
                    }

                    @Override
                    public void onError(Throwable e) {
                        // 当压缩过程出现问题时调用
                        compressCount++;
                        compressFinish(paths,lubanCompressPaths);
                    }
                }).launch();
    }
    private void compressFinish(List<String> paths,List<Map<String,String>> compressPaths){
        if (compressCount == paths.size()){
            Intent intent = new Intent();
            intent.putExtra(COMPRESS_PATHS, (Serializable) compressPaths);
            setResult(RESULT_OK,intent);
            finish();
        }
    }
}
