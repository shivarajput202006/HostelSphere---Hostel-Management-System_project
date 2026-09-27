<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="model.Student" %>

<%
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    String searchQuery = (String) request.getAttribute("searchQuery");
    String selectedStatus = (String) request.getAttribute("selectedStatus");

    if (studentList == null) {
        StudentDAO dao = new StudentDAO();
        studentList = dao.getAllStudents();
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Student Management</h3>
            <p class="text-muted mb-0">Manage registered student profiles, lifecycle status, room bindings, and academic records.</p>
        </div>
        <div class="d-flex gap-2">
            <a href="<%= request.getContextPath() %>/admin/student?action=old" class="btn btn-outline-secondary">
                <i class="fa-solid fa-user-clock me-1"></i> View Old/Archived Students
            </a>
            <a href="<%= request.getContextPath() %>/admin/student-form.jsp" class="btn btn-primary">
                <i class="fa-solid fa-user-plus me-2"></i> Enroll New Student
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

    <!-- Search & Filter Bar -->
    <div class="card mb-4 border-0 shadow-sm">
        <div class="card-body p-3">
            <form action="<%= request.getContextPath() %>/admin/student" method="get" class="row g-2 align-items-center">
                <input type="hidden" name="action" value="search">
                <div class="col-md-6 col-sm-12">
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0 text-muted"><i class="fa-solid fa-magnifying-glass"></i></span>
                        <input type="text" name="q" class="form-control border-start-0" 
                               placeholder="Search by student name, ID, course, mobile, username..." 
                               value="<%= searchQuery != null ? searchQuery : "" %>">
                    </div>
                </div>
                <div class="col-md-4 col-sm-8">
                    <select name="status" class="form-select">
                        <option value="all" <%= ("all".equalsIgnoreCase(selectedStatus) || selectedStatus == null) ? "selected" : "" %>>All Lifecycle States</option>
                        <option value="active" <%= "active".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Active Resident Students</option>
                        <option value="inactive" <%= ("inactive".equalsIgnoreCase(selectedStatus) || "old".equalsIgnoreCase(selectedStatus)) ? "selected" : "" %>>Old / Inactive Students</option>
                    </select>
                </div>
                <div class="col-md-2 col-sm-4 d-flex gap-2">
                    <button type="submit" class="btn btn-primary w-100 fw-semibold">Filter</button>
                    <a href="<%= request.getContextPath() %>/admin/student?action=list" class="btn btn-light" title="Reset Filters"><i class="fa-solid fa-rotate"></i></a>
                </div>
            </form>
        </div>
    </div>

    <!-- Student Table Card -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
            <span class="fw-bold text-dark"><i class="fa-solid fa-users me-2 text-primary"></i>Enrolled Students Roster</span>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Total: <%= studentList != null ? studentList.size() : 0 %> Students</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover datatable align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Student Name</th>
                            <th>Course & Sem</th>
                            <th>Contact</th>
                            <th>Allocated Room</th>
                            <th>Status</th>
                            <th>Admission</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (studentList != null && !studentList.isEmpty()) { 
                            for (Student s : studentList) { 
                                boolean isActive = !"Inactive".equalsIgnoreCase(s.getStatus());
                        %>
                            <tr>
                                <td><span class="badge bg-light text-dark border">#STU-<%= s.getStudentId() %></span></td>
                                <td>
                                    <div class="d-flex align-items-center gap-2">
                                        <div class="rounded-circle <%= isActive ? "bg-primary" : "bg-secondary" %> bg-opacity-10 <%= isActive ? "text-primary" : "text-secondary" %> d-flex align-items-center justify-content-center fw-bold" style="width: 38px; height: 38px;">
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
                                <td>
                                    <% if (s.getRoomNumber() != null) { %>
                                        <span class="badge badge-available">
                                            <i class="fa-solid fa-door-open me-1"></i> Room <%= s.getRoomNumber() %>
                                        </span>
                                        <div class="small text-muted mt-1"><%= s.getRoomType() %></div>
                                    <% } else { %>
                                        <span class="badge bg-secondary-subtle text-secondary">
                                            <i class="fa-solid fa-circle-xmark me-1"></i> Not Allocated
                                        </span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (isActive) { %>
                                        <span class="badge bg-success-subtle text-success"><i class="fa-solid fa-circle-check me-1"></i> Active</span>
                                    <% } else { %>
                                        <span class="badge bg-secondary-subtle text-secondary"><i class="fa-solid fa-archive me-1"></i> Inactive / Old</span>
                                    <% } %>
                                </td>
                                <td><small class="text-muted"><%= s.getAdmissionDate() %></small></td>
                                <td class="text-center">
                                    <div class="btn-group btn-group-sm">
                                        <a href="<%= request.getContextPath() %>/admin/student?action=view&id=<%= s.getStudentId() %>" 
                                           class="btn btn-outline-info" title="View Full Profile & History">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                        <a href="<%= request.getContextPath() %>/admin/student?action=edit&id=<%= s.getStudentId() %>" 
                                           class="btn btn-outline-warning" title="Edit Student">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </a>
                                        <% if (isActive) { %>
                                            <a href="<%= request.getContextPath() %>/admin/student?action=deactivate&id=<%= s.getStudentId() %>" 
                                               class="btn btn-outline-secondary" title="Archive / Mark Inactive"
                                               onclick="return confirm('Archive student #STU-<%= s.getStudentId() %> to Old Students? Historical fee & payment records are preserved.');">
                                                <i class="fa-solid fa-box-archive"></i>
                                            </a>
                                        <% } else { %>
                                            <a href="<%= request.getContextPath() %>/admin/student?action=reactivate&id=<%= s.getStudentId() %>" 
                                               class="btn btn-outline-success" title="Reactivate Student"
                                               onclick="return confirm('Reactivate student #STU-<%= s.getStudentId() %> to Active status?');">
                                                <i class="fa-solid fa-rotate-left"></i>
                                            </a>
                                        <% } %>
                                        <button type="button" 
                                                class="btn btn-outline-danger" 
                                                title="Delete Student Record"
                                                onclick="confirmDelete('<%= request.getContextPath() %>/admin/student?action=delete&id=<%= s.getStudentId() %>', 'student')">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="fa-solid fa-user-slash fa-3x mb-3 text-secondary opacity-50 d-block"></i>
                                    <h5 class="fw-bold text-dark">No Students Found</h5>
                                    <p class="mb-0">No matching student records found for the selected search/filter criteria.</p>
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
