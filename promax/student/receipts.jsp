<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.FeeDAO" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="model.Fee" %>
<%@ page import="model.Student" %>

<%
    int studentId = (Integer) session.getAttribute("studentId");
    FeeDAO dao = new FeeDAO();
    StudentDAO studentDAO = new StudentDAO();
    Student student = studentDAO.getStudentById(studentId);
    List<Fee> feeList = dao.getFeesByStudentId(studentId);
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">My Fee Receipts & Invoices</h3>
            <p class="text-muted mb-0">Official hostel fee receipts and payment transaction slips for verification.</p>
        </div>
    </div>

    <!-- Receipts Card -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
            <span class="fw-bold"><i class="fa-solid fa-receipt me-2 text-primary"></i>Issued Receipts Ledger</span>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Total Receipts: <%= feeList != null ? feeList.size() : 0 %></span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Receipt Number</th>
                            <th>Term / Period</th>
                            <th>Food Plan</th>
                            <th>Amount Paid</th>
                            <th>Balance Due</th>
                            <th>Date Issued</th>
                            <th>Mode</th>
                            <th class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (feeList != null && !feeList.isEmpty()) { 
                            for (Fee f : feeList) { 
                                boolean hasDue = (f.getDueAmount() != null && f.getDueAmount().compareTo(java.math.BigDecimal.ZERO) > 0);
                        %>
                            <tr>
                                <td>
                                    <span class="fw-bold text-primary"><code><%= f.getReceiptNumber() %></code></span>
                                </td>
                                <td><strong><%= f.getFeePeriod() != null ? f.getFeePeriod() : "Semester Fee" %></strong></td>
                                <td>
                                    <span class="badge bg-light text-dark border">
                                        <i class="fa-solid fa-utensils me-1 text-primary"></i><%= f.getFoodType() != null ? f.getFoodType() : "No Food" %>
                                    </span>
                                </td>
                                <td><span class="text-success fw-bold">₹ <%= f.getPaidAmount() %></span></td>
                                <td>
                                    <% if (hasDue) { %>
                                        <span class="badge bg-warning-subtle text-warning-emphasis">₹ <%= f.getDueAmount() %> Due</span>
                                    <% } else { %>
                                        <span class="badge bg-success-subtle text-success"><i class="fa-solid fa-check me-1"></i> Paid in Full</span>
                                    <% } %>
                                </td>
                                <td><%= f.getPaymentDate() %></td>
                                <td><span class="badge bg-light text-dark border"><%= f.getPaymentMode() %></span></td>
                                <td class="text-center">
                                    <a href="<%= request.getContextPath() %>/receipt?receipt=<%= f.getReceiptNumber() %>" 
                                       target="_blank" class="btn btn-sm btn-primary shadow-sm">
                                        <i class="fa-solid fa-print me-1"></i> View & Print Receipt
                                    </a>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="fa-solid fa-file-invoice fa-3x mb-3 text-secondary opacity-50 d-block"></i>
                                    <h5 class="fw-bold text-dark">No Receipts Found</h5>
                                    <p class="mb-0">You currently have no generated fee receipts on file.</p>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
