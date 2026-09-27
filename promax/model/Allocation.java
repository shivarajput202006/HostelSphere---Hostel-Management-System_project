package model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

public class Allocation implements Serializable {
    private static final long serialVersionUID = 1L;

    private int allocationId;
    private int studentId;
    private int roomId;
    private Date allocationDate;
    private Date vacateDate;
    private String status;
    private Timestamp createdAt;

    // Joined fields for display
    private String studentName;
    private String studentCourse;
    private String studentMobile;
    private String roomNumber;
    private int roomFloor;
    private String roomType;

    public Allocation() {}

    public int getAllocationId() { return allocationId; }
    public void setAllocationId(int allocationId) { this.allocationId = allocationId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }

    public Date getAllocationDate() { return allocationDate; }
    public void setAllocationDate(Date allocationDate) { this.allocationDate = allocationDate; }

    public Date getVacateDate() { return vacateDate; }
    public void setVacateDate(Date vacateDate) { this.vacateDate = vacateDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentCourse() { return studentCourse; }
    public void setStudentCourse(String studentCourse) { this.studentCourse = studentCourse; }

    public String getStudentMobile() { return studentMobile; }
    public void setStudentMobile(String studentMobile) { this.studentMobile = studentMobile; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public int getRoomFloor() { return roomFloor; }
    public void setRoomFloor(int roomFloor) { this.roomFloor = roomFloor; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }
}
