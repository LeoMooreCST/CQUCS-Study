package com.zqiang.caculate24project.controller;


import android.app.AlertDialog;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;

import com.zqiang.caculate24project.R;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class TwentyFourGameSolver {
    private final Context context;
    static int[] number = new int[4];
    //转换后的num1，num2,num3,num4
    static int[] m =new int [4];
    static String[] n = new String[4];
    //用来判断是否有解
    static boolean flag = false;
    static List<String> solutions = new ArrayList<>();
    //存放操作符
    static char[] operator = { '+', '-', '*', '/' };
    public TwentyFourGameSolver(Context context) {
        this.context = context;
    }

    public String solve24(int[] numbers) {
        AlertDialog.Builder alertDialog = new AlertDialog.Builder(context);
        number = numbers;
        solutions.clear();
        calculate();
        String results = "";
        String currentTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(new Date());
        results = currentTime + "\n";
        if (solutions.isEmpty()) {
            alertDialog.setTitle("很遗憾，你所选的扑克无可行解");
            alertDialog.setIcon(R.drawable.failed);
            alertDialog.setMessage("继续努力吧!");
            results += "无可行解\n";
        } else {
            results = results + solutions.size() + "组解: ";
            alertDialog.setTitle("恭喜你！一共找到"+solutions.size()+"个组合(含重复)\n");
            alertDialog.setIcon(R.drawable.success);
            StringBuilder message = new StringBuilder("以下是可能解的组合: \n");
            for (String solution : solutions) {
                message.append(solution).append("\n");
            }
            results += message.toString();
            alertDialog.setMessage(message.toString());
            alertDialog.setNeutralButton("复制", (dialog, which) -> {
                ClipboardManager clipboard  = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
                ClipData clip = ClipData.newPlainText("Copied Text", message);
                assert clipboard != null;
                clipboard.setPrimaryClip(clip);
            });
        }
        alertDialog.setPositiveButton("确定", (dialog, which) -> dialog.dismiss());
        alertDialog.show();
        return results;
    }


    //给定2个数和指定操作符的计算
    public static Double calcute(double count1, double count2, char operator) {
        if (operator == '+') {
            return (double) (count1 + count2);
        }
        else if (operator == '-') {
            return (double) count1 - count2;
        }
        else if (operator == '*') {
            return (double) count1 * count2;
        }
        else if ((operator == '/' )&& (count2 != 0)) {
            return (double) count1 / count2;
        }
        return -1.0;
    }


    //计算生成24的函数
    public static void calculate(){
        Map<Integer, Integer> map = new HashMap<>();
        //存放数字，用来判断输入的4个数字中有几个重复的，和重复的情况
        for (int j : number) {
            map.merge(j, 1, Integer::sum);
        }
        if(map.size() == 1){
            //如果只有一种数字，此时只有一种排列组合，如5，5，5，5
            calculation(number[0], number[1],number[2],number[3]);
        }
        else if(map.size()==2){
            //如果只有2种数字，有2种情况，如1,1,2,2和1,1,1,2
            int index = 0;//用于数据处理
            int state = 0;//判断是哪种情况
            for (Integer key : map.keySet()) {
                if(map.get(key) == 1){
                    //如果是有1个数字和其他3个都不同，将number变为 number[0]=number[1]=number[2]，
                    //将不同的那个放到number[3]，方便计算
                    number[3] = key;
                    state = 1;
                }
                else if(map.get(key)==2){
                    //如果是两两相同的情况，将number变为number[0]=number[1],number[2]=number[3]的情况
                    number[index++]=key;
                    number[index++]=key;
                }
                else{
                    number[index++]=key;
                }
            }
            //列出2种情况的所有排列组合，并分别计算
            if(state == 1){
                calculation(number[3],number[1],number[1],number[1]);
                calculation(number[1],number[3],number[1],number[1]);
                calculation(number[1],number[1],number[3],number[1]);
                calculation(number[1],number[1],number[1],number[3]);
            }
            if(state==0){
                calculation(number[1],number[1],number[3],number[3]);
                calculation(number[1],number[3],number[1],number[3]);
                calculation(number[1],number[3],number[3],number[1]);
                calculation(number[3],number[3],number[1],number[1]);
                calculation(number[3],number[1],number[3],number[1]);
                calculation(number[3],number[1],number[1],number[3]);
            }
        }
        else if(map.size()==3){
            //有3种数字的情况
            int index = 0;
            for (Integer key : map.keySet()) {
                if(map.get(key) == 2){
                    //将相同的2个数字放到number[2]=number[3]
                    number[2] = key;
                    number[3] = key;
                }
                else {
                    number[index++] = key;
                }
            }
            //排列组合，所有情况
            /*int[] numbers = {number[0], number[1], number[3], number[3]};
            for (int i = 0; i < 4; i++) {
                for (int j = 0; j < 4; j++) {
                    if (i != j) {
                        int temp = numbers[i];
                        numbers[i] = numbers[j];
                        calculation(numbers[0], numbers[1], numbers[2], numbers[3]);
                        numbers[i] = temp;  // 恢复原始值
                    }
                }
            }*/
            calculation(number[0],number[1],number[3],number[3]);
            calculation(number[0],number[3],number[1],number[3]);
            calculation(number[0],number[3],number[3],number[1]);
            calculation(number[1],number[0],number[3],number[3]);
            calculation(number[1],number[3],number[0],number[3]);
            calculation(number[1],number[3],number[3],number[0]);
            calculation(number[3],number[3],number[0],number[1]);
            calculation(number[3],number[3],number[1],number[0]);
            calculation(number[3],number[1],number[3],number[0]);
            calculation(number[3],number[0],number[3],number[1]);
            calculation(number[3],number[0],number[1],number[3]);
            calculation(number[3],number[1],number[0],number[3]);
        }
        else if(map.size() == 4){
            //4个数都不同的情况
            /*int[] numbers = {number[0], number[1], number[2], number[3]};
            for (int a = 0; a < 4; a++) {
                for (int b = 0; b < 4; b++) {
                    if (b != a) {
                        for (int c = 0; c < 4; c++) {
                            if (c != a && c != b) {
                                for (int d = 0; d < 4; d++) {
                                    if (d != a && d != b && d != c) {
                                        calculation(numbers[a], numbers[b], numbers[c], numbers[d]);
                                    }
                                }
                            }
                        }
                    }
                }
            }*/
            calculation(number[0],number[1],number[2],number[3]);
            calculation(number[0],number[1],number[3],number[2]);
            calculation(number[0],number[2],number[1],number[3]);
            calculation(number[0],number[2],number[3],number[1]);
            calculation(number[0],number[3],number[1],number[2]);
            calculation(number[0],number[3],number[2],number[1]);
            calculation(number[1],number[0],number[2],number[3]);
            calculation(number[1],number[0],number[3],number[2]);
            calculation(number[1],number[2],number[3],number[0]);
            calculation(number[1],number[2],number[0],number[3]);
            calculation(number[1],number[3],number[0],number[2]);
            calculation(number[1],number[3],number[2],number[0]);
            calculation(number[2],number[0],number[1],number[3]);
            calculation(number[2],number[0],number[3],number[1]);
            calculation(number[2],number[1],number[0],number[3]);
            calculation(number[2],number[1],number[3],number[0]);
            calculation(number[2],number[3],number[0],number[1]);
            calculation(number[2],number[3],number[1],number[0]);
            calculation(number[3],number[0],number[1],number[2]);
            calculation(number[3],number[0],number[2],number[1]);
            calculation(number[3],number[1],number[0],number[2]);
            calculation(number[3],number[1],number[2],number[0]);
            calculation(number[3],number[2],number[0],number[1]);
            calculation(number[3],number[2],number[1],number[0]);
        }
    }

    public static void calculation(int num1, int num2, int num3, int num4){

        for (int i = 0; i < 4; i++){
            //第1次计算，先从四个数中任意选择两个进行计算
            char operator1 = operator[i];
            double firstResult = calcute(num1, num2, operator1);//先选第一，和第二个数进行计算
            double midResult = calcute(num2, num3, operator1);//先选第二和第三两个数进行计算
            double tailResult = calcute(num3,num4, operator1);//先选第三和第四俩个数进行计算
            for (int j = 0; j < 4; j++){
                //第2次计算，从上次计算的结果继续执行，这次从三个数中选择两个进行计算
                char operator2 = operator[j];
                double firstMidResult = calcute(firstResult, num3, operator2);
                double firstTailResult = calcute(num3,num4,operator2);
                double midFirstResult = calcute(num1, midResult, operator2);
                double midTailResult= calcute(midResult,num4,operator2);
                double tailMidResult = calcute(num2, tailResult, operator2);
                for (int k = 0; k < 4; k++){
                    //第3次计算，也是最后1次计算，计算两个数的结果，如果是24则输出表达式
                    char operator3 = operator[k];
                    //在以上的计算中num1，num2,num3,num4都是整型数值，但若要输出为带有A，J,Q,K的表达式，则要将这四个数都变为String类型，下同
                    if(calcute(firstMidResult, num4, operator3) == 24){
                        m[0]=num1; m[1]=num2; m[2]=num3; m[3]=num4;
                        transformValue();
                        solutions.add("((" + n[0] + operator1 + n[1] + ")" + operator2 + n[2] + ")" + operator3 + n[3]);
                        flag = true;//若有表达式输出，则将说明有解，下同
                    }
                    if(calcute(firstResult, firstTailResult, operator3) == 24){
                        ///88888888888888888
                        m[0]=num1; m[1]=num2; m[2]=num3; m[3]=num4;
                        transformValue();
                        solutions.add("(" + n[0] + operator1 + n[1] + ")" + operator3 + "(" + n[2] + operator2 + n[3] + ")");
                        flag = true;
                    }
                    if(calcute(midFirstResult, num4, operator3) == 24){
                        m[0]=num1; m[1]=num2; m[2]=num3; m[3]=num4;
                        transformValue();
                        solutions.add("(" + n[0] + operator2 + "(" + n[1] + operator1 + n[2] + "))" + operator3 + n[3]);
                        flag = true;
                    }
                    if(calcute((double) num1,midTailResult, operator3) == 24){
                        m[0]=num1; m[1]=num2; m[2]=num3; m[3]=num4;
                        transformValue();
                        solutions.add(" " + n[0] + operator3 + "((" + n[1] + operator1 + n[2] + ")" + operator2 + n[3] + ")");
                        flag = true;
                    }
                    if(calcute((double) num1,tailMidResult,operator3) == 24){
                        m[0]=num1; m[1]=num2; m[2]=num3; m[3]=num4;
                        transformValue();
                        solutions.add(" " + n[0] + operator3 + "(" + n[1] + operator2 + "(" + n[2] + operator1 + n[3] + "))");
                        flag = true;
                    }
                }
            }
        }
    }

    public static void transformValue(){
        String[] cardNames = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"};
        for(int p=0;p<4;p++){
            if (m[p]>=1 && m[p]<=13){
                n[p] = cardNames[m[p]-1];
            }
        }
    }
}
