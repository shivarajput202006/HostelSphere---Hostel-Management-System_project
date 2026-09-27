<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Admin" %>

<%
    Admin admin = (Admin) request.getAttribute("admin");
    if (admin == null) {
        String adminUser = (String) session.getAttribute("adminUser");
        if (adminUser == null) {
            response.sendRedirect(request.getContextPath() + "/admin-login.jsp");
            return;
        }
        admin = new dao.AdminDAO().getAdminByUsername(adminUser);
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Administrator Profile</h3>
            <p class="text-muted mb-0">View and update administrative credentials, contact details, and account settings.</p>
        </div>
        <div>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">
                <i class="fa-solid fa-shield-halved me-1"></i> System Administrator
            </span>
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

    <div class="row g-4">
        <!-- Admin Info Card -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm text-center p-4">
                <div class="avatar-lg bg-primary text-white rounded-circle mx-auto d-flex align-items-center justify-content-center shadow" 
                     style="width: 88px; height: 88px; font-size: 2.2rem; font-weight: 700;">
                    <i class="fa-solid fa-user-shield"></i>
                </div>
                <h4 class="fw-bold text-dark mt-3 mb-1"><%= admin != null && admin.getName() != null ? admin.getName() : "Administrator" %></h4>
                <p class="text-muted small mb-3">@<%= admin != null ? admin.getUsername() : "admin" %></p>
                <div class="d-inline-block px-3 py-1 bg-light rounded-pill border small fw-semibold text-secondary mb-3">
                    <i class="fa-solid fa-lock text-success me-1"></i> Full Access Controller
                </div>

                <hr class="my-3">

                <div class="text-start small">
                    <div class="mb-2">
                        <span class="text-muted d-block">Admin Email:</span>
                        <strong class="text-dark"><%= admin != null && admin.getEmail() != null && !admin.getEmail().isEmpty() ? admin.getEmail() : "admin@hostel.com" %></strong>
                    </div>
                    <div class="mb-2">
                        <span class="text-muted d-block">Mobile Contact:</span>
                        <strong class="text-dark"><%= admin != null && admin.getMobile() != null && !admin.getMobile().isEmpty() ? admin.getMobile() : "+91 9876543210" %></strong>
                    </div>
                    <div>
                        <span class="text-muted d-block">Office Location:</span>
                        <strong class="text-dark"><%= admin != null && admin.getAddress() != null && !admin.getAddress().isEmpty() ? admin.getAddress() : "Admin Office, Main Hostel Block" %></strong>
                    </div>
                </div>
            </div>
        </div>

        <!-- Edit Profile Form -->
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-user-gear me-2 text-primary"></i>Update Profile Details</span>
                </div>
                <div class="card-body p-4">
                    <form action="<%= request.getContextPath() %>/admin/profile" method="post">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Username (Protected)</label>
                                <input type="text" class="form-control bg-light" value="<%= admin != null ? admin.getUsername() : "admin" %>" readonly disabled>
                                <small class="text-muted">Username is system-protected and cannot be changed.</small>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Full Name <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control" 
                                       value="<%= admin != null && admin.getName() != null ? admin.getName() : "" %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Official Email Address <span class="text-danger">*</span></label>
                                <input type="email" name="email" class="form-control" 
                                       value="<%= admin != null && admin.getEmail() != null ? admin.getEmail() : "" %>" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Contact Mobile Number <span class="text-danger">*</span></label>
                                <input type="tel" name="mobile" class="form-control" 
                                       value="<%= admin != null && admin.getMobile() != null ? admin.getMobile() : "" %>" required>
                            </div>

                            <div class="col-md-12">
                                <label class="form-label fw-semibold">Office Address / Department</label>
                                <textarea name="address" rows="2" class="form-control"><%= admin != null && admin.getAddress() != null ? admin.getAddress() : "" %></textarea>
                            </div>

                            <div class="col-md-12">
                                <hr class="my-2">
                                <label class="form-label fw-semibold text-dark">Change Account Password</label>
                                <input type="password" name="newPassword" class="form-control" placeholder="Leave blank to keep existing password unchanged">
                                <small class="text-muted">Only enter a new password if you wish to update your current login password.</small>
                            </div>
                        </div>

                        <div class="mt-4 pt-3 border-top d-flex justify-content-end gap-2">
                            <button type="submit" class="btn btn-primary px-4 py-2 fw-bold shadow-sm">
                                <i class="fa-solid fa-floppy-disk me-2"></i> Save Profile Changes
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
