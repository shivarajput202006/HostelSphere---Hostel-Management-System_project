package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import com.mongodb.client.model.Updates;
import model.Allocation;
import org.bson.Document;
import org.bson.conversions.Bson;
import util.MongoDBConnection;
import util.SequenceGenerator;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * AllocationDAO - MongoDB Repository for Room Allocations
 */
public class AllocationDAO {

    private MongoCollection<Document> getAllocationCollection() {
        return MongoDBConnection.getCollection("room_allocations");
    }

    private MongoCollection<Document> getRoomCollection() {
        return MongoDBConnection.getCollection("rooms");
    }

    private MongoCollection<Document> getStudentCollection() {
        return MongoDBConnection.getCollection("students");
    }

    /**
     * Allocate a room to a student in MongoDB
     */
    public synchronized String allocateRoom(int studentId, int roomId, Date allocationDate) {
        try {
            // 1. Check if student already has active allocation
            long activeCount = getAllocationCollection().countDocuments(
                    Filters.and(Filters.eq("studentId", studentId), Filters.eq("status", "Active"))
            );
            if (activeCount > 0) {
                return "Student already has an active room allocation.";
            }

            // 2. Check room availability
            Document roomDoc = getRoomCollection().find(Filters.eq("roomId", roomId)).first();
            if (roomDoc == null) {
                return "Selected room does not exist.";
            }
            int available = roomDoc.getInteger("availableBeds", 0);
            if (available <= 0) {
                return "Selected room has no available beds.";
            }

            // 3. Insert allocation record
            int allocationId = SequenceGenerator.getNextSequence("allocationId");
            Document allocDoc = new Document("allocationId", allocationId)
                    .append("studentId", studentId)
                    .append("roomId", roomId)
                    .append("allocationDate", allocationDate != null ? allocationDate.toString() : new Date(System.currentTimeMillis()).toString())
                    .append("vacateDate", null)
                    .append("status", "Active")
                    .append("createdAt", new java.util.Date());

            getAllocationCollection().insertOne(allocDoc);

            // 4. Update room occupied & available bed counts
            boolean updated = RoomDAO.updateBedCounts(roomId, +1);
            if (!updated) {
                getAllocationCollection().deleteOne(Filters.eq("allocationId", allocationId));
                return "Failed to update room capacity.";
            }

            return "SUCCESS";

        } catch (Exception e) {
            e.printStackTrace();
            return "Database Error: " + e.getMessage();
        }
    }

    /**
     * Vacate an allocated room
     */
    public synchronized String vacateRoom(int allocationId, Date vacateDate) {
        try {
            Document allocDoc = getAllocationCollection().find(Filters.eq("allocationId", allocationId)).first();
            if (allocDoc == null) {
                return "Allocation record not found.";
            }
            if (!"Active".equalsIgnoreCase(allocDoc.getString("status"))) {
                return "Allocation is already vacated or inactive.";
            }

            int roomId = allocDoc.getInteger("roomId", -1);

            // 1. Mark as Vacated
            getAllocationCollection().updateOne(
                    Filters.eq("allocationId", allocationId),
                    Updates.combine(
                            Updates.set("status", "Vacated"),
                            Updates.set("vacateDate", vacateDate != null ? vacateDate.toString() : new Date(System.currentTimeMillis()).toString())
                    )
            );

            // 2. Decrement occupied beds
            if (roomId > 0) {
                RoomDAO.updateBedCounts(roomId, -1);
            }

            return "SUCCESS";

        } catch (Exception e) {
            e.printStackTrace();
            return "Database Error: " + e.getMessage();
        }
    }

