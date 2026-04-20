package com.devdesk.pj.calendar;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/update-calendar")
public class CalendarUpdateC extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        try {
            ScheduleNewDAO.SCAO.updateSchedule(request, response);

            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("success");

            System.out.println("update success");

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("fail");
        }
    }
}