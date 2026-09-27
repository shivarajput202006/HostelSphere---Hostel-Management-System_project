<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentUri = request.getRequestURI();
%>
<!-- Admin Sidebar -->
<nav id="sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-hotel"></i>
        <span>HostelSphere</span>
    </div>

    <ul class="nav-list">
        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" 
               class="nav-link <%= currentUri.endsWith("dashboard.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-chart-pie"></i>
                <span>Dashboard</span>
            </a>
        </li>

        <li class="nav-item mt-3 mb-1 px-3 text-uppercase text-muted" style="font-size: 0.725rem; font-weight: 700; letter-spacing: 0.5px;">
            Student Records
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/student?action=list" 
               class="nav-link <%= ((currentUri.contains("student") || currentUri.contains("students.jsp")) && !currentUri.contains("old")) ? "active" : "" %>">
                <i class="fa-solid fa-user-graduate"></i>
                <span>Students</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/student?action=old" 
               class="nav-link <%= (currentUri.contains("old-students.jsp") || (currentUri.contains("student") && "old".equals(request.getParameter("action")))) ? "active" : "" %>">
                <i class="fa-solid fa-user-clock"></i>
                <span>Old Students</span>
            </a>
        </li>

        <li class="nav-item mt-3 mb-1 px-3 text-uppercase text-muted" style="font-size: 0.725rem; font-weight: 700; letter-spacing: 0.5px;">
            Hostel Operations
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/room?action=list" 
               class="nav-link <%= (currentUri.contains("room") && !currentUri.contains("allocation")) ? "active" : "" %>">
                <i class="fa-solid fa-door-open"></i>
                <span>Rooms</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/allocation?action=list" 
               class="nav-link <%= currentUri.contains("allocation") ? "active" : "" %>">
                <i class="fa-solid fa-bed"></i>
                <span>Room Allocation</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/fee?action=list" 
               class="nav-link <%= (currentUri.contains("fee") && !currentUri.contains("food")) ? "active" : "" %>">
                <i class="fa-solid fa-file-invoice-dollar"></i>
                <span>Fees</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/food-settings" 
               class="nav-link <%= (currentUri.contains("food-settings") || currentUri.contains("settings")) ? "active" : "" %>">
                <i class="fa-solid fa-utensils"></i>
                <span>Food/Fee Settings</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/complaint?action=list" 
               class="nav-link <%= currentUri.contains("complaint") ? "active" : "" %>">
                <i class="fa-solid fa-headset"></i>
                <span>Complaints</span>
            </a>
        </li>

        <li class="nav-item mt-3 mb-1 px-3 text-uppercase text-muted" style="font-size: 0.725rem; font-weight: 700; letter-spacing: 0.5px;">
            Account & System
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/profile" 
               class="nav-link <%= (currentUri.contains("profile") && currentUri.contains("admin")) ? "active" : "" %>">
                <i class="fa-solid fa-user-shield"></i>
                <span>My Profile</span>
            </a>
        </li>

        <li class="nav-item mt-4">
            <a href="<%= request.getContextPath() %>/logout" class="nav-link text-danger">
                <i class="fa-solid fa-right-from-bracket"></i>
                <span>Logout</span>
            </a>
        </li>
    </ul>

    <div class="sidebar-footer">
        <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center fw-bold" style="width: 36px; height: 36px;">
            A
        </div>
        <div class="overflow-hidden">
            <div class="text-white fw-bold text-truncate" style="font-size: 0.85rem;"><%= session.getAttribute("userName") %></div>
            <small class="text-muted d-block text-truncate" style="font-size: 0.75rem;">Administrator</small>
        </div>
    </div>
</nav>

<!-- Content Wrapper -->
<div id="content-wrapper">
    <!-- Top Navbar -->
    <header class="top-navbar">
        <div class="d-flex align-items-center gap-3">
            <h5 class="mb-0 fw-bold text-dark">Hostel Administration Portal</h5>
        </div>
        <div class="d-flex align-items-center gap-3">
            <span class="badge bg-light text-dark border px-3 py-2">
                <i class="fa-regular fa-calendar me-2 text-primary"></i>
                <%= new java.text.SimpleDateFormat("EEEE, dd MMM yyyy").format(new java.util.Date()) %>
            </span>
            <a href="<%= request.getContextPath() %>/logout" class="btn btn-sm btn-outline-danger">
                <i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout
            </a>
        </div>
    </header>
    <main class="main-content">
