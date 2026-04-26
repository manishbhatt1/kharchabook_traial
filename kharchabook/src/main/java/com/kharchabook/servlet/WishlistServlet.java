package com.kharchabook.servlet;

import com.kharchabook.dao.WishlistDAO;
import com.kharchabook.model.FinancialTip;
import com.kharchabook.util.SessionKeys;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/user/wishlist")
public class WishlistServlet extends HttpServlet {

    private final WishlistDAO wishlistDAO = new WishlistDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        int userId = (Integer) session.getAttribute(SessionKeys.USER_ID);
        try {
            List<FinancialTip> tips = wishlistDAO.findByUser(userId);
            req.setAttribute("tips", tips);
            req.getRequestDispatcher("/user/wishlist.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        int userId = (Integer) session.getAttribute(SessionKeys.USER_ID);
        String action = req.getParameter("action");
        try {
            if ("add".equals(action)) {
                int tipId = Integer.parseInt(req.getParameter("tipId"));
                wishlistDAO.add(userId, tipId);
                session.setAttribute(SessionKeys.FLASH_SUCCESS, "Tip saved to wishlist.");
            } else if ("remove".equals(action)) {
                int tipId = Integer.parseInt(req.getParameter("tipId"));
                wishlistDAO.remove(userId, tipId);
                session.setAttribute(SessionKeys.FLASH_SUCCESS, "Removed from wishlist.");
            }
            String from = req.getParameter("from");
            if ("tips".equals(from)) {
                resp.sendRedirect(req.getContextPath() + "/user/tips");
            } else {
                resp.sendRedirect(req.getContextPath() + "/user/wishlist");
            }
        } catch (SQLException e) {
            throw new IOException(e);
        }
    }
}
