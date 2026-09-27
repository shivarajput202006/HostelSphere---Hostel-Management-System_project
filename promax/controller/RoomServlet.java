package controller;

import dao.RoomDAO;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Room;

public class RoomServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private RoomDAO roomDAO;

    @Override
    public void init() throws ServletException {
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

        if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response);
            return;
        }

        List<Room> rooms;
        if ("available".equalsIgnoreCase(action)) {
            rooms = roomDAO.getAvailableRooms();
        } else {
            rooms = roomDAO.getAllRooms();
        }
        request.setAttribute("roomList", rooms);
        request.setAttribute("currentFilter", action);
        request.getRequestDispatcher("/admin/rooms.jsp").forward(request, response);
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
        if ("add".equalsIgnoreCase(action)) {
            handleAdd(request, response);
        } else if ("update".equalsIgnoreCase(action)) {
            handleUpdate(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/room?action=list");
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String roomNumber = request.getParameter("roomNumber");
            int floor = Integer.parseInt(request.getParameter("floor"));
            String roomType = request.getParameter("roomType");
            int totalBeds = Integer.parseInt(request.getParameter("totalBeds"));

            if (roomDAO.isRoomNumberTaken(roomNumber.trim(), 0)) {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=Room+number+already+exists.");
                return;
            }

            Room room = new Room();
            room.setRoomNumber(roomNumber.trim());
            room.setFloor(floor);
            room.setRoomType(roomType);
            room.setTotalBeds(totalBeds);

            boolean ok = roomDAO.addRoom(room);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&msg=Room+added+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=Failed+to+add+room.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=" + e.getMessage());
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String roomNumber = request.getParameter("roomNumber");
            int floor = Integer.parseInt(request.getParameter("floor"));
            String roomType = request.getParameter("roomType");
            int totalBeds = Integer.parseInt(request.getParameter("totalBeds"));

            if (roomDAO.isRoomNumberTaken(roomNumber.trim(), roomId)) {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=Room+number+already+taken.");
                return;
            }

            Room room = new Room();
            room.setRoomId(roomId);
            room.setRoomNumber(roomNumber.trim());
            room.setFloor(floor);
            room.setRoomType(roomType);
            room.setTotalBeds(totalBeds);

            boolean ok = roomDAO.updateRoom(room);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&msg=Room+updated+successfully!");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=Cannot+reduce+beds+below+occupied+count.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=" + e.getMessage());
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("id"));
            boolean ok = roomDAO.deleteRoom(roomId);
            if (ok) {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&msg=Room+deleted+successfully.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=Unable+to+delete+room.+Ensure+no+active+students+are+allocated.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/room?action=list&error=" + e.getMessage());
        }
    }
}
