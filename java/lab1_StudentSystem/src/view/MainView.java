package view;

import controller.AdminController;
import controller.StudentController;
import controller.TeacherController;
import model.*;
import util.DataStore;

import java.util.Scanner;

public class MainView {
    /**
     * 主视图
     * 1. 登录
     * 2. 初始化数据，生成测试数据，自动选课和打分（开发测试使用）
     * 0. 退出
     */
    private Scanner scanner;
    private AdminController adminController;
    private TeacherController teacherController;
    private StudentController studentController;
    private DataStore dataStore;

    public MainView() {
        scanner = new Scanner(System.in);
        adminController = new AdminController();
        teacherController = new TeacherController();
        studentController = new StudentController();
        dataStore = DataStore.getInstance();
    }

    public void displayMainMenu() {
        while(true) {
            System.out.println("===== 学生成绩管理系统 =====");
            System.out.println("1. 登录");
            System.out.println("2. 初始化数据，生成测试数据，自动选课和打分（开发测试使用）");
            System.out.println("0. 退出");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    login();
                    break;
                case "2":
                    dataStore.initializeData();
                    System.out.println("数据初始化完成！");
                    break;
                case "0":
                    System.out.println("退出系统！");
                    System.exit(0);
                default:
                    System.out.println("无效选择！");
            }
        }
    }

    private void login() {
        System.out.print("请输入用户ID: ");
        String id = scanner.nextLine();
        System.out.print("请输入密码: ");
        String pwd = scanner.nextLine();

        User user = authenticate(id, pwd);   // 返回的是User对象，是一个父类，可以指向子类对象
        if(user != null) {
            System.out.println("登录成功！角色: " + user.getRole());
            switch(user.getRole()) {
                case "管理员":
                    AdminView adminView = new AdminView();
                    adminView.displayMenu(scanner);   // 管理员有最高权限，不需要传入admin对象
                    break;
                case "教师":
                    TeacherView teacherView = new TeacherView();
                    teacherView.displayMenu(scanner, (Teacher)user);    // 可以转换为Teacher对象
                    break;
                case "学生":
                    StudentView studentView = new StudentView();
                    studentView.displayMenu(scanner, (Student)user);
                    break;
                default:
                    System.out.println("未知角色！");
            }
        } else {
            System.out.println("登录失败！请检查ID和密码。");
        }
    }

    private User authenticate(String id, String pwd) {
        for(Admin admin : dataStore.getAdmins()) {
            if(admin.getId().equals(id) && admin.checkPassword(pwd)) {
                return admin;
            }
        }
        for(Teacher teacher : dataStore.getTeachers()) {
            if(teacher.getId().equals(id) && teacher.checkPassword(pwd)) {
                return teacher;
            }
        }
        for(Student student : dataStore.getStudents()) {
            if(student.getId().equals(id) && student.checkPassword(pwd)) {
                return student;
            }
        }
        return null;
    }
}
