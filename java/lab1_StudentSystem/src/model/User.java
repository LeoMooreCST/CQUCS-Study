package model;

public abstract class User {
    private String id;
    private String name;
    private String password;

    public User(String id, String name) {
        this.id = id;
        this.name = name;
        this.password = "123456"; // 初始化密码
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean checkPassword(String pwd) {
        return this.password.equals(pwd);
    }

    public void setPassword(String newPwd) {
        this.password = newPwd;
    }

    public abstract String getRole();
}
