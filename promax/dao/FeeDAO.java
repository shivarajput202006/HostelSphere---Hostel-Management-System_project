package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import com.mongodb.client.model.Updates;
import model.Fee;
import org.bson.Document;
import org.bson.conversions.Bson;
import util.MongoDBConnection;
import util.SequenceGenerator;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

/**
 * FeeDAO - MongoDB Repository for Student Fees, Generation, and Payment History
 */
public class FeeDAO {

    private MongoCollection<Document> getFeeCollection() {
        return MongoDBConnection.getCollection("fees");
    }

    private MongoCollection<Document> getStudentCollection() {
        return MongoDBConnection.getCollection("students");
    }

    private MongoCollection<Document> getAllocationCollection() {
        return MongoDBConnection.getCollection("room_allocations");
    }

    private MongoCollection<Document> getRoomCollection() {
        return MongoDBConnection.getCollection("rooms");
    }

    public Fee generateFee(int studentId, BigDecimal hostelFee, String foodType, BigDecimal foodAmount, 
                           BigDecimal otherCharges, BigDecimal paidAmount, String paymentMode, String feePeriod) {
        Fee fee = new Fee();
        fee.setStudentId(studentId);
        fee.setHostelFee(hostelFee);
        fee.setFoodType(foodType);
        fee.setFoodAmount(foodAmount);
        fee.setOtherCharges(otherCharges);
        fee.setPaidAmount(paidAmount != null ? paidAmount : BigDecimal.ZERO);
        fee.setPaymentMode(paymentMode != null ? paymentMode : "Cash");
        fee.setFeePeriod(feePeriod != null ? feePeriod : "Current Term");
        fee.setPaymentDate(new Date(System.currentTimeMillis()));
        boolean success = addFee(fee);
        return success ? fee : null;
    }

