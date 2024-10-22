package model;

public class Course {
    /**
     * 课程编号
     * 课程名称
     */
    private String courseId;
    private String courseName;

    public Course(String id, String name) {
        this.courseId = id;
        this.courseName = name;
    }

    public String getCourseId() {
        return courseId;
    }

    public void setCourseId(String courseId) {
        this.courseId = courseId;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    @Override
    public String toString() {
        return courseId + " - " + courseName;
    }

    @Override
    public boolean equals(Object obj) {
        if(this == obj) return true;
        if(!(obj instanceof Course)) return false;
        Course other = (Course)obj;
        return this.courseId.equals(other.courseId);
    }

    @Override
    public int hashCode() {
        return courseId.hashCode();  // 课程编号相同的课程对象，hashCode相同
    }
}
