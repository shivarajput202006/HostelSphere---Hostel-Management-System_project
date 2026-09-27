<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.StudentDAO" %>
<%@ page import="model.Student" %>

<%
    Object sIdObj = session.getAttribute("studentId");
    if (sIdObj == null || !"student".equalsIgnoreCase((String) session.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?tab=student&error=Please+login+first.");
        return;
    }
    int studentId = (Integer) sIdObj;
    StudentDAO dao = new StudentDAO();
    Student s = dao.getStudentById(studentId);
    if (s == null) {
        response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp");
        return;
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header with Action Button -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">My Resident Profile</h3>
            <p class="text-muted mb-0">Official institutional identity registered with the Hostel Administration.</p>
        </div>
        <div>
            <button type="button" class="btn btn-primary fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                <i class="fa-solid fa-user-pen me-2"></i> Edit Profile
            </button>
        </div>
    </div>

    <!-- Feedback Alerts -->
    <% String msg = request.getParameter("msg");
       String error = request.getParameter("error");
       if (msg != null && !msg.trim().isEmpty()) { %>
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
            <i class="fa-solid fa-circle-check fa-lg"></i>
            <div><strong>Success!</strong> <%= msg %></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>
    <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
            <i class="fa-solid fa-triangle-exclamation fa-lg"></i>
            <div><strong>Error!</strong> <%= error %></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <div class="row g-4">
        <!-- Avatar & Summary Card -->
        <div class="col-lg-4">
            <div class="card text-center p-4 border-0 shadow-sm">
                <div class="mx-auto mb-3" style="width: 120px; height: 120px;">
                    <img src="<%= request.getContextPath() %>/assets/images/default_avatar.svg" 
                         alt="Profile Photo" class="rounded-circle shadow-sm" style="width: 100%; height: 100%;">
                </div>
                <h4 class="fw-bold text-dark mb-1"><%= s.getName() %></h4>
                <p class="text-muted mb-2"><%= s.getCourse() %> (<%= s.getSemester() %>)</p>
                <div class="badge bg-primary-subtle text-primary px-3 py-2 mb-3">
                    Student ID: #STU-<%= s.getStudentId() %>
                </div>

                <div class="border-top pt-3 text-start">
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted">Username:</span>
                        <span class="fw-semibold"><code><%= s.getUsername() %></code></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted">Gender:</span>
                        <span class="fw-semibold"><%= s.getGender() %></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted">Mobile:</span>
                        <span class="fw-semibold"><%= s.getMobile() %></span>
                    </div>
                    <div class="d-flex justify-content-between py-2 border-bottom">
                        <span class="text-muted">Email:</span>
                        <span class="fw-semibold text-break"><%= s.getEmail() %></span>
                    </div>
                    <div class="d-flex justify-content-between py-2">
                        <span class="text-muted">Allocated Room:</span>
                        <span class="fw-bold text-primary"><%= s.getRoomNumber() != null ? "Room " + s.getRoomNumber() : "Not Allocated" %></span>
                    </div>
                </div>

                <button type="button" class="btn btn-outline-primary w-100 mt-4 fw-semibold" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                    <i class="fa-solid fa-pen-to-square me-1"></i> Edit Personal Information
                </button>
            </div>
        </div>

        <!-- Detailed Info Cards -->
        <div class="col-lg-8">
            <div class="card mb-4 border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-user me-2 text-primary"></i>Personal & Guardian Information</span>
                    <span class="badge bg-light text-muted border">Self-Editable</span>
                </div>
                <div class="card-body p-4">
                    <div class="row g-4">
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Full Name</small>
                            <span class="fw-bold fs-6 text-dark"><%= s.getName() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Date of Birth</small>
                            <span class="fw-bold fs-6 text-dark"><%= s.getDob() != null ? s.getDob() : "Not specified" %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Father's Name</small>
                            <span class="fw-bold fs-6 text-dark"><%= (s.getFatherName() != null && !s.getFatherName().isEmpty()) ? s.getFatherName() : "N/A" %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Mother's Name</small>
                            <span class="fw-bold fs-6 text-dark"><%= (s.getMotherName() != null && !s.getMotherName().isEmpty()) ? s.getMotherName() : "N/A" %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Contact Mobile</small>
                            <span class="fw-semibold text-dark"><%= s.getMobile() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Registered Email</small>
                            <span class="fw-semibold text-dark"><%= s.getEmail() %></span>
                        </div>
                        <div class="col-12">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Permanent Address</small>
                            <span class="fw-semibold text-dark"><%= (s.getAddress() != null && !s.getAddress().isEmpty()) ? s.getAddress() : "No address provided" %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Academic & Institutional Details (Admin Protected) -->
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-graduation-cap me-2 text-primary"></i>Academic & Institutional Record</span>
                    <span class="badge bg-secondary-subtle text-secondary"><i class="fa-solid fa-lock me-1"></i> Admin Controlled</span>
                </div>
                <div class="card-body p-4">
                    <div class="row g-4">
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Degree / Enrolled Course</small>
                            <span class="fw-bold fs-5 text-primary"><%= s.getCourse() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Current Semester / Term</small>
                            <span class="fw-bold fs-5 text-dark"><%= s.getSemester() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Admission Date</small>
                            <span class="fw-semibold text-dark"><%= s.getAdmissionDate() %></span>
                        </div>
                        <div class="col-sm-6">
                            <small class="text-muted d-block text-uppercase fw-bold" style="font-size: 0.75rem;">Hostel Allocation</small>
                            <span class="fw-semibold text-dark">
                                <%= s.getRoomNumber() != null ? "Room " + s.getRoomNumber() + " (" + s.getRoomType() + ")" : "Not Allocated" %>
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ======================================================= -->
<!-- Edit Profile Modal                                      -->
<!-- ======================================================= -->
<div class="modal fade" id="editProfileModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
            <form action="<%= request.getContextPath() %>/student/update-profile" method="post" id="editProfileForm">
                <input type="hidden" name="action" value="updateSelfProfile">
                
                <div class="modal-header bg-primary text-white p-4">
                    <div>
                        <h5 class="modal-title fw-bold mb-1">
                            <i class="fa-solid fa-user-pen me-2"></i> Edit Personal Profile
                        </h5>
                        <small class="text-white-50">Update your contact details, personal information, and credentials</small>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body p-4">
                    <div class="row g-3">
                        <!-- Editable Section Header -->
                        <div class="col-12">
                            <h6 class="fw-bold text-primary mb-0"><i class="fa-solid fa-circle-user me-1"></i> Editable Personal Details</h6>
                            <hr class="my-2 text-muted opacity-25">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Full Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" value="<%= s.getName() %>" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Date of Birth</label>
                            <input type="date" name="dob" class="form-control" value="<%= s.getDob() != null ? s.getDob().toString() : "" %>">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Father's Name</label>
                            <input type="text" name="fatherName" class="form-control" value="<%= s.getFatherName() != null ? s.getFatherName() : "" %>">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Mother's Name</label>
                            <input type="text" name="motherName" class="form-control" value="<%= s.getMotherName() != null ? s.getMotherName() : "" %>">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Gender</label>
                            <select name="gender" class="form-select">
                                <option value="Male" <%= "Male".equalsIgnoreCase(s.getGender()) ? "selected" : "" %>>Male</option>
                                <option value="Female" <%= "Female".equalsIgnoreCase(s.getGender()) ? "selected" : "" %>>Female</option>
                                <option value="Other" <%= "Other".equalsIgnoreCase(s.getGender()) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Mobile Number <span class="text-danger">*</span></label>
                            <input type="tel" name="mobile" class="form-control" value="<%= s.getMobile() != null ? s.getMobile() : "" %>" placeholder="Mobile Number" required>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label fw-semibold text-dark">Email Address <span class="text-danger">*</span></label>
                            <input type="email" name="email" class="form-control" value="<%= s.getEmail() %>" required>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label fw-semibold text-dark">Permanent Address</label>
                            <textarea name="address" class="form-control" rows="2" placeholder="Full postal address"><%= s.getAddress() != null ? s.getAddress() : "" %></textarea>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label fw-semibold text-dark">New Password <small class="text-muted">(Leave blank to keep current password)</small></label>
                            <input type="password" name="password" class="form-control" placeholder="Enter new password if changing">
                        </div>

                        <!-- Read-only Protected Fields Preview -->
                        <div class="col-12 mt-4">
                            <h6 class="fw-bold text-secondary mb-0"><i class="fa-solid fa-lock me-1"></i> Institutional Protected Fields (Admin Controlled)</h6>
                            <hr class="my-2 text-muted opacity-25">
                        </div>

                        <div class="col-md-4">
                            <label class="form-label text-muted small mb-1">Student ID</label>
                            <input type="text" class="form-control bg-light" value="#STU-<%= s.getStudentId() %>" readonly disabled>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label text-muted small mb-1">Course</label>
                            <input type="text" class="form-control bg-light" value="<%= s.getCourse() %>" readonly disabled>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label text-muted small mb-1">Semester</label>
                            <input type="text" class="form-control bg-light" value="<%= s.getSemester() %>" readonly disabled>
                        </div>
                    </div>
                </div>

                <div class="modal-footer bg-light p-3">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4 fw-bold">
                        <i class="fa-solid fa-floppy-disk me-2"></i> Save Profile Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
