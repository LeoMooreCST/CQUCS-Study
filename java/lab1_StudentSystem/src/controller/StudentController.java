package controller;

import model.*;
import util.DataStore;
import view.StudentView;

import java.util.*;
import java.util.stream.Collectors;

public class StudentController {
    private DataStore dataStore;


    public StudentController() {
        // 使用的是单例模式，确保数据唯一，都是一个对象
        dataStore = DataStore.getInstance();
    }

    // 查询自己的成绩
    public void viewOwnGrades(Student student, StudentView studentView) {
        // 先判断是否有成绩
        if(student.getGrades().isEmpty()) {
            studentView.displayMessage("您尚未选修任何课程。");
            return;
        }
        String[] headers = {"课程编号", "课程名称", "平时成绩", "期中成绩", "实验成绩", "期末成绩", "综合成绩"};
        List<String[]> rows = new ArrayList<>();
        int total = 0;
        for(Map.Entry<Course, Grade> entry : student.getGrades().entrySet()) {
            Course course = entry.getKey();
            Grade grade = entry.getValue();
            rows.add(new String[]{
                    course.getCourseId(),
                    course.getCourseName(),
                    String.valueOf(grade.getUsualScore()),
                    String.valueOf(grade.getMidterm()),
                    String.valueOf(grade.getExperiment()),
                    String.valueOf(grade.getFinalExam()),
                    String.valueOf(grade.getTotalScore()),
            });
            total += grade.getTotalScore();
        }
        studentView.displayTable(headers, rows);
        System.out.println("总成绩: " + total);
    }

    // 选课
    public void selectCourse(Scanner scanner, Student student, StudentView studentView) {
        System.out.println("===== 可选课程 =====");
        // 找出未选的课程
        List<Course> availableCourses = dataStore.getCourses().stream()
                .filter(c -> !student.getSelectedClasses().containsKey(c))
                .collect(Collectors.toList());
        if(availableCourses.isEmpty()) {
            studentView.displayMessage("您已选修所有课程！");
            return;
        }
        String[] headers = {"课程编号", "课程名称"};
        List<String[]> rows = new ArrayList<>();
        for(Course c : availableCourses) {
            rows.add(new String[]{c.getCourseId(), c.getCourseName()});
        }
        studentView.displayTable(headers, rows);

        System.out.print("请输入要选的课程编号: ");
        String courseId = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
        if(course == null) {
            studentView.displayMessage("课程不存在！");
            return;
        }
        // 找到可选的教学班
        List<TeachingClass> availableClasses = dataStore.getTeachingClasses().stream()
                .filter(tc -> tc.getCourse().equals(course) && tc.getStudents().size() < tc.getTotalStudents())
                .collect(Collectors.toList());
        if(availableClasses.isEmpty()) {
            studentView.displayMessage("没有可选的教学班！");
            return;
        }
        String[] classHeaders = {"教学班编号", "教师", "学期"};
        List<String[]> classRows = new ArrayList<>();
        for(TeachingClass tc : availableClasses) {
            String teacherName = (tc.getTeacher() != null) ? tc.getTeacher().getName() : "无";
            classRows.add(new String[]{
                    tc.getClassId(),
                    teacherName,
                    tc.getSemester()
            });
        }
        studentView.displayTable(classHeaders, classRows);

        System.out.print("请输入要选择的教学班编号: ");
        String classIdInput = scanner.nextLine();
        TeachingClass tClass = availableClasses.stream().filter(tc -> tc.getClassId().equals(classIdInput)).findFirst().orElse(null);
        if(tClass == null) {
            studentView.displayMessage("教学班不存在或已满！");
            return;
        }
        boolean added = tClass.addStudent(student);
        if(added) {
            student.selectCourse(course, tClass);

            studentView.displayMessage("选课成功！");
        } else {
            studentView.displayMessage("教学班已满！");
        }
    }

    // 退课
    public void withdrawCourse(Scanner scanner, Student student, StudentView studentView) {
        if(student.getSelectedClasses().isEmpty()) {
            studentView.displayMessage("您未选修任何课程！");
            return;
        }
        String[] headers = {"课程编号", "课程名称", "教学班编号"};
        List<String[]> rows = new ArrayList<>();
        for(Map.Entry<Course, TeachingClass> entry : student.getSelectedClasses().entrySet()) {
            rows.add(new String[]{
                    entry.getKey().getCourseId(),
                    entry.getKey().getCourseName(),
                    entry.getValue().getClassId()
            });
        }
        studentView.displayTable(headers, rows);

        System.out.print("请输入要退选的课程编号: ");
        String courseId = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
        if(course == null) {
            studentView.displayMessage("课程不存在！");
            return;
        }
        if(!student.getSelectedClasses().containsKey(course)) {
            studentView.displayMessage("您未选修此课程！");
            return;
        }
        TeachingClass tClass = student.getSelectedClasses().get(course);
        tClass.removeStudent(student);
        student.withdrawCourse(course);
        studentView.displayMessage("退课成功！");
    }

    // 修改密码
    public void changePassword(Scanner scanner, Student student, StudentView studentView) {
        System.out.print("请输入当前密码: ");
        String currentPwd = scanner.nextLine();
        if(!student.checkPassword(currentPwd)) {
            studentView.displayMessage("当前密码错误！");
            return;
        }
        System.out.print("请输入新密码: ");
        String newPwd = scanner.nextLine();
        student.setPassword(newPwd);
        studentView.displayMessage("密码修改成功！");
    }
}
