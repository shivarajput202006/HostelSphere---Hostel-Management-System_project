package controller;

import dao.FeeDAO;
import dao.StudentDAO;
import model.Fee;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ReceiptServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private FeeDAO feeDAO;
    private StudentDAO studentDAO;

    @Override
    public void init() throws ServletException {
        feeDAO = new FeeDAO();
        studentDAO = new StudentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Please+login+to+view+receipt.");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        String receiptNumber = request.getParameter("receipt");
        String feeIdStr = request.getParameter("id");

        Fee fee = null;
        if (receiptNumber != null && !receiptNumber.trim().isEmpty()) {
            fee = feeDAO.getFeeByReceiptNumber(receiptNumber.trim());
        } else if (feeIdStr != null && !feeIdStr.trim().isEmpty()) {
            try {
                fee = feeDAO.getFeeById(Integer.parseInt(feeIdStr.trim()));
            } catch (Exception ignored) {}
        }

        if (fee == null) {
            if ("student".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp?error=Receipt+not+found.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=Receipt+not+found.");
            }
            return;
        }

        // Authorization check: If student, verify this receipt strictly belongs to their studentId
        if ("student".equalsIgnoreCase(role)) {
            int currentStudentId = (Integer) session.getAttribute("studentId");
            if (fee.getStudentId() != currentStudentId) {
                response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp?error=Access+denied.+You+cannot+access+another+student%27s+receipt.");
                return;
            }
        }

        Student student = studentDAO.getStudentById(fee.getStudentId());
        request.setAttribute("fee", fee);
        request.setAttribute("student", student);

        // Render printable receipt page
        request.getRequestDispatcher("/admin/fee-receipt.jsp").forward(request, response);
    }
}
