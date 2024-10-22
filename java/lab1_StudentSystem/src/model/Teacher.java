package model;

import java.util.ArrayList;
import java.util.List;

public class Teacher extends User {
    /**
     * 教师类
     * 工号为id
     * 姓名为name
     * 教授课程列表
     */
    private List<TeachingClass> teachingClasses;

    public Teacher(String id, String name) {
        super(id, name);
        this.teachingClasses = new ArrayList<>();
    }

    public List<TeachingClass> getTeachingClasses() {
        return teachingClasses;
    }

    public void setTeachingClasses(List<TeachingClass> teachingClasses) {
        this.teachingClasses = teachingClasses;
    }

    public void addTeachingClass(TeachingClass teachingClass) {
        if (teachingClass != null) {
            teachingClasses.add(teachingClass);
        }
    }

    public void removeTeachingClass(TeachingClass teachingClass) {
        teachingClasses.remove(teachingClass);
    }

    @Override
    public String getRole() {
        return "教师";
    }
}
