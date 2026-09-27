<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="dao.AllocationDAO" %>
<%@ page import="dao.FeeDAO" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="model.Student" %>
<%@ page import="model.Allocation" %>
<%@ page import="model.Fee" %>
<%@ page import="model.Complaint" %>

<%
    int studentId = (Integer) session.getAttribute("studentId");
    StudentDAO studentDAO = new StudentDAO();
    AllocationDAO allocationDAO = new AllocationDAO();
    FeeDAO feeDAO = new FeeDAO();
    ComplaintDAO complaintDAO = new ComplaintDAO();

    Student student = studentDAO.getStudentById(studentId);
    Allocation allocation = allocationDAO.getActiveAllocationByStudent(studentId);
    List<Fee> myFees = feeDAO.getFeesByStudentId(studentId);
    List<Complaint> myComplaints = complaintDAO.getComplaintsByStudent(studentId);

    // Precise backend fee calculation
    boolean feeGenerated = (myFees != null && !myFees.isEmpty());
    BigDecimal totalFees = BigDecimal.ZERO;
    BigDecimal paidFees = BigDecimal.ZERO;
    BigDecimal pendingFees = BigDecimal.ZERO;
    String feeStatus = "Fee Not Generated";
    String foodType = "No Food";
    BigDecimal foodAmount = BigDecimal.ZERO;
    String latestReceiptNum = null;

    if (feeGenerated) {
        Fee latestFee = feeDAO.getLatestFeeByStudentId(studentId);
        if (latestFee != null) {
            totalFees = latestFee.getTotalFee();
            foodType = latestFee.getFoodType() != null ? latestFee.getFoodType() : "No Food";
            foodAmount = latestFee.getFoodAmount() != null ? latestFee.getFoodAmount() : BigDecimal.ZERO;
            latestReceiptNum = latestFee.getReceiptNumber();
        }
        for (Fee f : myFees) {
            if (f.getPaidAmount() != null) {
                paidFees = paidFees.add(f.getPaidAmount());
            }
        }
        pendingFees = totalFees.subtract(paidFees);
        if (pendingFees.compareTo(BigDecimal.ZERO) < 0) {
            pendingFees = BigDecimal.ZERO;
        }

        if (paidFees.compareTo(BigDecimal.ZERO) <= 0) {
            feeStatus = "Pending";
        } else if (paidFees.compareTo(totalFees) >= 0) {
            feeStatus = "Complete";
        } else {
            feeStatus = "Partially Paid";
        }
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Welcome Banner -->
    <div class="card mb-4 bg-grad-primary text-white border-0 shadow-sm" style="border-radius: 16px;">
        <div class="card-body p-4">
            <div class="row align-items-center">
                <div class="col-md-7">
                    <span class="badge bg-white bg-opacity-25 mb-2 px-3 py-1">Resident Student</span>
                    <h3 class="fw-extrabold mb-1">Welcome back, <%= student != null ? student.getName() : "Student" %>!</h3>
                    <p class="mb-0 text-white-50">
                        Student ID: <strong>#STU-<%= student != null ? student.getStudentId() : studentId %></strong> • Course: <strong><%= student != null && student.getCourse() != null ? student.getCourse() : "N/A" %></strong> (<%= student != null ? student.getSemester() : "" %>)
                    </p>
                </div>
                <div class="col-md-5 text-md-end mt-3 mt-md-0 d-flex justify-content-md-end gap-2 flex-wrap">
                    <% if (feeGenerated && pendingFees.compareTo(BigDecimal.ZERO) > 0) { %>
                        <button type="button" class="btn btn-success fw-bold shadow-sm" onclick="openPaymentModal(<%= pendingFees %>)">
                            <i class="fa-solid fa-credit-card me-1"></i> Pay Hostel Fee
                        </button>
                    <% } else if (feeGenerated && latestReceiptNum != null) { %>
                        <a href="<%= request.getContextPath() %>/receipt?receipt=<%= latestReceiptNum %>" target="_blank" class="btn btn-light fw-bold text-success shadow-sm">
                            <i class="fa-solid fa-receipt me-1"></i> View Receipt
                        </a>
                    <% } %>
                    <a href="<%= request.getContextPath() %>/student/complaints.jsp" class="btn btn-light fw-bold text-primary">
                        <i class="fa-solid fa-pen-to-square me-1"></i> Submit Ticket
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Stat Cards -->
    <div class="row g-3 mb-4">
        <!-- 1. Room Card -->
        <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-body d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="text-muted fw-bold text-uppercase" style="font-size: 0.75rem;">Allocated Room</span>
                            <div class="icon-bubble bg-primary bg-opacity-10 text-primary rounded-3 p-2">
                                <i class="fa-solid fa-bed fa-lg"></i>
                            </div>
                        </div>
                        <% if (allocation != null) { %>
                            <h3 class="fw-extrabold text-dark mb-0">Room <%= allocation.getRoomNumber() %></h3>
                            <div class="text-success small fw-semibold mt-1">
                                <i class="fa-solid fa-circle-check me-1"></i> Active Allocation (Floor <%= allocation.getRoomFloor() %>)
                            </div>
                            <small class="text-muted d-block mt-2"><%= allocation.getRoomType() %> • Since <%= allocation.getAllocationDate() %></small>
                        <% } else { %>
                            <h4 class="fw-bold text-warning mb-0">Not Allocated</h4>
                            <small class="text-muted d-block mt-1">Please contact hostel warden for room assignment.</small>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2. Fee Dues Card (Real state based) -->
        <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-body d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="text-muted fw-bold text-uppercase" style="font-size: 0.75rem;">Hostel Fee Status</span>
                            <div class="icon-bubble <%= !feeGenerated ? "bg-secondary bg-opacity-10 text-secondary" : ("Complete".equals(feeStatus) ? "bg-success bg-opacity-10 text-success" : "bg-warning bg-opacity-10 text-warning") %> rounded-3 p-2">
                                <i class="fa-solid fa-file-invoice-dollar fa-lg"></i>
                            </div>
                        </div>

                        <% if (!feeGenerated) { %>
                            <!-- NO FEE GENERATED STATE -->
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <span class="badge bg-secondary-subtle text-secondary fs-6 px-3 py-2 fw-bold">
                                    <i class="fa-solid fa-hourglass-half me-1"></i> Fee Not Generated
                                </span>
                            </div>
                            <small class="text-muted d-block mt-2">
                                Hostel administration has not yet generated the semester fee invoice for your account.
                            </small>
                            <div class="mt-2 text-muted small">
                                Total: <strong>--</strong> | Paid: <strong>--</strong> | Due: <strong>--</strong>
                            </div>
                        <% } else { %>
                            <!-- FEE GENERATED STATE -->
                            <% if ("Complete".equalsIgnoreCase(feeStatus)) { %>
                                <h3 class="fw-extrabold text-success mb-0">₹ 0.00</h3>
                                <div class="text-success small fw-semibold mt-1">
                                    <span class="badge bg-success-subtle text-success px-2 py-1"><i class="fa-solid fa-circle-check me-1"></i> Complete (Paid in Full)</span>
                                </div>
                            <% } else if ("Partially Paid".equalsIgnoreCase(feeStatus)) { %>
                                <h3 class="fw-extrabold text-primary mb-0">₹ <%= pendingFees %></h3>
                                <div class="text-primary small fw-semibold mt-1">
                                    <span class="badge bg-info-subtle text-primary px-2 py-1"><i class="fa-solid fa-circle-half-stroke me-1"></i> Partially Paid</span>
                                </div>
                            <% } else { %>
                                <h3 class="fw-extrabold text-danger mb-0">₹ <%= pendingFees %></h3>
                                <div class="text-danger small fw-semibold mt-1">
                                    <span class="badge bg-warning-subtle text-warning-emphasis px-2 py-1"><i class="fa-solid fa-clock-rotate-left me-1"></i> Fee Pending</span>
                                </div>
                            <% } %>
                            
                            <div class="mt-2 small text-muted">
                                Total Fee: <strong>₹ <%= totalFees %></strong> • Paid: <strong class="text-success">₹ <%= paidFees %></strong>
                            </div>
                            <div class="mt-1 small text-muted">
                                Food Plan: <strong><%= foodType %></strong> <% if (!"No Food".equalsIgnoreCase(foodType)) { %>(₹ <%= foodAmount %>)<% } %>
                            </div>
                        <% } %>
                    </div>

                    <!-- Pay Hostel Fee Button or Awaiting Fee status -->
                    <% if (feeGenerated && pendingFees.compareTo(BigDecimal.ZERO) > 0) { %>
                        <button type="button" class="btn btn-sm btn-success w-100 mt-3 fw-bold py-2 shadow-sm" 
                                onclick="openPaymentModal(<%= pendingFees %>)">
                            <i class="fa-solid fa-credit-card me-2"></i> Pay Due Amount (₹ <%= pendingFees %>)
                        </button>
                    <% } else if (feeGenerated) { %>
                        <a href="<%= request.getContextPath() %>/student/receipts.jsp" class="btn btn-sm btn-outline-success w-100 mt-3 fw-semibold py-2">
                            <i class="fa-solid fa-receipt me-1"></i> View Payment Receipts
                        </a>
                    <% } else { %>
                        <button type="button" class="btn btn-sm btn-light w-100 mt-3 text-muted fw-semibold py-2" disabled>
                            <i class="fa-solid fa-clock me-1"></i> Awaiting Admin Fee Generation
                        </button>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- 3. Complaints Card -->
        <div class="col-md-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-body d-flex flex-column justify-content-between">
                    <div>
                        <div class="d-flex align-items-center justify-content-between mb-3">
                            <span class="text-muted fw-bold text-uppercase" style="font-size: 0.75rem;">Support Tickets</span>
                            <div class="icon-bubble bg-info bg-opacity-10 text-info rounded-3 p-2">
                                <i class="fa-solid fa-headset fa-lg"></i>
                            </div>
                        </div>
                        <h3 class="fw-extrabold text-dark mb-0"><%= myComplaints != null ? myComplaints.size() : 0 %></h3>
                        <div class="text-muted small fw-semibold mt-1">
                            Total grievances lodged by you
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/student/complaints.jsp" class="btn btn-sm btn-outline-primary w-100 mt-3 fw-semibold">
                        View Ticket Status →
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent Complaints & Payment Summary -->
    <div class="row g-4 mb-4">
        <!-- My Recent Complaints -->
        <div class="col-lg-7">
            <div class="card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <span class="fw-bold"><i class="fa-solid fa-headset me-2 text-primary"></i>My Recent Complaints & Warden Responses</span>
                    <a href="<%= request.getContextPath() %>/student/complaints.jsp" class="btn btn-sm btn-link text-decoration-none">All Tickets</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table mb-0">
                            <thead>
                                <tr>
                                    <th>Ticket</th>
                                    <th>Category</th>
                                    <th>Subject</th>
                                    <th>Status</th>
                                    <th>Warden Note</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myComplaints != null && !myComplaints.isEmpty()) { 
                                    int count = 0;
                                    for (Complaint c : myComplaints) { 
                                        if (count++ >= 4) break;
                                        String st = c.getStatus();
                                        String badgeClass = "badge-pending";
                                        if ("In Progress".equalsIgnoreCase(st)) badgeClass = "badge-in-progress";
                                        else if ("Resolved".equalsIgnoreCase(st)) badgeClass = "badge-resolved";
                                        else if ("Rejected".equalsIgnoreCase(st)) badgeClass = "badge-rejected";
                                %>
                                    <tr>
                                        <td><strong>#<%= c.getComplaintId() %></strong></td>
                                        <td><span class="badge bg-light text-dark border"><%= c.getCategory() %></span></td>
                                        <td><%= c.getSubject() %></td>
                                        <td><span class="badge <%= badgeClass %>"><%= st %></span></td>
                                        <td>
                                            <% if (c.getAdminResponse() != null && !c.getAdminResponse().trim().isEmpty()) { %>
                                                <small class="text-success fw-semibold"><%= c.getAdminResponse() %></small>
                                            <% } else { %>
                                                <small class="text-muted">Awaiting review</small>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="5" class="text-center py-4 text-muted">You have not submitted any complaints yet.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- My Recent Receipts -->
        <div class="col-lg-5">
            <div class="card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <span class="fw-bold"><i class="fa-solid fa-receipt me-2 text-primary"></i>Recent Receipts</span>
                    <a href="<%= request.getContextPath() %>/student/receipts.jsp" class="btn btn-sm btn-link text-decoration-none">View All</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table mb-0">
                            <thead>
                                <tr>
                                    <th>Receipt #</th>
                                    <th>Amount</th>
                                    <th>Date</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (myFees != null && !myFees.isEmpty()) { 
                                    int fcount = 0;
                                    for (Fee f : myFees) {
                                        if (fcount++ >= 4) break;
                                %>
                                    <tr>
                                        <td><code><%= f.getReceiptNumber() %></code></td>
                                        <td class="text-success fw-bold">₹ <%= f.getPaidAmount() %></td>
                                        <td><small class="text-muted"><%= f.getPaymentDate() %></small></td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/receipt?receipt=<%= f.getReceiptNumber() %>" 
                                               target="_blank" class="btn btn-xs btn-outline-primary py-1 px-2" style="font-size: 0.75rem;">
                                                <i class="fa-solid fa-print me-1"></i> Print
                                            </a>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="4" class="text-center py-4 text-muted">No fee or payment records found.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ======================================================= -->
<!-- Razorpay Online Fee Payment Modal                       -->
<!-- ======================================================= -->
<% if (feeGenerated && pendingFees.compareTo(BigDecimal.ZERO) > 0) { %>
<div class="modal fade" id="paymentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
            <div class="modal-header bg-primary text-white p-4">
                <div>
                    <h5 class="modal-title fw-bold mb-1">
                        <i class="fa-solid fa-credit-card me-2"></i> Pay Hostel Fee Online
                    </h5>
                    <small class="text-white-50">Instant, secure payment via Razorpay Gateway</small>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <!-- Resident & Dues Summary Card -->
                <div class="bg-light p-3 rounded-3 mb-4 border">
                    <div class="row g-2">
                        <div class="col-6">
                            <small class="text-muted d-block">Resident Student</small>
                            <span class="fw-bold text-dark"><%= student != null ? student.getName() : "Student" %></span>
                        </div>
                        <div class="col-6 text-end">
                            <small class="text-muted d-block">Student ID</small>
                            <span class="fw-bold text-primary">#STU-<%= student != null ? student.getStudentId() : studentId %></span>
                        </div>
                        <div class="col-6 mt-2">
                            <small class="text-muted d-block">Food Plan</small>
                            <span class="small fw-semibold"><%= foodType %> (<%= "No Food".equalsIgnoreCase(foodType) ? "₹0" : "₹" + foodAmount %>)</span>
                        </div>
                        <div class="col-6 text-end mt-2">
                            <small class="text-muted d-block">Allocated Room</small>
                            <span class="badge bg-primary-subtle text-primary">
                                <%= allocation != null ? "Room " + allocation.getRoomNumber() : "Unassigned" %>
                            </span>
                        </div>
                    </div>
                    <hr class="my-2 text-muted opacity-25">
                    <div class="d-flex justify-content-between align-items-center pt-1">
                        <span class="text-muted small">Outstanding Balance Due:</span>
                        <span class="fw-bold text-danger fs-5">₹ <%= pendingFees %></span>
                    </div>
                </div>

                <!-- Payment Form -->
                <div class="mb-3">
                    <label class="form-label fw-semibold text-dark">Enter Payment Amount (₹ INR) <span class="text-danger">*</span></label>
                    <div class="input-group input-group-lg">
                        <span class="input-group-text bg-white border-end-0 fw-bold text-muted">₹</span>
                        <input type="number" id="payAmountInput" class="form-control border-start-0 fw-bold text-primary" 
                               min="100" max="<%= pendingFees %>" step="100" value="<%= pendingFees %>">
                    </div>
                    <small class="text-muted">You can pay full pending dues or partial amount.</small>
                </div>

                <!-- Accepted Payment Modes Banner -->
                <div class="p-3 rounded-3 mb-3 border bg-white text-center">
                    <small class="text-muted d-block mb-2 fw-semibold">Accepted Payment Modes</small>
                    <div class="d-flex justify-content-center align-items-center gap-3 text-muted">
                        <span title="UPI / Google Pay / PhonePe"><i class="fa-solid fa-mobile-screen-button text-success fa-lg"></i> UPI</span>
                        <span>•</span>
                        <span title="Credit and Debit Cards"><i class="fa-regular fa-credit-card text-primary fa-lg"></i> Cards</span>
                        <span>•</span>
                        <span title="Netbanking"><i class="fa-solid fa-building-columns text-info fa-lg"></i> NetBanking</span>
                    </div>
                </div>

                <div class="alert alert-info py-2 small mb-0 d-flex align-items-center gap-2">
                    <i class="fa-solid fa-shield-halved text-info fa-lg"></i>
                    <span>Transactions are verified securely with 256-bit encryption.</span>
                </div>
            </div>

            <div class="modal-footer bg-light p-3">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" id="proceedPayBtn" class="btn btn-primary px-4 fw-bold" onclick="startRazorpayPayment()">
                    <i class="fa-solid fa-lock me-2"></i> Proceed to Pay
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Hidden POST form submitted after Razorpay confirmation for Server Verification -->
<form id="razorpaySuccessForm" action="<%= request.getContextPath() %>/payment" method="post" style="display: none;">
    <input type="hidden" name="studentId" value="<%= student != null ? student.getStudentId() : studentId %>">
    <input type="hidden" name="amount" id="formAmount">
    <input type="hidden" name="razorpayOrderId" id="formRazorpayOrderId">
    <input type="hidden" name="razorpayPaymentId" id="formRazorpayPaymentId">
    <input type="hidden" name="razorpaySignature" id="formRazorpaySignature">
    <input type="hidden" name="paymentMode" value="Razorpay Online (UPI/Card)">
</form>

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>
<script>
let currentModal;

function openPaymentModal(suggestedAmount) {
    const input = document.getElementById("payAmountInput");
    if (input) {
        input.value = suggestedAmount > 0 ? suggestedAmount : 5000;
    }
    const modalEl = document.getElementById("paymentModal");
    if (modalEl) {
        currentModal = new bootstrap.Modal(modalEl);
        currentModal.show();
    }
}

function startRazorpayPayment() {
    const amountVal = parseFloat(document.getElementById("payAmountInput").value);
    if (!amountVal || amountVal <= 0) {
        Swal.fire({
            icon: 'warning',
            title: 'Invalid Amount',
            text: 'Please enter a valid payment amount greater than 0.'
        });
        return;
    }

    const payBtn = document.getElementById("proceedPayBtn");
    if (payBtn) {
        payBtn.disabled = true;
        payBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Creating Order...';
    }

    // Step 1: Server-Side Razorpay Order Creation
    fetch('<%= request.getContextPath() %>/create-razorpay-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: 'amount=' + encodeURIComponent(amountVal)
    })
    .then(response => response.json())
    .then(data => {
        if (payBtn) {
            payBtn.disabled = false;
            payBtn.innerHTML = '<i class="fa-solid fa-lock me-2"></i> Proceed to Pay';
        }

        if (data.status !== 'success') {
            Swal.fire({
                icon: 'error',
                title: 'Order Creation Failed',
                text: data.message || 'Unable to initiate Razorpay order.'
            });
            return;
        }

        if (currentModal) {
            currentModal.hide();
        }

        // Step 2: Open Razorpay Checkout Modal
        const options = {
            "key": data.keyId,
            "amount": data.amountPaise,
            "currency": data.currency || "INR",
            "name": "HostelSphere Residence",
            "description": "Hostel Semester Fee Payment",
            "order_id": data.orderId,
            "image": "<%= request.getContextPath() %>/assets/images/default_avatar.svg",
            "prefill": {
                "name": data.studentName || "<%= student != null ? student.getName() : "" %>",
                "email": data.studentEmail || "<%= student != null && student.getEmail() != null ? student.getEmail() : "" %>",
                "contact": data.studentMobile || "<%= student != null && student.getMobile() != null ? student.getMobile() : "" %>"
            },
            "theme": { "color": "#4f46e5" },
            "handler": function (response) {
                if (response && response.razorpay_payment_id) {
                    document.getElementById("formAmount").value = amountVal;
                    document.getElementById("formRazorpayOrderId").value = response.razorpay_order_id || data.orderId;
                    document.getElementById("formRazorpayPaymentId").value = response.razorpay_payment_id;
                    document.getElementById("formRazorpaySignature").value = response.razorpay_signature || "simulated_signature_ok";
                    document.getElementById("razorpaySuccessForm").submit();
                }
            }
        };

        try {
            const rzp = new Razorpay(options);
            rzp.on('payment.failed', function (resp){
                Swal.fire({
                    icon: 'error',
                    title: 'Payment Failed',
                    text: resp.error.description || 'Transaction could not be completed.'
                });
            });
            rzp.open();
        } catch (err) {
            // Offline Sandbox Fallback
            Swal.fire({
                title: 'Simulate Payment Confirmation?',
                text: 'Order #' + data.orderId + ' generated for ₹ ' + amountVal + '. Complete test transaction in sandbox mode?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Complete Test Payment',
                confirmButtonColor: '#10b981'
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById("formAmount").value = amountVal;
                    document.getElementById("formRazorpayOrderId").value = data.orderId;
                    document.getElementById("formRazorpayPaymentId").value = "pay_sim_" + Date.now();
                    document.getElementById("formRazorpaySignature").value = "simulated_signature_ok";
                    document.getElementById("razorpaySuccessForm").submit();
                }
            });
        }
    })
    .catch(err => {
        if (payBtn) {
            payBtn.disabled = false;
            payBtn.innerHTML = '<i class="fa-solid fa-lock me-2"></i> Proceed to Pay';
        }
        Swal.fire({
            icon: 'error',
            title: 'Connection Error',
            text: 'Unable to connect to payment server.'
        });
    });
}
</script>
<% } %>

<jsp:include page="includes/footer.jsp" />
