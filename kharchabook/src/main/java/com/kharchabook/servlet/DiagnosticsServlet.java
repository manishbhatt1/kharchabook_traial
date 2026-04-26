package com.kharchabook.servlet;

import com.kharchabook.util.DBUtil;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/diagnostics")
public class DiagnosticsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("text/plain");
        PrintWriter out = resp.getWriter();
        out.println("--- Kharchabook System Diagnostics ---");
        
        try (Connection conn = DBUtil.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                out.println("Database Connection: SUCCESS");
                out.println("Database Product: " + conn.getMetaData().getDatabaseProductName());
                out.println("Database Version: " + conn.getMetaData().getDatabaseProductVersion());
            } else {
                out.println("Database Connection: FAILED (Connection is null or closed)");
            }
        } catch (SQLException e) {
            out.println("Database Connection: ERROR");
            out.println("Error Message: " + e.getMessage());
            e.printStackTrace(out);
        } catch (Exception e) {
            out.println("General System Error: " + e.getMessage());
            e.printStackTrace(out);
        }
    }
}