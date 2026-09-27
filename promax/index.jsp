<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // If already logged in, redirect to respective dashboard
    String role = (String) session.getAttribute("userRole");
    if ("admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        return;
    } else if ("student".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/student/dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hostel Management System - Portal Login</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome 6 -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="<%= request.getContextPath() %>/css/style.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #0f172a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .portal-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(12px);
            border-radius: 24px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            overflow: hidden;
            max-width: 960px;
            width: 100%;
        }
        .portal-sidebar {
            background: linear-gradient(135deg, #4f46e5 0%, #312e81 100%);
            color: #ffffff;
            padding: 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .portal-content {
            padding: 48px;
        }
        .nav-pills .nav-link {
            border-radius: 12px;
            padding: 12px 20px;
            font-weight: 700;
            color: #64748b;
            background: #f1f5f9;
            transition: all 0.2s ease;
        }
        .nav-pills .nav-link.active {
            background-color: #4f46e5;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
        }
    </style>
</head>
<body>

<div class="portal-card">
    <div class="row g-0">
        <!-- Left Showcase Panel -->
        <div class="col-lg-5 d-none d-lg-flex portal-sidebar">
            <div>
                <div class="d-flex align-items-center gap-3 mb-4">
                    <div class="rounded-3 bg-white bg-opacity-20 d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                        <i class="fa-solid fa-hotel fa-xl"></i>
                    </div>
                    <h3 class="mb-0 fw-bold tracking-tight">HostelSphere</h3>
                </div>
                <h2 class="fw-extrabold mb-3" style="line-height: 1.25;">Centralized Digital Hostel Management</h2>
                <p class="text-light opacity-75 mb-0" style="font-size: 1.05rem; line-height: 1.6;">
                    Streamline student resident onboarding, automated bed allocations, fee accounting, and real-time maintenance ticketing.
                </p>
            </div>
        </div>

        <!-- Right Login Form Panel -->
        <div class="col-lg-7 portal-content">
            <div class="mb-4">
                <h3 class="fw-bold text-dark mb-1">Welcome to Portal</h3>
                <p class="text-muted">Select your account role to sign in to your dashboard.</p>
            </div>

            <!-- Role Selector Tabs -->
            <ul class="nav nav-pills nav-fill mb-4" id="loginTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link <%= (!"admin".equals(request.getParameter("tab"))) ? "active" : "" %>" 
                            id="student-tab" data-bs-toggle="pill" data-bs-target="#student-login" type="button" role="tab">
                        <i class="fa-solid fa-user-graduate me-2"></i> Student Login
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link <%= ("admin".equals(request.getParameter("tab"))) ? "active" : "" %>" 
                            id="admin-tab" data-bs-toggle="pill" data-bs-target="#admin-login" type="button" role="tab">
                        <i class="fa-solid fa-user-shield me-2"></i> Admin Login
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="loginTabContent">
                <!-- 1. Student Login Form -->
                <div class="tab-pane fade <%= (!"admin".equals(request.getParameter("tab"))) ? "show active" : "" %>" 
                     id="student-login" role="tabpanel">
                    <form action="<%= request.getContextPath() %>/login" method="post">
                        <input type="hidden" name="userType" value="student">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Student Username</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-id-card text-muted"></i></span>
                                <input type="text" name="username" class="form-control border-start-0" placeholder="e.g. student1" required>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-lock text-muted"></i></span>
                                <input type="password" name="password" class="form-control border-start-0" placeholder="••••••••" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">
                            <i class="fa-solid fa-arrow-right-to-bracket me-2"></i> Sign In as Student
                        </button>
                    </form>
                </div>

                <!-- 2. Admin Login Form -->
                <div class="tab-pane fade <%= ("admin".equals(request.getParameter("tab"))) ? "show active" : "" %>" 
                     id="admin-login" role="tabpanel">
                    <form action="<%= request.getContextPath() %>/login" method="post">
                        <input type="hidden" name="userType" value="admin">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Administrator Username</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-shield text-muted"></i></span>
                                <input type="text" name="username" class="form-control border-start-0" placeholder="e.g. admin" required>
                            </div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Password</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light border-end-0"><i class="fa-solid fa-lock text-muted"></i></span>
                                <input type="password" name="password" class="form-control border-start-0" placeholder="••••••••" required>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">
                            <i class="fa-solid fa-shield-halved me-2"></i> Sign In as Administrator
                        </button>
                    </form>
                </div>
            </div>

            <div class="mt-4 pt-3 text-center border-top">
                <small class="text-muted">
                    <i class="fa-solid fa-lock me-1"></i> Public registration is restricted. Only hostel admin can enroll students.
                </small>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap 5 JS Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<!-- Custom JS -->
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
