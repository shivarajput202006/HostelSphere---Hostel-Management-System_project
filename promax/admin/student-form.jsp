<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>

<%
    Student student = (Student) request.getAttribute("student");
    boolean isEdit = (student != null);
    String pageTitle = isEdit ? "Edit Student Details" : "Enroll New Student";
    String formAction = isEdit ? "update" : "add";
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1"><%= pageTitle %></h3>
            <p class="text-muted mb-0">Fill in the student's personal, academic, and portal authentication details.</p>
        </div>
        <a href="<%= request.getContextPath() %>/admin/student?action=list" class="btn btn-outline-secondary">
            <i class="fa-solid fa-arrow-left me-2"></i> Back to Student List
        </a>
    </div>

    <!-- Info Note -->
    <% if (!isEdit) { %>
    <div class="alert alert-info py-2 small mb-4 d-flex align-items-center gap-2 border-0 shadow-sm" style="border-radius: 10px;">
        <i class="fa-solid fa-circle-info text-info fa-lg"></i>
        <span><strong>Note:</strong> Enrolling a student creates their resident record without generating a fee invoice. Fee invoices are created explicitly by the Admin via the Fee Management module.</span>
    </div>
    <% } %>

    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom">
            <span class="fw-bold text-dark"><i class="fa-solid fa-id-card me-2 text-primary"></i>Student Registration Form</span>
        </div>
        <div class="card-body p-4">
            <form action="<%= request.getContextPath() %>/admin/student" method="post">
                <input type="hidden" name="action" value="<%= formAction %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="studentId" value="<%= student.getStudentId() %>">
                <% } %>

                <!-- 1. Personal Details -->
                <h5 class="fw-bold text-primary mb-3 border-bottom pb-2">
                    <i class="fa-solid fa-user me-2"></i>1. Personal Information
                </h5>
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Full Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control" placeholder="e.g. Rahul Sharma" 
                               value="<%= isEdit && student.getName() != null ? student.getName() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Gender <span class="text-danger">*</span></label>
                        <select name="gender" class="form-select" required>
                            <option value="">Select Gender</option>
                            <option value="Male" <%= (isEdit && "Male".equalsIgnoreCase(student.getGender())) ? "selected" : "" %>>Male</option>
                            <option value="Female" <%= (isEdit && "Female".equalsIgnoreCase(student.getGender())) ? "selected" : "" %>>Female</option>
                            <option value="Other" <%= (isEdit && "Other".equalsIgnoreCase(student.getGender())) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Father's Name <span class="text-danger">*</span></label>
                        <input type="text" name="fatherName" class="form-control" placeholder="Father's Name" 
                               value="<%= isEdit && student.getFatherName() != null ? student.getFatherName() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Mother's Name <span class="text-danger">*</span></label>
                        <input type="text" name="motherName" class="form-control" placeholder="Mother's Name" 
                               value="<%= isEdit && student.getMotherName() != null ? student.getMotherName() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Date of Birth <span class="text-danger">*</span></label>
                        <input type="date" name="dob" class="form-control" 
                               value="<%= isEdit && student.getDob() != null ? student.getDob().toString() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Mobile Number <span class="text-danger">*</span></label>
                        <input type="tel" name="mobile" class="form-control" placeholder="10-digit Mobile Number" 
                               value="<%= isEdit && student.getMobile() != null ? student.getMobile() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Email Address <span class="text-danger">*</span></label>
                        <input type="email" name="email" class="form-control" placeholder="student@example.com" 
                               value="<%= isEdit && student.getEmail() != null ? student.getEmail() : "" %>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Permanent Residential Address <span class="text-danger">*</span></label>
                        <textarea name="address" class="form-control" rows="2" placeholder="Full postal address" required><%= isEdit && student.getAddress() != null ? student.getAddress() : "" %></textarea>
                    </div>
                </div>

                <!-- 2. Academic Information -->
                <h5 class="fw-bold text-primary mb-3 border-bottom pb-2">
                    <i class="fa-solid fa-graduation-cap me-2"></i>2. Academic Details & Lifecycle
                </h5>
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark">Course Enrolled <span class="text-danger">*</span></label>
                        <input type="text" name="course" id="course" class="form-control" 
                               placeholder="e.g. MCA, BCA, B.Tech CSE, MBA, B.Sc..." 
                               value="<%= isEdit && student.getCourse() != null ? student.getCourse() : "" %>" 
                               list="courseSuggestions" required autocomplete="off">
                        <datalist id="courseSuggestions">
                            <option value="MCA">
                            <option value="BCA">
                            <option value="MBA">
                            <option value="B.Tech CSE">
                            <option value="B.Tech IT">
                            <option value="B.Sc Computer Science">
                            <option value="M.Tech">
                            <option value="M.Sc IT">
                            <option value="BBA">
                        </datalist>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark">Semester / Year <span class="text-danger">*</span></label>
                        <select name="semester" class="form-select" required>
                            <option value="">Select Semester</option>
                            <option value="Semester 1" <%= (isEdit && "Semester 1".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 1</option>
                            <option value="Semester 2" <%= (isEdit && "Semester 2".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 2</option>
                            <option value="Semester 3" <%= (isEdit && "Semester 3".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 3</option>
                            <option value="Semester 4" <%= (isEdit && "Semester 4".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 4</option>
                            <option value="Semester 5" <%= (isEdit && "Semester 5".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 5</option>
                            <option value="Semester 6" <%= (isEdit && "Semester 6".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 6</option>
                            <option value="Semester 7" <%= (isEdit && "Semester 7".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 7</option>
                            <option value="Semester 8" <%= (isEdit && "Semester 8".equalsIgnoreCase(student.getSemester())) ? "selected" : "" %>>Semester 8</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark">Admission Date <span class="text-danger">*</span></label>
                        <input type="date" name="admissionDate" class="form-control" 
                               value="<%= isEdit && student.getAdmissionDate() != null ? student.getAdmissionDate().toString() : "" %>" required>
                    </div>
                    <% if (isEdit) { %>
                    <div class="col-md-4">
                        <label class="form-label fw-semibold text-dark">Student Lifecycle Status</label>
                        <select name="status" class="form-select">
                            <option value="Active" <%= "Active".equalsIgnoreCase(student.getStatus()) ? "selected" : "" %>>Active (Current Resident)</option>
                            <option value="Inactive" <%= "Inactive".equalsIgnoreCase(student.getStatus()) ? "selected" : "" %>>Inactive / Old Student</option>
                        </select>
                    </div>
                    <% } %>
                </div>

                <!-- 3. Portal Authentication -->
                <h5 class="fw-bold text-primary mb-3 border-bottom pb-2">
                    <i class="fa-solid fa-key me-2"></i>3. Portal Login Credentials
                </h5>
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Username <span class="text-danger">*</span></label>
                        <input type="text" name="username" class="form-control" placeholder="Unique Portal Username" 
                               value="<%= isEdit && student.getUsername() != null ? student.getUsername() : "" %>" required>
                        <small class="text-muted">The student will use this username to log in.</small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold text-dark">Password <%= isEdit ? "(Leave blank to keep unchanged)" : "<span class='text-danger'>*</span>" %></label>
                        <input type="password" name="password" class="form-control" placeholder="••••••••" <%= isEdit ? "" : "required" %>>
                        <small class="text-muted">Encrypted securely using SHA-256 upon save.</small>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-3 pt-3 border-top">
                    <a href="<%= request.getContextPath() %>/admin/student?action=list" class="btn btn-light px-4">Cancel</a>
                    <button type="submit" class="btn btn-primary px-4 fw-bold shadow-sm">
                        <i class="fa-solid fa-floppy-disk me-2"></i> <%= isEdit ? "Save Changes" : "Register Student" %>
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
