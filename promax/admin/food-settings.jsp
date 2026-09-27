<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="dao.FoodPriceDAO" %>

<%
    BigDecimal vegPrice = (BigDecimal) request.getAttribute("vegPrice");
    BigDecimal nonVegPrice = (BigDecimal) request.getAttribute("nonVegPrice");

    if (vegPrice == null || nonVegPrice == null) {
        FoodPriceDAO dao = new FoodPriceDAO();
        vegPrice = dao.getVegPrice();
        nonVegPrice = dao.getNonVegPrice();
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Food & Mess Pricing Settings</h3>
            <p class="text-muted mb-0">Configure standard meal rates applied automatically during fee invoice generation.</p>
        </div>
        <div>
            <a href="<%= request.getContextPath() %>/admin/fee?action=list" class="btn btn-outline-primary">
                <i class="fa-solid fa-file-invoice-dollar me-1"></i> Fee Management
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

    <div class="row g-4">
        <!-- Settings Form Card -->
        <div class="col-lg-7">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white py-3 border-bottom">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-sliders me-2 text-primary"></i>Configured Food Tariff</span>
                </div>
                <div class="card-body p-4">
                    <form action="<%= request.getContextPath() %>/admin/food-settings" method="post">
                        <!-- 1. Vegetarian Pricing -->
                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark d-flex align-items-center gap-2">
                                <span class="badge bg-success-subtle text-success p-2 rounded-circle"><i class="fa-solid fa-leaf"></i></span>
                                <span>Vegetarian Meal Plan (₹ / Term) <span class="text-danger">*</span></span>
                            </label>
                            <div class="input-group input-group-lg">
                                <span class="input-group-text bg-light fw-bold text-muted">₹</span>
                                <input type="number" step="0.01" min="0" name="vegPrice" class="form-control fw-bold text-success fs-5" 
                                       value="<%= vegPrice %>" placeholder="e.g. 3000" required>
                            </div>
                            <small class="text-muted">Standard vegetarian mess fee applied when "Veg" option is selected.</small>
                        </div>

                        <!-- 2. Non-Vegetarian Pricing -->
                        <div class="mb-4">
                            <label class="form-label fw-bold text-dark d-flex align-items-center gap-2">
                                <span class="badge bg-danger-subtle text-danger p-2 rounded-circle"><i class="fa-solid fa-drumstick-bite"></i></span>
                                <span>Non-Vegetarian Meal Plan (₹ / Term) <span class="text-danger">*</span></span>
                            </label>
                            <div class="input-group input-group-lg">
                                <span class="input-group-text bg-light fw-bold text-muted">₹</span>
                                <input type="number" step="0.01" min="0" name="nonVegPrice" class="form-control fw-bold text-danger fs-5" 
                                       value="<%= nonVegPrice %>" placeholder="e.g. 4000" required>
                            </div>
                            <small class="text-muted">Standard non-vegetarian mess fee applied when "Non-Veg" option is selected.</small>
                        </div>

                        <!-- 3. No Food / Self Catered -->
                        <div class="mb-4 p-3 bg-light rounded-3 border">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="fw-bold text-dark"><i class="fa-solid fa-ban me-1 text-muted"></i> No Food Option</div>
                                    <small class="text-muted">For students managing own meals or opting out of hostel mess.</small>
                                </div>
                                <span class="badge bg-secondary-subtle text-secondary fs-6 px-3 py-2 fw-bold">Fixed at ₹ 0.00</span>
                            </div>
                        </div>

                        <div class="pt-3 border-top d-flex justify-content-end gap-2">
                            <button type="submit" class="btn btn-primary px-4 py-2 fw-bold shadow-sm">
                                <i class="fa-solid fa-floppy-disk me-2"></i> Save Pricing Settings
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Rules & Guidance Card -->
        <div class="col-lg-5">
            <div class="card border-0 shadow-sm bg-light">
                <div class="card-header bg-white py-3 border-bottom">
                    <span class="fw-bold text-dark"><i class="fa-solid fa-circle-info me-2 text-primary"></i>Food Pricing Rules</span>
                </div>
                <div class="card-body p-4">
                    <ul class="list-unstyled mb-0 d-flex flex-column gap-3">
                        <li class="d-flex gap-2">
                            <i class="fa-solid fa-check text-success mt-1"></i>
                            <div>
                                <strong>Admin-Controlled Only:</strong>
                                <p class="text-muted small mb-0">Students cannot modify or manually override food prices.</p>
                            </div>
                        </li>
                        <li class="d-flex gap-2">
                            <i class="fa-solid fa-check text-success mt-1"></i>
                            <div>
                                <strong>Applied on Generation:</strong>
                                <p class="text-muted small mb-0">Fee generation automatically pulls the price configured here based on the selected food type.</p>
                            </div>
                        </li>
                        <li class="d-flex gap-2">
                            <i class="fa-solid fa-shield-halved text-primary mt-1"></i>
                            <div>
                                <strong>Historical Price Integrity:</strong>
                                <p class="text-muted small mb-0">Changing prices will ONLY affect newly generated fee invoices. Previously issued receipts and historical transactions are permanently preserved with their original saved amounts.</p>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="includes/footer.jsp" />
