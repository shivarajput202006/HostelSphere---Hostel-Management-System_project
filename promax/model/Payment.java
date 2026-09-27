package model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * Payment - Entity model representing a transaction logged in the MongoDB 'payments' collection
 */
public class Payment implements Serializable {
    private static final long serialVersionUID = 1L;

    private String paymentId;
    private String razorpayOrderId;
    private String razorpayPaymentId;
    private int studentId;
    private String studentName;
    private BigDecimal amount;
    private String currency;
    private String paymentStatus; // e.g. "SUCCESS", "FAILED", "PENDING"
    private Date paymentDate;
    private String paymentMethod;
    private boolean signatureVerificationStatus;
    private String receiptNumber;
    private Date createdAt;

    public Payment() {
        this.currency = "INR";
        this.paymentDate = new Date();
        this.createdAt = new Date();
    }

    public String getPaymentId() { return paymentId; }
    public void setPaymentId(String paymentId) { this.paymentId = paymentId; }

    public String getRazorpayOrderId() { return razorpayOrderId; }
    public void setRazorpayOrderId(String razorpayOrderId) { this.razorpayOrderId = razorpayOrderId; }

    public String getRazorpayPaymentId() { return razorpayPaymentId; }
    public void setRazorpayPaymentId(String razorpayPaymentId) { this.razorpayPaymentId = razorpayPaymentId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Date paymentDate) { this.paymentDate = paymentDate; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public boolean isSignatureVerificationStatus() { return signatureVerificationStatus; }
    public void setSignatureVerificationStatus(boolean signatureVerificationStatus) { this.signatureVerificationStatus = signatureVerificationStatus; }

    public String getReceiptNumber() { return receiptNumber; }
    public void setReceiptNumber(String receiptNumber) { this.receiptNumber = receiptNumber; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
