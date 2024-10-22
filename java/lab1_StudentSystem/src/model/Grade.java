package model;

import java.time.LocalDateTime;

public class Grade {
    /**
     * 平时成绩
     * 期中成绩
     * 实验成绩
     * 期末成绩
     * 总评成绩
     */
    private int usualScore;
    private int midterm;
    private int experiment;
    private int finalExam;
    private int totalScore;

    public Grade(int usual, int midterm, int experiment, int finalExam) {
        this.usualScore = usual;
        this.midterm = midterm;
        this.experiment = experiment;
        this.finalExam = finalExam;
        calculateTotal();
    }
    // 默认构造函数
    public Grade() {
        this(0, 0, 0, 0);
    }

    private void calculateTotal() {
        this.totalScore = (int)(usualScore * 0.1 + midterm * 0.2 + experiment * 0.2 + finalExam * 0.5);
    }

    public int getUsualScore() {
        return usualScore;
    }

    public void setUsualScore(int usualScore) {
        this.usualScore = usualScore;
        calculateTotal();
    }

    public int getMidterm() {
        return midterm;
    }

    public void setMidterm(int midterm) {
        this.midterm = midterm;
        calculateTotal();
    }

    public int getExperiment() {
        return experiment;
    }

    public void setExperiment(int experiment) {
        this.experiment = experiment;
        calculateTotal();
    }

    public int getFinalExam() {
        return finalExam;
    }

    public void setFinalExam(int finalExam) {
        this.finalExam = finalExam;
        calculateTotal();
    }

    public int getTotalScore() {
        return totalScore;
    }


    // 重写toString方法，用于打印成绩单
    @Override
    public String toString() {
        return String.format("%-10d %-10d %-10d %-10d %-10d",
                usualScore, midterm, experiment, finalExam, totalScore);
    }
}
