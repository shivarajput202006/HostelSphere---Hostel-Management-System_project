package controller;

import dao.ComplaintDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Complaint;

public class ComplaintServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private ComplaintDAO complaintDAO;

    @Override
    public void init() throws ServletException {
        complaintDAO = new ComplaintDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Please+login+to+continue.");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        if (action == null) action = "list";

        if ("student".equalsIgnoreCase(role)) {
            int studentId = (Integer) session.getAttribute("studentId");
            List<Complaint> complaints = complaintDAO.getComplaintsByStudent(studentId);
            request.setAttribute("complaintList", complaints);
            request.getRequestDispatcher("/student/complaints.jsp").forward(request, response);
            return;
        }

        // Admin workflows
        if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response);
            return;
        }

        String category = request.getParameter("category");
        String course = request.getParameter("course");
        String status = request.getParameter("status");

        List<Complaint> complaints;
        if ((category != null && !category.isEmpty()) || 
            (course != null && !course.isEmpty()) || 
            (status != null && !status.isEmpty())) {
            complaints = complaintDAO.filterComplaints(category, course, status);
        } else {
            complaints = complaintDAO.getAllComplaints();
        }

        request.setAttribute("complaintList", complaints);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("selectedCourse", course);
        request.setAttribute("selectedStatus", status);
        request.getRequestDispatcher("/admin/complaints.jsp").forward(request, response);
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

        if ("student".equalsIgnoreCase(role)) {
            // Student submitting a new complaint
            handleSubmitComplaint(request, response, (Integer) session.getAttribute("studentId"));
        } else if ("admin".equalsIgnoreCase(role)) {
            // Admin responding/updating status
            if ("respond".equalsIgnoreCase(action)) {
                handleAdminResponse(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/complaint?action=list");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    private void handleSubmitComplaint(HttpServletRequest request, HttpServletResponse response, int studentId) 
            throws IOException {
        try {
            String category = request.getParameter("category");
            String subject = request.getParameter("subject");
            String description = request.getParameter("description");

            if (category == null || subject == null || description == null ||
                category.trim().isEmpty() || subject.trim().isEmpty() || description.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/complaint?action=list&error=All+complaint+fields+are+required.");
                return;
            }

            Complaint c = new Complaint();
            c.setStudentId(studentId);
            c.setCategory(category.trim());
            c.setSubject(subject.trim());
            c.setDescription(description.trim());

            boolean ok = complaintDAO.submitComplaint(c);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/complaint?action=list&msg=Complaint+submitted+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/complaint?action=list&error=Failed+to+submit+complaint.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/complaint?action=list&error=" + e.getMessage());
        }
    }

    private void handleAdminResponse(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int complaintId = Integer.parseInt(request.getParameter("complaintId"));
            String status = request.getParameter("status");
            String adminResponse = request.getParameter("adminResponse");

            boolean ok = complaintDAO.updateResponseAndStatus(complaintId, status, adminResponse);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/complaint?action=list&msg=Complaint+updated+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/complaint?action=list&error=Failed+to+update+complaint.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/complaint?action=list&error=" + e.getMessage());
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int complaintId = Integer.parseInt(request.getParameter("id"));
            boolean ok = complaintDAO.deleteComplaint(complaintId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/complaint?action=list&msg=Complaint+deleted+successfully.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/complaint?action=list&error=Failed+to+delete+complaint.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/complaint?action=list&error=" + e.getMessage());
        }
    }
}
