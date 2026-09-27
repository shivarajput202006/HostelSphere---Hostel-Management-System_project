<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Fee" %>
<%@ page import="model.Student" %>

<%
    Fee fee = (Fee) request.getAttribute("fee");
    Student student = (Student) request.getAttribute("student");
    if (fee == null || student == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fee Receipt - <%= fee.getReceiptNumber() %></title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome 6 -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="<%= request.getContextPath() %>/css/style.css" rel="stylesheet">
    <style>
        body {
            background-color: #f1f5f9;
            padding: 30px 15px;
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: #1e293b;
        }
        .receipt-card {
            max-width: 820px;
            margin: 0 auto;
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
            border: 1px solid #e2e8f0;
            padding: 40px;
        }
        .receipt-watermark {
            position: absolute;
            top: 52%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-25deg);
            font-size: 4.8rem;
            color: rgba(16, 185, 129, 0.05);
            font-weight: 900;
            text-transform: uppercase;
            pointer-events: none;
            user-select: none;
            white-space: nowrap;
            letter-spacing: 4px;
        }
        .meta-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px 20px;
        }
        .table-receipt th {
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        @media print {
            body { 
                background: #ffffff !important; 
                padding: 0 !important; 
                margin: 0 !important;
            }
            .no-print, nav, .sidebar, .navbar, .btn { 
                display: none !important; 
            }
            .receipt-card { 
                box-shadow: none !important; 
                border: 1px solid #cbd5e1 !important;
                border-radius: 0 !important;
                padding: 25px !important;
                max-width: 100% !important;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <!-- Action Bar -->
    <div class="d-flex justify-content-between align-items-center mb-4 no-print" style="max-width: 820px; margin: 0 auto;">
        <button type="button" class="btn btn-outline-secondary px-3 py-2 fw-semibold" onclick="if(window.history.length > 1){ window.history.back(); } else { window.close(); }">
            <i class="fa-solid fa-arrow-left me-1"></i> Back
        </button>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-primary px-4 py-2 fw-bold shadow-sm" onclick="window.print();">
                <i class="fa-solid fa-print me-2"></i> Print Receipt
            </button>
        </div>
    </div>

    <!-- Printable Receipt Container -->
    <div class="receipt-card position-relative" id="printable-receipt">
        <div class="receipt-watermark">
            <%= fee.getStatus() != null ? fee.getStatus().toUpperCase() : "OFFICIAL RECEIPT" %>
        </div>

        <!-- Institute Header -->
        <div class="row align-items-center border-bottom pb-4 mb-4">
            <div class="col-8">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-3 bg-primary text-white d-flex align-items-center justify-content-center shadow-sm" style="width: 52px; height: 52px;">
                        <i class="fa-solid fa-hotel fa-xl"></i>
                    </div>
                    <div>
                        <h4 class="fw-extrabold mb-1 text-dark">HOSTEL RESIDENCE SPHERE</h4>
                        <div class="text-muted small">Central University Campus • Student Affairs Hostel Administration</div>
                        <div class="text-muted small">Contact: +91 98765 43210 • Email: hostel-admin@university.edu</div>
                    </div>
                </div>
            </div>
            <div class="col-4 text-end">
                <span class="badge bg-primary text-white px-3 py-2 fs-6 fw-bold">OFFICIAL RECEIPT</span>
                <div class="text-muted mt-2 small">Date: <strong class="text-dark"><%= fee.getPaymentDate() %></strong></div>
                <div class="text-muted small">Period: <strong class="text-dark"><%= fee.getFeePeriod() != null ? fee.getFeePeriod() : "Current Term" %></strong></div>
            </div>
        </div>

        <!-- Student & Receipt Info Box -->
        <div class="row g-3 mb-4 meta-box">
            <div class="col-sm-6">
                <small class="text-muted d-block text-uppercase fw-bold mb-1" style="font-size: 0.72rem; letter-spacing: 0.5px;">Student Information</small>
                <div class="fw-bold fs-5 text-dark mb-1"><%= student.getName() %></div>
                <div class="small text-secondary mb-1">
                    <span class="text-muted">Student ID:</span> <strong>#<%= student.getStudentId() %></strong> | 
                    <span class="text-muted">Course:</span> <strong><%= student.getCourse() %></strong> (<%= student.getSemester() %>)
                </div>
                <div class="small text-secondary">
                    <span class="text-muted">Contact:</span> <%= student.getMobile() %> | <%= student.getEmail() != null ? student.getEmail() : "" %>
                </div>
            </div>
            <div class="col-sm-6 text-sm-end">
                <small class="text-muted d-block text-uppercase fw-bold mb-1" style="font-size: 0.72rem; letter-spacing: 0.5px;">Receipt & Allocation Details</small>
                <div class="fw-bold fs-5 text-primary mb-1"><code><%= fee.getReceiptNumber() %></code></div>
                <div class="small text-secondary mb-1">
                    <span class="text-muted">Allocated Room:</span> 
                    <strong><%= fee.getRoomNumber() != null ? "Room " + fee.getRoomNumber() : "Room " + (student.getRoomNumber() != null ? student.getRoomNumber() : "N/A") %></strong>
                </div>
                <div class="small text-secondary">
                    <span class="text-muted">Payment Mode:</span> <strong><%= fee.getPaymentMode() != null ? fee.getPaymentMode() : "Online / Cash" %></strong>
                </div>
                <% if (fee.getRazorpayPaymentId() != null && !fee.getRazorpayPaymentId().isEmpty()) { %>
                    <div class="small text-muted mt-1">Transaction Ref: <code><%= fee.getRazorpayPaymentId() %></code></div>
                <% } %>
            </div>
        </div>

        <!-- Fee Details Breakdown Table -->
        <div class="table-responsive mb-4">
            <table class="table table-bordered table-receipt mb-0 align-middle">
                <thead>
                    <tr>
                        <th style="width: 55%;">Fee Particulars / Description</th>
                        <th class="text-center" style="width: 20%;">Plan / Type</th>
                        <th class="text-end" style="width: 25%;">Amount (INR)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <div class="fw-bold text-dark">Hostel Accommodation & Amenities</div>
                            <small class="text-muted">Room rent, electricity, water, wi-fi & maintenance charges</small>
                        </td>
                        <td class="text-center">
                            <span class="badge bg-light text-dark border">Standard Term</span>
                        </td>
                        <td class="text-end fw-semibold">₹ <%= fee.getHostelFee() != null ? fee.getHostelFee() : fee.getTotalFee() %></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="fw-bold text-dark">Mess / Food Plan Tariff</div>
                            <small class="text-muted">Mess dining membership charges for the semester</small>
                        </td>
                        <td class="text-center">
                            <% String fType = fee.getFoodType() != null ? fee.getFoodType() : "Veg"; %>
                            <span class="badge <%= "Non-Veg".equalsIgnoreCase(fType) ? "bg-danger-subtle text-danger" : ("Veg".equalsIgnoreCase(fType) ? "bg-success-subtle text-success" : "bg-secondary-subtle text-secondary") %> px-2 py-1">
                                <%= fType %>
                            </span>
                        </td>
                        <td class="text-end fw-semibold">₹ <%= fee.getFoodAmount() != null ? fee.getFoodAmount() : "0.00" %></td>
                    </tr>
                    <% if (fee.getOtherCharges() != null && fee.getOtherCharges().compareTo(java.math.BigDecimal.ZERO) > 0) { %>
                    <tr>
                        <td>
                            <div class="fw-bold text-dark">Other Institutional & Utility Charges</div>
                            <small class="text-muted">Caution deposit, laundry or administrative dues</small>
                        </td>
                        <td class="text-center"><span class="badge bg-light text-dark border">Additional</span></td>
                        <td class="text-end fw-semibold">₹ <%= fee.getOtherCharges() %></td>
                    </tr>
                    <% } %>

                    <!-- Summary Rows -->
                    <tr class="table-light">
                        <td colspan="2" class="text-end fw-bold text-dark">Total Fee Assessed:</td>
                        <td class="text-end fw-bold text-dark fs-6">₹ <%= fee.getTotalFee() %></td>
                    </tr>
                    <tr class="table-success bg-opacity-25">
                        <td colspan="2" class="text-end fw-bold text-success">
                            <i class="fa-solid fa-circle-check me-1"></i> Total Amount Paid:
                        </td>
                        <td class="text-end fw-bold text-success fs-6">₹ <%= fee.getPaidAmount() %></td>
                    </tr>
                    <tr class="<%= (fee.getDueAmount() != null && fee.getDueAmount().compareTo(java.math.BigDecimal.ZERO) > 0) ? "table-warning bg-opacity-25" : "table-light" %>">
                        <td colspan="2" class="text-end fw-bold <%= (fee.getDueAmount() != null && fee.getDueAmount().compareTo(java.math.BigDecimal.ZERO) > 0) ? "text-danger" : "text-muted" %>">
                            Outstanding Balance (Due Amount):
                        </td>
                        <td class="text-end fw-bold <%= (fee.getDueAmount() != null && fee.getDueAmount().compareTo(java.math.BigDecimal.ZERO) > 0) ? "text-danger" : "text-muted" %> fs-6">
                            ₹ <%= fee.getDueAmount() != null ? fee.getDueAmount() : "0.00" %>
                        </td>
                    </tr>
                    <tr class="table-light">
                        <td colspan="2" class="text-end fw-bold text-dark">Payment Status:</td>
                        <td class="text-end fw-bold">
                            <% 
                                String statusStr = fee.getStatus() != null ? fee.getStatus() : "Pending";
                                if ("Complete".equalsIgnoreCase(statusStr) || "Paid in Full".equalsIgnoreCase(statusStr)) { 
                            %>
                                <span class="badge bg-success px-3 py-1">Complete</span>
                            <% } else if ("Partially Paid".equalsIgnoreCase(statusStr)) { %>
                                <span class="badge bg-warning text-dark px-3 py-1">Partially Paid</span>
                            <% } else { %>
                                <span class="badge bg-danger px-3 py-1">Pending</span>
                            <% } %>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <!-- Footer / Signatures -->
        <div class="row pt-4 mt-4 border-top align-items-end">
            <div class="col-7">
                <small class="text-muted d-block lh-base">
                    • This is a computer-generated official payment receipt issued by the Hostel Administration.<br>
                    • Fees once paid are subject to institutional hostel refund guidelines.<br>
                    • For payment disputes or fee queries, please visit the Hostel Accounts Office.
                </small>
            </div>
            <div class="col-5 text-center">
                <div class="border-bottom border-dark pb-2 mb-1" style="margin-left: 30px;">
                    <span class="fw-bold" style="font-family: 'Brush Script MT', cursive, sans-serif; font-size: 1.3rem; color: #1e3a8a;">Hostel Warden</span>
                </div>
                <small class="text-muted fw-bold">Authorized Signatory & Seal</small>
            </div>
        </div>
    </div>
</div>

</body>
</html>
