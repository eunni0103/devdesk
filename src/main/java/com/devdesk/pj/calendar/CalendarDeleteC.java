package com.devdesk.pj.calendar;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CalendarDeleteC", value = "/delete-calendar")
public class CalendarDeleteC extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // 🚨 디버깅용 출력 추가!
        System.out.println("======================================");
        System.out.println("✅ [삭제 컨트롤러 진입 성공]");
        String reqId = request.getParameter("schedule_id");
        System.out.println("👉 넘겨받은 파라미터 값: " + reqId);
        System.out.println("======================================");

        try {
            int scheduleId = Integer.parseInt(reqId);
            ScheduleNewDAO.SCAO.deleteSchedule(scheduleId);

            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("success");

        } catch (Exception e) {
            System.out.println("❌ [컨트롤러 에러 발생]: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}