    /**
     * Generate & Record a new fee invoice for a student.
     * ONLY triggered by Admin via Fee Generation.
     * Computes: Total = Hostel Fee + Food Amount + Other Charges
     * Sets Initial Due = Total - Paid
     */
    public boolean addFee(Fee fee) {
        try {
            if (fee.getFeeId() <= 0) {
                fee.setFeeId(SequenceGenerator.getNextSequence("feeId"));
            }

            if (fee.getReceiptNumber() == null || fee.getReceiptNumber().trim().isEmpty()) {
                fee.setReceiptNumber(generateReceiptNumber());
            }

            BigDecimal hostelFee = (fee.getHostelFee() != null) ? fee.getHostelFee() : BigDecimal.ZERO;
            BigDecimal foodAmount = (fee.getFoodAmount() != null) ? fee.getFoodAmount() : BigDecimal.ZERO;
            BigDecimal otherCharges = (fee.getOtherCharges() != null) ? fee.getOtherCharges() : BigDecimal.ZERO;
            BigDecimal totalFee = hostelFee.add(foodAmount).add(otherCharges);
            fee.setTotalFee(totalFee);

            BigDecimal paidAmount = (fee.getPaidAmount() != null) ? fee.getPaidAmount() : BigDecimal.ZERO;
            if (paidAmount.compareTo(BigDecimal.ZERO) < 0) {
                paidAmount = BigDecimal.ZERO;
            }
            fee.setPaidAmount(paidAmount);

            BigDecimal dueAmount = totalFee.subtract(paidAmount);
            if (dueAmount.compareTo(BigDecimal.ZERO) < 0) {
                dueAmount = BigDecimal.ZERO;
            }
            fee.setDueAmount(dueAmount);

            String status;
            if (paidAmount.compareTo(BigDecimal.ZERO) <= 0) {
                status = "PENDING";
            } else if (paidAmount.compareTo(totalFee) >= 0) {
                status = "PAID";
            } else {
                status = "PARTIALLY_PAID";
            }
            fee.setPaymentStatus(status);

            String pDate = (fee.getPaymentDate() != null) 
                    ? fee.getPaymentDate().toString() 
                    : new Date(System.currentTimeMillis()).toString();

            Document doc = new Document("feeId", fee.getFeeId())
                    .append("studentId", fee.getStudentId())
                    .append("hostelFee", hostelFee.doubleValue())
                    .append("foodType", fee.getFoodType() != null ? fee.getFoodType() : "No Food")
                    .append("foodAmount", foodAmount.doubleValue())
                    .append("otherCharges", otherCharges.doubleValue())
                    .append("totalFee", totalFee.doubleValue())
                    .append("paidAmount", paidAmount.doubleValue())
                    .append("dueAmount", dueAmount.doubleValue())
                    .append("feePeriod", fee.getFeePeriod() != null ? fee.getFeePeriod() : "Current Term")
                    .append("paymentDate", pDate)
                    .append("paymentMode", fee.getPaymentMode() != null ? fee.getPaymentMode() : "Cash")
                    .append("receiptNumber", fee.getReceiptNumber())
                    .append("paymentStatus", status)
                    .append("razorpayPaymentId", fee.getRazorpayPaymentId())
                    .append("razorpayOrderId", fee.getRazorpayOrderId())
                    .append("createdAt", new java.util.Date());

            getFeeCollection().insertOne(doc);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Record an online Razorpay payment against an existing generated fee.
     * Returns the receipt number on success, or null if fee has not been generated or error occurs.
     */
    public synchronized String recordOnlinePayment(int studentId, BigDecimal amountPaid, String razorpayPaymentId, 
                                                   String razorpayOrderId, String paymentMode) {
        try {
            // 1. Check if an existing fee record exists for this student
            Document latestFee = getFeeCollection().find(Filters.eq("studentId", studentId))
                    .sort(Sorts.descending("feeId")).first();

            if (latestFee == null) {
                System.err.println("[FeeDAO] Cannot process payment: No fee record exists for studentId " + studentId);
                return null;
            }

            Double dbTotal = latestFee.getDouble("totalFee");
            BigDecimal totalFee = (dbTotal != null && dbTotal > 0) ? BigDecimal.valueOf(dbTotal) : BigDecimal.ZERO;
            if (totalFee.compareTo(BigDecimal.ZERO) <= 0) {
                System.err.println("[FeeDAO] Fee total is 0 or negative for studentId " + studentId);
                return null;
            }

            // Sum already paid across fee records for this student
            BigDecimal alreadyPaid = BigDecimal.ZERO;
            try (MongoCursor<Document> cursor = getFeeCollection().find(Filters.eq("studentId", studentId)).iterator()) {
                while (cursor.hasNext()) {
                    Double p = cursor.next().getDouble("paidAmount");
                    if (p != null) {
                        alreadyPaid = alreadyPaid.add(BigDecimal.valueOf(p));
                    }
                }
            }

            // Compute new totals
            BigDecimal newTotalPaid = alreadyPaid.add(amountPaid);
            if (newTotalPaid.compareTo(totalFee) > 0) {
                // Prevent overpayment
                amountPaid = totalFee.subtract(alreadyPaid);
                if (amountPaid.compareTo(BigDecimal.ZERO) < 0) amountPaid = BigDecimal.ZERO;
                newTotalPaid = totalFee;
            }

            BigDecimal newDue = totalFee.subtract(newTotalPaid);
            if (newDue.compareTo(BigDecimal.ZERO) < 0) {
                newDue = BigDecimal.ZERO;
            }

            String newStatus = (newTotalPaid.compareTo(totalFee) >= 0) ? "PAID" : "PARTIALLY_PAID";

            String receiptNumber = generateReceiptNumber();
            String todayStr = new Date(System.currentTimeMillis()).toString();
            int feeId = SequenceGenerator.getNextSequence("feeId");

            String foodType = latestFee.getString("foodType");
            Double foodAmount = latestFee.getDouble("foodAmount");
            Double hostelFee = latestFee.getDouble("hostelFee");
            Double otherCharges = latestFee.getDouble("otherCharges");
            String feePeriod = latestFee.getString("feePeriod");

            // Insert new payment transaction document
            Document doc = new Document("feeId", feeId)
                    .append("studentId", studentId)
                    .append("hostelFee", hostelFee != null ? hostelFee : 0.0)
                    .append("foodType", foodType != null ? foodType : "No Food")
                    .append("foodAmount", foodAmount != null ? foodAmount : 0.0)
                    .append("otherCharges", otherCharges != null ? otherCharges : 0.0)
                    .append("totalFee", totalFee.doubleValue())
                    .append("paidAmount", amountPaid.doubleValue())
                    .append("dueAmount", newDue.doubleValue())
                    .append("feePeriod", feePeriod != null ? feePeriod : "Current Term")
                    .append("paymentDate", todayStr)
                    .append("paymentMode", (paymentMode != null && !paymentMode.isEmpty()) ? paymentMode : "Razorpay Online (UPI/Card)")
                    .append("receiptNumber", receiptNumber)
                    .append("paymentStatus", newStatus)
                    .append("razorpayPaymentId", razorpayPaymentId)
                    .append("razorpayOrderId", razorpayOrderId)
                    .append("createdAt", new java.util.Date());

            getFeeCollection().insertOne(doc);

            // Also update all previous fee records for this student to reflect the updated due amount and status
            getFeeCollection().updateMany(
                    Filters.eq("studentId", studentId),
                    Updates.combine(
                            Updates.set("dueAmount", newDue.doubleValue()),
                            Updates.set("paymentStatus", newStatus)
                    )
            );

            return receiptNumber;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Backward-compatible overload
     */
    public String recordOnlinePayment(int studentId, BigDecimal amountPaid, String razorpayPaymentId, String paymentMode) {
        return recordOnlinePayment(studentId, amountPaid, razorpayPaymentId, null, paymentMode);
    }

    /**
     * Get all fee records
     */
    public List<Fee> getAllFees() {
        return fetchFees(null);
    }

    /**
     * Get fee records for a specific student
     */
    public List<Fee> getFeesByStudentId(int studentId) {
        return fetchFees(Filters.eq("studentId", studentId));
    }

    /**
     * Get the latest fee record for a student
     */
    public Fee getLatestFeeByStudentId(int studentId) {
        try {
            Document doc = getFeeCollection().find(Filters.eq("studentId", studentId))
                    .sort(Sorts.descending("feeId")).first();
            if (doc != null) {
                Fee f = mapFee(doc);
                populateFeeDetails(f);
                return f;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Check if a fee record exists for a student
     */
    public boolean hasFeeRecord(int studentId) {
        try {
            return getFeeCollection().countDocuments(Filters.eq("studentId", studentId)) > 0;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Get fee record by fee ID
     */
    public Fee getFeeById(int feeId) {
        List<Fee> list = fetchFees(Filters.eq("feeId", feeId));
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Get fee record by receipt number
     */
    public Fee getFeeByReceiptNumber(String receiptNumber) {
        if (receiptNumber == null || receiptNumber.trim().isEmpty()) return null;
        List<Fee> list = fetchFees(Filters.eq("receiptNumber", receiptNumber.trim()));
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Get fee records with pending due amount
     */
    public List<Fee> getPendingFees() {
        return fetchFees(Filters.gt("dueAmount", 0));
    }

    /**
     * Get recent fee payments for admin dashboard
     */
    public List<Fee> getRecentFees(int limit) {
        List<Fee> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getFeeCollection()
                    .find()
                    .sort(Sorts.descending("feeId"))
                    .limit(limit)
                    .iterator()) {
                while (cursor.hasNext()) {
                    Fee f = mapFee(cursor.next());
                    populateFeeDetails(f);
                    list.add(f);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Delete a fee record
     */
    public boolean deleteFee(int feeId) {
        try {
            getFeeCollection().deleteOne(Filters.eq("feeId", feeId));
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Generates a unique, standardized receipt number: REC-yyyyMMdd-XXXX
     */
    public synchronized String generateReceiptNumber() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String datePrefix = sdf.format(new java.util.Date());
        int randomSuffix = (int)(Math.random() * 9000) + 1000;
        return "REC-" + datePrefix + "-" + randomSuffix;
    }

    private List<Fee> fetchFees(Bson filter) {
        List<Fee> list = new ArrayList<>();
        try {
            MongoCursor<Document> cursor = (filter != null)
                    ? getFeeCollection().find(filter).sort(Sorts.descending("feeId")).iterator()
                    : getFeeCollection().find().sort(Sorts.descending("feeId")).iterator();

            try (cursor) {
                while (cursor.hasNext()) {
                    Fee f = mapFee(cursor.next());
                    populateFeeDetails(f);
                    list.add(f);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void populateFeeDetails(Fee f) {
        if (f == null || f.getStudentId() <= 0) return;
        try {
            Document stu = getStudentCollection().find(Filters.eq("studentId", f.getStudentId())).first();
            if (stu != null) {
                f.setStudentName(stu.getString("name"));
                f.setStudentCourse(stu.getString("course"));
                f.setStudentSemester(stu.getString("semester"));
                f.setStudentMobile(stu.getString("mobile"));
                f.setStudentEmail(stu.getString("email"));
            }

            Document alloc = getAllocationCollection().find(
                    Filters.and(Filters.eq("studentId", f.getStudentId()), Filters.eq("status", "Active"))
            ).first();

            if (alloc != null) {
                Integer roomId = alloc.getInteger("roomId");
                if (roomId != null) {
                    Document rm = getRoomCollection().find(Filters.eq("roomId", roomId)).first();
                    if (rm != null) {
                        f.setRoomNumber(rm.getString("roomNumber"));
                        f.setRoomType(rm.getString("roomType"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Fee mapFee(Document doc) {
        Fee f = new Fee();
        f.setFeeId(doc.getInteger("feeId", 0));
        f.setStudentId(doc.getInteger("studentId", 0));

        Double hostelFee = doc.getDouble("hostelFee");
        f.setHostelFee(hostelFee != null ? BigDecimal.valueOf(hostelFee) : BigDecimal.ZERO);

        String foodType = doc.getString("foodType");
        f.setFoodType(foodType != null ? foodType : "No Food");

        Double foodAmt = doc.getDouble("foodAmount");
        f.setFoodAmount(foodAmt != null ? BigDecimal.valueOf(foodAmt) : BigDecimal.ZERO);

        Double other = doc.getDouble("otherCharges");
        f.setOtherCharges(other != null ? BigDecimal.valueOf(other) : BigDecimal.ZERO);

        Double total = doc.getDouble("totalFee");
        f.setTotalFee(total != null ? BigDecimal.valueOf(total) : BigDecimal.ZERO);

        Double paid = doc.getDouble("paidAmount");
        f.setPaidAmount(paid != null ? BigDecimal.valueOf(paid) : BigDecimal.ZERO);

        Double due = doc.getDouble("dueAmount");
        f.setDueAmount(due != null ? BigDecimal.valueOf(due) : BigDecimal.ZERO);

        f.setFeePeriod(doc.getString("feePeriod"));

        Object pDateObj = doc.get("paymentDate");
        if (pDateObj instanceof String && !((String) pDateObj).isEmpty()) {
            try { f.setPaymentDate(Date.valueOf((String) pDateObj)); } catch (Exception ignored) {}
        } else if (pDateObj instanceof java.util.Date) {
            f.setPaymentDate(new Date(((java.util.Date) pDateObj).getTime()));
        }

        f.setPaymentMode(doc.getString("paymentMode"));
        f.setReceiptNumber(doc.getString("receiptNumber"));
        f.setPaymentStatus(doc.getString("paymentStatus"));
        f.setRazorpayPaymentId(doc.getString("razorpayPaymentId"));
        f.setRazorpayOrderId(doc.getString("razorpayOrderId"));

        java.util.Date createdAt = doc.getDate("createdAt");
        if (createdAt != null) {
            f.setCreatedAt(new Timestamp(createdAt.getTime()));
        }
        return f;
    }
}
