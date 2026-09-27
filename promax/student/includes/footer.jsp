    </main>
    <footer class="bg-white border-top py-3 px-4 text-center text-muted" style="font-size: 0.85rem;">
        HostelSphere Resident Portal &copy; <%= java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) %> • Academic Capstone Project
    </footer>
</div><!-- #content-wrapper -->
</div><!-- #wrapper -->

<!-- Scripts: jQuery, Bootstrap 5, DataTables, SweetAlert2 -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
