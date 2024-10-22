package view;

import controller.TeacherController;
import model.Teacher;
import model.Grade;
import model.TeachingClass;
import model.Student;

import util.Formatter;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class TeacherView {
    private TeacherController teacherController;

    public TeacherView() {
        teacherController = new TeacherController();
    }

    public void displayMenu(Scanner scanner, Teacher teacher) {
        while(true) {
            System.out.println("===== 教师菜单 =====");
            System.out.println("1. 查询自己教授的课程列表");
            System.out.println("2. 查询教学班的学生列表");
            System.out.println("3. 登记学生成绩");
            System.out.println("4. 修改密码");
            System.out.println("0. 退出登录");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    teacherController.listTeacherCourses(teacher, this);
                    break;
                case "2":
                    teacherController.listTeachingClassStudents(scanner, teacher, this);
                    break;
                case "3":
                    teacherController.enterStudentGrades(scanner, teacher, this);
                    break;
                case "4":
                    teacherController.changePassword(scanner, teacher, this);
                    break;
                case "0":
                    System.out.println("退出教师菜单！");
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
