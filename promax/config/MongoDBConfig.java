package config;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.IndexOptions;
import com.mongodb.client.model.Indexes;
import org.bson.Document;
import util.PasswordUtil;

import java.io.InputStream;
import java.util.Arrays;
import java.util.Date;
import java.util.Properties;

/**
 * MongoDBConfig - Configuration & Database Initialization for Hostel Management System
 * Supports:
 * 1. Environment Variable: MONGODB_URI, MONGODB_DATABASE
 * 2. System Properties: mongodb.uri, mongodb.database
 * 3. Configuration file: mongodb.properties
 * 4. Default Localhost: mongodb://localhost:27017 / hostel_db
 */
public class MongoDBConfig {

    private static final String DEFAULT_URI = "mongodb://localhost:27017";
    private static final String DEFAULT_DATABASE = "hostel_db";
    private static Properties fileProps = new Properties();

    static {
        try (InputStream is = MongoDBConfig.class.getClassLoader().getResourceAsStream("mongodb.properties")) {
            if (is != null) {
                fileProps.load(is);
            }
        } catch (Exception ignored) {}
    }

    public static String getConnectionString() {
        String uri = System.getenv("MONGODB_URI");
        if (uri == null || uri.trim().isEmpty()) {
            uri = System.getProperty("mongodb.uri");
        }
        if (uri == null || uri.trim().isEmpty()) {
            uri = fileProps.getProperty("mongodb.uri");
        }
        if (uri == null || uri.trim().isEmpty()) {
            uri = DEFAULT_URI;
        }
        return uri.trim();
    }

    public static String getDatabaseName() {
        String dbName = System.getenv("MONGODB_DATABASE");
        if (dbName == null || dbName.trim().isEmpty()) {
            dbName = System.getProperty("mongodb.database");
        }
        if (dbName == null || dbName.trim().isEmpty()) {
            dbName = fileProps.getProperty("mongodb.database");
        }
        if (dbName == null || dbName.trim().isEmpty()) {
            dbName = DEFAULT_DATABASE;
        }
        return dbName.trim();
    }

    /**
     * Initializes indexes and seeds demo data if collections are empty.
     */
    public static void initializeDatabase(MongoDatabase db) {
        try {
            // Create indexes for performance and uniqueness
            MongoCollection<Document> admins = db.getCollection("admins");
            admins.createIndex(Indexes.ascending("username"), new IndexOptions().unique(true));

            MongoCollection<Document> students = db.getCollection("students");
            students.createIndex(Indexes.ascending("username"), new IndexOptions().unique(true));
            students.createIndex(Indexes.ascending("studentId"), new IndexOptions().unique(true));

            MongoCollection<Document> rooms = db.getCollection("rooms");
            rooms.createIndex(Indexes.ascending("roomNumber"), new IndexOptions().unique(true));
            rooms.createIndex(Indexes.ascending("roomId"), new IndexOptions().unique(true));

            MongoCollection<Document> allocations = db.getCollection("room_allocations");
            allocations.createIndex(Indexes.ascending("allocationId"), new IndexOptions().unique(true));
            allocations.createIndex(Indexes.ascending("studentId"));

            MongoCollection<Document> fees = db.getCollection("fees");
            fees.createIndex(Indexes.ascending("feeId"), new IndexOptions().unique(true));
            fees.createIndex(Indexes.ascending("receiptNumber"), new IndexOptions().unique(true));
            fees.createIndex(Indexes.ascending("studentId"));

            MongoCollection<Document> payments = db.getCollection("payments");
            payments.createIndex(Indexes.ascending("paymentId"), new IndexOptions().unique(true));
            payments.createIndex(Indexes.ascending("razorpayPaymentId"), new IndexOptions().unique(true).sparse(true));

            MongoCollection<Document> complaints = db.getCollection("complaints");
            complaints.createIndex(Indexes.ascending("complaintId"), new IndexOptions().unique(true));
            complaints.createIndex(Indexes.ascending("studentId"));

            // Seed initial admin if missing
            if (admins.countDocuments() == 0) {
                seedInitialData(db);
            }
        } catch (Exception e) {
            System.err.println("[MongoDBConfig] Note during database index/seed initialization: " + e.getMessage());
        }
    }

