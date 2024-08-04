package com.zqiang.caculate24project.pojo;

public class ImageIdentity {
    /**
     * resID: 每一张扑克在drawable中的资源ID
     * arrayId: 每一张扑克在动态资源数组中的位置索引(按显示位置0-51编号)
     */
    private Integer resID;
    private Integer arrayId;

    public ImageIdentity() {
    }

    public ImageIdentity(Integer resID, Integer arrayId) {
        this.resID = resID;
        this.arrayId = arrayId;
    }

    public Integer getResID() {
        return resID;
    }

    public void setResID(Integer resID) {
        this.resID = resID;
    }

    public Integer getArrayId() {
        return arrayId;
    }

    public void setArrayId(Integer arrayId) {
        this.arrayId = arrayId;
    }

    @Override
    public String toString() {
        return "ImageIdentity{" +
                "resID=" + resID +
                ", arrayId=" + arrayId +
                '}';
    }
}
