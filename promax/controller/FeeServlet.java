package controller;

import dao.FeeDAO;
import dao.FoodPriceDAO;
import dao.StudentDAO;
import model.Fee;
import model.Student;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

public class FeeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private FeeDAO feeDAO;
    private StudentDAO studentDAO;
    private FoodPriceDAO foodPriceDAO;

    @Override
    public void init() throws ServletException {
        feeDAO = new FeeDAO();
        studentDAO = new StudentDAO();
        foodPriceDAO = new FoodPriceDAO();
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
            // Student viewing their own fees
            int studentId = (Integer) session.getAttribute("studentId");
            List<Fee> myFees = feeDAO.getFeesByStudentId(studentId);
            request.setAttribute("feeList", myFees);
            request.getRequestDispatcher("/student/fees.jsp").forward(request, response);
            return;
        }

        // Admin workflows
        if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response);
            return;
        }

        List<Fee> fees;
        if ("pending".equalsIgnoreCase(action)) {
            fees = feeDAO.getPendingFees();
            request.setAttribute("filterType", "pending");
        } else {
            fees = feeDAO.getAllFees();
            request.setAttribute("filterType", "all");
        }

        List<Student> students = studentDAO.getActiveStudents();
        request.setAttribute("feeList", fees);
        request.setAttribute("studentList", students);
        request.setAttribute("vegPrice", foodPriceDAO.getVegPrice());
        request.setAttribute("nonVegPrice", foodPriceDAO.getNonVegPrice());
        request.getRequestDispatcher("/admin/fees.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        if ("generate".equalsIgnoreCase(action) || "add".equalsIgnoreCase(action)) {
            handleGenerateFee(request, response);
        } else if ("recordPayment".equalsIgnoreCase(action)) {
            handleRecordOfflinePayment(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/fee?action=list");
        }
    }

    /**
     * Admin Fee Generation with configured food prices and component breakdown
     */
    private void handleGenerateFee(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String studentIdStr = request.getParameter("studentId");
            String hostelFeeStr = request.getParameter("hostelFee");
            String foodType = request.getParameter("foodType");
            String otherChargesStr = request.getParameter("otherCharges");
            String paidAmountStr = request.getParameter("paidAmount");
            String feePeriod = request.getParameter("feePeriod");
            String paymentDateStr = request.getParameter("paymentDate");
            String paymentMode = request.getParameter("paymentMode");

            if (studentIdStr == null || studentIdStr.trim().isEmpty() ||
                hostelFeeStr == null || hostelFeeStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=Student+and+Hostel+Fee+are+required.");
                return;
            }

            int studentId = Integer.parseInt(studentIdStr.trim());
            Student s = studentDAO.getStudentById(studentId);
            if (s == null) {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=Selected+student+does+not+exist.");
                return;
            }

            BigDecimal hostelFee = new BigDecimal(hostelFeeStr.trim());
            if (hostelFee.compareTo(BigDecimal.ZERO) < 0) {
                hostelFee = BigDecimal.ZERO;
            }

            if (foodType == null || foodType.trim().isEmpty()) {
                foodType = "No Food";
            }
            foodType = foodType.trim();

            // Fetch current configured food price from Admin Food Settings
            BigDecimal foodAmount = foodPriceDAO.getPriceByType(foodType);

            BigDecimal otherCharges = BigDecimal.ZERO;
            if (otherChargesStr != null && !otherChargesStr.trim().isEmpty()) {
                try {
                    otherCharges = new BigDecimal(otherChargesStr.trim());
                    if (otherCharges.compareTo(BigDecimal.ZERO) < 0) otherCharges = BigDecimal.ZERO;
                } catch (Exception ignored) {}
            }

            BigDecimal paidAmount = BigDecimal.ZERO;
            if (paidAmountStr != null && !paidAmountStr.trim().isEmpty()) {
                try {
                    paidAmount = new BigDecimal(paidAmountStr.trim());
                    if (paidAmount.compareTo(BigDecimal.ZERO) < 0) paidAmount = BigDecimal.ZERO;
                } catch (Exception ignored) {}
            }

            BigDecimal totalFee = hostelFee.add(foodAmount).add(otherCharges);
            if (paidAmount.compareTo(totalFee) > 0) {
                paidAmount = totalFee; // Prevent overpayment at creation
            }

            Date paymentDate = (paymentDateStr != null && !paymentDateStr.trim().isEmpty()) 
                    ? Date.valueOf(paymentDateStr.trim()) 
                    : new Date(System.currentTimeMillis());

            Fee fee = new Fee();
            fee.setStudentId(studentId);
            fee.setHostelFee(hostelFee);
            fee.setFoodType(foodType);
            fee.setFoodAmount(foodAmount);
            fee.setOtherCharges(otherCharges);
            fee.setTotalFee(totalFee);
            fee.setPaidAmount(paidAmount);
            fee.setFeePeriod(feePeriod != null && !feePeriod.trim().isEmpty() ? feePeriod.trim() : (s.getSemester() != null ? s.getSemester() : "Current Term"));
            fee.setPaymentDate(paymentDate);
            fee.setPaymentMode(paymentMode != null && !paymentMode.trim().isEmpty() ? paymentMode.trim() : "Cash");

            boolean ok = feeDAO.addFee(fee);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&msg=Fee+invoice+generated+successfully+for+" + s.getName().replace(" ", "+") + "+(Total:+Rs.+" + totalFee + ")");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=Failed+to+generate+fee+invoice.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=" + e.getMessage());
        }
    }

    /**
     * Admin recording manual offline payment for an existing fee
     */
    private void handleRecordOfflinePayment(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("studentId"));
            BigDecimal amount = new BigDecimal(request.getParameter("amount"));
            String paymentMode = request.getParameter("paymentMode");

            String receipt = feeDAO.recordOnlinePayment(studentId, amount, "OFFLINE_MANUAL", null, paymentMode != null ? paymentMode : "Cash");
            if (receipt != null) {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&msg=Offline+payment+of+Rs.+" + amount + "+recorded+successfully!+Receipt:+" + receipt);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=Could+not+record+payment.+Ensure+fee+has+been+generated+for+student.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=" + e.getMessage());
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int feeId = Integer.parseInt(request.getParameter("id"));
            boolean ok = feeDAO.deleteFee(feeId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&msg=Fee+record+deleted+successfully.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=Failed+to+delete+fee+record.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/fee?action=list&error=" + e.getMessage());
        }
    }
}
