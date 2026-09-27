package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import com.mongodb.client.model.Updates;
import model.Student;
import org.bson.Document;
import org.bson.conversions.Bson;
import util.MongoDBConnection;
import util.PasswordUtil;
import util.SequenceGenerator;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * StudentDAO - MongoDB Repository for Student Management & Lifecycle
 */
public class StudentDAO {

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
     * Authenticate student credentials
     */
    public Student authenticate(String username, String password) {
        if (username == null || password == null) return null;

        try {
            Document doc = getStudentCollection().find(Filters.eq("username", username.trim())).first();
            if (doc != null) {
                String storedPassword = doc.getString("password");
                if (PasswordUtil.checkPassword(password.trim(), storedPassword)) {
                    Student s = mapDocumentToStudent(doc);
                    populateActiveAllocation(s);
                    return s;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get all students with active allocated room information (defaults to all)
     */
    public List<Student> getAllStudents() {
        return getStudentsByFilter(null);
    }

    /**
     * Get only currently active students
     */
    public List<Student> getActiveStudents() {
        return getStudentsByFilter(Filters.ne("status", "Inactive"));
    }

    /**
     * Get old / inactive / archived students
     */
    public List<Student> getOldStudents() {
        return getStudentsByFilter(Filters.eq("status", "Inactive"));
    }

    /**
     * Search and filter students by keyword and status
     */
    public List<Student> searchStudents(String keyword, String status) {
        List<Bson> filterList = new ArrayList<>();

        if ("active".equalsIgnoreCase(status)) {
            filterList.add(Filters.ne("status", "Inactive"));
        } else if ("inactive".equalsIgnoreCase(status) || "old".equalsIgnoreCase(status)) {
            filterList.add(Filters.eq("status", "Inactive"));
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            String term = keyword.trim();
            Pattern regex = Pattern.compile(Pattern.quote(term), Pattern.CASE_INSENSITIVE);
            List<Bson> searchOr = new ArrayList<>();
            searchOr.add(Filters.regex("name", regex));
            searchOr.add(Filters.regex("email", regex));
            searchOr.add(Filters.regex("mobile", regex));
            searchOr.add(Filters.regex("course", regex));
            searchOr.add(Filters.regex("username", regex));
            try {
                int idNum = Integer.parseInt(term.replaceAll("[^0-9]", ""));
                if (idNum > 0) {
                    searchOr.add(Filters.eq("studentId", idNum));
                }
            } catch (Exception ignored) {}

            filterList.add(Filters.or(searchOr));
        }

        Bson finalFilter = filterList.isEmpty() ? null : Filters.and(filterList);
        return getStudentsByFilter(finalFilter);
    }

    private List<Student> getStudentsByFilter(Bson filter) {
        List<Student> list = new ArrayList<>();
        try {
            MongoCursor<Document> cursor = (filter != null)
                    ? getStudentCollection().find(filter).sort(Sorts.descending("studentId")).iterator()
                    : getStudentCollection().find().sort(Sorts.descending("studentId")).iterator();

            try (cursor) {
                while (cursor.hasNext()) {
                    Student s = mapDocumentToStudent(cursor.next());
                    populateActiveAllocation(s);
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get students who do not currently have an active room allocation
     */
    public List<Student> getStudentsWithoutRoom() {
        List<Student> list = new ArrayList<>();
        try {
            Set<Integer> allocatedStudentIds = new HashSet<>();
            try (MongoCursor<Document> allocCursor = getAllocationCollection()
                    .find(Filters.eq("status", "Active"))
                    .iterator()) {
                while (allocCursor.hasNext()) {
                    Document allocDoc = allocCursor.next();
                    Integer sId = allocDoc.getInteger("studentId");
                    if (sId != null) allocatedStudentIds.add(sId);
                }
            }

            Bson filter = Filters.and(
                    Filters.ne("status", "Inactive"),
                    Filters.nin("studentId", allocatedStudentIds)
            );

            try (MongoCursor<Document> cursor = getStudentCollection()
                    .find(filter)
                    .sort(Sorts.ascending("name"))
                    .iterator()) {
                while (cursor.hasNext()) {
                    list.add(mapDocumentToStudent(cursor.next()));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get student by ID
     */
    public Student getStudentById(int studentId) {
        try {
            Document doc = getStudentCollection().find(Filters.eq("studentId", studentId)).first();
            if (doc != null) {
                Student s = mapDocumentToStudent(doc);
                populateActiveAllocation(s);
                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Add a new student into MongoDB.
     * NOTE: Does NOT generate any fee record automatically!
     */
    public boolean addStudent(Student student) {
        try {
            if (student.getStudentId() <= 0) {
                student.setStudentId(SequenceGenerator.getNextSequence("studentId"));
            }

            String plainPassword = student.getPassword();
            String hashedPassword = (plainPassword != null && !plainPassword.trim().isEmpty()) 
                    ? PasswordUtil.hashPassword(plainPassword.trim()) 
                    : PasswordUtil.hashPassword("pass123");

            String uname = (student.getUsername() != null && !student.getUsername().trim().isEmpty()) 
                    ? student.getUsername().trim() 
                    : (student.getEmail() != null && !student.getEmail().trim().isEmpty() ? student.getEmail().trim() : "student" + student.getStudentId());

            Document doc = new Document("studentId", student.getStudentId())
                    .append("name", student.getName() != null ? student.getName().trim() : "")
                    .append("fatherName", student.getFatherName() != null ? student.getFatherName().trim() : "")
                    .append("motherName", student.getMotherName() != null ? student.getMotherName().trim() : "")
                    .append("dob", student.getDob() != null ? student.getDob().toString() : "")
                    .append("gender", student.getGender() != null ? student.getGender().trim() : "Other")
                    .append("mobile", student.getMobile() != null ? student.getMobile().trim() : "")
                    .append("email", student.getEmail() != null ? student.getEmail().trim() : "")
                    .append("address", student.getAddress() != null ? student.getAddress().trim() : "")
                    .append("course", student.getCourse() != null ? student.getCourse().trim() : "")
                    .append("semester", student.getSemester() != null ? student.getSemester().trim() : "Semester 1")
                    .append("admissionDate", student.getAdmissionDate() != null ? student.getAdmissionDate().toString() : "")
                    .append("username", uname)
                    .append("password", hashedPassword)
                    .append("photo", (student.getPhoto() != null && !student.getPhoto().isEmpty()) ? student.getPhoto() : "default_avatar.svg")
                    .append("status", (student.getStatus() != null && !student.getStatus().isEmpty()) ? student.getStatus() : "Active")
                    .append("createdAt", new java.util.Date());

            getStudentCollection().insertOne(doc);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update an existing student (Admin action)
     */
    public boolean updateStudent(Student student) {
        try {
            List<Bson> updates = new ArrayList<>();
            updates.add(Updates.set("name", student.getName()));
            updates.add(Updates.set("fatherName", student.getFatherName()));
            updates.add(Updates.set("motherName", student.getMotherName()));
            updates.add(Updates.set("dob", student.getDob() != null ? student.getDob().toString() : ""));
            updates.add(Updates.set("gender", student.getGender()));
            updates.add(Updates.set("mobile", student.getMobile()));
            updates.add(Updates.set("email", student.getEmail()));
            updates.add(Updates.set("address", student.getAddress()));
            updates.add(Updates.set("course", student.getCourse() != null ? student.getCourse().trim() : ""));
            updates.add(Updates.set("semester", student.getSemester()));
            updates.add(Updates.set("admissionDate", student.getAdmissionDate() != null ? student.getAdmissionDate().toString() : ""));
            updates.add(Updates.set("username", student.getUsername().trim()));

            if (student.getStatus() != null && !student.getStatus().trim().isEmpty()) {
                updates.add(Updates.set("status", student.getStatus().trim()));
            }

            if (student.getPassword() != null && !student.getPassword().trim().isEmpty()) {
                updates.add(Updates.set("password", PasswordUtil.hashPassword(student.getPassword().trim())));
            }

            getStudentCollection().updateOne(
                    Filters.eq("studentId", student.getStudentId()),
                    Updates.combine(updates)
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update personal profile information by student themselves.
     * Restricts editing of studentId, course, semester, admissionDate, room, fees, etc.
     */
    public boolean updateStudentPersonal(Student student) {
        if (student == null || student.getStudentId() <= 0) return false;
        try {
            List<Bson> updates = new ArrayList<>();
            if (student.getName() != null && !student.getName().trim().isEmpty()) {
                updates.add(Updates.set("name", student.getName().trim()));
            }
            if (student.getFatherName() != null) {
                updates.add(Updates.set("fatherName", student.getFatherName().trim()));
            }
            if (student.getMotherName() != null) {
                updates.add(Updates.set("motherName", student.getMotherName().trim()));
            }
            if (student.getDob() != null) {
                updates.add(Updates.set("dob", student.getDob().toString()));
            }
            if (student.getGender() != null && !student.getGender().trim().isEmpty()) {
                updates.add(Updates.set("gender", student.getGender().trim()));
            }
            if (student.getMobile() != null) {
                updates.add(Updates.set("mobile", student.getMobile().trim()));
            }
            if (student.getEmail() != null) {
                updates.add(Updates.set("email", student.getEmail().trim()));
            }
            if (student.getAddress() != null) {
                updates.add(Updates.set("address", student.getAddress().trim()));
            }
            if (student.getPassword() != null && !student.getPassword().trim().isEmpty()) {
                updates.add(Updates.set("password", PasswordUtil.hashPassword(student.getPassword().trim())));
            }

            if (!updates.isEmpty()) {
                getStudentCollection().updateOne(
                        Filters.eq("studentId", student.getStudentId()),
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
     * Deactivate / Archive student (Marks student as Inactive / Old without deleting historical data)
     */
    public boolean deactivateStudent(int studentId) {
        try {
            getStudentCollection().updateOne(
                    Filters.eq("studentId", studentId),
                    Updates.set("status", "Inactive")
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Reactivate an old/inactive student
     */
    public boolean reactivateStudent(int studentId) {
        try {
            getStudentCollection().updateOne(
                    Filters.eq("studentId", studentId),
                    Updates.set("status", "Active")
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete student by ID (Only used if explicitly requested)
     */
    public boolean deleteStudent(int studentId) {
        try {
            getStudentCollection().deleteOne(Filters.eq("studentId", studentId));
            getAllocationCollection().deleteMany(Filters.eq("studentId", studentId));
            MongoDBConnection.getCollection("fees").deleteMany(Filters.eq("studentId", studentId));
            MongoDBConnection.getCollection("complaints").deleteMany(Filters.eq("studentId", studentId));
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if username is already taken
     */
    public boolean isUsernameTaken(String username, int excludeStudentId) {
        if (username == null || username.trim().isEmpty()) return false;
        try {
            Bson filter = (excludeStudentId > 0)
                    ? Filters.and(Filters.eq("username", username.trim()), Filters.ne("studentId", excludeStudentId))
                    : Filters.eq("username", username.trim());
            return getStudentCollection().countDocuments(filter) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get recent students for dashboard widget
     */
    public List<Student> getRecentStudents(int limit) {
        List<Student> list = new ArrayList<>();
        try {
            try (MongoCursor<Document> cursor = getStudentCollection()
                    .find()
                    .sort(Sorts.descending("studentId"))
                    .limit(limit)
                    .iterator()) {
                while (cursor.hasNext()) {
                    Student s = mapDocumentToStudent(cursor.next());
                    populateActiveAllocation(s);
                    list.add(s);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private void populateActiveAllocation(Student s) {
        if (s == null) return;
        try {
            Document allocDoc = getAllocationCollection().find(
                    Filters.and(Filters.eq("studentId", s.getStudentId()), Filters.eq("status", "Active"))
            ).first();

            if (allocDoc != null) {
                Integer roomId = allocDoc.getInteger("roomId");
                Object allocDateObj = allocDoc.get("allocationDate");
                if (allocDateObj instanceof String && !((String) allocDateObj).isEmpty()) {
                    try { s.setAllocationDate(Date.valueOf((String) allocDateObj)); } catch (Exception ignored) {}
                } else if (allocDateObj instanceof java.util.Date) {
                    s.setAllocationDate(new Date(((java.util.Date) allocDateObj).getTime()));
                }

                if (roomId != null) {
                    Document roomDoc = getRoomCollection().find(Filters.eq("roomId", roomId)).first();
                    if (roomDoc != null) {
                        s.setRoomNumber(roomDoc.getString("roomNumber"));
                        s.setRoomType(roomDoc.getString("roomType"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Student mapDocumentToStudent(Document doc) {
        Student s = new Student();
        s.setStudentId(doc.getInteger("studentId", 0));
        s.setName(doc.getString("name"));
        s.setFatherName(doc.getString("fatherName"));
        s.setMotherName(doc.getString("motherName"));

        String dobStr = doc.getString("dob");
        if (dobStr != null && !dobStr.isEmpty()) {
            try { s.setDob(Date.valueOf(dobStr)); } catch (Exception ignored) {}
        }

        s.setGender(doc.getString("gender"));
        s.setMobile(doc.getString("mobile"));
        s.setEmail(doc.getString("email"));
        s.setAddress(doc.getString("address"));
        s.setCourse(doc.getString("course"));
        s.setSemester(doc.getString("semester"));

        String admStr = doc.getString("admissionDate");
        if (admStr != null && !admStr.isEmpty()) {
            try { s.setAdmissionDate(Date.valueOf(admStr)); } catch (Exception ignored) {}
        }

        s.setUsername(doc.getString("username"));
        s.setPassword(doc.getString("password"));
        s.setPhoto(doc.getString("photo"));
        s.setStatus(doc.getString("status") != null ? doc.getString("status") : "Active");

        java.util.Date createdAt = doc.getDate("createdAt");
        if (createdAt != null) {
            s.setCreatedAt(new Timestamp(createdAt.getTime()));
        }

        return s;
    }
}
