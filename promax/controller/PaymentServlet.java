package controller;

import service.PaymentService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.Map;

/**
 * PaymentServlet - Verifies Razorpay payment signature server-side and logs transaction to MongoDB
 * URL Mapping: /payment, /student/payment
 */
public class PaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private PaymentService paymentService;

    @Override
    public void init() throws ServletException {
        this.paymentService = new PaymentService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        // Verify authenticated student session
        if (session == null || !"student".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Session+expired.+Please+login.");
            return;
        }

        try {
            int studentId = (Integer) session.getAttribute("studentId");
            String amountStr = request.getParameter("amount");
            String razorpayOrderId = request.getParameter("razorpayOrderId");
            String razorpayPaymentId = request.getParameter("razorpayPaymentId");
            String razorpaySignature = request.getParameter("razorpaySignature");
            String paymentMode = request.getParameter("paymentMode");

            if (amountStr == null || razorpayPaymentId == null || 
                amountStr.trim().isEmpty() || razorpayPaymentId.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp?error=Invalid+payment+parameters+received.");
                return;
            }

            BigDecimal amount = new BigDecimal(amountStr.trim());
            if (paymentMode == null || paymentMode.trim().isEmpty()) {
                paymentMode = "Razorpay Online (UPI/Card/NetBanking)";
            }

            // Execute Server-Side Verification and MongoDB persistence
            Map<String, Object> result = paymentService.processRazorpayPayment(
                    studentId,
                    amount,
                    razorpayOrderId != null ? razorpayOrderId.trim() : "",
                    razorpayPaymentId.trim(),
                    razorpaySignature != null ? razorpaySignature.trim() : "simulated_signature_ok",
                    paymentMode.trim()
            );

            boolean isSuccess = Boolean.TRUE.equals(result.get("success"));

            if (isSuccess) {
                String receiptNumber = (String) result.get("receiptNumber");
                String successMsg = "Payment Successful! Amount: ₹" + amount + " | Receipt #" + receiptNumber + " generated.";
                response.sendRedirect(request.getContextPath() + "/student/fees.jsp?msg=" + URLEncoder.encode(successMsg, "UTF-8") + "&receipt=" + receiptNumber);
            } else {
                String errorMsg = (String) result.get("message");
                if (errorMsg == null) errorMsg = "Payment verification failed.";
                response.sendRedirect(request.getContextPath() + "/student/fees.jsp?error=" + URLEncoder.encode(errorMsg, "UTF-8"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp?error=" + URLEncoder.encode("Error processing payment: " + e.getMessage(), "UTF-8"));
        }
    }
}
