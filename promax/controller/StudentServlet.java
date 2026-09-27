package controller;

import dao.AllocationDAO;
import dao.FeeDAO;
import dao.ComplaintDAO;
import dao.StudentDAO;
import model.Allocation;
import model.Fee;
import model.Complaint;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

public class StudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private StudentDAO studentDAO;
    private FeeDAO feeDAO;
    private AllocationDAO allocationDAO;
    private ComplaintDAO complaintDAO;

    @Override
    public void init() throws ServletException {
        studentDAO = new StudentDAO();
        feeDAO = new FeeDAO();
        allocationDAO = new AllocationDAO();
        complaintDAO = new ComplaintDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.+Please+login+to+continue.");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        if (action == null) action = "list";

        if ("student".equalsIgnoreCase(role)) {
            // Student viewing own profile
            int studentId = (Integer) session.getAttribute("studentId");
            Student s = studentDAO.getStudentById(studentId);
            request.setAttribute("student", s);
            request.getRequestDispatcher("/student/profile.jsp").forward(request, response);
            return;
        }

        // Admin actions
        switch (action) {
            case "delete":
                handleDelete(request, response);
                break;
            case "deactivate":
                handleDeactivate(request, response);
                break;
            case "reactivate":
                handleReactivate(request, response);
                break;
            case "view":
                handleView(request, response);
                break;
            case "edit":
                handleEdit(request, response);
                break;
            case "old":
                handleOldStudents(request, response);
                break;
            case "search":
                handleSearch(request, response);
                break;
            case "list":
            default:
                List<Student> students = studentDAO.getAllStudents();
                request.setAttribute("studentList", students);
                request.getRequestDispatcher("/admin/students.jsp").forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");

        // 1. Student self-profile edit workflow
        if ("student".equalsIgnoreCase(role)) {
            handleStudentSelfUpdate(request, response, session);
            return;
        }

        // 2. Admin student operations
        if (!"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.");
            return;
        }

        if ("add".equalsIgnoreCase(action)) {
            handleAdd(request, response);
        } else if ("update".equalsIgnoreCase(action) || "edit".equalsIgnoreCase(action)) {
            handleUpdate(request, response);
        } else if ("updateSelfProfile".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/admin/profile.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/student?action=list");
        }
    }

    /**
     * Handles student self-profile update with strict authorization & validation
     */
    private void handleStudentSelfUpdate(HttpServletRequest request, HttpServletResponse response, HttpSession session) 
            throws IOException {
        try {
            int sessionStudentId = (Integer) session.getAttribute("studentId");
            
            // Reject any attempt if a client submits an external studentId
            String reqIdStr = request.getParameter("studentId");
            if (reqIdStr != null && !reqIdStr.trim().isEmpty()) {
                try {
                    String cleanId = reqIdStr.trim().replace("#", "").replace("STU-", "").replace("stu-", "").trim();
                    int reqStudentId = Integer.parseInt(cleanId);
                    if (reqStudentId != sessionStudentId) {
                        response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=Unauthorized+profile+update+attempt+blocked.");
                        return;
                    }
                } catch (Exception ignored) {}
            }

            Student existing = studentDAO.getStudentById(sessionStudentId);
            if (existing == null) {
                response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=Student+record+not+found.");
                return;
            }

            String name = request.getParameter("name");
            String fatherName = request.getParameter("fatherName");
            String motherName = request.getParameter("motherName");
            String dobStr = request.getParameter("dob");
            String gender = request.getParameter("gender");
            String mobile = request.getParameter("mobile");
            String email = request.getParameter("email");
            String address = request.getParameter("address");
            String password = request.getParameter("password");

            // Validate non-empty required fields
            if (name == null || name.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=Name+cannot+be+empty.");
                return;
            }
            if (mobile == null || mobile.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=Mobile+number+is+required.");
                return;
            }
            if (email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=Email+address+is+required.");
                return;
            }

            Student updateObj = new Student();
            updateObj.setStudentId(sessionStudentId);
            updateObj.setName(name.trim());
            updateObj.setFatherName(fatherName != null ? fatherName.trim() : "");
            updateObj.setMotherName(motherName != null ? motherName.trim() : "");
            if (dobStr != null && !dobStr.trim().isEmpty()) {
                try { updateObj.setDob(Date.valueOf(dobStr.trim())); } catch (Exception ignored) {}
            }
            updateObj.setGender(gender != null ? gender.trim() : existing.getGender());
            updateObj.setMobile(mobile.trim());
            updateObj.setEmail(email.trim());
            updateObj.setAddress(address != null ? address.trim() : "");
            if (password != null && !password.trim().isEmpty()) {
                updateObj.setPassword(password.trim());
            }

            boolean ok = studentDAO.updateStudentPersonal(updateObj);
            if (ok) {
                session.setAttribute("userName", updateObj.getName());
                response.sendRedirect(request.getContextPath() + "/student/profile.jsp?msg=Profile+updated+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=Failed+to+save+profile+changes.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=" + e.getMessage());
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String name = request.getParameter("name");
            String fatherName = request.getParameter("fatherName");
            String motherName = request.getParameter("motherName");
            String dobStr = request.getParameter("dob");
            String gender = request.getParameter("gender");
            String mobile = request.getParameter("mobile");
            String email = request.getParameter("email");
            String address = request.getParameter("address");
            String course = request.getParameter("course");
            String semester = request.getParameter("semester");
            String admissionDateStr = request.getParameter("admissionDate");
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            // Validation of required fields
            if (name == null || username == null || password == null || course == null ||
                name.trim().isEmpty() || username.trim().isEmpty() || password.trim().isEmpty() || course.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/student-form.jsp?error=Required+fields+missing.+Please+fill+Name,+Course,+Username+and+Password.");
                return;
            }

            if (studentDAO.isUsernameTaken(username.trim(), 0)) {
                response.sendRedirect(request.getContextPath() + "/admin/student-form.jsp?error=Username+is+already+taken.+Please+choose+another.");
                return;
            }

            Student s = new Student();
            s.setName(name.trim());
            s.setFatherName(fatherName != null ? fatherName.trim() : "");
            s.setMotherName(motherName != null ? motherName.trim() : "");
            s.setDob(dobStr != null && !dobStr.isEmpty() ? Date.valueOf(dobStr) : new Date(System.currentTimeMillis()));
            s.setGender(gender != null ? gender.trim() : "Other");
            s.setMobile(mobile != null ? mobile.trim() : "");
            s.setEmail(email != null ? email.trim() : "");
            s.setAddress(address != null ? address.trim() : "");
            s.setCourse(course.trim());
            s.setSemester(semester != null ? semester.trim() : "Semester 1");
            s.setAdmissionDate(admissionDateStr != null && !admissionDateStr.isEmpty() ? Date.valueOf(admissionDateStr) : new Date(System.currentTimeMillis()));
            s.setUsername(username.trim());
            s.setPassword(password.trim());
            s.setPhoto("default_avatar.svg");
            s.setStatus("Active");

            boolean ok = studentDAO.addStudent(s);
            if (ok) {
                // Notice: Fee is NOT auto-generated upon registration
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&msg=Student+enrolled+successfully!+(Fee+has+not+been+generated)");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/student-form.jsp?error=Database+error+saving+student.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/student-form.jsp?error=" + e.getMessage());
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("studentId"));
            String name = request.getParameter("name");
            String fatherName = request.getParameter("fatherName");
            String motherName = request.getParameter("motherName");
            String dobStr = request.getParameter("dob");
            String gender = request.getParameter("gender");
            String mobile = request.getParameter("mobile");
            String email = request.getParameter("email");
            String address = request.getParameter("address");
            String course = request.getParameter("course");
            String semester = request.getParameter("semester");
            String admissionDateStr = request.getParameter("admissionDate");
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String status = request.getParameter("status");

            if (name == null || username == null || course == null ||
                name.trim().isEmpty() || username.trim().isEmpty() || course.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=edit&id=" + studentId + "&error=Required+fields+missing.");
                return;
            }

            if (studentDAO.isUsernameTaken(username.trim(), studentId)) {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=edit&id=" + studentId + "&error=Username+is+already+taken.");
                return;
            }

            Student s = new Student();
            s.setStudentId(studentId);
            s.setName(name.trim());
            s.setFatherName(fatherName != null ? fatherName.trim() : "");
            s.setMotherName(motherName != null ? motherName.trim() : "");
            s.setDob(dobStr != null && !dobStr.isEmpty() ? Date.valueOf(dobStr) : new Date(System.currentTimeMillis()));
            s.setGender(gender != null ? gender.trim() : "Other");
            s.setMobile(mobile != null ? mobile.trim() : "");
            s.setEmail(email != null ? email.trim() : "");
            s.setAddress(address != null ? address.trim() : "");
            s.setCourse(course.trim());
            s.setSemester(semester != null ? semester.trim() : "Semester 1");
            s.setAdmissionDate(admissionDateStr != null && !admissionDateStr.isEmpty() ? Date.valueOf(admissionDateStr) : new Date(System.currentTimeMillis()));
            s.setUsername(username.trim());
            s.setStatus((status != null && !status.trim().isEmpty()) ? status.trim() : "Active");
            if (password != null && !password.trim().isEmpty()) {
                s.setPassword(password.trim());
            }

            boolean ok = studentDAO.updateStudent(s);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&msg=Student+updated+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=edit&id=" + studentId + "&error=Failed+to+update+student.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=" + e.getMessage());
        }
    }

    private void handleDeactivate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("id"));
            boolean ok = studentDAO.deactivateStudent(studentId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&msg=Student+moved+to+Old/Inactive+Records+successfully.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=Unable+to+deactivate+student.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=" + e.getMessage());
        }
    }

    private void handleReactivate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("id"));
            boolean ok = studentDAO.reactivateStudent(studentId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=old&msg=Student+restored+and+reactivated+successfully.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=old&error=Unable+to+reactivate+student.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/student?action=old&error=" + e.getMessage());
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("id"));
            boolean ok = studentDAO.deleteStudent(studentId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&msg=Student+permanently+deleted.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=Unable+to+delete+student.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=" + e.getMessage());
        }
    }

    private void handleOldStudents(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Student> oldStudents = studentDAO.getOldStudents();
        request.setAttribute("studentList", oldStudents);
        request.setAttribute("isOldList", true);
        request.getRequestDispatcher("/admin/old-students.jsp").forward(request, response);
    }

    private void handleSearch(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String q = request.getParameter("q");
        String status = request.getParameter("status");
        List<Student> results = studentDAO.searchStudents(q, status);
        request.setAttribute("studentList", results);
        request.setAttribute("searchQuery", q);
        request.setAttribute("selectedStatus", status);
        request.getRequestDispatcher("/admin/students.jsp").forward(request, response);
    }

    private void handleView(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("id"));
            Student student = studentDAO.getStudentById(studentId);
            if (student != null) {
                Allocation allocation = allocationDAO.getActiveAllocationByStudent(studentId);
                List<Fee> fees = feeDAO.getFeesByStudentId(studentId);
                List<Complaint> complaints = complaintDAO.getComplaintsByStudent(studentId);

                request.setAttribute("student", student);
                request.setAttribute("allocation", allocation);
                request.setAttribute("fees", fees);
                request.setAttribute("complaints", complaints);
                request.getRequestDispatcher("/admin/student-profile.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=Student+not+found.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=" + e.getMessage());
        }
    }

    private void handleEdit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("id"));
            Student student = studentDAO.getStudentById(studentId);
            if (student != null) {
                request.setAttribute("student", student);
                request.getRequestDispatcher("/admin/student-form.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=Student+not+found.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/student?action=list&error=" + e.getMessage());
        }
    }
}
