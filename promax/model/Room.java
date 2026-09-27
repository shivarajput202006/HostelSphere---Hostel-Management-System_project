package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Room implements Serializable {
    private static final long serialVersionUID = 1L;

    private int roomId;
    private String roomNumber;
    private int floor;
    private String roomType;
    private int totalBeds;
    private int occupiedBeds;
    private int availableBeds;
    private String status;
    private Timestamp createdAt;

    public Room() {}

    public Room(int roomId, String roomNumber, int floor, String roomType, int totalBeds, int occupiedBeds, int availableBeds, String status) {
        this.roomId = roomId;
        this.roomNumber = roomNumber;
        this.floor = floor;
        this.roomType = roomType;
        this.totalBeds = totalBeds;
        this.occupiedBeds = occupiedBeds;
        this.availableBeds = availableBeds;
        this.status = status;
    }

    public int getRoomId() { return roomId; }
    public void setRoomId(int roomId) { this.roomId = roomId; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public int getFloor() { return floor; }
    public void setFloor(int floor) { this.floor = floor; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public int getTotalBeds() { return totalBeds; }
    public void setTotalBeds(int totalBeds) { 
        this.totalBeds = totalBeds;
        this.availableBeds = this.totalBeds - this.occupiedBeds;
    }

    public int getOccupiedBeds() { return occupiedBeds; }
    public void setOccupiedBeds(int occupiedBeds) { 
        this.occupiedBeds = occupiedBeds;
        this.availableBeds = this.totalBeds - this.occupiedBeds;
    }

    public int getAvailableBeds() { return availableBeds; }
    public void setAvailableBeds(int availableBeds) { this.availableBeds = availableBeds; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
