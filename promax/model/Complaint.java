package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Complaint implements Serializable {
    private static final long serialVersionUID = 1L;

    private int complaintId;
    private int studentId;
    private String category;
    private String subject;
    private String description;
    private Timestamp complaintDate;
    private String status;
    private String adminResponse;
    private Timestamp resolvedDate;

    // Joined fields
    private String studentName;
    private String studentCourse;
    private String studentMobile;
    private String roomNumber;

    public Complaint() {}

    public int getComplaintId() { return complaintId; }
    public void setComplaintId(int complaintId) { this.complaintId = complaintId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getComplaintDate() { return complaintDate; }
    public void setComplaintDate(Timestamp complaintDate) { this.complaintDate = complaintDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getAdminResponse() { return adminResponse; }
    public void setAdminResponse(String adminResponse) { this.adminResponse = adminResponse; }

    public Timestamp getResolvedDate() { return resolvedDate; }
    public void setResolvedDate(Timestamp resolvedDate) { this.resolvedDate = resolvedDate; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentCourse() { return studentCourse; }
    public void setStudentCourse(String studentCourse) { this.studentCourse = studentCourse; }

    public String getStudentMobile() { return studentMobile; }
    public void setStudentMobile(String studentMobile) { this.studentMobile = studentMobile; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
}
