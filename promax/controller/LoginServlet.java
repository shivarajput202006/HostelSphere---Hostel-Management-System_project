package controller;

import dao.AdminDAO;
import dao.StudentDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Admin;
import model.Student;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AdminDAO adminDAO;
    private StudentDAO studentDAO;

    @Override
    public void init() throws ServletException {
        adminDAO = new AdminDAO();
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String userType = request.getParameter("userType"); // "admin" or "student"
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (userType == null || username == null || password == null ||
            username.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Please+enter+both+username+and+password");
            return;
        }

        username = username.trim();
        password = password.trim();

        if ("admin".equalsIgnoreCase(userType)) {
            Admin admin = adminDAO.authenticate(username, password);
            if (admin != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("userRole", "admin");
                session.setAttribute("adminObj", admin);
                session.setAttribute("adminId", admin.getAdminId());
                session.setAttribute("userName", admin.getName());
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/index.jsp?tab=admin&error=Invalid+Administrator+Credentials");
            }
        } else if ("student".equalsIgnoreCase(userType)) {
            Student student = studentDAO.authenticate(username, password);
            if (student != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("userRole", "student");
                session.setAttribute("studentObj", student);
                session.setAttribute("studentId", student.getStudentId());
                session.setAttribute("userName", student.getName());
                response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/index.jsp?tab=student&error=Invalid+Student+Credentials");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Invalid+User+Role");
        }
    }
}
