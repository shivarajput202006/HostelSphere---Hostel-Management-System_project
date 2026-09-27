# Installation & Setup Guide: Hostel Management System

A step-by-step installation and execution guide for the **Hostel Management System** (`hostel_shivv`) web application using **XAMPP (MySQL + Apache Tomcat)** and **Java 8 / 11 / 17 / 21+**.

---

## 1. Prerequisites Checklist

Ensure the following tools are installed on your computer:
1. **Java Development Kit (JDK)**: JDK 8 or higher (JDK 11, 17, 21, or 26 supported).
   - Check via terminal: `java -version` and `javac -version`
2. **XAMPP Control Panel**:
   - Contains **MySQL** (port `3306`), **Apache**, and **phpMyAdmin**.
   - Contains or has **Apache Tomcat** (port `8080`).
3. **Web Browser**: Google Chrome, Mozilla Firefox, or Microsoft Edge.

---

## 2. Step 1: Database Setup via XAMPP / phpMyAdmin

1. Open **XAMPP Control Panel** from `C:\xampp\xampp-control.exe`.
2. Click **Start** next to **MySQL**.
3. Open your browser and go to:
   ```
   http://localhost/phpmyadmin/
   ```
4. Click on the **Import** tab in the top navigation bar.
5. Click **Choose File** and select the database script located at:
   ```
   HostelManagementSystem/database/hostel_shivv.sql
   ```
6. Scroll down and click **Import** (or **Go**).
7. The database `hostel_shivv` and all 6 tables (`admins`, `students`, `rooms`, `room_allocations`, `fees`, `complaints`) will be created and populated with realistic test records.

> **Alternative via MySQL Command Line:**
> ```cmd
> cd C:\xampp\mysql\bin
> mysql -u root -p < "c:\Users\shiva\OneDrive\Desktop\projects\HostelManagementSystem\database\hostel_shivv.sql"
> ```

---

## 3. Step 2: Configure Database Connection (If Needed)

The project is pre-configured for standard XAMPP defaults:
- **Host**: `localhost:3306`
- **Database**: `hostel_shivv`
- **Username**: `root`
- **Password**: *(empty/blank)*

If your MySQL has a root password, open:
`HostelManagementSystem/src/util/DBConnection.java` and update:
```java
private static final String PASSWORD = "your_mysql_password";
```
Then re-run `compile.bat`.

---

## 4. Step 3: Compiling the Java Backend

The project includes an automated compilation script that compiles all Models, DAOs, Servlets, and Utilities against the servlet libraries.

1. Open a Command Prompt in the `HostelManagementSystem` folder.
2. Run:
   ```cmd
   compile.bat
   ```
3. You will see:
   ```
   ========================================================
     BUILD SUCCESSFUL! All classes compiled to:
     WebContent\WEB-INF\classes
   ========================================================
   ```

---

## 5. Step 4: Deploying to Apache Tomcat

### Option A: Using the One-Click Deployment Script (Recommended)
Double-click or run:
```cmd
deploy_xampp.bat
```
This automatically compiles your classes and copies the complete web application into:
`C:\xampp\tomcat\webapps\HostelManagementSystem`

### Option B: Manual Deployment to Tomcat
Copy the entire contents of the `HostelManagementSystem/WebContent` folder to:
`C:\xampp\tomcat\webapps\HostelManagementSystem\`

---

## 6. Step 5: Starting Apache Tomcat

1. In the **XAMPP Control Panel**, click **Start** next to **Tomcat**.
   *(Alternatively, run `C:\xampp\tomcat\bin\startup.bat` from terminal).*
2. Wait 3 to 5 seconds for Tomcat to initialize.

---

## 7. Step 6: Accessing the Application

Open your browser and navigate to:
```
http://localhost:8080/HostelManagementSystem/
```

---

## 8. Default Login Credentials for Testing & Viva

### 1. Administrator Login
- **Portal Option**: Select **Admin Login** tab
- **Username**: `admin`
- **Password**: `admin123`
- *(Alternate Admin)*: `warden` / `admin123`

### 2. Student Resident Login
- **Portal Option**: Select **Student Login** tab
- **Username**: `student1`
- **Password**: `pass123`
- *(Alternate Students)*: `student2`, `student3`, `student4`, `student5`, `student6` (all passwords are `pass123`).

---

## 9. Troubleshooting Common Issues

### Issue 1: "Port 8080 already in use"
- **Solution**: Open `C:\xampp\tomcat\conf\server.xml`, search for `<Connector port="8080"`, change to `port="8088"`, and restart Tomcat. Then access `http://localhost:8088/HostelManagementSystem/`.

### Issue 2: "Communications link failure / Database connection error"
- **Solution**: Verify that MySQL is running in XAMPP (green indicator). Verify that the database `hostel_shivv` has been imported via phpMyAdmin.

### Issue 3: "HTTP Status 404 - Not Found"
- **Solution**: Ensure folder name inside `C:\xampp\tomcat\webapps` matches `HostelManagementSystem` exactly (case-sensitive on certain Tomcat setups).
