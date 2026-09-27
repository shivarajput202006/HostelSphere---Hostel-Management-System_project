package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import model.Admin;
import org.bson.Document;
import org.bson.conversions.Bson;
import util.MongoDBConnection;
import util.PasswordUtil;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AdminDAO - MongoDB Repository for Admin Authentication, Profile Management, and Dashboard Metrics
 */
public class AdminDAO {

    private MongoCollection<Document> getAdminCollection() {
        return MongoDBConnection.getCollection("admins");
    }

    /**
     * Authenticate admin credentials against MongoDB
     */
    public Admin authenticate(String username, String password) {
        if (username == null || password == null) return null;

        try {
            Document doc = getAdminCollection().find(Filters.eq("username", username.trim())).first();
            if (doc != null) {
                String storedPassword = doc.getString("password");
                if (PasswordUtil.checkPassword(password.trim(), storedPassword)) {
                    return mapDocumentToAdmin(doc);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get Admin by ID
     */
    public Admin getAdminById(int adminId) {
        try {
            Document doc = getAdminCollection().find(Filters.eq("adminId", adminId)).first();
            if (doc != null) {
                return mapDocumentToAdmin(doc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Update admin profile
     */
    public boolean updateAdminProfile(Admin admin) {
        if (admin == null || admin.getAdminId() <= 0) return false;
        try {
            List<Bson> updates = new ArrayList<>();
            if (admin.getName() != null) {
                updates.add(Updates.set("name", admin.getName().trim()));
            }
            if (admin.getEmail() != null) {
                updates.add(Updates.set("email", admin.getEmail().trim()));
            }
            if (admin.getMobile() != null) {
                updates.add(Updates.set("mobile", admin.getMobile().trim()));
            }
            if (admin.getAddress() != null) {
                updates.add(Updates.set("address", admin.getAddress().trim()));
            }
            if (admin.getPassword() != null && !admin.getPassword().trim().isEmpty()) {
                updates.add(Updates.set("password", PasswordUtil.hashPassword(admin.getPassword().trim())));
            }

            if (!updates.isEmpty()) {
                getAdminCollection().updateOne(
                        Filters.eq("adminId", admin.getAdminId()),
                        Updates.combine(updates)
                );
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Fetch aggregated dashboard statistics from MongoDB collections
     */
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();

        // Initialize default stats
        stats.put("totalStudents", 0);
        stats.put("activeStudents", 0);
        stats.put("oldStudents", 0);
        stats.put("totalRooms", 0);
        stats.put("totalBeds", 0);
        stats.put("availableBeds", 0);
        stats.put("occupiedBeds", 0);
        stats.put("totalFees", BigDecimal.ZERO);
        stats.put("paidFees", BigDecimal.ZERO);
        stats.put("pendingFees", BigDecimal.ZERO);
        stats.put("totalComplaints", 0);
        stats.put("pendingComplaints", 0);
        stats.put("inProgressComplaints", 0);
        stats.put("resolvedComplaints", 0);
        stats.put("rejectedComplaints", 0);

        try {
            // 1. Student Counts (Total, Active, Old/Inactive)
            MongoCollection<Document> studentColl = MongoDBConnection.getCollection("students");
            long totalStudents = studentColl.countDocuments();
            long inactiveStudents = studentColl.countDocuments(Filters.eq("status", "Inactive"));
            long activeStudents = totalStudents - inactiveStudents;

            stats.put("totalStudents", (int) totalStudents);
            stats.put("activeStudents", (int) activeStudents);
            stats.put("oldStudents", (int) inactiveStudents);

            // 2. Room & Bed counts
            MongoCollection<Document> rooms = MongoDBConnection.getCollection("rooms");
            stats.put("totalRooms", (int) rooms.countDocuments());

            int sumTotalBeds = 0;
            int sumOccupiedBeds = 0;
            int sumAvailableBeds = 0;

            try (MongoCursor<Document> cursor = rooms.find().iterator()) {
                while (cursor.hasNext()) {
                    Document r = cursor.next();
                    int total = r.getInteger("totalBeds", 0);
                    int occupied = r.getInteger("occupiedBeds", 0);
                    int available = r.getInteger("availableBeds", total - occupied);

                    sumTotalBeds += total;
                    sumOccupiedBeds += occupied;
                    sumAvailableBeds += available;
                }
            }
            stats.put("totalBeds", sumTotalBeds);
            stats.put("occupiedBeds", sumOccupiedBeds);
            stats.put("availableBeds", sumAvailableBeds);

            // 3. Fee Stats
            MongoCollection<Document> fees = MongoDBConnection.getCollection("fees");
            BigDecimal totalFees = BigDecimal.ZERO;
            BigDecimal paidFees = BigDecimal.ZERO;
            BigDecimal pendingFees = BigDecimal.ZERO;

            try (MongoCursor<Document> cursor = fees.find().iterator()) {
                while (cursor.hasNext()) {
                    Document f = cursor.next();
                    Double total = f.getDouble("totalFee");
                    Double paid = f.getDouble("paidAmount");
                    Double due = f.getDouble("dueAmount");

                    if (total != null) totalFees = totalFees.add(BigDecimal.valueOf(total));
                    if (paid != null) paidFees = paidFees.add(BigDecimal.valueOf(paid));
                    if (due != null) pendingFees = pendingFees.add(BigDecimal.valueOf(due));
                }
            }
            stats.put("totalFees", totalFees);
            stats.put("paidFees", paidFees);
            stats.put("pendingFees", pendingFees);

            // 4. Complaint Stats
            MongoCollection<Document> complaints = MongoDBConnection.getCollection("complaints");
            stats.put("totalComplaints", (int) complaints.countDocuments());
            stats.put("pendingComplaints", (int) complaints.countDocuments(Filters.eq("status", "Pending")));
            stats.put("inProgressComplaints", (int) complaints.countDocuments(Filters.eq("status", "In Progress")));
            stats.put("resolvedComplaints", (int) complaints.countDocuments(Filters.eq("status", "Resolved")));
            stats.put("rejectedComplaints", (int) complaints.countDocuments(Filters.eq("status", "Rejected")));

        } catch (Exception e) {
            e.printStackTrace();
        }

        return stats;
    }

    private Admin mapDocumentToAdmin(Document doc) {
        Admin admin = new Admin();
        admin.setAdminId(doc.getInteger("adminId", 1));
        admin.setName(doc.getString("name"));
        admin.setUsername(doc.getString("username"));
        admin.setPassword(doc.getString("password"));
        admin.setEmail(doc.getString("email"));
        admin.setMobile(doc.getString("mobile"));
        admin.setAddress(doc.getString("address"));

        Date createdAt = doc.getDate("createdAt");
        if (createdAt != null) {
            admin.setCreatedAt(new Timestamp(createdAt.getTime()));
        }
        return admin;
    }
}
