package controller;

import dao.AllocationDAO;
import dao.RoomDAO;
import dao.StudentDAO;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Allocation;
import model.Room;
import model.Student;

public class AllocationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AllocationDAO allocationDAO;
    private StudentDAO studentDAO;
    private RoomDAO roomDAO;

    @Override
    public void init() throws ServletException {
        allocationDAO = new AllocationDAO();
        studentDAO = new StudentDAO();
        roomDAO = new RoomDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        if ("vacate".equalsIgnoreCase(action)) {
            handleVacate(request, response);
            return;
        }

        List<Allocation> allocations;
        if ("history".equalsIgnoreCase(action)) {
            allocations = allocationDAO.getAllAllocationsHistory();
            request.setAttribute("viewType", "history");
        } else {
            allocations = allocationDAO.getActiveAllocations();
            request.setAttribute("viewType", "active");
        }

        // Also supply available rooms and students without room for the allocation modal
        List<Room> availableRooms = roomDAO.getAvailableRooms();
        List<Student> studentsWithoutRoom = studentDAO.getStudentsWithoutRoom();

        request.setAttribute("allocationList", allocations);
        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("studentsWithoutRoom", studentsWithoutRoom);

        request.getRequestDispatcher("/admin/allocation.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.");
            return;
        }

        String action = request.getParameter("action");
        if ("allocate".equalsIgnoreCase(action)) {
            handleAllocate(request, response);
        } else if ("change".equalsIgnoreCase(action)) {
            handleChange(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list");
        }
    }

    private void handleAllocate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int studentId = Integer.parseInt(request.getParameter("studentId"));
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String allocDateStr = request.getParameter("allocationDate");
            Date allocDate = (allocDateStr != null && !allocDateStr.isEmpty()) 
                    ? Date.valueOf(allocDateStr) 
                    : new Date(System.currentTimeMillis());

            String result = allocationDAO.allocateRoom(studentId, roomId, allocDate);
            if ("SUCCESS".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&msg=Room+allocated+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&error=" + result);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&error=" + e.getMessage());
        }
    }

    private void handleVacate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int allocationId = Integer.parseInt(request.getParameter("id"));
            Date vacateDate = new Date(System.currentTimeMillis());

            String result = allocationDAO.vacateRoom(allocationId, vacateDate);
            if ("SUCCESS".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&msg=Room+vacated+successfully.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&error=" + result);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&error=" + e.getMessage());
        }
    }

    private void handleChange(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int allocationId = Integer.parseInt(request.getParameter("allocationId"));
            int newRoomId = Integer.parseInt(request.getParameter("newRoomId"));
            Date changeDate = new Date(System.currentTimeMillis());

            String result = allocationDAO.changeRoom(allocationId, newRoomId, changeDate);
            if ("SUCCESS".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&msg=Room+changed+successfully.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&error=" + result);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/allocation?action=list&error=" + e.getMessage());
        }
    }
}
