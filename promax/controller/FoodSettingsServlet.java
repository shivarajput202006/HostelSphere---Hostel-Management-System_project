package controller;

import dao.FoodPriceDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;

public class FoodSettingsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private FoodPriceDAO foodPriceDAO;

    @Override
    public void init() throws ServletException {
        foodPriceDAO = new FoodPriceDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=Access+denied.+Admin+login+required.");
            return;
        }

        BigDecimal vegPrice = foodPriceDAO.getVegPrice();
        BigDecimal nonVegPrice = foodPriceDAO.getNonVegPrice();

        request.setAttribute("vegPrice", vegPrice);
        request.setAttribute("nonVegPrice", nonVegPrice);
        request.getRequestDispatcher("/admin/food-settings.jsp").forward(request, response);
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

        try {
            String vegPriceStr = request.getParameter("vegPrice");
            String nonVegPriceStr = request.getParameter("nonVegPrice");

            if (vegPriceStr == null || vegPriceStr.trim().isEmpty() ||
                nonVegPriceStr == null || nonVegPriceStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/food-settings?error=Both+Veg+and+Non-Veg+prices+must+be+specified.");
                return;
            }

            BigDecimal vegPrice = new BigDecimal(vegPriceStr.trim());
            BigDecimal nonVegPrice = new BigDecimal(nonVegPriceStr.trim());

            if (vegPrice.compareTo(BigDecimal.ZERO) < 0 || nonVegPrice.compareTo(BigDecimal.ZERO) < 0) {
                response.sendRedirect(request.getContextPath() + "/admin/food-settings?error=Food+prices+cannot+be+negative.");
                return;
            }

            boolean ok1 = foodPriceDAO.setVegPrice(vegPrice);
            boolean ok2 = foodPriceDAO.setNonVegPrice(nonVegPrice);

            if (ok1 && ok2) {
                response.sendRedirect(request.getContextPath() + "/admin/food-settings?msg=Food+pricing+updated+successfully!+New+invoices+will+use+these+rates.");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/food-settings?error=Failed+to+save+food+prices+to+database.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/food-settings?error=" + e.getMessage());
        }
    }
}
