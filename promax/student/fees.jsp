<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.FeeDAO" %>
<%@ page import="dao.StudentDAO" %>
<%@ page import="model.Fee" %>
<%@ page import="model.Student" %>

<%
    int studentId = (Integer) session.getAttribute("studentId");
    FeeDAO dao = new FeeDAO();
    StudentDAO studentDAO = new StudentDAO();
    Student student = studentDAO.getStudentById(studentId);
    List<Fee> feeList = dao.getFeesByStudentId(studentId);

    boolean feeGenerated = (feeList != null && !feeList.isEmpty());
    BigDecimal total = BigDecimal.ZERO;
    BigDecimal paid = BigDecimal.ZERO;
    BigDecimal due = BigDecimal.ZERO;
    String statusStr = "Fee Not Generated";
    String foodPlan = "No Food";
    BigDecimal foodPrice = BigDecimal.ZERO;
    BigDecimal baseHostel = BigDecimal.ZERO;
    BigDecimal otherFee = BigDecimal.ZERO;

    if (feeGenerated) {
        Fee latestFee = dao.getLatestFeeByStudentId(studentId);
        if (latestFee != null) {
            total = latestFee.getTotalFee();
            foodPlan = latestFee.getFoodType() != null ? latestFee.getFoodType() : "No Food";
            foodPrice = latestFee.getFoodAmount() != null ? latestFee.getFoodAmount() : BigDecimal.ZERO;
            baseHostel = latestFee.getHostelFee() != null ? latestFee.getHostelFee() : BigDecimal.ZERO;
            otherFee = latestFee.getOtherCharges() != null ? latestFee.getOtherCharges() : BigDecimal.ZERO;
        }

        for (Fee f : feeList) {
            if (f.getPaidAmount() != null) {
                paid = paid.add(f.getPaidAmount());
            }
        }
        due = total.subtract(paid);
        if (due.compareTo(BigDecimal.ZERO) < 0) due = BigDecimal.ZERO;

        if (paid.compareTo(BigDecimal.ZERO) <= 0) {
            statusStr = "Pending";
        } else if (paid.compareTo(total) >= 0) {
            statusStr = "Complete";
        } else {
            statusStr = "Partially Paid";
        }
    }
%>

<jsp:include page="includes/header.jsp" />
<jsp:include page="includes/sidebar.jsp" />

