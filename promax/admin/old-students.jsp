<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="model.Student" %>

<%
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    if (studentList == null) {
        StudentDAO dao = new StudentDAO();
        studentList = dao.getOldStudents();
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Old & Inactive Students Management</h3>
            <p class="text-muted mb-0">Archived resident profiles, alumni records, and historical payment registers.</p>
        </div>
        <div>
            <a href="<%= request.getContextPath() %>/admin/student?action=list" class="btn btn-outline-primary">
                <i class="fa-solid fa-users me-1"></i> Active Students Roster
            </a>
        </div>
    </div>

    <!-- Alert Messages -->
    <% String msg = request.getParameter("msg");
       String error = request.getParameter("error");
       if (msg != null && !msg.trim().isEmpty()) { %>
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
            <i class="fa-solid fa-circle-check fa-lg"></i>
            <div><%= msg %></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>
    <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
            <i class="fa-solid fa-triangle-exclamation fa-lg"></i>
            <div><%= error %></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <!-- Notice info banner -->
    <div class="alert alert-info py-3 border-0 shadow-sm mb-4 d-flex align-items-center gap-3" style="border-radius: 12px;">
        <i class="fa-solid fa-shield-halved fa-2x text-info"></i>
        <div>
            <div class="fw-bold text-dark">Data Safety & Historical Integrity</div>
            <small class="text-muted">Historical records (past room allocations, fee transactions, and payment receipts) for inactive and archived students remain permanently safe and accessible.</small>
        </div>
    </div>

    <!-- Table Card -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
            <span class="fw-bold text-dark"><i class="fa-solid fa-user-clock me-2 text-primary"></i>Archived Students Ledger</span>
            <span class="badge bg-secondary text-white px-3 py-2 fw-semibold">Archived Count: <%= studentList != null ? studentList.size() : 0 %></span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover datatable align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Student Name</th>
                            <th>Course</th>
                            <th>Contact</th>
                            <th>Admission Date</th>
                            <th>Status</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (studentList != null && !studentList.isEmpty()) { 
                            for (Student s : studentList) { 
                        %>
                            <tr>
                                <td><span class="badge bg-light text-dark border">#STU-<%= s.getStudentId() %></span></td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="rounded-circle bg-secondary bg-opacity-10 text-secondary d-flex align-items-center justify-content-center fw-bold" style="width: 38px; height: 38px;">
                                            <%= (s.getName() != null && !s.getName().isEmpty()) ? s.getName().substring(0, 1) : "S" %>
                                        </div>
                                        <div>
                                            <div class="fw-bold text-dark"><%= s.getName() %></div>
                                            <small class="text-muted"><%= s.getGender() %> • <code><%= s.getUsername() %></code></small>
                                        </div>
                                    </div>
                                </td>
                                <td><%= s.getCourse() %> <br><small class="text-muted"><%= s.getSemester() %></small></td>
                                <td>
                                    <div><i class="fa-solid fa-phone me-1 text-muted" style="font-size: 0.8rem;"></i> <%= s.getMobile() %></div>
                                    <small class="text-muted"><i class="fa-solid fa-envelope me-1 text-muted" style="font-size: 0.8rem;"></i> <%= s.getEmail() %></small>
                                </td>
                                <td><small class="text-muted"><%= s.getAdmissionDate() %></small></td>
                                <td>
                                    <span class="badge bg-secondary-subtle text-secondary"><i class="fa-solid fa-box-archive me-1"></i> Inactive / Old</span>
                                </td>
                                <td class="text-center">
                                    <div class="btn-group btn-group-sm">
                                        <a href="<%= request.getContextPath() %>/admin/student?action=view&id=<%= s.getStudentId() %>" 
                                           class="btn btn-outline-info" title="View Full Profile & History">
                                            <i class="fa-solid fa-eye me-1"></i> View History
                                        </a>
                                        <a href="<%= request.getContextPath() %>/admin/student?action=reactivate&id=<%= s.getStudentId() %>" 
                                           class="btn btn-outline-success" title="Restore / Reactivate Student"
                                           onclick="return confirm('Restore #STU-<%= s.getStudentId() %> back to active student status?');">
                                            <i class="fa-solid fa-rotate-left me-1"></i> Restore
                                        </a>
                                        <button type="button" 
                                                class="btn btn-outline-danger" 
                                                title="Delete Permanently"
                                                onclick="confirmDelete('<%= request.getContextPath() %>/admin/student?action=delete&id=<%= s.getStudentId() %>', 'student')">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr>
                                <td colspan="7" class="text-center py-5 text-muted">
                                    <i class="fa-solid fa-user-check fa-3x mb-3 text-secondary opacity-50 d-block"></i>
                                    <h5 class="fw-bold text-dark">No Old / Archived Students</h5>
                                    <p class="mb-0">All enrolled student profiles are currently active.</p>
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
