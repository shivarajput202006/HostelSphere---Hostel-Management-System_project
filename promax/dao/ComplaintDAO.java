package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import com.mongodb.client.model.Updates;
import model.Complaint;
import org.bson.Document;
import org.bson.conversions.Bson;
import util.MongoDBConnection;
import util.SequenceGenerator;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * ComplaintDAO - MongoDB Repository for Student Complaints and Grievance Management
 */
public class ComplaintDAO {

    private MongoCollection<Document> getComplaintCollection() {
        return MongoDBConnection.getCollection("complaints");
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

    /**
     * Submit a new student complaint
     */
    public boolean submitComplaint(Complaint complaint) {
        try {
            if (complaint.getComplaintId() <= 0) {
                complaint.setComplaintId(SequenceGenerator.getNextSequence("complaintId"));
            }

            Document doc = new Document("complaintId", complaint.getComplaintId())
                    .append("studentId", complaint.getStudentId())
                    .append("category", complaint.getCategory() != null ? complaint.getCategory().trim() : "General")
                    .append("subject", complaint.getSubject() != null ? complaint.getSubject().trim() : "")
                    .append("description", complaint.getDescription() != null ? complaint.getDescription().trim() : "")
                    .append("complaintDate", new Date())
                    .append("status", "Pending")
                    .append("adminResponse", null)
                    .append("resolvedDate", null);

            getComplaintCollection().insertOne(doc);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get complaints submitted by a specific student
     */
    public List<Complaint> getComplaintsByStudent(int studentId) {
        return fetchComplaints(Filters.eq("studentId", studentId));
    }

    /**
     * Get all complaints (for Admin)
     */
    public List<Complaint> getAllComplaints() {
        return fetchComplaints(null);
    }

    /**
     * Filter complaints by category, course, and status
     */
    public List<Complaint> filterComplaints(String category, String course, String status) {
        List<Bson> filters = new ArrayList<>();

        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            filters.add(Filters.eq("category", category.trim()));
        }
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            filters.add(Filters.eq("status", status.trim()));
        }

        Bson query = filters.isEmpty() ? null : (filters.size() == 1 ? filters.get(0) : Filters.and(filters));
        List<Complaint> list = fetchComplaints(query);

        // Filter by course if specified
        if (course != null && !course.trim().isEmpty() && !"ALL".equalsIgnoreCase(course)) {
            String targetCourse = course.trim();
            List<Complaint> filtered = new ArrayList<>();
            for (Complaint c : list) {
                if (c.getStudentCourse() != null && c.getStudentCourse().equalsIgnoreCase(targetCourse)) {
                    filtered.add(c);
                }
            }
            return filtered;
        }

        return list;
    }

    /**
     * Get single complaint by ID
     */
    public Complaint getComplaintById(int complaintId) {
        List<Complaint> list = fetchComplaints(Filters.eq("complaintId", complaintId));
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Admin updates complaint status and response
     */
    public boolean updateResponseAndStatus(int complaintId, String status, String adminResponse) {
        try {
            boolean isResolved = "Resolved".equalsIgnoreCase(status);
            Date now = new Date();

            List<Bson> updates = new ArrayList<>();
            updates.add(Updates.set("status", status));
            updates.add(Updates.set("adminResponse", adminResponse));
            if (isResolved) {
                updates.add(Updates.set("resolvedDate", now));
            } else {
                updates.add(Updates.set("resolvedDate", null));
            }

            getComplaintCollection().updateOne(
                    Filters.eq("complaintId", complaintId),
                    Updates.combine(updates)
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete complaint
     */
    public boolean deleteComplaint(int complaintId) {
        try {
            getComplaintCollection().deleteOne(Filters.eq("complaintId", complaintId));
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get recent complaints for admin dashboard
     */
    public List<Complaint> getRecentComplaints(int limit) {
        List<Complaint> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getComplaintCollection()
                    .find()
                    .sort(Sorts.descending("complaintId"))
                    .limit(limit)
                    .iterator()) {
                while (cursor.hasNext()) {
                    Complaint c = mapComplaint(cursor.next());
                    populateComplaintDetails(c);
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Complaint> fetchComplaints(Bson filter) {
        List<Complaint> list = new ArrayList<>();
        try {
            MongoCursor<Document> cursor = (filter != null)
                    ? getComplaintCollection().find(filter).sort(Sorts.descending("complaintId")).iterator()
                    : getComplaintCollection().find().sort(Sorts.descending("complaintId")).iterator();

            try (cursor) {
                while (cursor.hasNext()) {
                    Complaint c = mapComplaint(cursor.next());
                    populateComplaintDetails(c);
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void populateComplaintDetails(Complaint c) {
        if (c == null || c.getStudentId() <= 0) return;
        try {
            Document stu = getStudentCollection().find(Filters.eq("studentId", c.getStudentId())).first();
            if (stu != null) {
                c.setStudentName(stu.getString("name"));
                c.setStudentCourse(stu.getString("course"));
                c.setStudentMobile(stu.getString("mobile"));
            }

            Document alloc = getAllocationCollection().find(
                    Filters.and(Filters.eq("studentId", c.getStudentId()), Filters.eq("status", "Active"))
            ).first();

            if (alloc != null) {
                Integer roomId = alloc.getInteger("roomId");
                if (roomId != null) {
                    Document rm = getRoomCollection().find(Filters.eq("roomId", roomId)).first();
                    if (rm != null) {
                        c.setRoomNumber(rm.getString("roomNumber"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Complaint mapComplaint(Document doc) {
        Complaint c = new Complaint();
        c.setComplaintId(doc.getInteger("complaintId", 0));
        c.setStudentId(doc.getInteger("studentId", 0));
        c.setCategory(doc.getString("category"));
        c.setSubject(doc.getString("subject"));
        c.setDescription(doc.getString("description"));

        Date cDate = doc.getDate("complaintDate");
        if (cDate != null) {
            c.setComplaintDate(new Timestamp(cDate.getTime()));
        }

        c.setStatus(doc.getString("status"));
        c.setAdminResponse(doc.getString("adminResponse"));

        Date rDate = doc.getDate("resolvedDate");
        if (rDate != null) {
            c.setResolvedDate(new Timestamp(rDate.getTime()));
        }
        return c;
    }
}
