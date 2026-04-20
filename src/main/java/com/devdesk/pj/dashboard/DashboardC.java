package com.devdesk.pj.dashboard;

import com.devdesk.pj.til.TilDAO;
import com.devdesk.pj.til.TilTagStatVO;
import com.devdesk.pj.til.TilV0;
import com.devdesk.pj.user.MemberDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

import com.devdesk.pj.calendar.ScheduleNewDAO;
import com.devdesk.pj.calendar.ScheduleNewDTO;

@WebServlet("/dashboard")
public class DashboardC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // TAG_CONFIG와 동일한 색상 매핑
        Map<String, String> tagColorMap = new HashMap<>();
        tagColorMap.put("Java", "#ff9f69");
        tagColorMap.put("Spring", "#56e39f");
        tagColorMap.put("SQL", "#4ecdc4");
        tagColorMap.put("JavaScript", "#ffd166");
        tagColorMap.put("Git", "#ff6b6b");
        tagColorMap.put("Python", "#5b7cf8");
        tagColorMap.put("CSS", "#8b6ef5");
        tagColorMap.put("React", "#4ecdc4");
        tagColorMap.put("기타", "#9da3b8");

        Map<String, String> tagBgMap = new HashMap<>();
        tagBgMap.put("Java", "rgba(255,159,105,0.12)");
        tagBgMap.put("Spring", "rgba(86,227,159,0.12)");
        tagBgMap.put("SQL", "rgba(78,205,196,0.12)");
        tagBgMap.put("JavaScript", "rgba(255,209,102,0.12)");
        tagBgMap.put("Git", "rgba(255,107,107,0.12)");
        tagBgMap.put("Python", "rgba(91,124,248,0.12)");
        tagBgMap.put("CSS", "rgba(139,110,245,0.12)");
        tagBgMap.put("React", "rgba(78,205,196,0.12)");
        tagBgMap.put("기타", "rgba(157,163,184,0.12)");

        // recentTils 가공
        TilDAO tilDao = new TilDAO();
        MemberDTO loginUser = (MemberDTO) request.getSession().getAttribute("user");

        // 로그인 체크 (세션이 만료되거나 로그인 없이 접근했을 때 예외 방지) // 선민 추가
        if (loginUser == null) {
            response.sendRedirect("login");
            return;
        }

        int memberId = loginUser.getMember_id();

        List<String> colors = new ArrayList<>(Arrays.asList(
                "#ff9f69", "#56e39f", "#ffd166", "#5b7cf8",
                "#ff6b6b", "#8b6ef5", "#4ecdc4", "#9da3b8"
        ));
        List<TilTagStatVO> tilTagStats = tilDao.getTilTagStats(memberId);
        for (int i = 0; i < tilTagStats.size(); i++) {
            tilTagStats.get(i).setColor(colors.get(i % colors.size()));
        }
        request.setAttribute("tilTagStats", tilTagStats);

        List<TilV0> rawTils = tilDao.getRecentTils(memberId, 5);

        for (TilV0 t : rawTils) {
            t.setTagColor(tagColorMap.getOrDefault(t.getTag(), "#9da3b8"));
            t.setTagBg(tagBgMap.getOrDefault(t.getTag(), "rgba(157,163,184,0.12)"));
            t.setTimeAgo(calcTimeAgo(t.getCreatedAt()));
        }

        request.setAttribute("recentTils", rawTils);

        // 예정 일정 가공
        ScheduleNewDAO scheduleDao = ScheduleNewDAO.SCAO;
        ArrayList<ScheduleNewDTO> rawSchedules = scheduleDao.getCalendarEvents(memberId);

        // 🌟🌟🌟 미니 캘린더용 데이터 전송 (이 한 줄이 핵심입니다!) 🌟🌟🌟
        // 위에서 가져온 rawSchedules를 미니 캘린더가 냠냠 먹을 수 있게 "schList"라는 이름으로 보냅니다!
        request.setAttribute("schList", rawSchedules);
        // 🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟

        // 오늘 날짜
        java.util.Calendar today = java.util.Calendar.getInstance();

        // 타입별 배지 색상
        Map<String, String> typeBgMap = new HashMap<>();
        typeBgMap.put("1차 면접", "rgba(78,205,196,0.15)");
        typeBgMap.put("2차 면접", "rgba(91,124,248,0.15)");
        typeBgMap.put("3차 면접", "rgba(139,110,245,0.15)");
        typeBgMap.put("코딩테스트", "rgba(255,209,102,0.15)");
        typeBgMap.put("최종 면접", "rgba(86,227,159,0.15)");

        Map<String, String> typeColorMap = new HashMap<>();
        typeColorMap.put("1차 면접", "#4ecdc4");
        typeColorMap.put("2차 면접", "#5b7cf8");
        typeColorMap.put("3차 면접", "#8b6ef5");
        typeColorMap.put("코딩테스트", "#ffd166");
        typeColorMap.put("최종 면접", "#56e39f");

        String[] MONTHS = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

        List<DashboardScheduleVO> upcomingSchedules = new ArrayList<>();
        // 오늘 자정 기준
        java.util.Calendar todayMidnight = java.util.Calendar.getInstance();
        todayMidnight.set(java.util.Calendar.HOUR_OF_DAY, 0);
        todayMidnight.set(java.util.Calendar.MINUTE, 0);
        todayMidnight.set(java.util.Calendar.SECOND, 0);
        todayMidnight.set(java.util.Calendar.MILLISECOND, 0);

        for (ScheduleNewDTO raw : rawSchedules) {
            if (raw.getSchedule_date() == null) continue;

            // 오늘 자정보다 이전 날짜만 제외
            if (raw.getSchedule_date().before(todayMidnight.getTime())) continue;

            java.util.Calendar c = java.util.Calendar.getInstance();
            c.setTime(raw.getSchedule_date());

            DashboardScheduleVO vo = new DashboardScheduleVO();
            vo.setMonth(MONTHS[c.get(java.util.Calendar.MONTH)]);
            vo.setDay(String.format("%02d", c.get(java.util.Calendar.DAY_OF_MONTH)));
            vo.setCompany(raw.getCompany_name());
            vo.setTime(raw.getSchedule_time());
            String type = raw.getInterview_type() != null ? raw.getInterview_type() : "면접";
            vo.setType(type);
            vo.setBadgeBg(typeBgMap.getOrDefault(type, "rgba(157,163,184,0.15)"));
            vo.setBadgeColor(typeColorMap.getOrDefault(type, "#9da3b8"));
            vo.setToday(isSameDay(c, today));
            upcomingSchedules.add(vo);
        }

        System.out.println("=== upcomingSchedules 크기: " + upcomingSchedules.size());

        request.setAttribute("upcomingSchedules", upcomingSchedules);

        for (ScheduleNewDTO r : rawSchedules) {
            System.out.println("  날짜: " + r.getSchedule_date()
                    + " / 회사: " + r.getCompany_name()
                    + " / 타입: [" + r.getInterview_type() + "]");
        }

        DashboardDAO.countGroupbystage(request);
        DashboardDAO.getFunnelData(DashboardDAO.countGroupbystage(request));
        List<Map<String, Object>> funnelData = DashboardDAO.getFunnelData(DashboardDAO.countGroupbystage(request));
        request.setAttribute("funnelData", funnelData);
        request.setAttribute("content", "/dashboard/dashboard.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);

    }

    private String calcTimeAgo(String createdAt) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date created = sdf.parse(createdAt);
            long diff = System.currentTimeMillis() - created.getTime();
            long days = diff / (1000 * 60 * 60 * 24);

            if (days == 0) return "오늘";
            if (days == 1) return "어제";
            if (days < 7) return days + "일 전";
            if (days < 30) return (days / 7) + "주 전";
            return (days / 30) + "개월 전";
        } catch (Exception e) {
            return createdAt;
        }
    }

    private boolean isSameDay(java.util.Calendar a, java.util.Calendar b) {
        return a.get(java.util.Calendar.YEAR) == b.get(java.util.Calendar.YEAR)
                && a.get(java.util.Calendar.DAY_OF_YEAR) == b.get(java.util.Calendar.DAY_OF_YEAR);
    }

    public void destroy() {
    }
}