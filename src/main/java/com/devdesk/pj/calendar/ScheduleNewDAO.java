package com.devdesk.pj.calendar;

import com.devdesk.pj.main.DBManager_new;
import com.devdesk.pj.user.MemberDTO;
import com.google.api.client.util.DateTime;
import com.google.api.services.calendar.Calendar;
import com.google.api.services.calendar.model.Event;
import com.google.api.services.calendar.model.EventDateTime;
import com.google.api.services.calendar.model.Events;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ScheduleNewDAO {
    public static final ScheduleNewDAO SCAO = new ScheduleNewDAO();

    private ScheduleNewDAO() {
    }

    public ArrayList<ScheduleNewDTO> getCalendarEvents(int memberId) {
        ArrayList<ScheduleNewDTO> list = new ArrayList<>();

        String sql = "SELECT s.SCHEDULE_ID, s.SCHEDULE_DATE, s.SCHEDULE_TIME, s.INTERVIEW_TYPE, s.MEMO, " +
                "s.COMPANY_NAME, a.POSITION, a.STAGE " +
                "FROM SCHEDULE s " +
                "JOIN APPLICATION a ON s.APP_ID = a.APP_ID " +
                "WHERE a.MEMBER_ID = ? " +
                "ORDER BY s.SCHEDULE_DATE ASC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setInt(1, memberId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ScheduleNewDTO dto = new ScheduleNewDTO(
                            rs.getInt("SCHEDULE_ID"),
                            rs.getDate("SCHEDULE_DATE"),
                            rs.getString("SCHEDULE_TIME"),
                            rs.getString("INTERVIEW_TYPE"),
                            rs.getString("MEMO"),
                            rs.getString("COMPANY_NAME"),
                            rs.getString("POSITION"),
                            rs.getString("STAGE")
                    );
                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private String mapTypeToStage(String type) {
        if (type == null) return "APPLIED";
        switch (type) {
            case "코딩테스트":
                return "TECH_INTERVIEW";
            case "1차면접":
                return "FIRST_INTERVIEW";
            case "2차면접":
                return "SECOND_INTERVIEW";
            case "임원면접":
                return "THIRD_INTERVIEW";
            default:
                return "ETC";
        }
    }

    public void addSchedule(HttpServletRequest request) throws Exception {


        try (Connection con = DBManager_new.connect()) {
            MemberDTO user = (MemberDTO) request.getSession().getAttribute("user");
            int memberId = user.getMember_id();

            // 기업명 양 옆 공백 제거
            String companyName = request.getParameter("company_name");
            if (companyName != null) companyName = companyName.trim();

            String position = request.getParameter("position");
            String applyDate = request.getParameter("apply_date");
            String date = request.getParameter("date");
            String time = request.getParameter("time");
            String type = request.getParameter("type");
            String memo = request.getParameter("memo");
            String stage = mapTypeToStage(type);

            System.out.println("✅ [일정 추가] 화면에서 넘어온 회사명: [" + companyName + "]");

            con.setAutoCommit(false);
            try {
                // ==========================================
                // 1. 오라클 DB 저장 로직 (메인 작업)
                // ==========================================

                /// 1-1. 회사 ID 찾기 (수정 버전)
                int companyId = 60; // 기본값을 '기타(60)'로 설정
                String findCompanySql = "SELECT COMPANY_ID FROM COMPANY WHERE COMPANY_NAME = ?";

                try (PreparedStatement pstmt = con.prepareStatement(findCompanySql)) {
                    pstmt.setString(1, companyName);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            companyId = rs.getInt("COMPANY_ID");
                            System.out.println("✅ [DB 검색 성공] 찾은 회사 번호: " + companyId);
                        } else {
                            // DB에 없는 회사일 경우
                            System.out.println("⚠️ [DB 검색 실패] '기타'로 등록하고 메모에 회사명을 기록합니다.");
                            // 원래 입력했던 회사명을 메모 앞에 붙여줍니다.
                            memo = "[미등록 기업: " + companyName + "] " + (memo == null ? "" : memo);
                        }
                    }
                }

                // 1-2. 새로운 APP_ID 채번
                int newAppId = 0;
                try (PreparedStatement pstmt = con.prepareStatement("SELECT APPLICATION_SEQ.NEXTVAL FROM DUAL");
                     ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) newAppId = rs.getInt(1);
                }

                // 1-3. APPLICATION 인서트
                String appSql = "INSERT INTO APPLICATION (APP_ID, MEMBER_ID, COMPANY_ID, POSITION, STAGE, APPLY_DATE, CREATED_DATE) " +
                        "VALUES (?, ?, ?, ?, ?, ?, SYSDATE)";
                try (PreparedStatement pstmt = con.prepareStatement(appSql)) {
                    pstmt.setInt(1, newAppId);
                    pstmt.setInt(2, memberId);
                    pstmt.setInt(3, companyId);
                    pstmt.setString(4, (position == null || position.isEmpty()) ? "미정" : position);
                    pstmt.setString(5, stage);

                    if (applyDate != null && !applyDate.isEmpty()) {
                        pstmt.setDate(6, Date.valueOf(applyDate));
                    } else {
                        pstmt.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
                    }
                    pstmt.executeUpdate();
                }

                // 1-4. SCHEDULE 인서트
                String schSql = "INSERT INTO SCHEDULE (SCHEDULE_ID, MEMBER_ID, COMPANY_NAME, SCHEDULE_DATE, SCHEDULE_TIME, INTERVIEW_TYPE, MEMO, APP_ID) " +
                        "VALUES (SEQ_SCHEDULE.nextval, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?)";
                try (PreparedStatement pstmt = con.prepareStatement(schSql)) {
                    pstmt.setInt(1, memberId);
                    pstmt.setString(2, companyName);
                    pstmt.setString(3, date);
                    pstmt.setString(4, time);
                    pstmt.setString(5, type);
                    pstmt.setString(6, memo);
                    pstmt.setInt(7, newAppId);
                    pstmt.executeUpdate();
                }

                // ==========================================
                // 2. 구글 캘린더 연동 로직 (부가 작업)
                // ==========================================
                try {
                    // 유저의 Refresh Token 조회 (여기서 pstmt, rs 새로 선언)
                    String refreshToken = null;
                    String tokenSql = "SELECT GOOGLE_REFRESH_TOKEN FROM MEMBER WHERE MEMBER_ID = ?";
                    try (PreparedStatement pstmt = con.prepareStatement(tokenSql)) {
                        pstmt.setInt(1, memberId);
                        try (ResultSet rs = pstmt.executeQuery()) {
                            if (rs.next()) {
                                refreshToken = rs.getString("GOOGLE_REFRESH_TOKEN");
                            }
                        }
                    }

                    // 토큰 확인 및 구글 연동
                    if (refreshToken == null || refreshToken.isEmpty()) {
                        System.out.println("⚠️ [구글 캘린더] 연동 토큰이 없어 DB에만 저장됩니다.");
                    } else {
                        Calendar service = GoogleCalendarHelper.getCalendarService(refreshToken);

                        Event event = new Event()
                                .setSummary("[" + companyName + "] " + type + " 일정")
                                .setDescription("직무: " + (position == null ? "미정" : position) + "\n메모: " + (memo == null ? "" : memo));

                        String startDateTimeStr = date + "T" + time + ":00+09:00";
                        DateTime startDateTime = new DateTime(startDateTimeStr);

                        event.setStart(new EventDateTime().setDateTime(startDateTime));
                        event.setEnd(new EventDateTime().setDateTime(startDateTime));

                        service.events().insert("primary", event).execute();
                        System.out.println("✅ [구글 캘린더] 진짜 내 캘린더에 일정 등록 완료!");
                    }

                } catch (Exception googleEx) {
                    // 구글 연동이 실패해도 메인 DB 트랜잭션은 롤백되지 않도록 별도 예외 처리
                    System.out.println("⚠️ [구글 캘린더] 연동 실패! (오라클 DB에는 정상 저장됩니다.) 원인: " + googleEx.getMessage());
                }

                // 모든 작업이 끝나면 오라클 DB 커밋!
                con.commit();

            } catch (Exception e) {
                con.rollback();
                throw e;
            }
        }
    }

    // --- Update로직 ---
    public void updateSchedule(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try (Connection con = DBManager_new.connect()) {
            MemberDTO user = (MemberDTO) request.getSession().getAttribute("user");
            int memberId = user.getMember_id();

            int scheduleId = Integer.parseInt(request.getParameter("schedule_id"));
            String companyName = request.getParameter("company_name");
            String position = request.getParameter("position");
            String date = request.getParameter("date");
            String time = request.getParameter("time");
            String type = request.getParameter("type");
            String memo = request.getParameter("memo");

            con.setAutoCommit(false);
            try {
                int companyId = 0;
                try (PreparedStatement pstmt = con.prepareStatement("SELECT COMPANY_ID FROM COMPANY WHERE COMPANY_NAME = ?")) {
                    pstmt.setString(1, companyName);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            companyId = rs.getInt("COMPANY_ID");
                        } else {
                            throw new Exception("존재하지 않는 회사입니다: " + companyName);
                        }
                    }
                }

                int appId = 0;
                try (PreparedStatement pstmt = con.prepareStatement("SELECT APP_ID FROM SCHEDULE WHERE SCHEDULE_ID = ?")) {
                    pstmt.setInt(1, scheduleId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) appId = rs.getInt("APP_ID");
                    }
                }

                String updateAppSql = "UPDATE APPLICATION SET COMPANY_ID = ?, POSITION = ?, STAGE = ? WHERE APP_ID = ?";
                try (PreparedStatement pstmt = con.prepareStatement(updateAppSql)) {
                    pstmt.setInt(1, companyId);
                    pstmt.setString(2, (position == null || position.isEmpty()) ? "미정" : position);
                    pstmt.setString(3, mapTypeToStage(type));
                    pstmt.setInt(4, appId);
                    pstmt.executeUpdate();
                }

                String updateSchSql = "UPDATE SCHEDULE SET COMPANY_NAME = ?, SCHEDULE_DATE = TO_DATE(?, 'YYYY-MM-DD'), " +
                        "SCHEDULE_TIME = ?, INTERVIEW_TYPE = ?, MEMO = ? WHERE SCHEDULE_ID = ?";
                try (PreparedStatement pstmt = con.prepareStatement(updateSchSql)) {
                    pstmt.setString(1, companyName);
                    pstmt.setString(2, date);
                    pstmt.setString(3, time);
                    pstmt.setString(4, type);
                    pstmt.setString(5, memo);
                    pstmt.setInt(6, scheduleId);
                    pstmt.executeUpdate();
                }

                con.commit();
            } catch (Exception e) {
                con.rollback();
                throw e;
            }
        }
    }

    // --- Delete ---
    public void deleteSchedule(int scheduleId) {
        System.out.println("✅ [DAO 진입] DB 삭제 로직 시작. 삭제할 ID: " + scheduleId);

        try (Connection con = DBManager_new.connect()) {
            con.setAutoCommit(false);
            try {
                int appId = 0;
                String findAppSql = "SELECT APP_ID FROM SCHEDULE WHERE SCHEDULE_ID = ?";
                try (PreparedStatement pstmt = con.prepareStatement(findAppSql)) {
                    pstmt.setInt(1, scheduleId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) appId = rs.getInt("APP_ID");
                    }
                }

                System.out.println("👉 조회된 APP_ID: " + appId);

                String delSchSql = "DELETE FROM SCHEDULE WHERE SCHEDULE_ID = ?";
                try (PreparedStatement pstmt = con.prepareStatement(delSchSql)) {
                    pstmt.setInt(1, scheduleId);
                    int result = pstmt.executeUpdate();
                    System.out.println("👉 SCHEDULE 테이블 삭제 결과(영향받은 행): " + result);
                }

                if (appId > 0) {
                    String delAppSql = "DELETE FROM APPLICATION WHERE APP_ID = ?";
                    try (PreparedStatement pstmt = con.prepareStatement(delAppSql)) {
                        pstmt.setInt(1, appId);
                        int result = pstmt.executeUpdate();
                        System.out.println("👉 APPLICATION 테이블 삭제 결과(영향받은 행): " + result);
                    }
                }

                con.commit();
                System.out.println("✅ [DB 삭제 완료 및 커밋 성공]");
            } catch (Exception e) {
                con.rollback();
                System.out.println("❌ [DB 삭제 중 에러 발생 - 롤백 처리됨]");
                e.printStackTrace();
            }
        } catch (Exception e) {
            System.out.println("❌ [DB 연결 실패]");
            e.printStackTrace();
        }
    }

    public ArrayList<String> getAllCompanyNames() {
        ArrayList<String> names = new ArrayList<>();

        String sql = "SELECT COMPANY_NAME FROM COMPANY ORDER BY COMPANY_NAME ASC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                names.add(rs.getString("COMPANY_NAME"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return names;
    }

    // 🌟🌟🌟 구글 -> 웹 DB 양방향 동기화 핵심 로직 🌟🌟🌟
    public void syncGoogleCalendarToDB() {
        try (Connection con = DBManager_new.connect()) {
            // 등록된 회사 목록 미리 가져오기 (이름 매칭용)
            ArrayList<String> companyList = getAllCompanyNames();

            String sql = "SELECT MEMBER_ID, GOOGLE_REFRESH_TOKEN FROM MEMBER WHERE GOOGLE_REFRESH_TOKEN IS NOT NULL";
            try (PreparedStatement pstmt = con.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {

                while (rs.next()) {
                    int memberId = rs.getInt("MEMBER_ID");
                    String refreshToken = rs.getString("GOOGLE_REFRESH_TOKEN");

                    System.out.println("▶ 회원번호 [" + memberId + "] 구글 캘린더 동기화 시작...");

                    com.google.api.services.calendar.Calendar service = GoogleCalendarHelper.getCalendarService(refreshToken);

                    // ==============================================================
                    // [설정 포인트] 얼마 동안의 구글 일정을 긁어올 것인가?
                    // 서버 무리를 방지하기 위해, 초반엔 12시간, 발표 땐 1분(60,000ms)으로 변경하세요.
                    // ==============================================================
                    long timeWindowMillis = 24 * 60 * 60 * 1000L; // 현재 세팅: 12시간
                    // 서버가 꺼져있던 시간 대비해 확인하는 코드입니다
                   //  long timeWindowMillis = 60 * 1000L; // 발표 시연용 세팅: 1분 (나중에 바꿔주세요)

                    com.google.api.client.util.DateTime updatedMin =
                            new com.google.api.client.util.DateTime(System.currentTimeMillis() - timeWindowMillis);

                    // 업데이트된 이벤트만 가져오기 (최신순 정렬)
                    com.google.api.services.calendar.model.Events events = service.events().list("primary")
                            .setUpdatedMin(updatedMin)
                            .setOrderBy("updated")
                            .execute();

                    for (com.google.api.services.calendar.model.Event event : events.getItems()) {
                        if ("cancelled".equals(event.getStatus())) continue; // 삭제된 일정 패스

                        String summary = event.getSummary(); // 예: "오후 1시 카카오 면접"
                        if (summary == null) continue;

                        // 1. 파싱 로직: 등록된 회사 이름이 summary에 포함되어 있는지 확인
                        String matchedCompany = "기타";
                        int companyId = 60; // 60번: 기타 (DB에 없는 기업일 경우 기본값)
                        String type = "기타";
                        String position = "미정";

                        for (String comp : companyList) {
                            if (summary.contains(comp)) {
                                matchedCompany = comp;
                                // DB에서 찾은 회사 ID 조회
                                try (PreparedStatement idStmt = con.prepareStatement("SELECT COMPANY_ID FROM COMPANY WHERE COMPANY_NAME = ?")) {
                                    idStmt.setString(1, matchedCompany);
                                    ResultSet idRs = idStmt.executeQuery();
                                    if (idRs.next()) companyId = idRs.getInt("COMPANY_ID");
                                }
                                break;
                            }
                        }

                        // 면접 전형(type) 유추
                        if (summary.contains("코딩테스트")) type = "코딩테스트";
                        else if (summary.contains("1차")) type = "1차면접";
                        else if (summary.contains("2차")) type = "2차면접";
                        else if (summary.contains("임원")) type = "임원면접";

                        // 2. 시간 및 메모 정리
                        String memo = "[구글 자동등록] 원본: " + summary; // 유저가 쓴 원문 보존
                        if (event.getDescription() != null) {
                            String[] lines = event.getDescription().split("\n");
                            for (String line : lines) {
                                if (line.startsWith("직무:")) {
                                    position = line.substring(3).trim();
                                } else if (line.startsWith("메모:")) {
                                    memo += " / " + line.substring(3).trim();
                                }
                            }
                        }

                        // 이벤트 날짜/시간 가져오기
                        String dateStr = "";
                        String timeStr = "14:00"; // 기본값
                        if (event.getStart().getDateTime() != null) {
                            String rfc3339 = event.getStart().getDateTime().toStringRfc3339(); // 예: 2026-04-15T13:00:00.000+09:00
                            dateStr = rfc3339.substring(0, 10);
                            timeStr = rfc3339.substring(11, 16);
                        } else if (event.getStart().getDate() != null) {
                            dateStr = event.getStart().getDate().toString();
                        }

                        // 3. 중복 체크 (DB에 이미 같은 날짜, 같은 회사 일정이 있는지 확인)
                        boolean isExist = false;
                        String checkSql = "SELECT COUNT(*) FROM SCHEDULE WHERE MEMBER_ID = ? AND SCHEDULE_DATE = TO_DATE(?, 'YYYY-MM-DD') AND COMPANY_NAME = ?";
                        try (PreparedStatement checkStmt = con.prepareStatement(checkSql)) {
                            checkStmt.setInt(1, memberId);
                            checkStmt.setString(2, dateStr);
                            checkStmt.setString(3, matchedCompany);
                            ResultSet checkRs = checkStmt.executeQuery();
                            if (checkRs.next() && checkRs.getInt(1) > 0) {
                                isExist = true; // 이미 DB에 일정이 있음
                            }
                        }

                        // 4. DB에 없다면 Insert 진행!
                        if (!isExist && !dateStr.isEmpty()) {
                            con.setAutoCommit(false); // 트랜잭션 시작
                            try {
                                // 4-1. APP_ID 생성 및 APPLICATION 인서트
                                int newAppId = 0;
                                try (PreparedStatement seqStmt = con.prepareStatement("SELECT APPLICATION_SEQ.NEXTVAL FROM DUAL");
                                     ResultSet seqRs = seqStmt.executeQuery()) {
                                    if (seqRs.next()) newAppId = seqRs.getInt(1);
                                }

                                String appSql = "INSERT INTO APPLICATION (APP_ID, MEMBER_ID, COMPANY_ID, POSITION, STAGE, CREATED_DATE) VALUES (?, ?, ?, ?, ?, SYSDATE)";
                                try (PreparedStatement appStmt = con.prepareStatement(appSql)) {
                                    appStmt.setInt(1, newAppId);
                                    appStmt.setInt(2, memberId);
                                    appStmt.setInt(3, companyId);
                                    appStmt.setString(4, position);
                                    appStmt.setString(5, mapTypeToStage(type)); // 기존 작성된 메서드 활용
                                    appStmt.executeUpdate();
                                }

                                // 4-2. SCHEDULE 인서트 (이때 matchedCompany와 합쳐진 memo를 넣습니다)
                                String schSql = "INSERT INTO SCHEDULE (SCHEDULE_ID, MEMBER_ID, COMPANY_NAME, SCHEDULE_DATE, SCHEDULE_TIME, INTERVIEW_TYPE, MEMO, APP_ID) " +
                                        "VALUES (SEQ_SCHEDULE.nextval, ?, ?, TO_DATE(?, 'YYYY-MM-DD'), ?, ?, ?, ?)";
                                try (PreparedStatement schStmt = con.prepareStatement(schSql)) {
                                    schStmt.setInt(1, memberId);
                                    schStmt.setString(2, matchedCompany);
                                    schStmt.setString(3, dateStr);
                                    schStmt.setString(4, timeStr);
                                    schStmt.setString(5, type);
                                    schStmt.setString(6, memo);
                                    schStmt.setInt(7, newAppId);
                                    schStmt.executeUpdate();
                                }
                                con.commit(); // 성공 시 커밋
                                System.out.println("✅ [구글->DB] 신규 일정 자동 추가 완료: " + matchedCompany + " (" + dateStr + ")");
                            } catch (Exception e) {
                                con.rollback(); // 에러 발생 시 롤백
                                System.err.println("❌ DB Insert 실패: " + e.getMessage());
                            } finally {
                                con.setAutoCommit(true);
                            }
                        }
                    }
                }
            }
            System.out.println("✅ [DevDesk 스케줄러] 구글 캘린더 동기화 완료!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


}
