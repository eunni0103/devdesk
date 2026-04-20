package com.devdesk.pj.application;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ApplicationUpdateC", value = "/application_update")
public class ApplicationUpdateC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        ApplicationV0 dto = ApplicationDAO.selectApplication(request);
        request.setAttribute("app", dto);
        request.setAttribute("content", "/application/application_update.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        ApplicationDAO.updateApplication(request);

        response.sendRedirect("application-list");
    }


    public void destroy() {
    }
}