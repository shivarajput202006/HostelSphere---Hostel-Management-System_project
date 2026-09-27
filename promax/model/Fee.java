package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Fee implements Serializable {
    private static final long serialVersionUID = 1L;

    private int feeId;
    private int studentId;
    private BigDecimal hostelFee;   // Base room rent / accommodation fee
    private String foodType;         // Veg, Non-Veg, No Food
    private BigDecimal foodAmount;   // Configured food amount at generation time
    private BigDecimal otherCharges; // Utilities, maintenance, etc.
    private BigDecimal totalFee;     // hostelFee + foodAmount + otherCharges
    private BigDecimal paidAmount;
    private BigDecimal dueAmount;
    private String feePeriod;        // e.g. "Semester 1", "2025-2026 Term"
    private Date paymentDate;
    private String paymentMode;
    private String receiptNumber;
    private String paymentStatus;    // "PENDING", "PARTIALLY_PAID", "PAID"
    private String razorpayPaymentId;
    private String razorpayOrderId;
    private Timestamp createdAt;

    // Joined fields for display & receipt generation
    private String studentName;
    private String studentCourse;
    private String studentSemester;
    private String studentMobile;
    private String studentEmail;
    private String roomNumber;
    private String roomType;

    public Fee() {
        this.hostelFee = BigDecimal.ZERO;
        this.foodType = "No Food";
        this.foodAmount = BigDecimal.ZERO;
        this.otherCharges = BigDecimal.ZERO;
        this.totalFee = BigDecimal.ZERO;
        this.paidAmount = BigDecimal.ZERO;
        this.dueAmount = BigDecimal.ZERO;
        this.paymentStatus = "PENDING";
    }

    public int getFeeId() { return feeId; }
    public void setFeeId(int feeId) { this.feeId = feeId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public BigDecimal getHostelFee() { return (hostelFee != null) ? hostelFee : BigDecimal.ZERO; }
    public void setHostelFee(BigDecimal hostelFee) { 
        this.hostelFee = hostelFee; 
    }

    public String getFoodType() { return (foodType != null && !foodType.trim().isEmpty()) ? foodType : "No Food"; }
    public void setFoodType(String foodType) { this.foodType = foodType; }

    public BigDecimal getFoodAmount() { return (foodAmount != null) ? foodAmount : BigDecimal.ZERO; }
    public void setFoodAmount(BigDecimal foodAmount) { this.foodAmount = foodAmount; }

    public BigDecimal getOtherCharges() { return (otherCharges != null) ? otherCharges : BigDecimal.ZERO; }
    public void setOtherCharges(BigDecimal otherCharges) { this.otherCharges = otherCharges; }

    public BigDecimal getTotalFee() { return (totalFee != null) ? totalFee : BigDecimal.ZERO; }
    public void setTotalFee(BigDecimal totalFee) { 
        this.totalFee = totalFee; 
        calculateDue();
    }

    public BigDecimal getPaidAmount() { return (paidAmount != null) ? paidAmount : BigDecimal.ZERO; }
    public void setPaidAmount(BigDecimal paidAmount) { 
        this.paidAmount = paidAmount; 
        calculateDue();
    }

    public BigDecimal getDueAmount() { return (dueAmount != null) ? dueAmount : BigDecimal.ZERO; }
    public void setDueAmount(BigDecimal dueAmount) { this.dueAmount = dueAmount; }

    public void calculateDue() {
        BigDecimal total = (this.totalFee != null) ? this.totalFee : BigDecimal.ZERO;
        BigDecimal paid = (this.paidAmount != null) ? this.paidAmount : BigDecimal.ZERO;
        BigDecimal due = total.subtract(paid);
        if (due.compareTo(BigDecimal.ZERO) < 0) {
            due = BigDecimal.ZERO;
        }
        this.dueAmount = due;

        // Auto update payment status string if not manually set
        if (paid.compareTo(BigDecimal.ZERO) <= 0) {
            this.paymentStatus = "PENDING";
        } else if (paid.compareTo(total) >= 0) {
            this.paymentStatus = "PAID";
        } else {
            this.paymentStatus = "PARTIALLY_PAID";
        }
    }

    public String getFeePeriod() { return feePeriod; }
    public void setFeePeriod(String feePeriod) { this.feePeriod = feePeriod; }

    public Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Date paymentDate) { this.paymentDate = paymentDate; }

    public String getPaymentMode() { return paymentMode; }
    public void setPaymentMode(String paymentMode) { this.paymentMode = paymentMode; }

    public String getReceiptNumber() { return receiptNumber; }
    public void setReceiptNumber(String receiptNumber) { this.receiptNumber = receiptNumber; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getStatus() { 
        if ("PAID".equalsIgnoreCase(paymentStatus) || "Complete".equalsIgnoreCase(paymentStatus)) return "Complete";
        if ("PARTIALLY_PAID".equalsIgnoreCase(paymentStatus) || "Partially Paid".equalsIgnoreCase(paymentStatus)) return "Partially Paid";
        return "Pending";
    }
    public void setStatus(String status) { 
        this.paymentStatus = status; 
    }

    public String getRazorpayPaymentId() { return razorpayPaymentId; }
    public void setRazorpayPaymentId(String razorpayPaymentId) { this.razorpayPaymentId = razorpayPaymentId; }

    public String getRazorpayOrderId() { return razorpayOrderId; }
    public void setRazorpayOrderId(String razorpayOrderId) { this.razorpayOrderId = razorpayOrderId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentCourse() { return studentCourse; }
    public void setStudentCourse(String studentCourse) { this.studentCourse = studentCourse; }

    public String getStudentSemester() { return studentSemester; }
    public void setStudentSemester(String studentSemester) { this.studentSemester = studentSemester; }

    public String getStudentMobile() { return studentMobile; }
    public void setStudentMobile(String studentMobile) { this.studentMobile = studentMobile; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }
}
