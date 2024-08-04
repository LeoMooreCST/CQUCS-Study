package com.zqiang.caculate24project.pojo;

import android.annotation.SuppressLint;
import android.content.Context;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class PokerData {
    public static ArrayList<Integer> pokers = new ArrayList<>();
    public static Map<Integer,Integer>numMap = new HashMap<>();
    public static Map<Integer, Boolean> Selected = new HashMap<>();
    private static final String[]pokerTypes = {"heart","club","diamond","spade"};
    public static void init(Context context) {
        for (String poker : pokerTypes) {
            for (int j = 1; j <= 13; j++) {
                @SuppressLint("DiscouragedApi")
                int resId = context.getResources().getIdentifier
                        (poker + j, "drawable", context.getPackageName());
                pokers.add(resId);
            }
        }
        for (int i=0;i<pokers.size();i++){
            numMap.put(pokers.get(i),i%13+1);
            Selected.put(i,false);
        }
    }
    public static Integer getResource(int i){
        return pokers.get(i);
    }
    public static Integer getNumber(int i){
        return numMap.get(i);
    }
    public static Boolean isSelected(int i){
        return Selected.get(i);
    }
    public static void changeSelected(int i){
        if(Boolean.FALSE.equals(isSelected(i)))
            Selected.put(i,true);
        else Selected.put(i,false);
    }
}
