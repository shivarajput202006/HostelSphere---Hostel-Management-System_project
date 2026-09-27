<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="dao.RoomDAO" %>
<%@ page import="model.Room" %>

<%
    List<Room> roomList = (List<Room>) request.getAttribute("roomList");
    if (roomList == null) {
        RoomDAO dao = new RoomDAO();
        roomList = dao.getAllRooms();
    }
    String currentFilter = (String) request.getAttribute("currentFilter");
    if (currentFilter == null) currentFilter = "all";
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4">
        <div>
            <h3 class="fw-bold text-dark mb-1">Room Management</h3>
            <p class="text-muted mb-0">Manage hostel inventory, bed availability, floors, and room categories.</p>
        </div>
        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addRoomModal">
            <i class="fa-solid fa-plus me-2"></i> Add New Room
        </button>
    </div>

    <!-- Filter Pills -->
    <div class="mb-3 d-flex gap-2">
        <a href="<%= request.getContextPath() %>/admin/room?action=list" 
           class="btn btn-sm <%= ("all".equalsIgnoreCase(currentFilter) || "list".equalsIgnoreCase(currentFilter)) ? "btn-primary" : "btn-light" %>">
            All Rooms
        </a>
        <a href="<%= request.getContextPath() %>/admin/room?action=available" 
           class="btn btn-sm <%= "available".equalsIgnoreCase(currentFilter) ? "btn-primary" : "btn-light" %>">
            <i class="fa-solid fa-circle-check me-1 text-success"></i> Available Only
        </a>
    </div>

    <!-- Rooms Table Card -->
    <div class="card">
        <div class="card-header d-flex align-items-center justify-content-between">
            <span class="fw-bold"><i class="fa-solid fa-door-open me-2 text-primary"></i>Hostel Rooms & Bed Status</span>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Total: <%= roomList.size() %> Rooms</span>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover datatable align-middle">
                    <thead>
                        <tr>
                            <th>Room No.</th>
                            <th>Floor</th>
                            <th>Room Type</th>
                            <th>Total Beds</th>
                            <th>Occupied</th>
                            <th>Available</th>
                            <th>Status</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (roomList != null && !roomList.isEmpty()) { 
                            for (Room r : roomList) { 
                                int avail = r.getAvailableBeds();
                                int total = r.getTotalBeds();
                                int occupied = r.getOccupiedBeds();
                                int percentOccupied = (total > 0) ? (occupied * 100 / total) : 0;
                        %>
                            <tr>
                                <td>
                                    <strong class="fs-6 text-primary">Room <%= r.getRoomNumber() %></strong>
                                </td>
                                <td>Floor <%= r.getFloor() %></td>
                                <td><%= r.getRoomType() %></td>
                                <td><span class="badge bg-light text-dark border px-2 py-1"><%= total %> Beds</span></td>
                                <td><span class="badge bg-danger-subtle text-danger"><%= occupied %></span></td>
                                <td><span class="badge bg-success-subtle text-success fw-bold"><%= avail %></span></td>
                                <td>
                                    <% if (avail > 0) { %>
                                        <span class="badge badge-available"><i class="fa-solid fa-check me-1"></i> Available</span>
                                    <% } else { %>
                                        <span class="badge badge-occupied"><i class="fa-solid fa-ban me-1"></i> Fully Occupied</span>
                                    <% } %>
                                    <div class="progress mt-2" style="height: 6px; width: 100px;">
                                        <div class="progress-bar <%= avail == 0 ? "bg-danger" : "bg-primary" %>" 
                                             style="width: <%= percentOccupied %>%;"></div>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <div class="btn-group btn-group-sm">
                                        <button type="button" class="btn btn-outline-warning" 
                                                onclick="openEditModal(<%= r.getRoomId() %>, '<%= r.getRoomNumber() %>', <%= r.getFloor() %>, '<%= r.getRoomType() %>', <%= r.getTotalBeds() %>)"
                                                title="Edit Room">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </button>
                                        <button type="button" class="btn btn-outline-danger" 
                                                onclick="confirmDelete('<%= request.getContextPath() %>/admin/room?action=delete&id=<%= r.getRoomId() %>', 'room')"
                                                title="Delete Room">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 1. Add Room Modal -->
<div class="modal fade" id="addRoomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/room" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-plus-circle me-2 text-primary"></i>Add New Room</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Room Number <span class="text-danger">*</span></label>
                        <input type="text" name="roomNumber" class="form-control" placeholder="e.g. 105" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Floor Number <span class="text-danger">*</span></label>
                        <input type="number" name="floor" class="form-control" min="0" max="10" placeholder="e.g. 1" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Room Sharing Type <span class="text-danger">*</span></label>
                        <select name="roomType" class="form-select" required>
                            <option value="Single Sharing">Single Sharing (1 Bed)</option>
                            <option value="Double Sharing" selected>Double Sharing (2 Beds)</option>
                            <option value="Triple Sharing">Triple Sharing (3 Beds)</option>
                            <option value="Four Sharing">Four Sharing (4 Beds)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Total Beds in Room <span class="text-danger">*</span></label>
                        <input type="number" name="totalBeds" class="form-control" min="1" max="6" value="2" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-check me-1"></i> Save Room
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 2. Edit Room Modal -->
<div class="modal fade" id="editRoomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="<%= request.getContextPath() %>/admin/room" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="roomId" id="editRoomId">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2 text-warning"></i>Edit Room Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Room Number <span class="text-danger">*</span></label>
                        <input type="text" name="roomNumber" id="editRoomNumber" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Floor Number <span class="text-danger">*</span></label>
                        <input type="number" name="floor" id="editFloor" class="form-control" min="0" max="10" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Room Sharing Type <span class="text-danger">*</span></label>
                        <select name="roomType" id="editRoomType" class="form-select" required>
                            <option value="Single Sharing">Single Sharing (1 Bed)</option>
                            <option value="Double Sharing">Double Sharing (2 Beds)</option>
                            <option value="Triple Sharing">Triple Sharing (3 Beds)</option>
                            <option value="Four Sharing">Four Sharing (4 Beds)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Total Beds <span class="text-danger">*</span></label>
                        <input type="number" name="totalBeds" id="editTotalBeds" class="form-control" min="1" max="6" required>
                        <small class="text-muted">Note: Total beds cannot be less than currently occupied beds.</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-floppy-disk me-1"></i> Update Room
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function openEditModal(id, number, floor, type, beds) {
    document.getElementById("editRoomId").value = id;
    document.getElementById("editRoomNumber").value = number;
    document.getElementById("editFloor").value = floor;
    document.getElementById("editRoomType").value = type;
    document.getElementById("editTotalBeds").value = beds;
    new bootstrap.Modal(document.getElementById("editRoomModal")).show();
}
</script>

<jsp:include page="includes/footer.jsp" />
