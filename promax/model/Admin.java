package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Admin implements Serializable {
    private static final long serialVersionUID = 1L;

    private int adminId;
    private String name;
    private String username;
    private String password;
    private String email;
    private String mobile;
    private String address;
    private Timestamp createdAt;

    public Admin() {}

    public Admin(int adminId, String name, String username, String password) {
        this.adminId = adminId;
        this.name = name;
        this.username = username;
        this.password = password;
    }

    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getMobile() { return mobile; }
    public void setMobile(String mobile) { this.mobile = mobile; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
