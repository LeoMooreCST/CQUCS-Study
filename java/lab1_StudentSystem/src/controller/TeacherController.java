package controller;

import model.*;
import util.DataStore;
import view.TeacherView;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class TeacherController {
    private DataStore dataStore;

    public TeacherController() {
        dataStore = DataStore.getInstance();
    }

    // 查询教师教授的课程列表
    public void listTeacherCourses(Teacher teacher, TeacherView teacherView) {
        List<TeachingClass> teachingClasses = teacher.getTeachingClasses();
        if(teachingClasses.isEmpty()) {
            teacherView.displayMessage("您尚未教授任何课程。");
            return;
        }
        String[] headers = {"教学班编号", "课程名称", "学期"};
        List<String[]> rows = new ArrayList<>();
        for(TeachingClass tc : teachingClasses) {
            rows.add(new String[]{
                    tc.getClassId(),
                    tc.getCourse().getCourseName(),
                    tc.getSemester()
            });
        }
        teacherView.displayTable(headers, rows);
    }

    // 查询教学班的学生列表
    public void listTeachingClassStudents(Scanner scanner, Teacher teacher, TeacherView teacherView) {
        System.out.print("请输入教学班编号: ");
        String classId = scanner.nextLine();
        TeachingClass tClass = teacher.getTeachingClasses().stream()
                .filter(tc -> tc.getClassId().equals(classId))
                .findFirst().orElse(null);
        if(tClass == null) {
            teacherView.displayMessage("教学班不存在或不属于您！");
            return;
        }
        List<Student> students = tClass.getStudents();
        if(students.isEmpty()) {
            teacherView.displayMessage("该教学班暂无学生。");
            return;
        }
        String[] headers = {"学生编号", "姓名", "性别", "平时成绩", "期中成绩", "实验成绩", "期末成绩", "综合成绩"};
        List<String[]> rows = new ArrayList<>();
        for(Student s : students) {
            Grade grade = s.getGrades().get(tClass.getCourse());
            if(grade != null) {
                rows.add(new String[]{
                        s.getId(),
                        s.getName(),
                        s.getGender(),
                        String.valueOf(grade.getUsualScore()),
                        String.valueOf(grade.getMidterm()),
                        String.valueOf(grade.getExperiment()),
                        String.valueOf(grade.getFinalExam()),
                        String.valueOf(grade.getTotalScore()),
                });
            } else {
                rows.add(new String[]{
                        s.getId(),
                        s.getName(),
                        s.getGender(),
                        "未录入",
                        "未录入",
                        "未录入",
                        "未录入",
                        "未录入",
                        "未录入"
                });
            }
        }
        teacherView.displayTable(headers, rows);
    }

    // 登记学生成绩
    public void enterStudentGrades(Scanner scanner, Teacher teacher, TeacherView teacherView) {
        System.out.print("请输入教学班编号: ");
        String classId = scanner.nextLine();
        TeachingClass tClass = teacher.getTeachingClasses().stream()
                .filter(tc -> tc.getClassId().equals(classId))
                .findFirst().orElse(null);
        if(tClass == null) {
            teacherView.displayMessage("教学班不存在或不属于您！");
            return;
        }
        if(tClass.getStudents().isEmpty()) {
            teacherView.displayMessage("该教学班暂无学生。");
            return;
        }
        for(Student s : tClass.getStudents()) {
            System.out.println("正在为学生 " + s.getName() + " 录入成绩：");
            try {
                System.out.print("平时成绩: ");
                int usual = Integer.parseInt(scanner.nextLine());
                System.out.print("期中成绩: ");
                int midterm = Integer.parseInt(scanner.nextLine());
                System.out.print("实验成绩: ");
                int experiment = Integer.parseInt(scanner.nextLine());
                System.out.print("期末成绩: ");
                int finalExam = Integer.parseInt(scanner.nextLine());

                Grade grade = new Grade(usual, midterm, experiment, finalExam);
                s.getGrades().put(tClass.getCourse(), grade);
                teacherView.displayMessage("成绩录入成功！");
            } catch(NumberFormatException e) {
                teacherView.displayMessage("请输入有效的数字！");
            }
        }
    }

    // 修改密码
    public void changePassword(Scanner scanner, Teacher teacher, TeacherView teacherView) {
        System.out.print("请输入当前密码: ");
        String currentPwd = scanner.nextLine();
        if(!teacher.checkPassword(currentPwd)) {
            teacherView.displayMessage("当前密码错误！");
            return;
        }
        System.out.print("请输入新密码: ");
        String newPwd = scanner.nextLine();
        teacher.setPassword(newPwd);
        teacherView.displayMessage("密码修改成功！");
    }
}
