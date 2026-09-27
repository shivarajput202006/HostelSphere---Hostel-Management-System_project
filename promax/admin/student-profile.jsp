<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Student" %>
<%@ page import="model.Allocation" %>
<%@ page import="model.Fee" %>
<%@ page import="model.Complaint" %>

<%
    Student s = (Student) request.getAttribute("student");
    Allocation allocation = (Allocation) request.getAttribute("allocation");
    List<Fee> fees = (List<Fee>) request.getAttribute("fees");
    List<Complaint> complaints = (List<Complaint>) request.getAttribute("complaints");

    if (s == null) {
        response.sendRedirect(request.getContextPath() + "/admin/student?action=list");
        return;
    }
    boolean isActive = !"Inactive".equalsIgnoreCase(s.getStatus());
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Student Profile & Dossier</h3>
            <p class="text-muted mb-0">Complete historical records, fee collections, and room history for <strong><%= s.getName() %></strong></p>
        </div>
        <div class="d-flex gap-2">
            <a href="<%= request.getContextPath() %>/admin/student?action=edit&id=<%= s.getStudentId() %>" class="btn btn-warning">
                <i class="fa-solid fa-pen-to-square me-2"></i> Edit Record
            </a>
            <% if (isActive) { %>
                <a href="<%= request.getContextPath() %>/admin/student?action=deactivate&id=<%= s.getStudentId() %>" class="btn btn-outline-secondary"
                   onclick="return confirm('Archive student to Old Students?');">
                    <i class="fa-solid fa-box-archive me-1"></i> Archive
                </a>
            <% } else { %>
                <a href="<%= request.getContextPath() %>/admin/student?action=reactivate&id=<%= s.getStudentId() %>" class="btn btn-outline-success"
                   onclick="return confirm('Reactivate student?');">
                    <i class="fa-solid fa-rotate-left me-1"></i> Reactivate
                </a>
            <% } %>
            <a href="<%= request.getContextPath() %>/admin/student?action=list" class="btn btn-outline-secondary">
                <i class="fa-solid fa-arrow-left me-1"></i> Back to Roster
            </a>
        </div>
    </div>

    <div class="row g-4">
        <!-- Profile Left Card -->
        <div class="col-lg-4">
            <div class="card text-center p-4 border-0 shadow-sm">
                <div class="mx-auto mb-3" style="width: 110px; height: 110px;">
                    <img src="<%= request.getContextPath() %>/assets/images/default_avatar.svg" 
                         alt="Avatar" class="rounded-circle shadow-sm" style="width: 100%; height: 100%;">
                </div>
                <h4 class="fw-bold mb-1 text-dark"><%= s.getName() %></h4>
                <p class="text-muted mb-2"><%= s.getCourse() %> • <%= s.getSemester() %></p>
                <div class="d-flex justify-content-center gap-2 mb-3">
                    <span class="badge bg-primary-subtle text-primary px-3 py-2">
                        ID: #STU-<%= s.getStudentId() %>
                    </span>
                    <% if (isActive) { %>
                        <span class="badge bg-success-subtle text-success px-3 py-2">Active</span>
                    <% } else { %>
                        <span class="badge bg-secondary-subtle text-secondary px-3 py-2">Old / Inactive</span>
                    <% } %>
                </div>

                <div class="border-top pt-3 text-start">
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted">Username</span>
                        <span class="fw-semibold"><code><%= s.getUsername() %></code></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted">Gender</span>
                        <span class="fw-semibold"><%= s.getGender() %></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted">Mobile</span>
                        <span class="fw-semibold"><%= s.getMobile() %></span>
                    </div>
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted">Email</span>
                        <span class="fw-semibold text-break"><%= s.getEmail() %></span>
                    </div>
                </div>
            </div>

            <!-- Current Room Status Card -->
            <div class="card mt-3 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-bed me-2 text-primary"></i>Room Residency Status</span>
                </div>
                <div class="card-body">
                    <% if (s.getRoomNumber() != null) { %>
                        <div class="alert alert-success d-flex align-items-center gap-3 mb-0">
                            <i class="fa-solid fa-circle-check fa-2x text-success"></i>
                            <div>
                                <h6 class="mb-0 fw-bold">Allocated: Room <%= s.getRoomNumber() %></h6>
                                <small class="text-muted"><%= s.getRoomType() %> (Since <%= s.getAllocationDate() %>)</small>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="alert alert-warning d-flex align-items-center gap-3 mb-0">
                            <i class="fa-solid fa-triangle-exclamation fa-2x text-warning"></i>
                            <div>
                                <h6 class="mb-0 fw-bold">No Room Allocated</h6>
                                <small class="text-muted">Assign bed from Room Allocation module.</small>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Details Right Card -->
        <div class="col-lg-8">
            <!-- Personal & Academic Info Card -->
            <div class="card mb-4 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-user-circle me-2 text-primary"></i>Personal & Academic Information</span>
                </div>
                <div class="card-body p-4">
                    <div class="row g-3">
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Father's Name</small>
                            <span class="fw-bold"><%= s.getFatherName() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Mother's Name</small>
                            <span class="fw-bold"><%= s.getMotherName() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Date of Birth</small>
                            <span class="fw-bold"><%= s.getDob() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Hostel Admission Date</small>
                            <span class="fw-bold"><%= s.getAdmissionDate() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Degree / Course</small>
                            <span class="fw-bold text-primary"><%= s.getCourse() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block">Current Semester</small>
                            <span class="fw-bold"><%= s.getSemester() %></span>
                        </div>
                        <div class="col-12">
                            <small class="text-muted d-block">Permanent Address</small>
                            <span class="fw-semibold"><%= s.getAddress() %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Historical Fee & Payment Ledger -->
            <div class="card mb-4 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-receipt me-2 text-primary"></i>Fee & Payment History</span>
                    <span class="badge bg-primary-subtle text-primary px-3 py-1">Invoices: <%= fees != null ? fees.size() : 0 %></span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Receipt #</th>
                                    <th>Term</th>
                                    <th>Total Fee</th>
                                    <th>Paid</th>
                                    <th>Due</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (fees != null && !fees.isEmpty()) { 
                                    for (Fee f : fees) { %>
                                    <tr>
                                        <td><code><%= f.getReceiptNumber() %></code></td>
                                        <td><%= f.getFeePeriod() != null ? f.getFeePeriod() : "Term" %></td>
                                        <td>₹ <%= f.getTotalFee() %></td>
                                        <td class="text-success fw-bold">₹ <%= f.getPaidAmount() %></td>
                                        <td class="text-danger fw-bold">₹ <%= f.getDueAmount() %></td>
                                        <td><span class="badge bg-light text-dark border"><%= f.getPaymentStatus() %></span></td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/receipt?receipt=<%= f.getReceiptNumber() %>" 
                                               target="_blank" class="btn btn-xs btn-outline-primary py-1 px-2" style="font-size: 0.75rem;">
                                                <i class="fa-solid fa-print me-1"></i> Receipt
                                            </a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="7" class="text-center py-3 text-muted">No fee records generated for this student.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Complaints History -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-headset me-2 text-primary"></i>Complaints History</span>
                    <span class="badge bg-light text-dark">Tickets: <%= complaints != null ? complaints.size() : 0 %></span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Ticket</th>
                                    <th>Category</th>
                                    <th>Subject</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (complaints != null && !complaints.isEmpty()) { 
                                    for (Complaint c : complaints) { %>
                                    <tr>
                                        <td><strong>#CMP-<%= c.getComplaintId() %></strong></td>
                                        <td><%= c.getCategory() %></td>
                                        <td><%= c.getSubject() %></td>
                                        <td><span class="badge bg-light text-dark border"><%= c.getStatus() %></span></td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="4" class="text-center py-3 text-muted">No complaints logged by this student.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
