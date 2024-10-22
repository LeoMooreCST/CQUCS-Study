package view;

import controller.AdminController;
import util.Formatter;

import java.util.List;
import java.util.Scanner;

public class AdminView {
    private AdminController adminController;

    public AdminView() {
        adminController = new AdminController();
    }

    public void displayMenu(Scanner scanner) {
        while(true) {
            System.out.println("===== 管理员菜单 =====");
            System.out.println("1. 管理教师");
            System.out.println("2. 管理学生");
            System.out.println("3. 管理课程");
            System.out.println("4. 管理教学班");
            System.out.println("5. 修改学生成绩");
            System.out.println("6. 查询功能");
            System.out.println("7. 初始化测试数据");
            System.out.println("0. 退出登录");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    adminController.manageTeachers(scanner, this); // 传入当前视图对象
                    break;
                case "2":
                    adminController.manageStudents(scanner, this);
                    break;
                case "3":
                    adminController.manageCourses(scanner, this);
                    break;
                case "4":
                    adminController.manageTeachingClasses(scanner, this);
                    break;
                case "5":
                    adminController.modifyStudentGrades(scanner, this);
                    break;
                case "6":
                    adminController.queryFunctions(scanner, this);
                    break;
                case "7":
                    adminController.initializeData(scanner, this);
                    break;
                case "0":
                    System.out.println("退出管理员菜单！");
                    return;
                default:
                    System.out.println("无效选择！");
            }
        }
    }

    // 方法用于接收和显示查询结果等信息
    public void displayMessage(String message) {
        System.out.println(message);
    }

    public void displayTable(String[] headers, List<String[]> rows) {
        Formatter.printTable(headers, rows);

    }
}