    private static void seedInitialData(MongoDatabase db) {
        System.out.println("[MongoDBConfig] Seeding initial demo data into MongoDB...");

        // 1. Admins
        MongoCollection<Document> admins = db.getCollection("admins");
        admins.insertMany(Arrays.asList(
            new Document("adminId", 1)
                .append("name", "System Administrator")
                .append("username", "admin")
                .append("password", PasswordUtil.hashPassword("admin123"))
                .append("createdAt", new Date()),
            new Document("adminId", 2)
                .append("name", "Chief Warden Sharma")
                .append("username", "warden")
                .append("password", PasswordUtil.hashPassword("admin123"))
                .append("createdAt", new Date())
        ));

        // 2. Rooms
        MongoCollection<Document> rooms = db.getCollection("rooms");
        rooms.insertMany(Arrays.asList(
            new Document("roomId", 1).append("roomNumber", "101").append("floor", 1).append("roomType", "Single Sharing").append("totalBeds", 1).append("occupiedBeds", 1).append("availableBeds", 0).append("status", "Occupied").append("createdAt", new Date()),
            new Document("roomId", 2).append("roomNumber", "102").append("floor", 1).append("roomType", "Double Sharing").append("totalBeds", 2).append("occupiedBeds", 2).append("availableBeds", 0).append("status", "Occupied").append("createdAt", new Date()),
            new Document("roomId", 3).append("roomNumber", "103").append("floor", 1).append("roomType", "Double Sharing").append("totalBeds", 2).append("occupiedBeds", 1).append("availableBeds", 1).append("status", "Available").append("createdAt", new Date()),
            new Document("roomId", 4).append("roomNumber", "104").append("floor", 1).append("roomType", "Triple Sharing").append("totalBeds", 3).append("occupiedBeds", 1).append("availableBeds", 2).append("status", "Available").append("createdAt", new Date()),
            new Document("roomId", 5).append("roomNumber", "201").append("floor", 2).append("roomType", "Single Sharing").append("totalBeds", 1).append("occupiedBeds", 0).append("availableBeds", 1).append("status", "Available").append("createdAt", new Date()),
            new Document("roomId", 6).append("roomNumber", "202").append("floor", 2).append("roomType", "Double Sharing").append("totalBeds", 2).append("occupiedBeds", 1).append("availableBeds", 1).append("status", "Available").append("createdAt", new Date()),
            new Document("roomId", 7).append("roomNumber", "203").append("floor", 2).append("roomType", "Triple Sharing").append("totalBeds", 3).append("occupiedBeds", 0).append("availableBeds", 3).append("status", "Available").append("createdAt", new Date()),
            new Document("roomId", 8).append("roomNumber", "301").append("floor", 3).append("roomType", "Double Sharing").append("totalBeds", 2).append("occupiedBeds", 0).append("availableBeds", 2).append("status", "Available").append("createdAt", new Date())
        ));

        // 3. Students
        MongoCollection<Document> students = db.getCollection("students");
        students.insertMany(Arrays.asList(
            new Document("studentId", 1).append("name", "Aarav Sharma").append("fatherName", "Ramesh Sharma").append("motherName", "Sunita Sharma").append("dob", "2003-05-14").append("gender", "Male").append("mobile", "9876543210").append("email", "aarav.sharma@example.com").append("address", "Flat 402, Green Valley Apartments, New Delhi").append("course", "BCA").append("semester", "Semester 4").append("admissionDate", "2025-07-15").append("username", "student1").append("password", PasswordUtil.hashPassword("pass123")).append("photo", "default_avatar.svg").append("createdAt", new Date()),
            new Document("studentId", 2).append("name", "Priya Patel").append("fatherName", "Dinesh Patel").append("motherName", "Meena Patel").append("dob", "2002-11-20").append("gender", "Female").append("mobile", "9876543211").append("email", "priya.patel@example.com").append("address", "12-B, Sunrise Colony, Ahmedabad, Gujarat").append("course", "MCA").append("semester", "Semester 2").append("admissionDate", "2025-08-01").append("username", "student2").append("password", PasswordUtil.hashPassword("pass123")).append("photo", "default_avatar.svg").append("createdAt", new Date()),
            new Document("studentId", 3).append("name", "Rohan Verma").append("fatherName", "Sanjay Verma").append("motherName", "Kavita Verma").append("dob", "2004-01-10").append("gender", "Male").append("mobile", "9876543212").append("email", "rohan.verma@example.com").append("address", "78 Civil Lines, Jaipur, Rajasthan").append("course", "BCA").append("semester", "Semester 2").append("admissionDate", "2025-07-20").append("username", "student3").append("password", PasswordUtil.hashPassword("pass123")).append("photo", "default_avatar.svg").append("createdAt", new Date()),
            new Document("studentId", 4).append("name", "Sneha Reddy").append("fatherName", "Venkatesh Reddy").append("motherName", "Lakshmi Reddy").append("dob", "2003-09-08").append("gender", "Female").append("mobile", "9876543213").append("email", "sneha.reddy@example.com").append("address", "H.No 4-55, Jubilee Hills, Hyderabad").append("course", "MCA").append("semester", "Semester 4").append("admissionDate", "2025-07-18").append("username", "student4").append("password", PasswordUtil.hashPassword("pass123")).append("photo", "default_avatar.svg").append("createdAt", new Date()),
            new Document("studentId", 5).append("name", "Vikram Singh").append("fatherName", "Ranbir Singh").append("motherName", "Geeta Singh").append("dob", "2002-03-25").append("gender", "Male").append("mobile", "9876543214").append("email", "vikram.singh@example.com").append("address", "Block C, Sector 15, Chandigarh").append("course", "BCA").append("semester", "Semester 6").append("admissionDate", "2024-07-12").append("username", "student5").append("password", PasswordUtil.hashPassword("pass123")).append("photo", "default_avatar.svg").append("createdAt", new Date()),
            new Document("studentId", 6).append("name", "Ananya Iyer").append("fatherName", "Subramanian Iyer").append("motherName", "Radha Iyer").append("dob", "2003-12-14").append("gender", "Female").append("mobile", "9876543215").append("email", "ananya.iyer@example.com").append("address", "24 Gandhi Road, Chennai, Tamil Nadu").append("course", "MCA").append("semester", "Semester 2").append("admissionDate", "2025-08-10").append("username", "student6").append("password", PasswordUtil.hashPassword("pass123")).append("photo", "default_avatar.svg").append("createdAt", new Date())
        ));

        // 4. Room Allocations
        MongoCollection<Document> allocations = db.getCollection("room_allocations");
        allocations.insertMany(Arrays.asList(
            new Document("allocationId", 1).append("studentId", 1).append("roomId", 1).append("allocationDate", "2025-07-16").append("vacateDate", null).append("status", "Active").append("createdAt", new Date()),
            new Document("allocationId", 2).append("studentId", 2).append("roomId", 2).append("allocationDate", "2025-08-02").append("vacateDate", null).append("status", "Active").append("createdAt", new Date()),
            new Document("allocationId", 3).append("studentId", 3).append("roomId", 2).append("allocationDate", "2025-08-02").append("vacateDate", null).append("status", "Active").append("createdAt", new Date()),
            new Document("allocationId", 4).append("studentId", 4).append("roomId", 3).append("allocationDate", "2025-07-19").append("vacateDate", null).append("status", "Active").append("createdAt", new Date()),
            new Document("allocationId", 5).append("studentId", 5).append("roomId", 4).append("allocationDate", "2024-07-15").append("vacateDate", null).append("status", "Active").append("createdAt", new Date())
        ));

        // 5. Fees
        MongoCollection<Document> fees = db.getCollection("fees");
        fees.insertMany(Arrays.asList(
            new Document("feeId", 1).append("studentId", 1).append("totalFee", 45000.00).append("paidAmount", 45000.00).append("dueAmount", 0.00).append("paymentDate", "2025-07-16").append("paymentMode", "UPI").append("receiptNumber", "REC-2025-001").append("paymentStatus", "PAID").append("razorpayPaymentId", "pay_demo_001").append("createdAt", new Date()),
            new Document("feeId", 2).append("studentId", 2).append("totalFee", 40000.00).append("paidAmount", 25000.00).append("dueAmount", 15000.00).append("paymentDate", "2025-08-02").append("paymentMode", "Bank Transfer").append("receiptNumber", "REC-2025-002").append("paymentStatus", "PAID").append("razorpayPaymentId", "pay_demo_002").append("createdAt", new Date()),
            new Document("feeId", 3).append("studentId", 3).append("totalFee", 40000.00).append("paidAmount", 40000.00).append("dueAmount", 0.00).append("paymentDate", "2025-08-03").append("paymentMode", "Cash").append("receiptNumber", "REC-2025-003").append("paymentStatus", "PAID").append("razorpayPaymentId", null).append("createdAt", new Date()),
            new Document("feeId", 4).append("studentId", 4).append("totalFee", 40000.00).append("paidAmount", 20000.00).append("dueAmount", 20000.00).append("paymentDate", "2025-07-20").append("paymentMode", "UPI").append("receiptNumber", "REC-2025-004").append("paymentStatus", "PAID").append("razorpayPaymentId", "pay_demo_004").append("createdAt", new Date()),
            new Document("feeId", 5).append("studentId", 5).append("totalFee", 35000.00).append("paidAmount", 35000.00).append("dueAmount", 0.00).append("paymentDate", "2025-07-15").append("paymentMode", "UPI").append("receiptNumber", "REC-2025-005").append("paymentStatus", "PAID").append("razorpayPaymentId", "pay_demo_005").append("createdAt", new Date())
        ));

        // 6. Complaints
        MongoCollection<Document> complaints = db.getCollection("complaints");
        complaints.insertMany(Arrays.asList(
            new Document("complaintId", 1).append("studentId", 1).append("category", "Electricity Problem").append("subject", "Ceiling fan making squeaking noise").append("description", "The ceiling fan in Room 101 rotates very slowly and makes a loud squeaking noise.").append("complaintDate", new Date()).append("status", "Resolved").append("adminResponse", "Electrician replaced the fan capacitor and lubricated the motor bearing. Working fine now.").append("resolvedDate", new Date()),
            new Document("complaintId", 2).append("studentId", 2).append("category", "Water Problem").append("subject", "Low water pressure in bathroom geyser").append("description", "Hot water flow in Room 102 attached bathroom is very low in morning hours.").append("complaintDate", new Date()).append("status", "In Progress").append("adminResponse", "Plumbing team has inspected pipeline and descaling is scheduled.").append("resolvedDate", null),
            new Document("complaintId", 3).append("studentId", 3).append("category", "Maintenance Problem").append("subject", "Study table drawer lock broken").append("description", "The study table drawer key is stuck inside the lock cylinder.").append("complaintDate", new Date()).append("status", "Pending").append("adminResponse", null).append("resolvedDate", null)
        ));

        // 7. Initialize Sequence Counters
        MongoCollection<Document> counters = db.getCollection("counters");
        counters.insertMany(Arrays.asList(
            new Document("_id", "studentId").append("seq", 6),
            new Document("_id", "roomId").append("seq", 8),
            new Document("_id", "allocationId").append("seq", 5),
            new Document("_id", "feeId").append("seq", 5),
            new Document("_id", "complaintId").append("seq", 3),
            new Document("_id", "paymentId").append("seq", 5)
        ));

        System.out.println("[MongoDBConfig] Seeding completed successfully.");
    }
}
