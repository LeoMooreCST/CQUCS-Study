package model;

public class Admin extends User {
    public Admin(String id, String name) {
        super(id, name);
        // 没有其他属性
    }

    @Override
    public String getRole() {
        return "管理员";
    }
}
