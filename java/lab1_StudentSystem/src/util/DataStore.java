package util;

import model.*;

import java.util.*;

public class DataStore {
    private static DataStore instance = null;

    private List<Admin> admins;
    private List<Teacher> teachers;
    private List<Student> students;
    private List<Course> courses;
    private List<TeachingClass> teachingClasses;

    private DataStore() {
        admins = new ArrayList<>();
        teachers = new ArrayList<>();
        students = new ArrayList<>();
        courses = new ArrayList<>();
        teachingClasses = new ArrayList<>();
        // 创建管理员
        admins.add(new Admin("admin001", "超级管理员"));// 保证系统中至少有一个管理员
        
    }

    public static DataStore getInstance() {
        if(instance == null) {
            instance = new DataStore();
        }
        return instance;
    }

    public List<Admin> getAdmins() {
        return admins;
    }

    public void setAdmins(List<Admin> admins) {
        this.admins = admins;
    }

    public List<Teacher> getTeachers() {
        return teachers;
    }

    public void setTeachers(List<Teacher> teachers) {
        this.teachers = teachers;
    }

    public List<Student> getStudents() {
        return students;
    }

    public void setStudents(List<Student> students) {
        this.students = students;
    }

    public List<Course> getCourses() {
        return courses;
    }

    public void setCourses(List<Course> courses) {
        this.courses = courses;
    }

    public List<TeachingClass> getTeachingClasses() {
        return teachingClasses;
    }

    public void setTeachingClasses(List<TeachingClass> teachingClasses) {
        this.teachingClasses = teachingClasses;
    }

    // 初始化数据
    public void initializeData() {
        //开发测试使用
        admins.clear();
        teachers.clear();
        students.clear();
        courses.clear();
        teachingClasses.clear();

        // 创建管理员
        admins.add(new Admin("admin001", "超级管理员"));

        // 创建教师
        for(int i=1;i<=6;i++) {
            teachers.add(new Teacher("T" + String.format("%03d", i), "教师" + i));
        }

        // 创建课程
        courses.add(new Course("CS101", "C++程序设计"));
        courses.add(new Course("CS102", "Java程序设计"));
        courses.add(new Course("CS103", "数据结构"));

        // 创建教学班
        int classCounter = 1;
        for(Course course : courses) {
            for(int i=0;i<2;i++) { // 每门课至少两个教师
                Teacher teacher = teachers.get((classCounter -1) % teachers.size());
                TeachingClass tClass = new TeachingClass("CL" + String.format("%03d", classCounter),
                        teacher, course, 50, "2024秋季");
                teachingClasses.add(tClass);
                teacher.addTeachingClass(tClass);
                classCounter++;
            }
        }

        // 创建学生
        for(int i=1;i<=100;i++) {
            String gender = (i % 2 == 0) ? "男" : "女";
            students.add(new Student("S" + String.format("%03d", i), "学生" + i, gender));
        }

        // 模拟选课
        Random rand = new Random();
        for(Student student : students) {
            List<TeachingClass> shuffledClasses = new ArrayList<>(teachingClasses);
            Collections.shuffle(shuffledClasses, rand);
            int selected = 0;
            for(TeachingClass tClass : shuffledClasses) {
                if(selected >=3) break;
                if(tClass.getStudents().size() <tClass.getTotalStudents()) {
                    boolean added = tClass.addStudent(student);
                    if(added) {
                        student.selectCourse(tClass.getCourse(), tClass);
                        selected++;
                    }
                }
            }

        }

        // 模拟成绩
        for(Student student : students) {
            for(Map.Entry<Course, TeachingClass> entry : student.getSelectedClasses().entrySet()) {
                int usual = rand.nextInt(21) + 80; // 80-100
                int midterm = rand.nextInt(21) + 80; // 80-100
                int experiment = rand.nextInt(21) + 80; //80-100
                int finalExam = rand.nextInt(21) + 80; //80-100
                Grade grade = new Grade(usual, midterm, experiment, finalExam);
                student.getGrades().put(entry.getKey(), grade);
            }
        }
        // 检查一下是否每个学生都选了至少3门课
        for(Student student : students) {
            if(student.getSelectedClasses().size() < 3) {
                System.out.println("Error");
                System.out.println("学生" + student.getName() + "选课不足3门！");
                // 输出选了几门课
                System.out.println("选了" + student.getSelectedClasses().size() + "门课");
            }
        }
    }


}
