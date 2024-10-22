package controller;

import model.*;
import util.DataStore;
import view.AdminView;

import java.util.*;
import java.util.stream.Collectors;

public class AdminController {
    private DataStore dataStore;

    public AdminController() {
        dataStore = DataStore.getInstance();
        // 数据只有一份
    }

    // 管理教师
    public void manageTeachers(Scanner scanner, AdminView adminView) {
        while(true) {
            System.out.println("===== 管理教师 =====");
            System.out.println("1. 添加教师");
            System.out.println("2. 删除教师");
            System.out.println("3. 修改教师");
            System.out.println("4. 查询教师");
            System.out.println("0. 返回上级菜单");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    addTeacher(scanner, adminView);
                    break;
                case "2":
                    deleteTeacher(scanner, adminView);
                    break;
                case "3":
                    updateTeacher(scanner, adminView);
                    break;
                case "4":
                    listTeachers(adminView);
                    break;
                case "0":
                    return;
                default:
                    adminView.displayMessage("无效选择！");
            }
        }
    }

    private void addTeacher(Scanner scanner, AdminView adminView) {
        System.out.print("请输入教师编号: ");
        String id = scanner.nextLine();
        if(dataStore.getTeachers().stream().anyMatch(t -> t.getId().equals(id))) {
            adminView.displayMessage("教师编号已存在！");
            return;
        }
        System.out.print("请输入教师姓名: ");
        String name = scanner.nextLine();
        Teacher teacher = new Teacher(id, name);
        dataStore.getTeachers().add(teacher);
        adminView.displayMessage("教师添加成功！");
    }

    private void deleteTeacher(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要删除的教师编号: ");
        String id = scanner.nextLine();
        Teacher teacher = dataStore.getTeachers().stream().filter(t -> t.getId().equals(id)).findFirst().orElse(null);
        if(teacher != null) {
            // 解绑教学班
            List<TeachingClass> classesToRemove = new ArrayList<>(teacher.getTeachingClasses());
            for(TeachingClass tc : classesToRemove) {
                tc.setTeacher(null); // 可根据需求重新分配教师
                teacher.removeTeachingClass(tc);
            }
            dataStore.getTeachers().remove(teacher);
            adminView.displayMessage("教师删除成功！");
        } else {
            adminView.displayMessage("教师不存在！");
        }
    }

    private void updateTeacher(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要修改的教师编号: ");
        String id = scanner.nextLine();
        Teacher teacher = dataStore.getTeachers().stream().filter(t -> t.getId().equals(id)).findFirst().orElse(null);
        if(teacher != null) {
            System.out.print("请输入新的姓名: ");
            String name = scanner.nextLine();
            teacher.setName(name);
            adminView.displayMessage("教师信息更新成功！");
        } else {
            adminView.displayMessage("教师不存在！");
        }
    }

    private void listTeachers(AdminView adminView) {
        List<Teacher> teachers = dataStore.getTeachers();
        if(teachers.isEmpty()) {
            adminView.displayMessage("教师列表为空！");
            return;
        }
        String[] headers = {"教师编号", "教师姓名"};
        List<String[]> rows = new ArrayList<>();
        for(Teacher t : teachers) {
            rows.add(new String[]{t.getId(), t.getName()});
        }
        adminView.displayTable(headers, rows);
    }

    // 管理学生
    public void manageStudents(Scanner scanner, AdminView adminView) {
        while(true) {
            System.out.println("===== 管理学生 =====");
            System.out.println("1. 添加学生");
            System.out.println("2. 删除学生");
            System.out.println("3. 修改学生");
            System.out.println("4. 查询学生");
            System.out.println("0. 返回上级菜单");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    addStudent(scanner, adminView);
                    break;
                case "2":
                    deleteStudent(scanner, adminView);
                    break;
                case "3":
                    updateStudent(scanner, adminView);
                    break;
                case "4":
                    listStudents(scanner, adminView);
                    break;
                case "0":
                    return;
                default:
                    adminView.displayMessage("无效选择！");
            }
        }
    }

    private void addStudent(Scanner scanner, AdminView adminView) {
        System.out.print("请输入学生编号: ");
        String id = scanner.nextLine();
        if(dataStore.getStudents().stream().anyMatch(s -> s.getId().equals(id))) {
            adminView.displayMessage("学生编号已存在！");
            return;
        }
        System.out.print("请输入学生姓名: ");
        String name = scanner.nextLine();
        System.out.print("请输入性别: ");
        String gender = scanner.nextLine();
        Student student = new Student(id, name, gender);
        dataStore.getStudents().add(student);
        adminView.displayMessage("学生添加成功！");
    }

    private void deleteStudent(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要删除的学生编号: ");
        String id = scanner.nextLine();
        Student student = dataStore.getStudents().stream().filter(s -> s.getId().equals(id)).findFirst().orElse(null);
        if(student != null) {
            // 从教学班中移除学生
            for(Map.Entry<Course, TeachingClass> entry : student.getSelectedClasses().entrySet()) {
                TeachingClass tc = entry.getValue();
                tc.removeStudent(student);
            }
            dataStore.getStudents().remove(student);
            adminView.displayMessage("学生删除成功！");
        } else {
            adminView.displayMessage("学生不存在！");
        }
    }

    private void updateStudent(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要修改的学生编号: ");
        String id = scanner.nextLine();
        Student student = dataStore.getStudents().stream().filter(s -> s.getId().equals(id)).findFirst().orElse(null);
        if(student != null) {
            System.out.print("请输入新的姓名: ");
            String name = scanner.nextLine();
            System.out.print("请输入新的性别: ");
            String gender = scanner.nextLine();
            student.setName(name);
            student.setGender(gender);
            adminView.displayMessage("学生信息更新成功！");
        } else {
            adminView.displayMessage("学生不存在！");
        }
    }

    private void listStudents(Scanner scanner, AdminView adminView) {
        System.out.println("===== 学生列表 =====");
        System.out.println("请选择排序方式:");
        System.out.println("1. 按学号排序");
        System.out.println("2. 按总成绩排序");
        System.out.println("3.按照某门课程的成绩排序");
        System.out.print("请选择: ");
        String sortChoice = scanner.nextLine();
        List<Student> sortedStudents = new ArrayList<>(dataStore.getStudents());
        switch(sortChoice) {
            case "1":
                sortedStudents.sort(Comparator.comparing(Student::getId));
                break;
            case "2":
                sortedStudents.sort((s1, s2) -> {
                    int total1 = s1.getGrades().values().stream().mapToInt(Grade::getTotalScore).sum();
                    int total2 = s2.getGrades().values().stream().mapToInt(Grade::getTotalScore).sum();
                    return Integer.compare(total2, total1); // 降序
                });
                break;
            case "3":
                // 选择课程
                System.out.print("请输入课程编号: ");
                String courseId = scanner.nextLine();
                Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
                if(course == null) {
                    adminView.displayMessage("课程不存在！");
                    return;
                }
                sortedStudents.sort((s1, s2) -> {
                    Grade g1 = s1.getGrades().get(course);
                    Grade g2 = s2.getGrades().get(course);
                    int score1 = (g1 != null) ? g1.getTotalScore() : 0;
                    int score2 = (g2 != null) ? g2.getTotalScore() : 0;
                    return Integer.compare(score2, score1); // 降序
                });
                break;
            default:
                adminView.displayMessage("无效选择！");
                return;
        }
        String[] headers = {"学生编号", "姓名", "性别"};
        // 遍历所有课程，生成表头
        for(Course c : dataStore.getCourses()) {
            headers = Arrays.copyOf(headers, headers.length + 1);
            headers[headers.length - 1] = c.getCourseName();
        }
        headers = Arrays.copyOf(headers, headers.length + 1);
        headers[headers.length - 1] = "总成绩";

        List<String[]> rows = new ArrayList<>();
        for(Student s : sortedStudents) {
            int total = s.getGrades().values().stream().mapToInt(Grade::getTotalScore).sum();
            String[] row = new String[headers.length];
            row[0] = s.getId();
            row[1] = s.getName();
            row[2] = s.getGender();
            // 遍历所有课程，生成行数据
            int i = 3;
            for(Course c : dataStore.getCourses()) {
                Grade grade = s.getGrades().get(c);
                row[i++] = (grade != null) ? String.valueOf(grade.getTotalScore()) : "未录入";
            }
            row[i] = String.valueOf(total);
            rows.add(row);
        }
        adminView.displayTable(headers, rows);
    }

    // 管理课程
    public void manageCourses(Scanner scanner, AdminView adminView) {
        while(true) {
            System.out.println("===== 管理课程 =====");
            System.out.println("1. 添加课程");
            System.out.println("2. 删除课程");
            System.out.println("3. 修改课程");
            System.out.println("4. 查询课程");
            System.out.println("0. 返回上级菜单");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    addCourse(scanner, adminView);
                    break;
                case "2":
                    deleteCourse(scanner, adminView);
                    break;
                case "3":
                    updateCourse(scanner, adminView);
                    break;
                case "4":
                    listCourses(adminView);
                    break;
                case "0":
                    return;
                default:
                    adminView.displayMessage("无效选择！");
            }
        }
    }

    private void addCourse(Scanner scanner, AdminView adminView) {
        System.out.print("请输入课程编号: ");
        String id = scanner.nextLine();
        if(dataStore.getCourses().stream().anyMatch(c -> c.getCourseId().equals(id))) {
            adminView.displayMessage("课程编号已存在！");
            return;
        }
        System.out.print("请输入课程名称: ");
        String name = scanner.nextLine();
        Course course = new Course(id, name);
        dataStore.getCourses().add(course);
        adminView.displayMessage("课程添加成功！");
    }

    private void deleteCourse(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要删除的课程编号: ");
        String id = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(id)).findFirst().orElse(null);
        if(course != null) {
            // 从教学班中移除课程
            List<TeachingClass> classesToRemove = dataStore.getTeachingClasses().stream()
                    .filter(tc -> tc.getCourse().equals(course))
                    .collect(Collectors.toList());
            for(TeachingClass tc : classesToRemove) {
                tc.setCourse(null);
                tc.setTeacher(null); // 可根据需求重新分配教师
                dataStore.getTeachingClasses().remove(tc);
            }
            // 从学生成绩中移除课程
            for(Student student : dataStore.getStudents()) {
                student.getGrades().remove(course);
                student.getSelectedClasses().remove(course);
            }
            dataStore.getCourses().remove(course);
            adminView.displayMessage("课程删除成功！");
        } else {
            adminView.displayMessage("课程不存在！");
        }
    }

    private void updateCourse(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要修改的课程编号: ");
        String id = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(id)).findFirst().orElse(null);
        if(course != null) {
            System.out.print("请输入新的课程名称: ");
            String name = scanner.nextLine();
            course.setCourseName(name);
            // 更新教学班中的课程名称
            for(TeachingClass tc : dataStore.getTeachingClasses()) {
                if(tc.getCourse() != null && tc.getCourse().getCourseId().equals(id)) {
                    tc.getCourse().setCourseName(name);
                }
            }
            adminView.displayMessage("课程信息更新成功！");
        } else {
            adminView.displayMessage("课程不存在！");
        }
    }

    private void listCourses(AdminView adminView) {
        List<Course> courses = dataStore.getCourses();
        if(courses.isEmpty()) {
            adminView.displayMessage("课程列表为空！");
            return;
        }
        String[] headers = {"课程编号", "课程名称"};
        List<String[]> rows = new ArrayList<>();
        for(Course c : courses) {
            rows.add(new String[]{c.getCourseId(), c.getCourseName()});
        }
        adminView.displayTable(headers, rows);
    }

    // 管理教学班
    public void manageTeachingClasses(Scanner scanner, AdminView adminView) {
        while(true) {
            System.out.println("===== 管理教学班 =====");
            System.out.println("1. 添加教学班");
            System.out.println("2. 删除教学班");
            System.out.println("3. 修改教学班");
            System.out.println("4. 查询教学班");
            System.out.println("0. 返回上级菜单");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    addTeachingClass(scanner, adminView);
                    break;
                case "2":
                    deleteTeachingClass(scanner, adminView);
                    break;
                case "3":
                    updateTeachingClass(scanner, adminView);
                    break;
                case "4":
                    listTeachingClasses(scanner, adminView);
                    break;
                case "0":
                    return;
                default:
                    adminView.displayMessage("无效选择！");
            }
        }
    }

    private void addTeachingClass(Scanner scanner, AdminView adminView) {
        System.out.print("请输入教学班编号: ");
        String id = scanner.nextLine();
        if(dataStore.getTeachingClasses().stream().anyMatch(tc -> tc.getClassId().equals(id))) {
            adminView.displayMessage("教学班编号已存在！");
            return;
        }
        System.out.print("请输入教师编号: ");
        String teacherId = scanner.nextLine();
        Teacher teacher = dataStore.getTeachers().stream().filter(t -> t.getId().equals(teacherId)).findFirst().orElse(null);
        if(teacher == null) {
            adminView.displayMessage("教师不存在！");
            return;
        }
        System.out.print("请输入课程编号: ");
        String courseId = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
        if(course == null) {
            adminView.displayMessage("课程不存在！");
            return;
        }
        System.out.print("请输入总人数: ");
        int total;
        try {
            total = Integer.parseInt(scanner.nextLine());
        } catch(NumberFormatException e) {
            adminView.displayMessage("请输入有效的数字！");
            return;
        }
        System.out.print("请输入开课学期: ");
        String semester = scanner.nextLine();
        TeachingClass tClass = new TeachingClass(id, teacher, course, total, semester);
        dataStore.getTeachingClasses().add(tClass);
        teacher.addTeachingClass(tClass);
        adminView.displayMessage("教学班添加成功！");
    }

    private void deleteTeachingClass(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要删除的教学班编号: ");
        String id = scanner.nextLine();
        TeachingClass tClass = dataStore.getTeachingClasses().stream().filter(tc -> tc.getClassId().equals(id)).findFirst().orElse(null);
        if(tClass != null) {
            // 从教师的教学班中移除
            if(tClass.getTeacher() != null) {
                tClass.getTeacher().removeTeachingClass(tClass);
            }
            // 从学生的选课中移除
            for(Student student : tClass.getStudents()) {
                student.withdrawCourse(tClass.getCourse());
            }
            dataStore.getTeachingClasses().remove(tClass);
            adminView.displayMessage("教学班删除成功！");
        } else {
            adminView.displayMessage("教学班不存在！");
        }
    }


    private void updateTeachingClass(Scanner scanner, AdminView adminView) {
        System.out.print("请输入要修改的教学班编号: ");
        String id = scanner.nextLine();
        TeachingClass tClass = dataStore.getTeachingClasses().stream().filter(tc -> tc.getClassId().equals(id)).findFirst().orElse(null);
        if(tClass != null) {
            System.out.print("请输入新的教师编号: ");
            String teacherId = scanner.nextLine();
            Teacher newTeacher = dataStore.getTeachers().stream().filter(t -> t.getId().equals(teacherId)).findFirst().orElse(null);
            if(newTeacher == null) {
                adminView.displayMessage("教师不存在！");
                return;
            }
            // 移除旧教师的教学班
            if(tClass.getTeacher() != null) {
                tClass.getTeacher().removeTeachingClass(tClass);
            }
            // 设置新教师
            tClass.setTeacher(newTeacher);
            newTeacher.addTeachingClass(tClass);

            System.out.print("请输入新的课程编号: ");
            String courseId = scanner.nextLine();
            Course newCourse = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
            if(newCourse == null) {
                adminView.displayMessage("课程不存在！");
                return;
            }
            tClass.setCourse(newCourse);

            System.out.print("请输入新的总人数: ");
            int total;
            try {
                total = Integer.parseInt(scanner.nextLine());
                tClass.setTotalStudents(total);
            } catch(NumberFormatException e) {
                adminView.displayMessage("请输入有效的数字！");
                return;
            }

            System.out.print("请输入新的开课学期: ");
            String semester = scanner.nextLine();
            tClass.setSemester(semester);

            adminView.displayMessage("教学班信息更新成功！");
        } else {
            adminView.displayMessage("教学班不存在！");
        }
    }

    private void listTeachingClasses(Scanner scanner, AdminView adminView) {
        System.out.println("===== 教学班列表 =====");
        System.out.println("请选择排序方式:");
        System.out.println("1. 按教学班编号排序");
        System.out.println("2. 按课程排序");
        System.out.println("3. 按教师排序");
        System.out.println("4. 按学期排序");
        System.out.print("请选择: ");
        String sortChoice = scanner.nextLine();
        List<TeachingClass> sortedClasses = new ArrayList<>(dataStore.getTeachingClasses());
        switch(sortChoice) {
            case "1":
                sortedClasses.sort(Comparator.comparing(TeachingClass::getClassId));
                break;
            case "2":
                sortedClasses.sort(Comparator.comparing(tc -> tc.getCourse().getCourseName()));
                break;
            case "3":
                sortedClasses.sort(Comparator.comparing(tc -> tc.getTeacher() != null ? tc.getTeacher().getName() : ""));
                break;
            case "4":
                sortedClasses.sort(Comparator.comparing(TeachingClass::getSemester));
                break;
            default:
                adminView.displayMessage("无效选择！");
                return;
        }
        String[] headers = {"教学班编号", "教师", "课程", "总人数", "学期", "当前人数"};
        List<String[]> rows = new ArrayList<>();
        for(TeachingClass tc : sortedClasses) {
            String teacherName = (tc.getTeacher() != null) ? tc.getTeacher().getName() : "无";
            String courseName = (tc.getCourse() != null) ? tc.getCourse().getCourseName() : "无";
            rows.add(new String[]{
                    tc.getClassId(),
                    teacherName,
                    courseName,
                    String.valueOf(tc.getTotalStudents()),
                    tc.getSemester(),
                    String.valueOf(tc.getStudents().size())
            });
        }
        adminView.displayTable(headers, rows);
    }

    // 修改学生成绩
    public void modifyStudentGrades(Scanner scanner, AdminView adminView) {
        System.out.print("请输入学生编号: ");
        String studentId = scanner.nextLine();
        Student student = dataStore.getStudents().stream().filter(s -> s.getId().equals(studentId)).findFirst().orElse(null);
        if(student == null) {
            adminView.displayMessage("学生不存在！");
            return;
        }
        System.out.print("请输入课程编号: ");
        String courseId = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
        if(course == null) {
            adminView.displayMessage("课程不存在！");
            return;
        }
        Grade grade = student.getGrades().get(course);
        if(grade == null) {
            adminView.displayMessage("该学生未选修此课程！");
            return;
        }
        try {
            System.out.print("请输入新的平时成绩: ");
            int usual = Integer.parseInt(scanner.nextLine());
            System.out.print("请输入新的期中成绩: ");
            int midterm = Integer.parseInt(scanner.nextLine());
            System.out.print("请输入新的实验成绩: ");
            int experiment = Integer.parseInt(scanner.nextLine());
            System.out.print("请输入新的期末成绩: ");
            int finalExam = Integer.parseInt(scanner.nextLine());

            grade.setUsualScore(usual);
            grade.setMidterm(midterm);
            grade.setExperiment(experiment);
            grade.setFinalExam(finalExam);

            adminView.displayMessage("成绩更新成功！");
        } catch(NumberFormatException e) {
            adminView.displayMessage("请输入有效的数字！");
        }
    }

    // 查询功能
    public void queryFunctions(Scanner scanner, AdminView adminView) {
        while(true) {
            System.out.println("===== 查询功能 =====");
            System.out.println("1. 查询所有课程列表");
            System.out.println("2. 查询所有课程的教学班列表");
            System.out.println("3. 查询某学生的各科和总分");
            System.out.println("4. 查询所有学生按照各科、总分或学号排序");
            System.out.println("5. 查询一门课程所有同学的得分");
            System.out.println("6. 查询一门课程的分数分布");
            System.out.println("7. 查询一个教学班的学生得分情况及分数分布");
            System.out.println("0. 返回上级菜单");
            System.out.print("请选择: ");
            String choice = scanner.nextLine();
            switch(choice) {
                case "1":
                    queryAllCourses(adminView);
                    break;
                case "2":
                    queryTeachingClassesOfCourse(scanner, adminView);
                    break;
                case "3":
                    queryStudentGrades(scanner, adminView);
                    break;
                case "4":
                    queryAllStudentsSorted(scanner, adminView);
                    break;
                case "5":
                    queryCourseGrades(adminView, scanner);
                    break;
                case "6":
                    queryCourseGradeDistribution(adminView, scanner);
                    break;
                case "7":
                    queryTeachingClassGradesAndDistribution(scanner, adminView);
                    break;
                case "0":
                    return;
                default:
                    adminView.displayMessage("无效选择！");
            }
        }
    }

    private void queryAllCourses(AdminView adminView) {
        List<Course> courses = dataStore.getCourses();
        if(courses.isEmpty()) {
            adminView.displayMessage("课程列表为空！");
            return;
        }
        String[] headers = {"课程编号", "课程名称"};
        List<String[]> rows = new ArrayList<>();
        for(Course c : courses) {
            rows.add(new String[]{c.getCourseId(), c.getCourseName()});
        }
        adminView.displayTable(headers, rows);
    }

    private void queryTeachingClassesOfCourse(Scanner scanner, AdminView adminView) {
        System.out.print("请输入课程编号: ");
        String courseId = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
        if(course == null) {
            adminView.displayMessage("课程不存在！");
            return;
        }
        List<TeachingClass> classes = dataStore.getTeachingClasses().stream()
                .filter(tc -> tc.getCourse().equals(course))
                .collect(Collectors.toList());
        if(classes.isEmpty()) {
            adminView.displayMessage("该课程暂无教学班！");
            return;
        }
        String[] headers = {"教学班编号", "教师", "学期", "总人数", "当前人数"};
        List<String[]> rows = new ArrayList<>();
        for(TeachingClass tc : classes) {
            String teacherName = (tc.getTeacher() != null) ? tc.getTeacher().getName() : "无";
            rows.add(new String[]{
                    tc.getClassId(),
                    teacherName,
                    tc.getSemester(),
                    String.valueOf(tc.getTotalStudents()),
                    String.valueOf(tc.getStudents().size())
            });
        }
        adminView.displayTable(headers, rows);
    }

    private void queryStudentGrades(Scanner scanner, AdminView adminView) {
        System.out.print("请输入学生编号: ");
        String studentId = scanner.nextLine();
        Student student = dataStore.getStudents().stream().filter(s -> s.getId().equals(studentId)).findFirst().orElse(null);
        if(student == null) {
            adminView.displayMessage("学生不存在！");
            return;
        }
        if(student.getGrades().isEmpty()) {
            adminView.displayMessage("该学生未选修任何课程！");
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
        adminView.displayTable(headers, rows);
        System.out.println("总成绩: " + total);
    }

    private void queryAllStudentsSorted(Scanner scanner, AdminView adminView) {
        System.out.println("===== 查询所有学生列表 =====");
        System.out.println("请选择排序方式:");
        System.out.println("1. 按学号排序");
        System.out.println("2. 按总成绩排序");
        System.out.println("3. 按某科成绩排序");
        System.out.print("请选择: ");
        String sortChoice = scanner.nextLine();
        List<Student> sortedStudents = new ArrayList<>(dataStore.getStudents());
        switch(sortChoice) {
            case "1":
                sortedStudents.sort(Comparator.comparing(Student::getId));
                break;
            case "2":
                sortedStudents.sort((s1, s2) -> {
                    int total1 = s1.getGrades().values().stream().mapToInt(Grade::getTotalScore).sum();
                    int total2 = s2.getGrades().values().stream().mapToInt(Grade::getTotalScore).sum();
                    return Integer.compare(total2, total1); // 降序
                });
                break;
            case "3":
                System.out.print("请输入课程编号: ");
                String courseId = scanner.nextLine();
                Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
                if(course == null) {
                    adminView.displayMessage("课程不存在！");
                    return;
                }
                sortedStudents.sort((s1, s2) -> {
                    Grade g1 = s1.getGrades().get(course);
                    Grade g2 = s2.getGrades().get(course);
                    int score1 = (g1 != null) ? g1.getTotalScore() : 0;
                    int score2 = (g2 != null) ? g2.getTotalScore() : 0;
                    return Integer.compare(score2, score1); // 降序
                });
                break;
            default:
                adminView.displayMessage("无效选择！");
                return;
        }

        String[] headers = {"学生编号", "姓名", "性别"};
        // 遍历所有课程，生成表头
        for(Course c : dataStore.getCourses()) {
            headers = Arrays.copyOf(headers, headers.length + 1);
            headers[headers.length - 1] = c.getCourseName();
        }
        headers = Arrays.copyOf(headers, headers.length + 1);
        headers[headers.length - 1] = "总成绩";

        List<String[]> rows = new ArrayList<>();
        for(Student s : sortedStudents) {
            int total = s.getGrades().values().stream().mapToInt(Grade::getTotalScore).sum();
            String[] row = new String[headers.length];
            row[0] = s.getId();
            row[1] = s.getName();
            row[2] = s.getGender();
            // 遍历所有课程，生成行数据
            int i = 3;
            for(Course c : dataStore.getCourses()) {
                Grade grade = s.getGrades().get(c);
                row[i++] = (grade != null) ? String.valueOf(grade.getTotalScore()) : "未录入";
            }
            row[i] = String.valueOf(total);
            rows.add(row);
        }
        adminView.displayTable(headers, rows);
    }

    private void queryCourseGrades(AdminView adminView, Scanner scanner) {
        System.out.print("请输入课程编号: ");
        String courseId = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
        if(course == null) {
            adminView.displayMessage("课程不存在！");
            return;
        }
        System.out.println("===== 课程 " + course.getCourseName() + " 的所有学生成绩 =====");
        String[] headers = {"学生编号", "姓名", "平时成绩", "期中成绩", "实验成绩", "期末成绩", "综合成绩"};
        List<String[]> rows = new ArrayList<>();
        for(TeachingClass tc : dataStore.getTeachingClasses()) {
            if(tc.getCourse().equals(course)) {
                for(Student s : tc.getStudents()) {
                    Grade grade = s.getGrades().get(course);
                    if(grade != null) {
                        rows.add(new String[]{
                                s.getId(),
                                s.getName(),
                                String.valueOf(grade.getUsualScore()),
                                String.valueOf(grade.getMidterm()),
                                String.valueOf(grade.getExperiment()),
                                String.valueOf(grade.getFinalExam()),
                                String.valueOf(grade.getTotalScore()),

                        });
                    }
                }
            }
        }
        if(rows.isEmpty()) {
            adminView.displayMessage("该课程暂无学生成绩！");
            return;
        }
        adminView.displayTable(headers, rows);
    }

    private void queryCourseGradeDistribution(AdminView adminView, Scanner scanner) {
        System.out.print("请输入课程编号: ");
        String courseId = scanner.nextLine();
        Course course = dataStore.getCourses().stream().filter(c -> c.getCourseId().equals(courseId)).findFirst().orElse(null);
        if(course == null) {
            adminView.displayMessage("课程不存在！");
            return;
        }
        System.out.println("===== 课程 " + course.getCourseName() + " 的分数分布 =====");
        Map<String, Long> distribution = dataStore.getTeachingClasses().stream()
                .filter(tc -> tc.getCourse().equals(course))
                .flatMap(tc -> tc.getStudents().stream())
                .map(s -> s.getGrades().get(course))
                .filter(Objects::nonNull)
                .map(Grade::getTotalScore)
                .map(score -> {
                    if(score >= 90) return "90-100";
                    else if(score >=80) return "80-89";
                    else if(score >=70) return "70-79";
                    else return "低于70";
                })
                .collect(Collectors.groupingBy(s -> s, Collectors.counting()));
        String[] headers = {"分数区间", "人数"};
        List<String[]> rows = new ArrayList<>();
        for(Map.Entry<String, Long> entry : distribution.entrySet()) {
            rows.add(new String[]{entry.getKey(), String.valueOf(entry.getValue())});
        }
        adminView.displayTable(headers, rows);
    }

    private void queryTeachingClassGradesAndDistribution(Scanner scanner, AdminView adminView) {
        System.out.print("请输入教学班编号: ");
        String classId = scanner.nextLine();
        TeachingClass tClass = dataStore.getTeachingClasses().stream().filter(tc -> tc.getClassId().equals(classId)).findFirst().orElse(null);
        if(tClass == null) {
            adminView.displayMessage("教学班不存在！");
            return;
        }
        System.out.println("===== 教学班 " + classId + " 的学生得分情况 =====");
        String[] headers = {"学生编号", "姓名", "性别", "平时成绩", "期中成绩", "实验成绩", "期末成绩", "综合成绩"};
        List<String[]> rows = new ArrayList<>();
        for(Student s : tClass.getStudents()) {
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
        adminView.displayTable(headers, rows);

        // 分数分布
        System.out.println("===== 分数分布 =====");
        Map<String, Long> distribution = tClass.getStudents().stream()
                .map(s -> s.getGrades().get(tClass.getCourse()))
                .filter(Objects::nonNull)
                .map(Grade::getTotalScore)
                .map(score -> {
                    if(score >= 90) return "90-100";
                    else if(score >=80) return "80-89";
                    else if(score >=70) return "70-79";
                    else return "低于70";
                })
                .collect(Collectors.groupingBy(s -> s, Collectors.counting()));
        String[] distHeaders = {"分数区间", "人数"};
        List<String[]> distRows = new ArrayList<>();
        for(Map.Entry<String, Long> entry : distribution.entrySet()) {
            distRows.add(new String[]{entry.getKey(), String.valueOf(entry.getValue())});
        }
        adminView.displayTable(distHeaders, distRows);
    }

    // 初始化测试数据
    public void initializeData(Scanner scanner, AdminView adminView) {
        dataStore.initializeData();
        adminView.displayMessage("测试数据初始化完成！");
    }
}
