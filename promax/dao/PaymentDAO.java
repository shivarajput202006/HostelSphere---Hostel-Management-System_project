package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import model.Payment;
import org.bson.Document;
import util.MongoDBConnection;
import util.SequenceGenerator;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * PaymentDAO - MongoDB Repository for Payment Transactions
 */
public class PaymentDAO {

    private MongoCollection<Document> getCollection() {
        return MongoDBConnection.getCollection("payments");
    }

    /**
     * Record a new payment transaction
     */
    public boolean savePayment(Payment payment) {
        try {
            if (payment.getPaymentId() == null || payment.getPaymentId().trim().isEmpty()) {
                payment.setPaymentId("PAY" + String.format("%04d", SequenceGenerator.getNextSequence("paymentId")));
            }
            if (payment.getPaymentDate() == null) {
                payment.setPaymentDate(new Date());
            }
            if (payment.getCreatedAt() == null) {
                payment.setCreatedAt(new Date());
            }

            Document doc = new Document("paymentId", payment.getPaymentId())
                    .append("razorpayOrderId", payment.getRazorpayOrderId())
                    .append("razorpayPaymentId", payment.getRazorpayPaymentId())
                    .append("studentId", payment.getStudentId())
                    .append("studentName", payment.getStudentName())
                    .append("amount", payment.getAmount() != null ? payment.getAmount().doubleValue() : 0.0)
                    .append("currency", payment.getCurrency() != null ? payment.getCurrency() : "INR")
                    .append("paymentStatus", payment.getPaymentStatus())
                    .append("paymentDate", payment.getPaymentDate())
                    .append("paymentMethod", payment.getPaymentMethod())
                    .append("signatureVerificationStatus", payment.isSignatureVerificationStatus())
                    .append("receiptNumber", payment.getReceiptNumber())
                    .append("createdAt", payment.getCreatedAt());

            getCollection().insertOne(doc);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if a razorpayPaymentId already exists (prevent duplicate processing)
     */
    public boolean isPaymentIdProcessed(String razorpayPaymentId) {
        if (razorpayPaymentId == null || razorpayPaymentId.trim().isEmpty()) return false;
        try {
            long count = getCollection().countDocuments(Filters.eq("razorpayPaymentId", razorpayPaymentId.trim()));
            return count > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get payment history for a specific student
     */
    public List<Payment> getPaymentsByStudent(int studentId) {
        List<Payment> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getCollection()
                    .find(Filters.eq("studentId", studentId))
                    .sort(Sorts.descending("createdAt"))
                    .iterator()) {
                while (cursor.hasNext()) {
                    list.add(mapDocumentToPayment(cursor.next()));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get all payment logs (for Admin)
     */
    public List<Payment> getAllPayments() {
        List<Payment> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getCollection()
                    .find()
                    .sort(Sorts.descending("createdAt"))
                    .iterator()) {
                while (cursor.hasNext()) {
                    list.add(mapDocumentToPayment(cursor.next()));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get payment by transaction/payment ID
     */
    public Payment getPaymentById(String paymentId) {
        try {
            Document doc = getCollection().find(Filters.eq("paymentId", paymentId)).first();
            if (doc != null) {
                return mapDocumentToPayment(doc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private Payment mapDocumentToPayment(Document doc) {
        Payment p = new Payment();
        p.setPaymentId(doc.getString("paymentId"));
        p.setRazorpayOrderId(doc.getString("razorpayOrderId"));
        p.setRazorpayPaymentId(doc.getString("razorpayPaymentId"));
        p.setStudentId(doc.getInteger("studentId", 0));
        p.setStudentName(doc.getString("studentName"));
        
        Double amt = doc.getDouble("amount");
        p.setAmount(amt != null ? BigDecimal.valueOf(amt) : BigDecimal.ZERO);
        
        p.setCurrency(doc.getString("currency"));
        p.setPaymentStatus(doc.getString("paymentStatus"));
        p.setPaymentDate(doc.getDate("paymentDate"));
        p.setPaymentMethod(doc.getString("paymentMethod"));
        p.setSignatureVerificationStatus(Boolean.TRUE.equals(doc.getBoolean("signatureVerificationStatus")));
        p.setReceiptNumber(doc.getString("receiptNumber"));
        p.setCreatedAt(doc.getDate("createdAt"));
        return p;
    }
}
