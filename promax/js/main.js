/**
 * Hostel Management System - Main JavaScript File
 * Handles SweetAlert2 alerts, DataTables, confirmations, and dynamic calculations.
 */

document.addEventListener("DOMContentLoaded", function () {
    // 1. Initialize SweetAlert2 Alerts from URL Query Parameters
    const urlParams = new URLSearchParams(window.location.search);
    const successMsg = urlParams.get("msg");
    const errorMsg = urlParams.get("error");

    if (successMsg) {
        Swal.fire({
            icon: 'success',
            title: 'Success',
            text: decodeURIComponent(successMsg),
            timer: 3500,
            showConfirmButton: false,
            toast: true,
            position: 'top-end'
        });
    }

    if (errorMsg) {
        Swal.fire({
            icon: 'error',
            title: 'Notice',
            text: decodeURIComponent(errorMsg),
            confirmButtonColor: '#4f46e5'
        });
    }

    // 2. Initialize DataTables
    if (typeof $.fn.DataTable !== 'undefined') {
        $('.datatable').DataTable({
            responsive: true,
            pageLength: 10,
            language: {
                search: "_INPUT_",
                searchPlaceholder: "Search records...",
                lengthMenu: "Show _MENU_ entries"
            }
        });
    }

    // 3. Dynamic Fee Calculation in Fee Forms
    const totalFeeInput = document.getElementById("totalFee");
    const paidAmountInput = document.getElementById("paidAmount");
    const dueAmountDisplay = document.getElementById("dueAmountDisplay");
    const dueAmountInput = document.getElementById("dueAmount");

    function calculateDue() {
        if (totalFeeInput && paidAmountInput) {
            const total = parseFloat(totalFeeInput.value) || 0;
            const paid = parseFloat(paidAmountInput.value) || 0;
            let due = total - paid;
            if (due < 0) due = 0;

            if (dueAmountDisplay) {
                dueAmountDisplay.textContent = "₹ " + due.toFixed(2);
            }
            if (dueAmountInput) {
                dueAmountInput.value = due.toFixed(2);
            }
        }
    }

    if (totalFeeInput && paidAmountInput) {
        totalFeeInput.addEventListener("input", calculateDue);
        paidAmountInput.addEventListener("input", calculateDue);
    }
});

/**
 * Universal SweetAlert2 delete confirmation
 */
function confirmDelete(url, itemType) {
    Swal.fire({
        title: 'Are you sure?',
        text: `Do you really want to delete this ${itemType || 'record'}? This action cannot be undone.`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ef4444',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Yes, delete it!'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = url;
        }
    });
}

/**
 * SweetAlert2 vacate room confirmation
 */
function confirmVacate(url) {
    Swal.fire({
        title: 'Vacate this Room?',
        text: "The student will be checked out and this bed will become available for new allocation.",
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#f59e0b',
        cancelButtonColor: '#64748b',
        confirmButtonText: 'Yes, vacate room'
    }).then((result) => {
        if (result.isConfirmed) {
            window.location.href = url;
        }
    });
}
