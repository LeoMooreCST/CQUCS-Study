package model;

import java.util.HashMap;
import java.util.Map;

public class Student extends User {
    /**
     * 学生类
     * 学号为id
     * 姓名为name
     * 性别
     */
    private String gender;
    private Map<Course, Grade> grades;
    private Map<Course, TeachingClass> selectedClasses;

    public Student(String id, String name, String gender) {
        super(id, name);
        this.gender = gender;
        this.grades = new HashMap<>();
        this.selectedClasses = new HashMap<>();
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Map<Course, Grade> getGrades() {
        return grades;
    }

    public void setGrades(Map<Course, Grade> grades) {
        this.grades = grades;
    }

    public Map<Course, TeachingClass> getSelectedClasses() {
        return selectedClasses;
    }

    public void setSelectedClasses(Map<Course, TeachingClass> selectedClasses) {
        this.selectedClasses = selectedClasses;
    }

    public void selectCourse(Course course, TeachingClass teachingClass) {
        selectedClasses.put(course, teachingClass);
    }

    public void withdrawCourse(Course course) {
        selectedClasses.remove(course);
        grades.remove(course);
    }

    @Override
    public String getRole() {
        return "学生";
    }
}
