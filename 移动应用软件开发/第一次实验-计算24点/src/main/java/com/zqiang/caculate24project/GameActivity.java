package com.zqiang.caculate24project;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map.Entry;
import com.google.android.material.snackbar.Snackbar;
import com.zqiang.caculate24project.controller.TwentyFourGameSolver;
import com.zqiang.caculate24project.pojo.PokerData;
import com.zqiang.caculate24project.pojo.ImageIdentity;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class GameActivity extends AppCompatActivity {

    //topImages: 存储四张选择的扑克牌
    private final ArrayList<ImageView> topImages = new ArrayList<>();
    //topImageMap：映射四张扑克牌的drawable ID和id，初始值为null
    //ImageIdentity: {resID, arrayID}
    private final Map<ImageView, ImageIdentity>topImageMap = new HashMap<>();
    //存储当前界面动态创建的各个ImageView对象，根据arrayID一一索引
    private final ArrayList<ImageView> dynamicImageViews = new ArrayList<>();
    //玩家选择的游戏模式
    private static String mode = null;
    private SharedPreferences sharedPreferences;
    TextView textBox;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_game);
        Intent intent = getIntent();
        mode = intent.getStringExtra("mode");
        textBox = findViewById(R.id.textBox);
        //设置每张扑克牌的样式: width(px->dp), height(px->dp), gravity(0x...)
        FrameLayout.LayoutParams pokerParam = new FrameLayout.LayoutParams(DpToPx(100),DpToPx(90),0x50);
        //初始化界面数据项
        PokerData.init(this);
        for (int i = 1; i <= 4; i++) {
            @SuppressLint("DiscouragedApi")
            int imageId = getResources().getIdentifier
                    ("imageView" + i, "id", getPackageName());
            ImageView topImage = findViewById(imageId);
            topImages.add(topImage);
            topImageMap.put(topImage,null);
        }
        addImageViews(pokerParam);
        //提交按钮
        Button submitBtn  = findViewById(R.id.submit_button);
        submitBtn.setOnClickListener(view -> {
            if (calculateValues() == null){
                Snackbar.make(view,"请选择4张扑克牌！",Snackbar.LENGTH_LONG).show();
            }
            else {
                TwentyFourGameSolver gameSolver = new TwentyFourGameSolver( GameActivity.this);
                String newRecord = textBox.getText().toString() + gameSolver.solve24(calculateValues());
                textBox.setText(newRecord);
                saveRecordToSharedPreferences(newRecord);
            }
        });
        //清空按钮
        Button resetBtn = findViewById(R.id.reset_button);
        resetBtn.setOnClickListener(this::resetPokers);
        //历史记录按钮
        Button historyButton = findViewById(R.id.historyButton);
        historyButton.setOnClickListener(view -> historyShow());

        sharedPreferences = getSharedPreferences("Preference", Context.MODE_PRIVATE);
        loadRecordFromSharedPreferences();

    }

    /**
     * 初始化52张扑克牌
     * @param pokerParam: 每张扑克牌的基础布局
     */
    public void addImageViews(FrameLayout.LayoutParams pokerParam){
        dynamicImageViews.clear();
        //获取存放玩家扑克牌的容器
        FrameLayout pokerFrameLayout1 = findViewById(R.id.poker_layout1);
        FrameLayout pokerFrameLayout2 = findViewById(R.id.poker_layout2);
        FrameLayout pokerFrameLayout3 = findViewById(R.id.poker_layout3);
        FrameLayout pokerFrameLayout4 = findViewById(R.id.poker_layout4);
        //随机生成四副各含13张扑克牌,根据用户选择的模式进行生成
        int numOfPoker = 52;
        List<Integer> randomNumbers = generateRandomNumbers(numOfPoker);
        //对四副牌进行升序排序
        for(int i=0;i<=3;i++){
            randomNumbers.subList(13*i,13+13*i).sort(new SizeOfNumberComparator());
        }
        for(int t = 0;t < numOfPoker; t++){
            int i = randomNumbers.get(t);
            //设置扑克布局
            FrameLayout.LayoutParams layoutParams1 = new FrameLayout.LayoutParams
                    (pokerParam.width,pokerParam.height,pokerParam.gravity);
            layoutParams1.leftMargin=(t%13)*90;
            //新建一个图片对象和图片来源
            ImageView pokeImageView = new ImageView(GameActivity.this);
            pokeImageView.setImageResource(PokerData.pokers.get(i));
            pokeImageView.setLayoutParams(layoutParams1);
            pokeImageView.setScaleX(1.15f);
            pokeImageView.setScaleY(1.15f);

            dynamicImageViews.add(pokeImageView);
            int arrayID = t;
            pokeImageView.setOnClickListener(view -> pokerClickListener(view,i, arrayID));

            if(t<13) {pokerFrameLayout1.addView(pokeImageView);}
            else if(t<26) {pokerFrameLayout2.addView(pokeImageView);}
            else if(t<39) {pokerFrameLayout3.addView(pokeImageView);}
            else {pokerFrameLayout4.addView(pokeImageView);}
        }
    }

    /**
     * 点击每张图片的效果
     * @param view        传入一个image view
     * @param i           每张扑克的hash映射key
     * @param arrayID     每张扑克牌在dynamicImageViews中的索引
     */
    public void pokerClickListener(View view, int i, int arrayID){
        ImageView clickedImage = dynamicImageViews.get(arrayID);
        FrameLayout.LayoutParams pokerParam = new FrameLayout.LayoutParams(DpToPx(100),DpToPx(90),0x50);
        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) clickedImage.getLayoutParams();
        Integer targetValue = PokerData.getResource(i);
        //未选中状态
        if (Boolean.FALSE.equals(PokerData.isSelected(arrayID))){
            int pos;
            for (pos = 0; pos <= 3; pos++){
                ImageView tempImage = topImages.get(pos);
                if(topImageMap.get(tempImage)==null){
                    tempImage.setImageResource(targetValue);
                    topImageMap.put(tempImage,new ImageIdentity(targetValue,arrayID));
                    PokerData.changeSelected(arrayID);
                    pokerParam.setMargins(params.leftMargin,params.topMargin,params.rightMargin,50);
                    clickedImage.setLayoutParams(pokerParam);
                    break;
                }
            }
            if(pos >= 4) {
                Snackbar.make(view,"所选用的牌不能超过4张!",Snackbar.LENGTH_LONG).show();
            }
        }
        //选中状态
        else {
            ImageView foundView = null;
            for (Entry<ImageView, ImageIdentity> entry : topImageMap.entrySet()) {
                ImageIdentity tempIdentity = entry.getValue();
                if(tempIdentity!=null){
                    Integer value = entry.getValue().getResID();
                    if (value != null && value.equals(targetValue)) {
                        foundView = entry.getKey();
                        break;
                    }
                }
            }
            if(foundView!=null){
                foundView.setImageResource(R.drawable.ic_ok);
                topImageMap.put(foundView,null);
                PokerData.changeSelected(arrayID);
                pokerParam.setMargins(params.leftMargin,params.topMargin,params.rightMargin,0);
                clickedImage.setLayoutParams(pokerParam);
            }
            else Snackbar.make(view,"发生异常！请稍后再试！",Snackbar.LENGTH_LONG).show();  //发生异常
        }
    }

    /***
     * 计算扑克数值数组，用于计算24点
     * @return null: 代表玩家选择的扑克牌小于4张
     * otherwise: 返回玩家所选择的牌的数字数组
     */
    public int[] calculateValues(){
        int[] num = new int[4];
        int cnt = 0;
        for (int pos=0; pos<=3; pos++ ){
            ImageView tempImage = topImages.get(pos);
            if(topImageMap.get(tempImage) != null){
                Integer pokerId = Objects.requireNonNull(topImageMap.get(tempImage)).getResID();
                if (pokerId !=null){
                    Integer pokerValue = PokerData.getNumber(pokerId);
                    if (pokerValue != null) num[cnt] = pokerValue;
                    cnt++;
                }
            }
        }
        if (cnt<4) return null;
        else return num;
    }

    /**
     * 清空底部扑克牌
     */
    public void resetPokers(View view){
        for (Entry<ImageView, ImageIdentity> entry : topImageMap.entrySet()) {
            ImageIdentity tempIdentity = entry.getValue();
            if(tempIdentity!=null){
                ImageView tempView = entry.getKey();
                ImageView currImage = dynamicImageViews.get(tempIdentity.getArrayId());
                //一定要把选中状态进行修改
                PokerData.changeSelected(tempIdentity.getArrayId());
                //下边距设为0
                FrameLayout.LayoutParams pokerParam = new FrameLayout.LayoutParams(DpToPx(100),DpToPx(90),0x50);
                FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) currImage.getLayoutParams();
                pokerParam.setMargins(params.leftMargin,params.topMargin,params.rightMargin,0);
                currImage.setLayoutParams(pokerParam);
                //消除映射关系
                topImageMap.put(tempView,null);
                tempView.setImageResource(R.drawable.ic_ok);
            }
        }
    }

    /**
     * 显示历史记录
     */
    public void historyShow(){
        AlertDialog alertDialog = new AlertDialog.Builder(GameActivity.this)
                .setTitle("游戏历史记录")
                .setIcon(R.drawable.rule_icon)
                .setMessage(textBox.getText())
                .setPositiveButton("确定",((dialogInterface, i) -> {}))
                .setNegativeButton("清空历史记录",((dialogInterface, i) -> clearHistory()))
                .show();
    }

    public void loadRecordFromSharedPreferences(){
        String records = sharedPreferences.getString("Record","");
        textBox.setText(records);
    }

    /**
     * 将历史记录缓存到本地
     * @param record  每次游戏产生的记录
     */
    public void saveRecordToSharedPreferences(String record){
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString("Record",record);
        editor.apply();
    }

    /**
     * 清空历史记录
     */
    public void clearHistory(){
        textBox.setText("");
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.remove("Record");
        editor.apply();
    }
    /**
     *
     * @param n: 随机生成n张不同的扑克牌
     * @return tempNumbers：含n个0-51的整数的List
     */
    public static List<Integer> generateRandomNumbers(int n) {
        List<Integer> tempNumbers = new ArrayList<>();
        for (int i=0;i<n;i++){
            tempNumbers.add(i);
        }
        //进阶模式时四副牌为乱序
        if (mode.equals("advance")){
            Collections.shuffle(tempNumbers);
        }
        return tempNumbers;
    }

    /**
     * 将获得的每张扑克牌按照映射的数值从小到大排序
     * 获取数值函数为: DataModel.numMap.get(DataModel.pokers.get(num1));
     */
    static class SizeOfNumberComparator implements Comparator<Integer> {
        @Override
        public int compare(Integer num1, Integer num2) {
            Integer Num1 = PokerData.getNumber(PokerData.getResource(num1));
            Integer Num2 = PokerData.getNumber(PokerData.getResource(num2));
            if (Num1 != null && Num2 != null) {
                return Integer.compare(Num1, Num2);
            }
            return 0;
        }
    }

    /**
     * 单位转化：dp --> px
     * @param dp: layout单位
     * @return px: java int单位
     */
    public int DpToPx(float dp) {
        final float scale =getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }
    /*
     * 单位转化：px --> dp
     * @param px: java int单位
     * @return dp: layout单位
    public int PxToDp(float px) {
        final float scale = getResources().getDisplayMetrics().density;
        return (int) (px / scale + 0.5f);
    }*/
}