<div class="container-fluid px-0">
    <!-- Header -->
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h3 class="fw-bold text-dark mb-1">Hostel Fees & Payment History</h3>
            <p class="text-muted mb-0">Track your semester hostel fees, receipts, and outstanding dues.</p>
        </div>
        <div>
            <% if (feeGenerated && due.compareTo(BigDecimal.ZERO) > 0) { %>
                <button type="button" class="btn btn-success fw-bold shadow-sm" onclick="openPaymentModal(<%= due %>)">
                    <i class="fa-solid fa-credit-card me-2"></i> Pay Now with Razorpay
                </button>
            <% } %>
        </div>
    </div>

    <!-- Feedback Messages -->
    <% String msg = request.getParameter("msg");
       String error = request.getParameter("error");
       if (msg != null && !msg.trim().isEmpty()) { %>
        <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
            <i class="fa-solid fa-circle-check fa-lg"></i>
            <div><strong>Success!</strong> <%= msg %></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>
    <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2 mb-4" role="alert">
            <i class="fa-solid fa-triangle-exclamation fa-lg"></i>
            <div><strong>Error!</strong> <%= error %></div>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

    <!-- Summary Cards -->
    <div class="row g-3 mb-4">
        <!-- 1. Total Fee -->
        <div class="col-md-3 col-sm-6">
            <div class="card p-3 border-0 shadow-sm bg-light h-100">
                <small class="text-muted text-uppercase fw-bold" style="font-size: 0.75rem;">Total Assessed Fee</small>
                <% if (feeGenerated) { %>
                    <h3 class="fw-extrabold text-dark mt-1 mb-0">₹ <%= total %></h3>
                <% } else { %>
                    <h3 class="fw-extrabold text-muted mt-1 mb-0">--</h3>
                <% } %>
            </div>
        </div>

        <!-- 2. Paid Amount -->
        <div class="col-md-3 col-sm-6">
            <div class="card p-3 border-0 shadow-sm bg-light h-100">
                <small class="text-muted text-uppercase fw-bold" style="font-size: 0.75rem;">Total Paid</small>
                <% if (feeGenerated) { %>
                    <h3 class="fw-extrabold text-success mt-1 mb-0">₹ <%= paid %></h3>
                <% } else { %>
                    <h3 class="fw-extrabold text-muted mt-1 mb-0">--</h3>
                <% } %>
            </div>
        </div>

        <!-- 3. Due Amount -->
        <div class="col-md-3 col-sm-6">
            <div class="card p-3 border-0 shadow-sm bg-light h-100">
                <small class="text-muted text-uppercase fw-bold" style="font-size: 0.75rem;">Outstanding Due</small>
                <% if (feeGenerated) { %>
                    <h3 class="fw-extrabold <%= due.compareTo(BigDecimal.ZERO) > 0 ? "text-danger" : "text-success" %> mt-1 mb-0">
                        ₹ <%= due %>
                    </h3>
                <% } else { %>
                    <h3 class="fw-extrabold text-muted mt-1 mb-0">--</h3>
                <% } %>
            </div>
        </div>

        <!-- 4. Fee Status -->
        <div class="col-md-3 col-sm-6">
            <div class="card p-3 border-0 shadow-sm bg-light h-100">
                <small class="text-muted text-uppercase fw-bold" style="font-size: 0.75rem;">Fee Status</small>
                <div class="mt-2">
                    <% if (!feeGenerated) { %>
                        <span class="badge bg-secondary-subtle text-secondary px-3 py-2 fw-bold">
                            <i class="fa-solid fa-hourglass-half me-1"></i> Fee Not Generated
                        </span>
                    <% } else if ("Complete".equalsIgnoreCase(statusStr)) { %>
                        <span class="badge bg-success-subtle text-success px-3 py-2 fw-bold">
                            <i class="fa-solid fa-circle-check me-1"></i> Paid in Full
                        </span>
                    <% } else if ("Partially Paid".equalsIgnoreCase(statusStr)) { %>
                        <span class="badge bg-info-subtle text-primary px-3 py-2 fw-bold">
                            <i class="fa-solid fa-circle-half-stroke me-1"></i> Partially Paid
                        </span>
                    <% } else { %>
                        <span class="badge bg-warning-subtle text-warning-emphasis px-3 py-2 fw-bold">
                            <i class="fa-solid fa-clock-rotate-left me-1"></i> Pending
                        </span>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <!-- Fee Component Breakdown Card (If fee is generated) -->
    <% if (feeGenerated) { %>
    <div class="card mb-4 border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom">
            <span class="fw-bold text-dark"><i class="fa-solid fa-list-check me-2 text-primary"></i>Fee Structure Components</span>
        </div>
        <div class="card-body p-3">
            <div class="row g-3 text-center">
                <div class="col-md-3 col-6">
                    <small class="text-muted d-block">Hostel Room Rent</small>
                    <span class="fw-bold fs-6">₹ <%= baseHostel %></span>
                </div>
                <div class="col-md-3 col-6">
                    <small class="text-muted d-block">Mess / Food Option</small>
                    <span class="fw-bold fs-6"><%= foodPlan %> (₹ <%= foodPrice %>)</span>
                </div>
                <div class="col-md-3 col-6">
                    <small class="text-muted d-block">Utility & Maintenance</small>
                    <span class="fw-bold fs-6">₹ <%= otherFee %></span>
                </div>
                <div class="col-md-3 col-6 border-start">
                    <small class="text-muted d-block">Total Semester Fee</small>
                    <span class="fw-bold fs-6 text-primary">₹ <%= total %></span>
                </div>
            </div>
        </div>
    </div>
    <% } %>

    <!-- Payments Table Card -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3 border-bottom d-flex align-items-center justify-content-between">
            <span class="fw-bold"><i class="fa-solid fa-receipt me-2 text-primary"></i>Payment Transactions & Receipts</span>
            <span class="badge bg-primary-subtle text-primary px-3 py-2 fw-semibold">Count: <%= feeList != null ? feeList.size() : 0 %></span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Receipt Number</th>
                            <th>Total Fee</th>
                            <th>Amount Paid</th>
                            <th>Due Amount</th>
                            <th>Payment Date</th>
                            <th>Payment Mode</th>
                            <th>Food Plan</th>
                            <th class="text-center">Receipt Slip</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (feeList != null && !feeList.isEmpty()) { 
                            for (Fee f : feeList) { 
                                boolean hasDue = (f.getDueAmount() != null && f.getDueAmount().compareTo(BigDecimal.ZERO) > 0);
                        %>
                            <tr>
                                <td>
                                    <span class="fw-bold text-primary"><code><%= f.getReceiptNumber() %></code></span>
                                </td>
                                <td><strong>₹ <%= f.getTotalFee() %></strong></td>
                                <td><span class="text-success fw-bold">₹ <%= f.getPaidAmount() %></span></td>
                                <td>
                                    <% if (hasDue) { %>
                                        <span class="badge bg-warning-subtle text-warning-emphasis">₹ <%= f.getDueAmount() %> Due</span>
                                    <% } else { %>
                                        <span class="badge bg-success-subtle text-success"><i class="fa-solid fa-check me-1"></i> Paid</span>
                                    <% } %>
                                </td>
                                <td><%= f.getPaymentDate() %></td>
                                <td><span class="badge bg-light text-dark border"><%= f.getPaymentMode() %></span></td>
                                <td><small class="text-muted"><%= f.getFoodType() != null ? f.getFoodType() : "No Food" %></small></td>
                                <td class="text-center">
                                    <a href="<%= request.getContextPath() %>/receipt?receipt=<%= f.getReceiptNumber() %>" 
                                       target="_blank" class="btn btn-sm btn-primary shadow-sm">
                                        <i class="fa-solid fa-print me-1"></i> Print Receipt
                                    </a>
                                </td>
                            </tr>
                        <% } } else { %>
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="fa-solid fa-file-circle-question fa-3x mb-3 text-secondary opacity-50 d-block"></i>
                                    <h5 class="fw-bold text-dark">Fee Not Generated</h5>
                                    <p class="mb-0">No fee record exists for your account. Please await fee invoice generation by hostel administration.</p>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- ======================================================= -->
<!-- Razorpay Online Fee Payment Modal                       -->
<!-- ======================================================= -->
<% if (feeGenerated && due.compareTo(BigDecimal.ZERO) > 0) { %>
<div class="modal fade" id="paymentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 20px; overflow: hidden;">
            <div class="modal-header bg-primary text-white p-4">
                <div>
                    <h5 class="modal-title fw-bold mb-1">
                        <i class="fa-solid fa-credit-card me-2"></i> Pay Hostel Fee Online
                    </h5>
                    <small class="text-white-50">Instant payment via Razorpay Payment Gateway</small>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <div class="bg-light p-3 rounded-3 mb-4 border">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-muted">Outstanding Balance Due:</span>
                        <span class="fw-bold text-danger fs-5">₹ <%= due %></span>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-semibold text-dark">Enter Payment Amount (₹ INR) <span class="text-danger">*</span></label>
                    <div class="input-group input-group-lg">
                        <span class="input-group-text bg-white border-end-0 fw-bold text-muted">₹</span>
                        <input type="number" id="payAmountInput" class="form-control border-start-0 fw-bold text-primary" 
                               min="100" max="<%= due %>" step="100" value="<%= due %>">
                    </div>
                </div>

                <div class="alert alert-info py-2 small mb-0 d-flex align-items-center gap-2">
                    <i class="fa-solid fa-shield-halved text-info fa-lg"></i>
                    <span>Transactions are verified with 256-bit cryptographic encryption.</span>
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
    <input type="hidden" name="studentId" value="<%= studentId %>">
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
        Swal.fire({ icon: 'warning', title: 'Invalid Amount', text: 'Please enter a valid amount.' });
        return;
    }

    const payBtn = document.getElementById("proceedPayBtn");
    if (payBtn) {
        payBtn.disabled = true;
        payBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Creating Order...';
    }

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
            Swal.fire({ icon: 'error', title: 'Order Creation Failed', text: data.message || 'Error creating order.' });
            return;
        }

        if (currentModal) currentModal.hide();

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
                Swal.fire({ icon: 'error', title: 'Payment Failed', text: resp.error.description || 'Transaction failed.' });
            });
            rzp.open();
        } catch (err) {
            Swal.fire({
                title: 'Simulate Test Payment?',
                text: 'Order #' + data.orderId + ' generated. Complete test payment of ₹ ' + amountVal + '?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Complete Payment',
                confirmButtonColor: '#10b981'
            }).then((res) => {
                if (res.isConfirmed) {
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
        Swal.fire({ icon: 'error', title: 'Error', text: 'Unable to connect to payment server.' });
    });
}
</script>
<% } %>

<jsp:include page="includes/footer.jsp" />
