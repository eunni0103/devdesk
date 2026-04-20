package com.devdesk.pj.til;

import com.devdesk.pj.main.DBManager_new;
import com.devdesk.pj.user.MemberDTO;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TilDAO {
    // ✅ 1. static 제거 (인스턴스 메서드로)
    public List<TilV0> selectAllTils(int memberId) {

        // ✅ 2. WHERE 절로 해당 유저 것만 조회
        String sql = "SELECT * FROM til WHERE member_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setInt(1, memberId); // ✅ 파라미터 바인딩

            try (ResultSet rs = pstmt.executeQuery()) {
                ArrayList<TilV0> dtos = new ArrayList<>();

                while (rs.next()) {
                    TilV0 dto = new TilV0();
                    dto.setTilId(rs.getString("til_id"));
                    dto.setTitle(rs.getString("title"));
                    dto.setTag(rs.getString("tag"));
                    dto.setStudyTime(rs.getDouble("study_time"));
                    dto.setContent(rs.getString("content"));
                    dto.setCreatedAt(rs.getString("created_date"));
                    dtos.add(dto);
                }

                // ✅ 3. request.setAttribute 제거하고 dtos 반환
                return dtos;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<>(); // ✅ null 대신 빈 리스트 반환
    }

    public static void addTil(HttpServletRequest request) {
        MemberDTO loginUser = (MemberDTO) request.getSession().getAttribute("user");
        if (loginUser == null) return;
        int memberId = loginUser.getMember_id();

        String sql = "INSERT INTO til "
                + "(til_id, member_id, title, content, CREATED_DATE, tag, STUDY_TIME) "
                + "VALUES (APPLICATION_SEQ.NEXTVAL, ?, ?, ?, SYSDATE, ?, ?)";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            // 파라미터 받기
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            String tag = request.getParameter("tag");
            String studyTimeParam = request.getParameter("study_time");
            double studyTime = (studyTimeParam == null || studyTimeParam.isEmpty()) ? 0 : Double.parseDouble(studyTimeParam);

            // 바인딩
            pstmt.setInt(1, memberId);
            pstmt.setString(2, title);
            pstmt.setString(3, content);
            pstmt.setString(4, tag);
            pstmt.setDouble(5, studyTime);

            // 실행
            int result = pstmt.executeUpdate();

            if (result == 1) {
                System.out.println("add success");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

    }


    public static void updateTil(HttpServletRequest request) {

        String sql = "UPDATE til "
                + "SET title = ?, content = ?, tag = ?, study_time = ? "
                + "WHERE til_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            String title = request.getParameter("title");
            String content = request.getParameter("content");
            String tag = request.getParameter("tag");
            String studyTimeParam = request.getParameter("study_time");
            double studyTime = (studyTimeParam == null || studyTimeParam.isEmpty()) ? 0 : Double.parseDouble(studyTimeParam);
            String tilId = request.getParameter("til_id");

            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setString(3, tag);
            pstmt.setDouble(4, studyTime);
            pstmt.setInt(5, Integer.parseInt(tilId));

            int result = pstmt.executeUpdate();
            System.out.println("status changed: " + result);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void deleteTil(HttpServletRequest request) {

        String sql = "DELETE FROM til WHERE til_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            // 👉 파라미터 받기
            String tilIdStr = request.getParameter("til_id");
            System.out.println("til_id = " + tilIdStr);
            int tilId = Integer.parseInt(tilIdStr);

            pstmt.setInt(1, tilId);

            int result = pstmt.executeUpdate();

            if (result == 1) {
                System.out.println("삭제 성공");
            } else {
                System.out.println("삭제 실패");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<TilV0> getRecentTils(int memberId, int limit) {
        List<TilV0> list = new ArrayList<>();
        // Oracle에서 최근 5개만 가져오기
        String sql = "SELECT * FROM ("
                + "  SELECT * FROM til WHERE member_id = ? ORDER BY created_date DESC"
                + ") WHERE ROWNUM <= ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setInt(1, memberId);
            pstmt.setInt(2, limit);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    TilV0 vo = new TilV0();
                    vo.setTilId(rs.getString("til_id"));
                    vo.setTitle(rs.getString("title"));
                    vo.setTag(rs.getString("tag"));
                    vo.setContent(rs.getString("content"));
                    vo.setStudyTime(rs.getDouble("study_time"));
                    vo.setCreatedAt(rs.getString("created_date"));
                    list.add(vo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


    public List<TilTagStatVO> getTilTagStats(int memberId) {
        List<TilTagStatVO> list = new ArrayList<>();

        // Oracle 윈도우 함수로 태그별 비율 계산 (이번 달)
        String sql = "SELECT tag, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 0) AS pct "
                + "FROM til "
                + "WHERE member_id = ? "
                + "AND EXTRACT(YEAR FROM created_date) = EXTRACT(YEAR FROM SYSDATE) "
                + "AND EXTRACT(MONTH FROM created_date) = EXTRACT(MONTH FROM SYSDATE) "
                + "GROUP BY tag "
                + "ORDER BY pct DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setInt(1, memberId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    TilTagStatVO vo = new TilTagStatVO();
                    vo.setTag(rs.getString("tag"));
                    vo.setPct(rs.getInt("pct"));
                    list.add(vo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }


}
