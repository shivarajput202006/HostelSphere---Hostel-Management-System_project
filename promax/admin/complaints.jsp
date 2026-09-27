<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="model.Complaint" %>

<%
    List<Complaint> complaintList = (List<Complaint>) request.getAttribute("complaintList");
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    String selectedCourse = (String) request.getAttribute("selectedCourse");
    String selectedStatus = (String) request.getAttribute("selectedStatus");

    if (complaintList == null) {
        ComplaintDAO dao = new ComplaintDAO();
        complaintList = dao.getAllComplaints();
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Complaint & Grievance Desk</h3>
            <p class="text-muted mb-0">Track student maintenance issues, update progress, and provide administrative responses.</p>
        </div>
    </div>

    <!-- Filter Bar Card -->
    <div class="card mb-4 bg-light">
        <div class="card-body py-3">
            <form action="<%= request.getContextPath() %>/admin/complaint" method="get" class="row g-2 align-items-center">
                <input type="hidden" name="action" value="list">
                <div class="col-md-3">
                    <label class="form-label small fw-semibold mb-1">Filter by Category:</label>
                    <select name="category" class="form-select form-select-sm">
                        <option value="">All Categories</option>
                        <option value="Room Problem" <%= "Room Problem".equals(selectedCategory) ? "selected" : "" %>>Room Problem</option>
                        <option value="Electricity Problem" <%= "Electricity Problem".equals(selectedCategory) ? "selected" : "" %>>Electricity Problem</option>
                        <option value="Water Problem" <%= "Water Problem".equals(selectedCategory) ? "selected" : "" %>>Water Problem</option>
                        <option value="Food/Mess Problem" <%= "Food/Mess Problem".equals(selectedCategory) ? "selected" : "" %>>Food/Mess Problem</option>
                        <option value="Cleaning Problem" <%= "Cleaning Problem".equals(selectedCategory) ? "selected" : "" %>>Cleaning Problem</option>
                        <option value="Maintenance Problem" <%= "Maintenance Problem".equals(selectedCategory) ? "selected" : "" %>>Maintenance Problem</option>
                        <option value="Other" <%= "Other".equals(selectedCategory) ? "selected" : "" %>>Other</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold mb-1">Filter by Course:</label>
                    <select name="course" class="form-select form-select-sm">
                        <option value="">All Courses</option>
                        <option value="BCA" <%= "BCA".equals(selectedCourse) ? "selected" : "" %>>BCA</option>
                        <option value="MCA" <%= "MCA".equals(selectedCourse) ? "selected" : "" %>>MCA</option>
                        <option value="B.Tech" <%= "B.Tech".equals(selectedCourse) ? "selected" : "" %>>B.Tech</option>
                        <option value="B.Sc IT" <%= "B.Sc IT".equals(selectedCourse) ? "selected" : "" %>>B.Sc IT</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold mb-1">Filter by Status:</label>
                    <select name="status" class="form-select form-select-sm">
                        <option value="">All Statuses</option>
                        <option value="Pending" <%= "Pending".equals(selectedStatus) ? "selected" : "" %>>Pending</option>
                        <option value="In Progress" <%= "In Progress".equals(selectedStatus) ? "selected" : "" %>>In Progress</option>
                        <option value="Resolved" <%= "Resolved".equals(selectedStatus) ? "selected" : "" %>>Resolved</option>
                        <option value="Rejected" <%= "Rejected".equals(selectedStatus) ? "selected" : "" %>>Rejected</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex align-items-end gap-2 pt-3">
                    <button type="submit" class="btn btn-sm btn-primary flex-grow-1">
                        <i class="fa-solid fa-filter me-1"></i> Apply Filter
                    </button>
                    <a href="<%= request.getContextPath() %>/admin/complaint?action=list" class="btn btn-sm btn-outline-secondary">Reset</a>
                </div>
            </form>
        </div>
    </div>

    <!-- Complaints Table Card -->
    <div class="card">
        <div class="card-header d-flex align-items-center justify-content-between">
            <span class="fw-bold"><i class="fa-solid fa-headset me-2 text-primary"></i>Logged Grievances</span>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Total: <%= complaintList.size() %></span>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover datatable align-middle">
                    <thead>
                        <tr>
                            <th>Ticket #</th>
                            <th>Student</th>
                            <th>Room</th>
                            <th>Category</th>
                            <th>Subject</th>
                            <th>Logged At</th>
                            <th>Status</th>
                            <th>Warden Response</th>
                            <th class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (complaintList != null && !complaintList.isEmpty()) { 
                            for (Complaint c : complaintList) { 
                                String st = c.getStatus();
                                String badgeClass = "badge-pending";
                                if ("In Progress".equalsIgnoreCase(st)) badgeClass = "badge-in-progress";
                                else if ("Resolved".equalsIgnoreCase(st)) badgeClass = "badge-resolved";
                                else if ("Rejected".equalsIgnoreCase(st)) badgeClass = "badge-rejected";
                        %>
                            <tr>
                                <td><span class="badge bg-light text-dark border">#CMP-<%= c.getComplaintId() %></span></td>
                                <td>
                                    <div class="fw-bold text-dark"><%= c.getStudentName() %></div>
                                    <small class="text-muted"><%= c.getStudentCourse() %></small>
                                </td>
                                <td>
                                    <% if (c.getRoomNumber() != null) { %>
                                        <span class="badge bg-light text-dark border">Room <%= c.getRoomNumber() %></span>
                                    <% } else { %>
                                        <span class="text-muted small">N/A</span>
                                    <% } %>
                                </td>
                                <td><span class="badge bg-light text-dark border"><%= c.getCategory() %></span></td>
                                <td>
                                    <div class="fw-semibold text-dark"><%= c.getSubject() %></div>
                                    <small class="text-muted text-truncate d-inline-block" style="max-width: 220px;">
                                        <%= c.getDescription() %>
                                    </small>
                                </td>
                                <td><small class="text-muted"><%= c.getComplaintDate() %></small></td>
                                <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                                <td>
                                    <% if (c.getAdminResponse() != null && !c.getAdminResponse().trim().isEmpty()) { %>
                                        <span class="text-success small fw-semibold" title="<%= c.getAdminResponse() %>">
                                            <i class="fa-solid fa-comment-dots me-1"></i> Responded
                                        </span>
                                    <% } else { %>
                                        <span class="text-muted small">Awaiting Response</span>
                                    <% } %>
                                </td>
                                <td class="text-center">
                                    <div class="btn-group btn-group-sm">
                                        <button type="button" class="btn btn-outline-primary" 
                                                onclick="openRespondModal(<%= c.getComplaintId() %>, '<%= c.getStudentName().replace("'", "\\'") %>', '<%= c.getCategory() %>', '<%= c.getSubject().replace("'", "\\'").replace("\n", " ") %>', '<%= c.getDescription().replace("'", "\\'").replace("\n", " ") %>', '<%= c.getStatus() %>', '<%= c.getAdminResponse() != null ? c.getAdminResponse().replace("'", "\\'").replace("\n", " ") : "" %>')"
                                                title="Review & Respond">
                                            <i class="fa-solid fa-reply"></i>
                                        </button>
                                        <button type="button" class="btn btn-outline-danger" 
                                                onclick="confirmDelete('<%= request.getContextPath() %>/admin/complaint?action=delete&id=<%= c.getComplaintId() %>', 'complaint ticket')"
                                                title="Delete Ticket">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Admin Response Modal -->
<div class="modal fade" id="respondModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/complaint" method="post">
                <input type="hidden" name="action" value="respond">
                <input type="hidden" name="complaintId" id="modalComplaintId">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-reply me-2 text-primary"></i>Review & Respond to Complaint</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="p-3 bg-light rounded-3 mb-3 border">
                        <div class="row g-2">
                            <div class="col-sm-6">
                                <small class="text-muted d-block">Complainant:</small>
                                <span class="fw-bold" id="modalStudentName"></span>
                            </div>
                            <div class="col-sm-6">
                                <small class="text-muted d-block">Category:</small>
                                <span class="badge bg-light text-dark border" id="modalCategory"></span>
                            </div>
                            <div class="col-12 mt-2">
                                <small class="text-muted d-block">Subject:</small>
                                <div class="fw-semibold text-dark" id="modalSubject"></div>
                            </div>
                            <div class="col-12 mt-2">
                                <small class="text-muted d-block">Full Problem Description:</small>
                                <div class="p-2 bg-white rounded border small" id="modalDescription"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Status Selector -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Update Ticket Status <span class="text-danger">*</span></label>
                        <select name="status" id="modalStatus" class="form-select" required>
                            <option value="Pending">Pending (Not yet investigated)</option>
                            <option value="In Progress">In Progress (Maintenance team assigned)</option>
                            <option value="Resolved">Resolved (Issue fixed & closed)</option>
                            <option value="Rejected">Rejected (Declined / Invalid complaint)</option>
                        </select>
                    </div>

                    <!-- Warden / Admin Response Textarea -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Official Admin Response to Student <span class="text-danger">*</span></label>
                        <textarea name="adminResponse" id="modalResponse" class="form-control" rows="4" 
                                  placeholder="e.g. Electrician Sharma has inspected the wiring and replaced the broken switch on 14th Aug." required></textarea>
                        <small class="text-muted">This response will be visible immediately on the student's dashboard.</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-paper-plane me-1"></i> Submit Response & Update Status
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openRespondModal(id, student, category, subject, desc, status, response) {
    document.getElementById("modalComplaintId").value = id;
    document.getElementById("modalStudentName").textContent = student;
    document.getElementById("modalCategory").textContent = category;
    document.getElementById("modalSubject").textContent = subject;
    document.getElementById("modalDescription").textContent = desc;
    document.getElementById("modalStatus").value = status;
    document.getElementById("modalResponse").value = response;
    new bootstrap.Modal(document.getElementById("respondModal")).show();
}
</script>

<jsp:include page="includes/footer.jsp" />
