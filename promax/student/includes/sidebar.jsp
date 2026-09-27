<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentUri = request.getRequestURI();
%>
<!-- Student Sidebar -->
<nav id="sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-hotel"></i>
        <span>Resident Portal</span>
    </div>

    <ul class="nav-list">
        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/student/dashboard.jsp" 
               class="nav-link <%= currentUri.endsWith("dashboard.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-gauge-high"></i>
                <span>Dashboard</span>
            </a>
        </li>

        <li class="nav-item mt-3 mb-1 px-3 text-uppercase text-muted" style="font-size: 0.725rem; font-weight: 700; letter-spacing: 0.5px;">
            Resident Services
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/student/profile.jsp" 
               class="nav-link <%= currentUri.endsWith("profile.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-id-badge"></i>
                <span>My Profile</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/student/room.jsp" 
               class="nav-link <%= currentUri.endsWith("room.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-bed"></i>
                <span>Room</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/fee" 
               class="nav-link <%= (currentUri.endsWith("fees.jsp") || (currentUri.contains("/fee") && !currentUri.contains("receipt"))) ? "active" : "" %>">
                <i class="fa-solid fa-file-invoice-dollar"></i>
                <span>Fees</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/student/receipts.jsp" 
               class="nav-link <%= currentUri.endsWith("receipts.jsp") ? "active" : "" %>">
                <i class="fa-solid fa-receipt"></i>
                <span>Receipts</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/complaint" 
               class="nav-link <%= (currentUri.contains("complaint") || currentUri.endsWith("complaints.jsp")) ? "active" : "" %>">
                <i class="fa-solid fa-headset"></i>
                <span>Complaints</span>
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
        <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center fw-bold" style="width: 36px; height: 36px;">
            S
        </div>
        <div class="overflow-hidden">
            <div class="text-white fw-bold text-truncate" style="font-size: 0.85rem;"><%= session.getAttribute("userName") %></div>
            <small class="text-muted d-block text-truncate" style="font-size: 0.75rem;">Resident Student</small>
        </div>
    </div>
</nav>

<!-- Content Wrapper -->
<div id="content-wrapper">
    <!-- Top Navbar -->
    <header class="top-navbar">
        <div class="d-flex align-items-center gap-3">
            <h5 class="mb-0 fw-bold text-dark">Hostel Resident Self-Service Portal</h5>
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
