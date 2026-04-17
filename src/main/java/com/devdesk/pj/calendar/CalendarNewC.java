package com.devdesk.pj.calendar;
import com.devdesk.pj.user.MemberDTO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "calendarC", value = "/calendar")
public class CalendarNewC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        MemberDTO user = (MemberDTO) request.getSession().getAttribute("user");

        if (user == null) {
            request.getSession().setAttribute("dest", request.getRequestURI());

            // 로그인 페이지로 쫓아내기
            response.sendRedirect("login");
            return;
        }

        int memberId = user.getMember_id();

        ArrayList<ScheduleNewDTO> schList = ScheduleNewDAO.SCAO.getCalendarEvents(memberId);
        request.setAttribute("list", schList);

        ArrayList<String> companyList = ScheduleNewDAO.SCAO.getAllCompanyNames();
        request.setAttribute("companyList", companyList);

        request.setAttribute("content", "calendar/index_cal.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}