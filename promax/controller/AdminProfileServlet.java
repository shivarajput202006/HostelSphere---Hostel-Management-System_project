package controller;

import dao.AdminDAO;
import model.Admin;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AdminProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AdminDAO adminDAO;

    @Override
    public void init() throws ServletException {
        adminDAO = new AdminDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.+Admin+login+required.");
            return;
        }

        int adminId = (Integer) session.getAttribute("adminId");
        Admin admin = adminDAO.getAdminById(adminId);
        request.setAttribute("admin", admin);
        request.getRequestDispatcher("/admin/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.");
            return;
        }

        try {
            int adminId = (Integer) session.getAttribute("adminId");
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String mobile = request.getParameter("mobile");
            String address = request.getParameter("address");
            String password = request.getParameter("password");

            if (name == null || name.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/profile?error=Name+cannot+be+empty.");
                return;
            }

            Admin admin = new Admin();
            admin.setAdminId(adminId);
            admin.setName(name.trim());
            admin.setEmail(email != null ? email.trim() : "");
            admin.setMobile(mobile != null ? mobile.trim() : "");
            admin.setAddress(address != null ? address.trim() : "");
            if (password != null && !password.trim().isEmpty()) {
                admin.setPassword(password.trim());
            }

            boolean ok = adminDAO.updateAdminProfile(admin);
            if (ok) {
                session.setAttribute("userName", admin.getName());
                response.sendRedirect(request.getContextPath() + "/admin/profile?msg=Admin+profile+updated+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/profile?error=Failed+to+update+admin+profile.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/profile?error=" + e.getMessage());
        }
    }
}
