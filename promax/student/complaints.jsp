<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="model.Complaint" %>

<%
    int studentId = (Integer) session.getAttribute("studentId");
    ComplaintDAO dao = new ComplaintDAO();
    List<Complaint> myComplaints = dao.getComplaintsByStudent(studentId);
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Hostel Grievance & Complaint Desk</h3>
            <p class="text-muted mb-0">Submit maintenance issues, track investigation status, and view warden responses.</p>
        </div>
    </div>

    <div class="row g-4">
        <!-- 1. Submit Complaint Form (Left Column) -->
        <div class="col-lg-5">
            <div class="card h-100">
                <div class="card-header bg-light">
                    <span class="fw-bold"><i class="fa-solid fa-pen-to-square me-2 text-primary"></i>Submit New Complaint</span>
                </div>
                <div class="card-body p-4">
                    <form action="<%= request.getContextPath() %>/complaint" method="post">
                        <input type="hidden" name="action" value="submit">

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Complaint Category <span class="text-danger">*</span></label>
                            <select name="category" class="form-select" required>
                                <option value="">-- Select Category --</option>
                                <option value="Room Problem">Room Problem</option>
                                <option value="Electricity Problem">Electricity Problem</option>
                                <option value="Water Problem">Water Problem</option>
                                <option value="Food/Mess Problem">Food / Mess Problem</option>
                                <option value="Cleaning Problem">Cleaning / Housekeeping</option>
                                <option value="Maintenance Problem">Maintenance / Carpentry / Plumbing</option>
                                <option value="Other">Other Issues</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">Subject / Brief Summary <span class="text-danger">*</span></label>
                            <input type="text" name="subject" class="form-control" placeholder="e.g. Ceiling fan not rotating" required>
                        </div>

                        <div class="mb-4">
                            <label class="form-label fw-semibold">Detailed Description <span class="text-danger">*</span></label>
                            <textarea name="description" class="form-control" rows="4" 
                                      placeholder="Please explain the issue in detail with location/room context..." required></textarea>
                            <small class="text-muted">Note: Once submitted, complaints cannot be edited by the student.</small>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">
                            <i class="fa-solid fa-paper-plane me-2"></i> File Complaint
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- 2. My Complaints Tracker (Right Column) -->
        <div class="col-lg-7">
            <div class="card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <span class="fw-bold"><i class="fa-solid fa-list-check me-2 text-primary"></i>My Submitted Complaints</span>
                    <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Total: <%= myComplaints != null ? myComplaints.size() : 0 %></span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Ticket #</th>
                                    <th>Category & Subject</th>
                                    <th>Logged On</th>
                                    <th>Status</th>
                                    <th>Warden Feedback</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myComplaints != null && !myComplaints.isEmpty()) { 
                                    for (Complaint c : myComplaints) { 
                                        String st = c.getStatus();
                                        String badgeClass = "badge-pending";
                                        if ("In Progress".equalsIgnoreCase(st)) badgeClass = "badge-in-progress";
                                        else if ("Resolved".equalsIgnoreCase(st)) badgeClass = "badge-resolved";
                                        else if ("Rejected".equalsIgnoreCase(st)) badgeClass = "badge-rejected";
                                %>
                                    <tr>
                                        <td><strong>#CMP-<%= c.getComplaintId() %></strong></td>
                                        <td>
                                            <span class="badge bg-light text-dark border mb-1" style="font-size: 0.75rem;"><%= c.getCategory() %></span>
                                            <div class="fw-bold text-dark"><%= c.getSubject() %></div>
                                            <small class="text-muted"><%= c.getDescription() %></small>
                                        </td>
                                        <td><small class="text-muted"><%= c.getComplaintDate() %></small></td>
                                        <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                                        <td>
                                            <% if (c.getAdminResponse() != null && !c.getAdminResponse().trim().isEmpty()) { %>
                                                <div class="p-2 bg-success bg-opacity-10 rounded border border-success border-opacity-25" style="font-size: 0.85rem;">
                                                    <div class="text-success fw-bold"><i class="fa-solid fa-reply me-1"></i> Warden Response:</div>
                                                    <div class="text-dark"><%= c.getAdminResponse() %></div>
                                                    <% if (c.getResolvedDate() != null) { %>
                                                        <small class="text-muted d-block mt-1">Resolved: <%= c.getResolvedDate() %></small>
                                                    <% } %>
                                                </div>
                                            <% } else { %>
                                                <span class="text-muted small"><i class="fa-regular fa-clock me-1"></i> Pending Warden Review</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr>
                                        <td colspan="5" class="text-center py-5 text-muted">
                                            <i class="fa-regular fa-folder-open fa-2x mb-2 d-block"></i>
                                            You haven't filed any complaints yet. Use the form on the left to report any issue.
                                        </td>
                                    </tr>
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
