package com.devdesk.pj.til;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "TilUpdateC", value = "/til_update")
public class TilUpdateC extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        TilDAO.updateTil(request);
        response.sendRedirect("til-list");

    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        TilDAO.updateTil(request);
        request.setAttribute("content", "/dashboard/dashboard.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }


    public void destroy() {
    }
}