    /**
     * Change room for an active allocation
     */
    public synchronized String changeRoom(int allocationId, int newRoomId, Date changeDate) {
        try {
            Document allocDoc = getAllocationCollection().find(Filters.eq("allocationId", allocationId)).first();
            if (allocDoc == null || !"Active".equalsIgnoreCase(allocDoc.getString("status"))) {
                return "Active allocation not found.";
            }

            int studentId = allocDoc.getInteger("studentId");
            int oldRoomId = allocDoc.getInteger("roomId");

            if (oldRoomId == newRoomId) {
                return "Student is already in this room.";
            }

            // Check new room availability
            Document newRoomDoc = getRoomCollection().find(Filters.eq("roomId", newRoomId)).first();
            if (newRoomDoc == null || newRoomDoc.getInteger("availableBeds", 0) <= 0) {
                return "New room has no available beds.";
            }

            // Vacate old
            getAllocationCollection().updateOne(
                    Filters.eq("allocationId", allocationId),
                    Updates.combine(
                            Updates.set("status", "Vacated"),
                            Updates.set("vacateDate", changeDate != null ? changeDate.toString() : new Date(System.currentTimeMillis()).toString())
                    )
            );
            RoomDAO.updateBedCounts(oldRoomId, -1);

            // Create new allocation
            int newAllocId = SequenceGenerator.getNextSequence("allocationId");
            Document newAllocDoc = new Document("allocationId", newAllocId)
                    .append("studentId", studentId)
                    .append("roomId", newRoomId)
                    .append("allocationDate", changeDate != null ? changeDate.toString() : new Date(System.currentTimeMillis()).toString())
                    .append("vacateDate", null)
                    .append("status", "Active")
                    .append("createdAt", new java.util.Date());

            getAllocationCollection().insertOne(newAllocDoc);
            RoomDAO.updateBedCounts(newRoomId, +1);

            return "SUCCESS";

        } catch (Exception e) {
            e.printStackTrace();
            return "Database Error: " + e.getMessage();
        }
    }

    /**
     * Get all active allocations
     */
    public List<Allocation> getActiveAllocations() {
        return fetchAllocations(Filters.eq("status", "Active"));
    }

    /**
     * Get all allocations history
     */
    public List<Allocation> getAllAllocationsHistory() {
        return fetchAllocations(null);
    }

    /**
     * Get active allocation for a student
     */
    public Allocation getActiveAllocationByStudent(int studentId) {
        List<Allocation> list = fetchAllocations(
                Filters.and(Filters.eq("studentId", studentId), Filters.eq("status", "Active"))
        );
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * Get recent allocations
     */
    public List<Allocation> getRecentAllocations(int limit) {
        List<Allocation> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getAllocationCollection()
                    .find()
                    .sort(Sorts.descending("allocationId"))
                    .limit(limit)
                    .iterator()) {
                while (cursor.hasNext()) {
                    Allocation a = mapAllocation(cursor.next());
                    populateDetails(a);
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Allocation> fetchAllocations(Bson filter) {
        List<Allocation> list = new ArrayList<>();
        try {
            MongoCursor<Document> cursor = (filter != null)
                    ? getAllocationCollection().find(filter).sort(Sorts.descending("allocationId")).iterator()
                    : getAllocationCollection().find().sort(Sorts.descending("allocationId")).iterator();

            try (cursor) {
                while (cursor.hasNext()) {
                    Allocation a = mapAllocation(cursor.next());
                    populateDetails(a);
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void populateDetails(Allocation a) {
        if (a == null) return;
        try {
            if (a.getStudentId() > 0) {
                Document stu = getStudentCollection().find(Filters.eq("studentId", a.getStudentId())).first();
                if (stu != null) {
                    a.setStudentName(stu.getString("name"));
                    a.setStudentCourse(stu.getString("course"));
                    a.setStudentMobile(stu.getString("mobile"));
                }
            }
            if (a.getRoomId() > 0) {
                Document rm = getRoomCollection().find(Filters.eq("roomId", a.getRoomId())).first();
                if (rm != null) {
                    a.setRoomNumber(rm.getString("roomNumber"));
                    a.setRoomFloor(rm.getInteger("floor", 1));
                    a.setRoomType(rm.getString("roomType"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Allocation mapAllocation(Document doc) {
        Allocation a = new Allocation();
        a.setAllocationId(doc.getInteger("allocationId", 0));
        a.setStudentId(doc.getInteger("studentId", 0));
        a.setRoomId(doc.getInteger("roomId", 0));

        Object allocDateObj = doc.get("allocationDate");
        if (allocDateObj instanceof String && !((String) allocDateObj).isEmpty()) {
            try { a.setAllocationDate(Date.valueOf((String) allocDateObj)); } catch (Exception ignored) {}
        } else if (allocDateObj instanceof java.util.Date) {
            a.setAllocationDate(new Date(((java.util.Date) allocDateObj).getTime()));
        }

        Object vacateDateObj = doc.get("vacateDate");
        if (vacateDateObj instanceof String && !((String) vacateDateObj).isEmpty()) {
            try { a.setVacateDate(Date.valueOf((String) vacateDateObj)); } catch (Exception ignored) {}
        } else if (vacateDateObj instanceof java.util.Date) {
            a.setVacateDate(new Date(((java.util.Date) vacateDateObj).getTime()));
        }

        a.setStatus(doc.getString("status"));

        java.util.Date createdAt = doc.getDate("createdAt");
        if (createdAt != null) {
            a.setCreatedAt(new Timestamp(createdAt.getTime()));
        }
        return a;
    }
}
