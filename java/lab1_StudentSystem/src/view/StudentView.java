package view;

import controller.StudentController;
import model.Student;
import model.Grade;
import model.Course;
import model.TeachingClass;

import util.Formatter;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class StudentView {
    private StudentController studentController;

    public StudentView() {
        studentController = new StudentController();
    }

    public void displayMenu(Scanner scanner, Student student) {
        while(true) {
            System.out.println("===== 学生菜单 =====");
            System.out.println("1. 查询自己的成绩");
            System.out.println("2. 选课");
            System.out.println("3. 退课");
            System.out.println("4. 修改密码");
            System.out.println("0. 退出登录");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    studentController.viewOwnGrades(student, this);
                    break;
                case "2":
                    studentController.selectCourse(scanner, student, this);
                    break;
                case "3":
                    studentController.withdrawCourse(scanner, student, this);
                    break;
                case "4":
                    studentController.changePassword(scanner, student, this);
                    break;
                case "0":
                    System.out.println("退出学生菜单！");
                    return;
                default:
                    System.out.println("无效选择！");
            }
        }
    }

    public void displayTable(String[] headers, List<String[]> rows) {
        Formatter.printTable(headers, rows);
    }

    public void displayMessage(String message) {
        System.out.println(message);
    }
}
