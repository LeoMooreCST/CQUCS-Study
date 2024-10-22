package model;

import java.util.ArrayList;
import java.util.List;

public class TeachingClass {
    /**
     * 教学班类
     * 教学班号为classId
     * 教师为teacher
     * 课程为course
     * 总人数为totalStudents
     * 学期为semester
     * 学生列表为students
     */
    private String classId;
    private Teacher teacher;
    private Course course;
    private int totalStudents;
    private String semester;
    private List<Student> students;

    public TeachingClass(String classId, Teacher teacher, Course course, int totalStudents, String semester) {
        this.classId = classId;
        this.teacher = teacher;
        this.course = course;
        this.totalStudents = totalStudents;
        this.semester = semester;
        this.students = new ArrayList<>();
    }

    public String getClassId() {
        return classId;
    }

    public void setClassId(String classId) {
        this.classId = classId;
    }

    public Teacher getTeacher() {
        return teacher;
    }

    public void setTeacher(Teacher teacher) {
        this.teacher = teacher;
    }

    public Course getCourse() {
        return course;
    }

    public void setCourse(Course course) {
        this.course = course;
    }

    public int getTotalStudents() {
        return totalStudents;
    }

    public void setTotalStudents(int totalStudents) {
        this.totalStudents = totalStudents;
    }

    public String getSemester() {
        return semester;
    }

    public void setSemester(String semester) {
        this.semester = semester;
    }

    public List<Student> getStudents() {
        return students;
    }

    // 添加学生到教学班
    public boolean addStudent(Student student) {
        // 检查是否已经进入了这个教学班
        for (Student s : students) {
            if (s.getId().equals(student.getId())) {
                return false;
            }
        }
        // 检查这个学生是否已经选了这门课
        // 遍历学生的选课列表getSelectedClasses，检查键值对中的key的id是否等于当前教学班的课程id
        for (Course c : student.getSelectedClasses().keySet()) {
            if (c.getCourseId().equals(course.getCourseId())) {
                return false;
            }
        }

        if (students.size() < totalStudents) {
            students.add(student);
            return true;
        }
        return false;
    }

    // 从教学班中移除学生
    public void removeStudent(Student student) {
        students.remove(student);
    }
}
