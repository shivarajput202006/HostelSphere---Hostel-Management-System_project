<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="dao.AdminDAO" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="dao.AllocationDAO" %>
<%@ page import="dao.FeeDAO" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="model.Student" %>
<%@ page import="model.Allocation" %>
<%@ page import="model.Fee" %>
<%@ page import="model.Complaint" %>

<%
    AdminDAO adminDAO = new AdminDAO();
    StudentDAO studentDAO = new StudentDAO();
    AllocationDAO allocationDAO = new AllocationDAO();
    FeeDAO feeDAO = new FeeDAO();
    ComplaintDAO complaintDAO = new ComplaintDAO();

    Map<String, Object> stats = adminDAO.getDashboardStats();
    List<Student> recentStudents = studentDAO.getRecentStudents(5);
    List<Allocation> recentAllocations = allocationDAO.getRecentAllocations(5);
    List<Fee> recentFees = feeDAO.getRecentFees(5);
    List<Complaint> recentComplaints = complaintDAO.getRecentComplaints(5);

    int totalStudents = (Integer) stats.getOrDefault("totalStudents", 0);
    int activeStudents = (Integer) stats.getOrDefault("activeStudents", 0);
    int oldStudents = (Integer) stats.getOrDefault("oldStudents", 0);
    int totalRooms = (Integer) stats.getOrDefault("totalRooms", 0);
    int availableBeds = (Integer) stats.getOrDefault("availableBeds", 0);
    int occupiedBeds = (Integer) stats.getOrDefault("occupiedBeds", 0);
    BigDecimal totalFees = (BigDecimal) stats.getOrDefault("totalFees", BigDecimal.ZERO);
    BigDecimal paidFees = (BigDecimal) stats.getOrDefault("paidFees", BigDecimal.ZERO);
    BigDecimal pendingFees = (BigDecimal) stats.getOrDefault("pendingFees", BigDecimal.ZERO);
    int totalComplaints = (Integer) stats.getOrDefault("totalComplaints", 0);
    int pendingComplaints = (Integer) stats.getOrDefault("pendingComplaints", 0);
    int inProgressComplaints = (Integer) stats.getOrDefault("inProgressComplaints", 0);
    int resolvedComplaints = (Integer) stats.getOrDefault("resolvedComplaints", 0);
    int rejectedComplaints = (Integer) stats.getOrDefault("rejectedComplaints", 0);
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header Title -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Administrative Dashboard</h3>
            <p class="text-muted mb-0">Real-time live hostel overview, active & old student metrics, occupancy, and revenue.</p>
        </div>
        <div class="d-flex gap-2">
            <a href="<%= request.getContextPath() %>/admin/student-form.jsp" class="btn btn-primary">
                <i class="fa-solid fa-user-plus me-2"></i> Enroll Student
            </a>
            <a href="<%= request.getContextPath() %>/admin/fee?action=list" class="btn btn-outline-primary">
                <i class="fa-solid fa-file-invoice-dollar me-2"></i> Generate Fee
            </a>
        </div>
    </div>

    <!-- 8 Real Database Statistics Cards -->
    <div class="row g-3 mb-4">
        <!-- 1. Total Students -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-primary">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Total Students</div>
                        <h2 class="fw-extrabold mb-0 mt-1"><%= totalStudents %></h2>
                        <small class="text-white-50">Active: <strong><%= activeStudents %></strong> • Old: <strong><%= oldStudents %></strong></small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-user-graduate"></i></div>
                </div>
            </div>
        </div>

        <!-- 2. Active Resident Students -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-info">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Active Residents</div>
                        <h2 class="fw-extrabold mb-0 mt-1"><%= activeStudents %></h2>
                        <small class="text-white-50">Enrolled & Current</small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-users"></i></div>
                </div>
            </div>
        </div>

        <!-- 3. Available Beds -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-success">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Available Beds</div>
                        <h2 class="fw-extrabold mb-0 mt-1"><%= availableBeds %></h2>
                        <small class="text-white-50">Occupied: <strong><%= occupiedBeds %></strong> (Total: <%= availableBeds + occupiedBeds %>)</small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-bed"></i></div>
                </div>
            </div>
        </div>

        <!-- 4. Occupied Rooms -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-purple">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Total Rooms</div>
                        <h2 class="fw-extrabold mb-0 mt-1"><%= totalRooms %></h2>
                        <small class="text-white-50">Hostel Blocks 1-3</small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-door-open"></i></div>
                </div>
            </div>
        </div>

        <!-- 5. Total Fee Collections -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-success">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Fee Collected</div>
                        <h2 class="fw-extrabold mb-0 mt-1">₹ <%= paidFees %></h2>
                        <small class="text-white-50">Assessed: ₹ <%= totalFees %></small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-sack-dollar"></i></div>
                </div>
            </div>
        </div>

        <!-- 6. Total Pending Fees -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-warning">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Pending Dues</div>
                        <h2 class="fw-extrabold mb-0 mt-1">₹ <%= pendingFees %></h2>
                        <small class="text-white-50">Awaiting clearance</small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-clock-rotate-left"></i></div>
                </div>
            </div>
        </div>

        <!-- 7. Total Support Tickets -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-info">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Total Complaints</div>
                        <h2 class="fw-extrabold mb-0 mt-1"><%= totalComplaints %></h2>
                        <small class="text-white-50">Resolved: <%= resolvedComplaints %></small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-list-check"></i></div>
                </div>
            </div>
        </div>

        <!-- 8. Pending Complaints -->
        <div class="col-xl-3 col-md-6">
            <div class="stat-card bg-grad-danger">
                <div class="d-flex align-items-center justify-content-between">
                    <div>
                        <div class="text-white-50 text-uppercase fw-bold" style="font-size: 0.75rem;">Pending Issues</div>
                        <h2 class="fw-extrabold mb-0 mt-1"><%= pendingComplaints %></h2>
                        <small class="text-white-50">In Progress: <%= inProgressComplaints %></small>
                    </div>
                    <div class="icon-bubble"><i class="fa-solid fa-triangle-exclamation"></i></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Interactive Charts Section -->
    <div class="row g-3 mb-4">
        <!-- Chart 1: Fee Financial Overview -->
        <div class="col-lg-6">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                    <span class="fw-bold"><i class="fa-solid fa-chart-pie me-2 text-primary"></i>Fee Collections Breakdown</span>
                    <span class="badge bg-light text-dark">Total: ₹ <%= totalFees %></span>
                </div>
                <div class="card-body d-flex align-items-center justify-content-center" style="position: relative; height: 280px;">
                    <canvas id="feeChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Chart 2: Complaint Status Breakdown -->
        <div class="col-lg-6">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                    <span class="fw-bold"><i class="fa-solid fa-chart-column me-2 text-primary"></i>Complaint Resolution Status</span>
                    <span class="badge bg-light text-dark">Total: <%= totalComplaints %> Tickets</span>
                </div>
                <div class="card-body d-flex align-items-center justify-content-center" style="position: relative; height: 280px;">
                    <canvas id="complaintChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Activities Grid -->
    <div class="row g-3 mb-4">
        <!-- Recent Students -->
        <div class="col-lg-6">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                    <span class="fw-bold"><i class="fa-solid fa-user-graduate me-2 text-primary"></i>Recent Student Admissions</span>
                    <a href="<%= request.getContextPath() %>/admin/student?action=list" class="btn btn-sm btn-link text-decoration-none">View All</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Name</th>
                                    <th>Course</th>
                                    <th>Room</th>
                                    <th>Admission</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (recentStudents != null && !recentStudents.isEmpty()) { 
                                    for (Student s : recentStudents) { %>
                                    <tr>
                                        <td class="fw-semibold">
                                            <div class="d-flex align-items-center gap-2">
                                                <div class="rounded-circle bg-primary bg-opacity-10 text-primary d-flex align-items-center justify-content-center fw-bold" style="width: 32px; height: 32px; font-size: 0.8rem;">
                                                    <%= s.getName() != null && !s.getName().isEmpty() ? s.getName().substring(0, 1) : "S" %>
                                                </div>
                                                <%= s.getName() %>
                                            </div>
                                        </td>
                                        <td><%= s.getCourse() %> (<%= s.getSemester() %>)</td>
                                        <td>
                                            <% if (s.getRoomNumber() != null) { %>
                                                <span class="badge bg-light text-dark border">Room <%= s.getRoomNumber() %></span>
                                            <% } else { %>
                                                <span class="badge bg-secondary-subtle text-secondary">Unallocated</span>
                                            <% } %>
                                        </td>
                                        <td><small class="text-muted"><%= s.getAdmissionDate() %></small></td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="4" class="text-center py-4 text-muted">No students enrolled yet.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Room Allocations -->
        <div class="col-lg-6">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
                    <span class="fw-bold"><i class="fa-solid fa-bed me-2 text-primary"></i>Recent Room Allocations</span>
                    <a href="<%= request.getContextPath() %>/admin/allocation?action=list" class="btn btn-sm btn-link text-decoration-none">View All</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Student</th>
                                    <th>Room</th>
                                    <th>Type</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (recentAllocations != null && !recentAllocations.isEmpty()) { 
                                    for (Allocation a : recentAllocations) { %>
                                    <tr>
                                        <td class="fw-semibold"><%= a.getStudentName() %></td>
                                        <td><strong>Room <%= a.getRoomNumber() %></strong> (Fl. <%= a.getRoomFloor() %>)</td>
                                        <td><small class="text-muted"><%= a.getRoomType() %></small></td>
                                        <td>
                                            <span class="badge <%= "Active".equalsIgnoreCase(a.getStatus()) ? "badge-active" : "badge-vacated" %>">
                                                <%= a.getStatus() %>
                                            </span>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="4" class="text-center py-4 text-muted">No room allocations recorded.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Complaints Table -->
    <div class="card mb-4 border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
            <span class="fw-bold"><i class="fa-solid fa-headset me-2 text-primary"></i>Recent Student Complaints & Support Tickets</span>
            <a href="<%= request.getContextPath() %>/admin/complaint?action=list" class="btn btn-sm btn-link text-decoration-none">Manage Complaints</a>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Ticket #</th>
                            <th>Student</th>
                            <th>Room</th>
                            <th>Category</th>
                            <th>Subject</th>
                            <th>Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (recentComplaints != null && !recentComplaints.isEmpty()) { 
                            for (Complaint c : recentComplaints) { %>
                            <tr>
                                <td><strong>#CMP-<%= c.getComplaintId() %></strong></td>
                                <td><%= c.getStudentName() %></td>
                                <td><%= c.getRoomNumber() != null ? "Room " + c.getRoomNumber() : "N/A" %></td>
                                <td><span class="badge bg-light text-dark border"><%= c.getCategory() %></span></td>
                                <td><%= c.getSubject() %></td>
                                <td><small class="text-muted"><%= c.getComplaintDate() %></small></td>
                                <td>
                                    <% 
                                        String st = c.getStatus();
                                        String badgeClass = "badge-pending";
                                        if ("In Progress".equalsIgnoreCase(st)) badgeClass = "badge-in-progress";
                                        else if ("Resolved".equalsIgnoreCase(st)) badgeClass = "badge-resolved";
                                        else if ("Rejected".equalsIgnoreCase(st)) badgeClass = "badge-rejected";
                                    %>
                                    <span class="badge <%= badgeClass %>"><%= st %></span>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr><td colspan="7" class="text-center py-4 text-muted">No complaints logged.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Chart.js Initialization Script -->
<script>
document.addEventListener("DOMContentLoaded", function() {
    // 1. Fee Breakdown Doughnut Chart
    const ctxFee = document.getElementById('feeChart').getContext('2d');
    new Chart(ctxFee, {
        type: 'doughnut',
        data: {
            labels: ['Fees Paid (₹ <%= paidFees %>)', 'Pending Dues (₹ <%= pendingFees %>)'],
            datasets: [{
                data: [<%= paidFees %>, <%= pendingFees %>],
                backgroundColor: ['#10b981', '#f59e0b'],
                hoverOffset: 6,
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });

    // 2. Complaint Status Bar Chart
    const ctxComp = document.getElementById('complaintChart').getContext('2d');
    new Chart(ctxComp, {
        type: 'bar',
        data: {
            labels: ['Pending', 'In Progress', 'Resolved', 'Rejected'],
            datasets: [{
                label: 'Tickets',
                data: [<%= pendingComplaints %>, <%= inProgressComplaints %>, <%= resolvedComplaints %>, <%= rejectedComplaints %>],
                backgroundColor: ['#f59e0b', '#0ea5e9', '#10b981', '#ef4444'],
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1 } }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });
});
</script>

<jsp:include page="includes/footer.jsp" />
