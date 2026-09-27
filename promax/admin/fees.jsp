<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="dao.FeeDAO" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="dao.FoodPriceDAO" %>
<%@ page import="model.Fee" %>
<%@ page import="model.Student" %>

<%
    List<Fee> feeList = (List<Fee>) request.getAttribute("feeList");
    List<Student> studentList = (List<Student>) request.getAttribute("studentList");
    String filterType = (String) request.getAttribute("filterType");
    if (filterType == null) filterType = "all";

    if (feeList == null) {
        FeeDAO dao = new FeeDAO();
        feeList = "pending".equalsIgnoreCase(filterType) ? dao.getPendingFees() : dao.getAllFees();
    }
    if (studentList == null) {
        studentList = new StudentDAO().getActiveStudents();
    }

    FoodPriceDAO foodPriceDAO = new FoodPriceDAO();
    BigDecimal currentVegPrice = foodPriceDAO.getVegPrice();
    BigDecimal currentNonVegPrice = foodPriceDAO.getNonVegPrice();
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Hostel Fee Management & Invoicing</h3>
            <p class="text-muted mb-0">Assess semester dues, generate structured fee invoices with food plans, and track collections.</p>
        </div>
        <div class="d-flex gap-2">
            <a href="<%= request.getContextPath() %>/admin/food-settings" class="btn btn-outline-secondary">
                <i class="fa-solid fa-sliders me-1"></i> Food Pricing Settings
            </a>
            <button type="button" class="btn btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#generateFeeModal">
                <i class="fa-solid fa-file-invoice-dollar me-2"></i> Generate Student Fee
            </button>
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

    <!-- Filter Buttons -->
    <div class="mb-3 d-flex gap-2">
        <a href="<%= request.getContextPath() %>/admin/fee?action=list" 
           class="btn btn-sm <%= "all".equalsIgnoreCase(filterType) ? "btn-primary fw-semibold" : "btn-light border" %>">
            All Fee Invoices (<%= feeList != null ? feeList.size() : 0 %>)
        </a>
        <a href="<%= request.getContextPath() %>/admin/fee?action=pending" 
           class="btn btn-sm <%= "pending".equalsIgnoreCase(filterType) ? "btn-warning text-dark fw-bold" : "btn-light border" %>">
            <i class="fa-solid fa-clock-rotate-left me-1"></i> Outstanding / Pending Dues
        </a>
    </div>

    <!-- Fee Records Table Card -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 d-flex align-items-center justify-content-between border-bottom">
            <span class="fw-bold text-dark"><i class="fa-solid fa-receipt me-2 text-primary"></i>Fee Assessment & Collection Ledger</span>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Total Records: <%= feeList != null ? feeList.size() : 0 %></span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-4">Receipt #</th>
                            <th>Student</th>
                            <th>Room</th>
                            <th>Hostel Fee</th>
                            <th>Food Plan</th>
                            <th>Total Fee</th>
                            <th>Paid</th>
                            <th>Due Amount</th>
                            <th>Status</th>
                            <th class="text-center pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (feeList != null && !feeList.isEmpty()) { 
                            for (Fee f : feeList) { 
                                String status = f.getStatus();
                                if (status == null) {
                                    if (f.getPaidAmount() == null || f.getPaidAmount().compareTo(BigDecimal.ZERO) == 0) {
                                        status = "Pending";
                                    } else if (f.getDueAmount() != null && f.getDueAmount().compareTo(BigDecimal.ZERO) == 0) {
                                        status = "Complete";
                                    } else {
                                        status = "Partially Paid";
                                    }
                                }
                        %>
                            <tr>
                                <td class="ps-4">
                                    <span class="fw-bold text-primary"><code><%= f.getReceiptNumber() %></code></span>
                                </td>
                                <td>
                                    <div class="fw-bold text-dark"><%= f.getStudentName() != null ? f.getStudentName() : "Student #" + f.getStudentId() %></div>
                                    <small class="text-muted"><%= f.getStudentCourse() != null ? f.getStudentCourse() : "" %> • ID: #<%= f.getStudentId() %></small>
                                </td>
                                <td>
                                    <% if (f.getRoomNumber() != null && !f.getRoomNumber().isEmpty()) { %>
                                        <span class="badge bg-light text-dark border">Room <%= f.getRoomNumber() %></span>
                                    <% } else { %>
                                        <span class="text-muted small">N/A</span>
                                    <% } %>
                                </td>
                                <td>₹ <%= f.getHostelFee() != null ? f.getHostelFee() : f.getTotalFee() %></td>
                                <td>
                                    <% String ft = f.getFoodType() != null ? f.getFoodType() : "Veg"; %>
                                    <span class="badge <%= "Non-Veg".equalsIgnoreCase(ft) ? "bg-danger-subtle text-danger" : ("Veg".equalsIgnoreCase(ft) ? "bg-success-subtle text-success" : "bg-secondary-subtle text-secondary") %> px-2 py-1">
                                        <%= ft %>
                                    </span>
                                    <small class="text-muted d-block">₹ <%= f.getFoodAmount() != null ? f.getFoodAmount() : "0.00" %></small>
                                </td>
                                <td><strong>₹ <%= f.getTotalFee() %></strong></td>
                                <td><span class="text-success fw-bold">₹ <%= f.getPaidAmount() != null ? f.getPaidAmount() : "0.00" %></span></td>
                                <td>
                                    <% if (f.getDueAmount() != null && f.getDueAmount().compareTo(BigDecimal.ZERO) > 0) { %>
                                        <span class="text-danger fw-bold">₹ <%= f.getDueAmount() %></span>
                                    <% } else { %>
                                        <span class="text-muted">₹ 0.00</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if ("Complete".equalsIgnoreCase(status) || "Paid in Full".equalsIgnoreCase(status)) { %>
                                        <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">
                                            <i class="fa-solid fa-check me-1"></i> Complete
                                        </span>
                                    <% } else if ("Partially Paid".equalsIgnoreCase(status)) { %>
                                        <span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1">
                                            <i class="fa-solid fa-hourglass-half me-1"></i> Partially Paid
                                        </span>
                                    <% } else { %>
                                        <span class="badge bg-danger-subtle text-danger border border-danger-subtle px-2 py-1">
                                            <i class="fa-solid fa-circle-exclamation me-1"></i> Pending
                                        </span>
                                    <% } %>
                                </td>
                                <td class="text-center pe-4">
                                    <div class="btn-group btn-group-sm">
                                        <a href="<%= request.getContextPath() %>/receipt?receipt=<%= f.getReceiptNumber() %>" 
                                           target="_blank" class="btn btn-outline-primary" title="Print Fee Receipt">
                                            <i class="fa-solid fa-print me-1"></i> Receipt
                                        </a>
                                        <% if (f.getDueAmount() != null && f.getDueAmount().compareTo(BigDecimal.ZERO) > 0) { %>
                                        <button type="button" class="btn btn-outline-success" 
                                                onclick="openPayModal('<%= f.getFeeId() %>', '<%= f.getStudentName() %>', '<%= f.getDueAmount() %>')"
                                                title="Record Payment">
                                            <i class="fa-solid fa-money-bill-wave"></i> Pay
                                        </button>
                                        <% } %>
                                        <button type="button" class="btn btn-outline-danger" 
                                                onclick="confirmDelete('<%= request.getContextPath() %>/admin/fee?action=delete&id=<%= f.getFeeId() %>', 'fee record')"
                                                title="Delete Record">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr>
                                <td colspan="10" class="text-center py-5">
                                    <div class="text-muted">
                                        <i class="fa-solid fa-receipt fa-3x mb-3 text-secondary opacity-50"></i>
                                        <h5>No Fee Records Found</h5>
                                        <p class="small mb-3">No student fees have been generated yet.</p>
                                        <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#generateFeeModal">
                                            <i class="fa-solid fa-plus me-1"></i> Generate First Fee
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- 1. Generate Fee Modal (With Live Dynamic Calculation & Food Tariff) -->
<div class="modal fade" id="generateFeeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content border-0 shadow">
            <form action="<%= request.getContextPath() %>/admin/fee" method="post" id="generateFeeForm">
                <input type="hidden" name="action" value="generate">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-file-invoice-dollar me-2"></i>Generate Student Fee Invoice</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="row g-3">
                        <!-- Student Selection -->
                        <div class="col-md-12">
                            <label class="form-label fw-bold text-dark">Select Student <span class="text-danger">*</span></label>
                            <select name="studentId" class="form-select form-select-lg" required>
                                <option value="">-- Choose Active Student --</option>
                                <% if (studentList != null) { 
                                    for (Student s : studentList) { %>
                                    <option value="<%= s.getStudentId() %>">
                                        <%= s.getName() %> (ID: #<%= s.getStudentId() %>, <%= s.getCourse() %>, <%= s.getRoomNumber() != null ? "Room " + s.getRoomNumber() : "No Room" %>)
                                    </option>
                                <% } } %>
                            </select>
                        </div>

                        <!-- 1. Base Hostel Fee -->
                        <div class="col-md-4">
                            <label class="form-label fw-semibold text-dark">Base Hostel Fee (₹) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text bg-light">₹</span>
                                <input type="number" step="0.01" min="0" name="hostelFee" id="genHostelFee" class="form-control fw-bold" placeholder="e.g. 20000" value="20000" required oninput="recalcFee()">
                            </div>
                            <small class="text-muted">Room, electricity & amenities</small>
                        </div>

                        <!-- 2. Food Option Selection -->
                        <div class="col-md-4">
                            <label class="form-label fw-semibold text-dark">Food / Mess Plan <span class="text-danger">*</span></label>
                            <select name="foodType" id="genFoodType" class="form-select fw-semibold" required onchange="onFoodTypeChange()">
                                <option value="Veg" selected>Veg (₹ <%= currentVegPrice %>)</option>
                                <option value="Non-Veg">Non-Veg (₹ <%= currentNonVegPrice %>)</option>
                                <option value="No Food">No Food (₹ 0.00)</option>
                            </select>
                            <input type="hidden" name="foodAmount" id="genFoodAmount" value="<%= currentVegPrice %>">
                            <small class="text-muted">Auto-populated tariff</small>
                        </div>

                        <!-- 3. Other Charges -->
                        <div class="col-md-4">
                            <label class="form-label fw-semibold text-dark">Other Charges (₹)</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light">₹</span>
                                <input type="number" step="0.01" min="0" name="otherCharges" id="genOtherCharges" class="form-control" placeholder="0" value="0" oninput="recalcFee()">
                            </div>
                            <small class="text-muted">Caution deposit / admin dues</small>
                        </div>

                        <!-- Live Calculation Summary Card -->
                        <div class="col-md-12">
                            <div class="p-3 bg-light rounded-3 border">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="text-muted small fw-bold text-uppercase">Fee Assessment Breakdown</span>
                                    <span class="badge bg-primary-subtle text-primary">Formula: Hostel Fee + Food Amount + Other Charges</span>
                                </div>
                                <div class="row text-center g-2 pt-2 border-top">
                                    <div class="col-3">
                                        <small class="text-muted d-block">Hostel Fee</small>
                                        <strong class="text-dark" id="displayHostel">₹ 20,000.00</strong>
                                    </div>
                                    <div class="col-1 d-flex align-items-center justify-content-center text-muted fw-bold">+</div>
                                    <div class="col-3">
                                        <small class="text-muted d-block">Food Amount (<span id="displayFoodLabel">Veg</span>)</small>
                                        <strong class="text-success" id="displayFood">₹ <%= currentVegPrice %></strong>
                                    </div>
                                    <div class="col-1 d-flex align-items-center justify-content-center text-muted fw-bold">+</div>
                                    <div class="col-2">
                                        <small class="text-muted d-block">Other</small>
                                        <strong class="text-dark" id="displayOther">₹ 0.00</strong>
                                    </div>
                                    <div class="col-2 bg-primary bg-opacity-10 rounded p-2">
                                        <small class="text-primary fw-bold d-block">Total Assessed Fee</small>
                                        <span class="fs-5 fw-bold text-primary" id="displayTotal">₹ 0.00</span>
                                        <input type="hidden" name="totalFee" id="genTotalFee" value="0">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Initial Payment (Optional) -->
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Initial Amount Paid Now (₹)</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light">₹</span>
                                <input type="number" step="0.01" min="0" name="paidAmount" id="genPaidAmount" class="form-control" placeholder="0 (Default: Unpaid)" value="0" oninput="recalcFee()">
                            </div>
                            <small class="text-muted">Enter ₹0 to create as Pending with full Due</small>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-dark">Payment Mode</label>
                            <select name="paymentMode" class="form-select">
                                <option value="UPI">UPI (Google Pay / PhonePe / Paytm)</option>
                                <option value="Cash" selected>Cash</option>
                                <option value="Bank Transfer">Bank Transfer (NEFT/IMPS)</option>
                                <option value="Cheque / DD">Cheque / DD</option>
                            </select>
                        </div>

                        <!-- Resulting Status & Due Preview -->
                        <div class="col-md-12">
                            <div class="p-3 bg-white rounded border d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="text-muted small d-block">Resulting Initial Balance (Due):</span>
                                    <span class="text-danger fw-bold fs-5" id="displayDue">₹ 0.00</span>
                                </div>
                                <div>
                                    <span class="text-muted small d-block">Initial Fee Status:</span>
                                    <span class="badge bg-danger fs-6 px-3 py-1" id="displayStatusBadge">Pending</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-light border" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary px-4 fw-bold shadow-sm">
                        <i class="fa-solid fa-file-circle-check me-1"></i> Generate & Issue Fee
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 2. Offline Payment Collection Modal -->
<div class="modal fade" id="offlinePayModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content border-0 shadow">
            <form action="<%= request.getContextPath() %>/admin/fee" method="post">
                <input type="hidden" name="action" value="payOffline">
                <input type="hidden" name="feeId" id="payFeeId" value="">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-cash-register me-2"></i>Record Offline Payment</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">Student Name</label>
                        <input type="text" id="payStudentName" class="form-control bg-light fw-bold" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold">Outstanding Balance (Due)</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light fw-bold">₹</span>
                            <input type="text" id="payDueAmount" class="form-control bg-light text-danger fw-bold" readonly>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-dark">Amount Being Paid (₹) <span class="text-danger">*</span></label>
                        <div class="input-group">
                            <span class="input-group-text bg-light fw-bold">₹</span>
                            <input type="number" step="0.01" min="1" name="amountPaid" id="payAmountInput" class="form-control fw-bold text-success fs-5" required>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold text-dark">Payment Mode <span class="text-danger">*</span></label>
                        <select name="paymentMode" class="form-select" required>
                            <option value="Cash" selected>Cash</option>
                            <option value="UPI">UPI</option>
                            <option value="Bank Transfer">Bank Transfer</option>
                            <option value="Cheque / DD">Cheque / DD</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer bg-light">
                    <button type="button" class="btn btn-light border" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-success px-4 fw-bold shadow-sm">
                        <i class="fa-solid fa-check me-1"></i> Confirm Payment
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
const VEG_PRICE = <%= currentVegPrice %>;
const NON_VEG_PRICE = <%= currentNonVegPrice %>;

function onFoodTypeChange() {
    const foodType = document.getElementById('genFoodType').value;
    let price = 0;
    if (foodType === 'Veg') {
        price = VEG_PRICE;
    } else if (foodType === 'Non-Veg') {
        price = NON_VEG_PRICE;
    } else {
        price = 0;
    }
    document.getElementById('genFoodAmount').value = price;
    document.getElementById('displayFoodLabel').innerText = foodType;
    document.getElementById('displayFood').innerText = '₹ ' + Number(price).toLocaleString('en-IN', {minimumFractionDigits: 2});
    recalcFee();
}

function recalcFee() {
    const hostelFee = parseFloat(document.getElementById('genHostelFee').value) || 0;
    const foodAmount = parseFloat(document.getElementById('genFoodAmount').value) || 0;
    const otherCharges = parseFloat(document.getElementById('genOtherCharges').value) || 0;
    const paidAmount = parseFloat(document.getElementById('genPaidAmount').value) || 0;

    const totalFee = hostelFee + foodAmount + otherCharges;
    const dueAmount = Math.max(0, totalFee - paidAmount);

    document.getElementById('genTotalFee').value = totalFee.toFixed(2);
    document.getElementById('displayHostel').innerText = '₹ ' + hostelFee.toLocaleString('en-IN', {minimumFractionDigits: 2});
    document.getElementById('displayOther').innerText = '₹ ' + otherCharges.toLocaleString('en-IN', {minimumFractionDigits: 2});
    document.getElementById('displayTotal').innerText = '₹ ' + totalFee.toLocaleString('en-IN', {minimumFractionDigits: 2});
    document.getElementById('displayDue').innerText = '₹ ' + dueAmount.toLocaleString('en-IN', {minimumFractionDigits: 2});

    const statusBadge = document.getElementById('displayStatusBadge');
    if (totalFee === 0) {
        statusBadge.className = 'badge bg-secondary fs-6 px-3 py-1';
        statusBadge.innerText = 'Pending';
    } else if (paidAmount === 0) {
        statusBadge.className = 'badge bg-danger fs-6 px-3 py-1';
        statusBadge.innerText = 'Pending';
    } else if (paidAmount >= totalFee) {
        statusBadge.className = 'badge bg-success fs-6 px-3 py-1';
        statusBadge.innerText = 'Complete';
    } else {
        statusBadge.className = 'badge bg-warning text-dark fs-6 px-3 py-1';
        statusBadge.innerText = 'Partially Paid';
    }
}

function openPayModal(feeId, studentName, dueAmount) {
    document.getElementById('payFeeId').value = feeId;
    document.getElementById('payStudentName').value = studentName;
    document.getElementById('payDueAmount').value = dueAmount;
    document.getElementById('payAmountInput').value = dueAmount;
    document.getElementById('payAmountInput').max = dueAmount;
    var myModal = new bootstrap.Modal(document.getElementById('offlinePayModal'));
    myModal.show();
}

// Initial calculation on page load
document.addEventListener('DOMContentLoaded', function() {
    onFoodTypeChange();
});
</script>

<jsp:include page="includes/footer.jsp" />
