package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import com.mongodb.client.model.Updates;
import model.Room;
import org.bson.Document;
import org.bson.conversions.Bson;
import util.MongoDBConnection;
import util.SequenceGenerator;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * RoomDAO - MongoDB Repository for Room Management and Bed Capacity
 */
public class RoomDAO {

    private static MongoCollection<Document> getRoomCollection() {
        return MongoDBConnection.getCollection("rooms");
    }

    /**
     * Get all rooms
     */
    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getRoomCollection()
                    .find()
                    .sort(Sorts.ascending("floor", "roomNumber"))
                    .iterator()) {
                while (cursor.hasNext()) {
                    list.add(mapDocumentToRoom(cursor.next()));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get only available rooms (availableBeds > 0)
     */
    public List<Room> getAvailableRooms() {
        List<Room> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getRoomCollection()
                    .find(Filters.gt("availableBeds", 0))
                    .sort(Sorts.ascending("floor", "roomNumber"))
                    .iterator()) {
                while (cursor.hasNext()) {
                    list.add(mapDocumentToRoom(cursor.next()));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get room by ID
     */
    public Room getRoomById(int roomId) {
        try {
            Document doc = getRoomCollection().find(Filters.eq("roomId", roomId)).first();
            if (doc != null) {
                return mapDocumentToRoom(doc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Add a new room
     */
    public boolean addRoom(Room room) {
        try {
            if (room.getRoomId() <= 0) {
                room.setRoomId(SequenceGenerator.getNextSequence("roomId"));
            }

            int total = room.getTotalBeds();
            int occupied = 0;
            int available = total - occupied;
            String status = (available > 0) ? "Available" : "Occupied";

            Document doc = new Document("roomId", room.getRoomId())
                    .append("roomNumber", room.getRoomNumber().trim())
                    .append("floor", room.getFloor())
                    .append("roomType", room.getRoomType())
                    .append("totalBeds", total)
                    .append("occupiedBeds", occupied)
                    .append("availableBeds", available)
                    .append("status", status)
                    .append("createdAt", new Date());

            getRoomCollection().insertOne(doc);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update room details
     */
    public boolean updateRoom(Room room) {
        try {
            Room existing = getRoomById(room.getRoomId());
            int occupied = (existing != null) ? existing.getOccupiedBeds() : 0;
            int total = room.getTotalBeds();
            if (total < occupied) {
                // Cannot reduce total beds below current occupied count
                return false;
            }
            int available = total - occupied;
            String status = (available > 0) ? "Available" : "Occupied";

            getRoomCollection().updateOne(
                    Filters.eq("roomId", room.getRoomId()),
                    Updates.combine(
                            Updates.set("roomNumber", room.getRoomNumber().trim()),
                            Updates.set("floor", room.getFloor()),
                            Updates.set("roomType", room.getRoomType()),
                            Updates.set("totalBeds", total),
                            Updates.set("occupiedBeds", occupied),
                            Updates.set("availableBeds", available),
                            Updates.set("status", status)
                    )
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete room by ID
     */
    public boolean deleteRoom(int roomId) {
        try {
            // Check if there are active allocations in this room
            long activeAllocs = MongoDBConnection.getCollection("room_allocations")
                    .countDocuments(Filters.and(Filters.eq("roomId", roomId), Filters.eq("status", "Active")));
            if (activeAllocs > 0) {
                return false;
            }
            getRoomCollection().deleteOne(Filters.eq("roomId", roomId));
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if room number is already taken
     */
    public boolean isRoomNumberTaken(String roomNumber, int excludeRoomId) {
        if (roomNumber == null || roomNumber.trim().isEmpty()) return false;
        try {
            Bson filter = (excludeRoomId > 0)
                    ? Filters.and(Filters.eq("roomNumber", roomNumber.trim()), Filters.ne("roomId", excludeRoomId))
                    : Filters.eq("roomNumber", roomNumber.trim());
            return getRoomCollection().countDocuments(filter) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Atomic bed count updater used when allocating or vacating rooms
     */
    public static synchronized boolean updateBedCounts(int roomId, int deltaOccupied) {
        try {
            Document roomDoc = getRoomCollection().find(Filters.eq("roomId", roomId)).first();
            if (roomDoc == null) return false;

            int total = roomDoc.getInteger("totalBeds", 0);
            int occupied = roomDoc.getInteger("occupiedBeds", 0) + deltaOccupied;
            if (occupied < 0 || occupied > total) {
                return false; // Exceeds capacity or invalid
            }
            int available = total - occupied;
            String status = (available > 0) ? "Available" : "Occupied";

            getRoomCollection().updateOne(
                    Filters.eq("roomId", roomId),
                    Updates.combine(
                            Updates.set("occupiedBeds", occupied),
                            Updates.set("availableBeds", available),
                            Updates.set("status", status)
                    )
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Room mapDocumentToRoom(Document doc) {
        Room r = new Room();
        r.setRoomId(doc.getInteger("roomId", 0));
        r.setRoomNumber(doc.getString("roomNumber"));
        r.setFloor(doc.getInteger("floor", 1));
        r.setRoomType(doc.getString("roomType"));
        r.setTotalBeds(doc.getInteger("totalBeds", 0));
        r.setOccupiedBeds(doc.getInteger("occupiedBeds", 0));
        r.setAvailableBeds(doc.getInteger("availableBeds", 0));
        r.setStatus(doc.getString("status"));

        Date createdAt = doc.getDate("createdAt");
        if (createdAt != null) {
            r.setCreatedAt(new Timestamp(createdAt.getTime()));
        }
        return r;
    }
}
