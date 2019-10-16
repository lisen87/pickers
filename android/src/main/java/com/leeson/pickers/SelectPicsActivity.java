package com.leeson.pickers;

import android.content.Intent;
import android.os.Bundle;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.entity.LocalMedia;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


/**
 * Created by lisen on 2018-09-11.
 *  只选择多张图片，
 * @author lisen < 453354858@qq.com >
 */

public class SelectPicsActivity extends BaseActivity {

    public static final String GALLERY_MODE = "GALLERY_MODE";
    public static final String SHOW_CAMERA = "SHOW_CAMERA";
    public static final String ENABLE_CROP = "ENABLE_CROP";
    public static final String WIDTH = "WIDTH";
    public static final String HEIGHT = "HEIGHT";
    public static final String COMPRESS_SIZE = "COMPRESS_SIZE";
    public static final String MEDIA_LIST = "MEDIA_LIST";//原画
    public static final String ORIGINAL_PATHS = "ORIGINAL_PATHS";//原画
    public static final String COMPRESS_PATHS = "COMPRESS_PATHS";//压缩的画

    public static final String SELECT_COUNT = "SELECT_COUNT";//可选择的数量

    private Number selectCount = 9;
    private String mode = "image";
    private Boolean showCamera;
    private Boolean enableCrop;
    private Number width;
    private Number height;
    private Number compressSize;


    @Override
    public void onCreate(@androidx.annotation.Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mode = getIntent().getStringExtra(GALLERY_MODE);
        selectCount = getIntent().getIntExtra(SELECT_COUNT,9);
        showCamera = getIntent().getBooleanExtra(SHOW_CAMERA,false);
        enableCrop = getIntent().getBooleanExtra(ENABLE_CROP,false);
        width = getIntent().getIntExtra(WIDTH,1);
        height = getIntent().getIntExtra(HEIGHT,1);
        compressSize = getIntent().getIntExtra(COMPRESS_SIZE,500);

        //添加图片
        PictureSelector.create(this)
                .openGallery(mode.equals("image") ? PictureMimeType.ofImage() : PictureMimeType.ofVideo())
                .isCamera(showCamera)
                .maxSelectNum(selectCount.intValue())
                .withAspectRatio(width.intValue(),height.intValue())
                .imageSpanCount(3)// 每行显示个数 int
                .selectionMode(selectCount.intValue() == 1 ? PictureConfig.SINGLE : PictureConfig.MULTIPLE)// 多选 or 单选 PictureConfig.MULTIPLE or PictureConfig.SINGLE
                .previewImage(true)// 是否可预览图片 true or false
                .enableCrop(enableCrop)// 是否裁剪 true or false
                .compress(true)// 是否压缩 true or false
                .minimumCompressSize(compressSize.intValue())// 小于100kb的图片不压缩
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

    private int size = 0;
    @SuppressWarnings("unchecked")
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

                    List<String> compressPaths = new ArrayList<>();
                    List<String> paths = new ArrayList<>();
                    for (int i = 0; i < selectList.size(); i++) {
                        LocalMedia localMedia = selectList.get(i);
                        if (localMedia.isCompressed()){
                            compressPaths.add(localMedia.getCompressPath());
                        }else{
                            compressPaths.add(localMedia.getPath());
                        }
                        paths.add(localMedia.getPath());
                    }

                    Intent intent = new Intent();
                    intent.putExtra(COMPRESS_PATHS, (Serializable) compressPaths);
                    intent.putExtra(ORIGINAL_PATHS, (Serializable) paths);
                    intent.putExtra(MEDIA_LIST, (Serializable) selectList);
                    setResult(RESULT_OK,intent);
                    finish();
                    break;
            }
        }else{
            finish();
        }

    }
}
