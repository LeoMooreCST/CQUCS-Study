package com.zqiang.caculate24project;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * 启动界面
 */
public class WelcomeActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_welcome);
        //实现跑马灯效果
        TextView top_text = findViewById(R.id.top_text);
        top_text.setSelected(true);
        //游戏规则按钮
        Button ruleBtn = findViewById(R.id.button_rule);
        ruleBtn.setOnClickListener(view -> ruleClick());
        //简单模式按钮
        Button easyBtn = findViewById(R.id.button_easymode);
        easyBtn.setOnClickListener(view -> {
            Intent intent = new Intent(WelcomeActivity.this, GameActivity.class);
            intent.putExtra("mode","easy");
            startActivity(intent);
        });
        //进阶模式按钮
        Button advanceBtn = findViewById(R.id.button_advancemode);
        advanceBtn.setOnClickListener(view -> {
            Intent intent = new Intent(WelcomeActivity.this, GameActivity.class);
            intent.putExtra("mode","advance");
            startActivity(intent);
        });
    }


    /**
     * 点击查看游戏规则
     */
    public void ruleClick(){
        AlertDialog alertDialog = new AlertDialog.Builder(WelcomeActivity.this)
                .setTitle("24点游戏规则")
                .setIcon(R.drawable.rule_icon)
                .setMessage("1. 游戏介绍：24点扑克游戏是一种数字游戏，通过使用扑克牌中的四张牌来得出结果为24。\n" +
                        "2. 牌面介绍：四张牌包括红桃、梅花、方块、黑桃，不包括大小王\n" +
                        "3. 基本操作：玩家需要通过加减乘除四种基本运算，将四张牌的点数相加得出结果为24。\n" +
                        "4. 运算优先级：在进行运算时，先乘除后加减，可以使用括号运算。\n" +
                        "5. 游戏策略：可以通过先计算出结果再进行加法，减法，乘法，除法等方式来提高解题速度。\n")
                .setPositiveButton("确定", (dialogInterface, i) -> { })
                .create();
        alertDialog.show();
    }
}