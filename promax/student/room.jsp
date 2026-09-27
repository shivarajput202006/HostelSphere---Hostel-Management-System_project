<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.AllocationDAO" %>
<%@ page import="model.Allocation" %>

<%
    int studentId = (Integer) session.getAttribute("studentId");
    AllocationDAO dao = new AllocationDAO();
    Allocation a = dao.getActiveAllocationByStudent(studentId);
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">My Allocated Room</h3>
            <p class="text-muted mb-0">Details regarding your allocated hostel accommodation and amenities.</p>
        </div>
    </div>

    <% if (a != null) { %>
        <div class="row g-4">
            <!-- Room Highlight Card -->
            <div class="col-lg-6">
                <div class="card h-100">
                    <div class="card-header bg-light d-flex justify-content-between align-items-center">
                        <span class="fw-bold"><i class="fa-solid fa-door-open me-2 text-primary"></i>Room Specifications</span>
                        <span class="badge badge-active"><i class="fa-solid fa-circle-check me-1"></i>Active Residency</span>
                    </div>
                    <div class="card-body">
                        <div class="d-flex align-items-center gap-3 mb-4 pb-3 border-bottom">
                            <div class="rounded-3 bg-primary text-white d-flex align-items-center justify-content-center" style="width: 56px; height: 56px;">
                                <i class="fa-solid fa-bed fa-2x"></i>
                            </div>
                            <div>
                                <h3 class="fw-extrabold mb-0 text-dark">Room <%= a.getRoomNumber() %></h3>
                                <div class="text-muted"><%= a.getRoomType() %> • Floor <%= a.getRoomFloor() %></div>
                            </div>
                        </div>

                        <div class="row g-3">
                            <div class="col-6">
                                <small class="text-muted d-block">Allocation Reference ID:</small>
                                <span class="fw-bold">#ALC-<%= a.getAllocationId() %></span>
                            </div>
                            <div class="col-6">
                                <small class="text-muted d-block">Allotment Date:</small>
                                <span class="fw-bold text-primary"><%= a.getAllocationDate() %></span>
                            </div>
                            <div class="col-6">
                                <small class="text-muted d-block">Hostel Block:</small>
                                <span class="fw-semibold">Block A (Main Campus Wing)</span>
                            </div>
                            <div class="col-6">
                                <small class="text-muted d-block">Checkout Status:</small>
                                <span class="badge bg-success-subtle text-success">Occupying Bed</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Standard Amenities Card -->
            <div class="col-lg-6">
                <div class="card h-100">
                    <div class="card-header bg-light">
                        <span class="fw-bold"><i class="fa-solid fa-shield-halved me-2 text-primary"></i>Hostel Room Inclusions & Amenities</span>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex align-items-center gap-3 px-0">
                                <i class="fa-solid fa-wifi text-primary fa-lg"></i>
                                <div>
                                    <div class="fw-semibold">High-Speed Campus Wi-Fi</div>
                                    <small class="text-muted">24/7 unlimited academic broadband access</small>
                                </div>
                            </li>
                            <li class="list-group-item d-flex align-items-center gap-3 px-0">
                                <i class="fa-solid fa-lightbulb text-warning fa-lg"></i>
                                <div>
                                    <div class="fw-semibold">24x7 Power Backup</div>
                                    <small class="text-muted">Generator back-up for fan and study illumination</small>
                                </div>
                            </li>
                            <li class="list-group-item d-flex align-items-center gap-3 px-0">
                                <i class="fa-solid fa-droplet text-info fa-lg"></i>
                                <div>
                                    <div class="fw-semibold">Hot & Cold Water Supply</div>
                                    <small class="text-muted">Solar & electric geysers in attached facilities</small>
                                </div>
                            </li>
                            <li class="list-group-item d-flex align-items-center gap-3 px-0">
                                <i class="fa-solid fa-broom text-success fa-lg"></i>
                                <div>
                                    <div class="fw-semibold">Daily Housekeeping</div>
                                    <small class="text-muted">Corridor cleaning and scheduled room waste clearing</small>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    <% } else { %>
        <div class="card p-5 text-center">
            <div class="mx-auto mb-3 text-warning">
                <i class="fa-solid fa-bed fa-4x"></i>
            </div>
            <h4 class="fw-bold text-dark">No Active Room Allocation Found</h4>
            <p class="text-muted" style="max-width: 500px; margin: 0 auto;">
                You are currently not assigned to any hostel room or bed. Please contact the Chief Warden or Hostel Admin office for room allotment.
            </p>
        </div>
    <% } %>
</div>

<jsp:include page="includes/footer.jsp" />
