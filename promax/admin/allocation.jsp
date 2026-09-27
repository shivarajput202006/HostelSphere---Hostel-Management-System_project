<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.AllocationDAO" %>
<%@ page import="dao.RoomDAO" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="model.Allocation" %>
<%@ page import="model.Room" %>
<%@ page import="model.Student" %>

<%
    List<Allocation> allocationList = (List<Allocation>) request.getAttribute("allocationList");
    List<Room> availableRooms = (List<Room>) request.getAttribute("availableRooms");
    List<Student> studentsWithoutRoom = (List<Student>) request.getAttribute("studentsWithoutRoom");
    String viewType = (String) request.getAttribute("viewType");
    if (viewType == null) viewType = "active";

    if (allocationList == null) {
        AllocationDAO dao = new AllocationDAO();
        allocationList = "history".equalsIgnoreCase(viewType) ? dao.getAllAllocationsHistory() : dao.getActiveAllocations();
    }
    if (availableRooms == null) {
        availableRooms = new RoomDAO().getAvailableRooms();
    }
    if (studentsWithoutRoom == null) {
        studentsWithoutRoom = new StudentDAO().getStudentsWithoutRoom();
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Room Allocation Module</h3>
            <p class="text-muted mb-0">Assign students to vacant beds with transactional capacity updates.</p>
        </div>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#allocateModal">
                <i class="fa-solid fa-bed me-2"></i> Allocate Bed to Student
            </button>
        </div>
    </div>

    <!-- View Toggle Pills -->
    <div class="mb-3 d-flex gap-2">
        <a href="<%= request.getContextPath() %>/admin/allocation?action=list" 
           class="btn btn-sm <%= "active".equalsIgnoreCase(viewType) ? "btn-primary" : "btn-light" %>">
            <i class="fa-solid fa-circle-check me-1"></i> Active Allocations
        </a>
        <a href="<%= request.getContextPath() %>/admin/allocation?action=history" 
           class="btn btn-sm <%= "history".equalsIgnoreCase(viewType) ? "btn-primary" : "btn-light" %>">
            <i class="fa-solid fa-clock-rotate-left me-1"></i> Complete Allocation History
        </a>
    </div>

    <!-- Allocations Table Card -->
    <div class="card">
        <div class="card-header d-flex align-items-center justify-content-between">
            <span class="fw-bold"><i class="fa-solid fa-list-check me-2 text-primary"></i>Resident Allocations</span>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Count: <%= allocationList.size() %></span>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover datatable align-middle">
                    <thead>
                        <tr>
                            <th>Allocation ID</th>
                            <th>Student Details</th>
                            <th>Allocated Room</th>
                            <th>Allocation Date</th>
                            <th>Vacate Date</th>
                            <th>Status</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (allocationList != null && !allocationList.isEmpty()) { 
                            for (Allocation a : allocationList) { 
                                boolean isActive = "Active".equalsIgnoreCase(a.getStatus());
                        %>
                            <tr>
                                <td><span class="badge bg-light text-dark border">#ALC-<%= a.getAllocationId() %></span></td>
                                <td>
                                    <div class="fw-bold text-dark"><%= a.getStudentName() %></div>
                                    <small class="text-muted"><%= a.getStudentCourse() %> • <%= a.getStudentMobile() %></small>
                                </td>
                                <td>
                                    <span class="badge badge-available">
                                        <i class="fa-solid fa-door-open me-1"></i> Room <%= a.getRoomNumber() %>
                                    </span>
                                    <div class="small text-muted mt-1">Floor <%= a.getRoomFloor() %> • <%= a.getRoomType() %></div>
                                </td>
                                <td><%= a.getAllocationDate() %></td>
                                <td><%= a.getVacateDate() != null ? a.getVacateDate() : "-" %></td>
                                <td>
                                    <span class="badge <%= isActive ? "badge-active" : "badge-vacated" %>">
                                        <%= a.getStatus() %>
                                    </span>
                                </td>
                                <td class="text-center">
                                    <% if (isActive) { %>
                                        <div class="btn-group btn-group-sm">
                                            <button type="button" class="btn btn-outline-warning" 
                                                    onclick="openChangeModal(<%= a.getAllocationId() %>, '<%= a.getStudentName() %>', '<%= a.getRoomNumber() %>')"
                                                    title="Change Room">
                                                <i class="fa-solid fa-arrows-rotate"></i> Change
                                            </button>
                                            <button type="button" class="btn btn-outline-danger" 
                                                    onclick="confirmVacate('<%= request.getContextPath() %>/admin/allocation?action=vacate&id=<%= a.getAllocationId() %>')"
                                                    title="Vacate Bed">
                                                <i class="fa-solid fa-person-walking-dashed-line-arrow-right"></i> Vacate
                                            </button>
                                        </div>
                                    <% } else { %>
                                        <span class="text-muted small"><i class="fa-solid fa-check-double me-1"></i>Archived</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 1. Allocate Room Modal -->
<div class="modal fade" id="allocateModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/allocation" method="post">
                <input type="hidden" name="action" value="allocate">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-bed me-2 text-primary"></i>Allocate Room Bed</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <!-- Select Student -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Select Resident Student <span class="text-danger">*</span></label>
                        <% if (studentsWithoutRoom != null && !studentsWithoutRoom.isEmpty()) { %>
                            <select name="studentId" class="form-select" required>
                                <option value="">-- Choose Student without Room --</option>
                                <% for (Student s : studentsWithoutRoom) { %>
                                    <option value="<%= s.getStudentId() %>">
                                        <%= s.getName() %> (ID: <%= s.getStudentId() %>, <%= s.getCourse() %>)
                                    </option>
                                <% } %>
                            </select>
                        <% } else { %>
                            <div class="alert alert-info py-2 mb-0" style="font-size: 0.85rem;">
                                <i class="fa-solid fa-info-circle me-1"></i> All enrolled students already have active room allocations.
                            </div>
                        <% } %>
                    </div>

                    <!-- Select Room -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Select Vacant Room <span class="text-danger">*</span></label>
                        <% if (availableRooms != null && !availableRooms.isEmpty()) { %>
                            <select name="roomId" class="form-select" required>
                                <option value="">-- Choose Room with Available Bed --</option>
                                <% for (Room r : availableRooms) { %>
                                    <option value="<%= r.getRoomId() %>">
                                        Room <%= r.getRoomNumber() %> (Floor <%= r.getFloor() %>, <%= r.getRoomType() %> - <%= r.getAvailableBeds() %> Bed(s) Free)
                                    </option>
                                <% } %>
                            </select>
                        <% } else { %>
                            <div class="alert alert-danger py-2 mb-0" style="font-size: 0.85rem;">
                                <i class="fa-solid fa-triangle-exclamation me-1"></i> No rooms with vacant beds currently available.
                            </div>
                        <% } %>
                    </div>

                    <!-- Allocation Date -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Allocation Date <span class="text-danger">*</span></label>
                        <input type="date" name="allocationDate" class="form-control" 
                               value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary" 
                            <%= (studentsWithoutRoom == null || studentsWithoutRoom.isEmpty() || availableRooms == null || availableRooms.isEmpty()) ? "disabled" : "" %>>
                        <i class="fa-solid fa-check me-1"></i> Confirm Allocation
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 2. Change Room Modal -->
<div class="modal fade" id="changeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/allocation" method="post">
                <input type="hidden" name="action" value="change">
                <input type="hidden" name="allocationId" id="changeAllocId">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-arrows-rotate me-2 text-warning"></i>Transfer Room</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Student</label>
                        <input type="text" id="changeStudentName" class="form-control bg-light" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Current Room</label>
                        <input type="text" id="changeCurrentRoom" class="form-control bg-light" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Select New Room <span class="text-danger">*</span></label>
                        <select name="newRoomId" class="form-select" required>
                            <option value="">-- Choose New Room --</option>
                            <% if (availableRooms != null) { 
                                for (Room r : availableRooms) { %>
                                <option value="<%= r.getRoomId() %>">
                                    Room <%= r.getRoomNumber() %> (Floor <%= r.getFloor() %>, <%= r.getRoomType() %> - <%= r.getAvailableBeds() %> Free)
                                </option>
                            <% } } %>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Transfer Student</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openChangeModal(allocId, studentName, currentRoom) {
    document.getElementById("changeAllocId").value = allocId;
    document.getElementById("changeStudentName").value = studentName;
    document.getElementById("changeCurrentRoom").value = "Room " + currentRoom;
    new bootstrap.Modal(document.getElementById("changeModal")).show();
}
</script>

<jsp:include page="includes/footer.jsp" />
