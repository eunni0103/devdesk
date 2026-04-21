
package com.devdesk.pj.report;

import com.devdesk.pj.main.DBManager_new;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {

    public static final ReportDAO REPORT_DAO = new ReportDAO();

    public ReportDAO() {
    }

    // 1. 신고 등록 (Insert)
    public int insertReport(ReportVO r) {
        String sql = "INSERT INTO report "
                + "(report_id, review_id, board_id, member_id, repo_reason, repo_content, repo_status, repo_created_date) "
                + "VALUES (report_seq.NEXTVAL, ?, ?, ?, ?, ?, 'PENDING', SYSDATE)";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            if (r.getRepoReviewId() > 0) pstmt.setInt(1, r.getRepoReviewId());
            else pstmt.setNull(1, Types.INTEGER);

            if (r.getRepoBoardId() > 0) pstmt.setInt(2, r.getRepoBoardId());
            else pstmt.setNull(2, Types.INTEGER);

            pstmt.setInt(3, r.getRepoMemberId());
            pstmt.setString(4, r.getRepoReason());
            pstmt.setString(5, r.getRepoContent());

            System.out.println("Executing insertReport SQL with:");
            System.out.println("reviewId: " + r.getRepoReviewId());
            System.out.println("boardId: " + r.getRepoBoardId());
            System.out.println("memberId: " + r.getRepoMemberId());
            System.out.println("reason: " + r.getRepoReason());

            int result = pstmt.executeUpdate();
            System.out.println("Insert result: " + result);
            return result;
        } catch (Exception e) {
            System.err.println("Error in insertReport: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    // 2. 전체 신고 목록 조회 (Select All)
    public List<ReportVO> getReports(String targetType, String status, String searchType, String keyword, int page, int pageSize) {
        List<ReportVO> reports = new ArrayList<>();
        StringBuilder sb = new StringBuilder(
                "SELECT * FROM (SELECT a.*, ROWNUM rn FROM (SELECT * FROM report WHERE 1=1");
        List<Object> params = new ArrayList<>();

        appendFilters(sb, params, targetType, status, searchType, keyword);

        sb.append(" ORDER BY repo_created_date DESC) a WHERE ROWNUM <= ?) WHERE rn > ?");
        params.add(page * pageSize);
        params.add((page - 1) * pageSize);

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sb.toString())) {
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reports.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return reports;
    }

    // 필터 조건에 맞는 전체 건수
    public int countReports(String targetType, String status, String searchType, String keyword) {
        StringBuilder sb = new StringBuilder("SELECT COUNT(*) FROM report WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sb, params, targetType, status, searchType, keyword);

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sb.toString())) {
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void appendFilters(StringBuilder sb, List<Object> params,
                               String targetType, String status, String searchType, String keyword) {
        if ("review".equals(targetType)) {
            sb.append(" AND review_id IS NOT NULL");
        } else if ("board".equals(targetType)) {
            sb.append(" AND board_id IS NOT NULL");
        }
        if (status != null && !"ALL".equals(status) && !status.isEmpty()) {
            sb.append(" AND repo_status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            String col = "repoReason".equals(searchType) ? "repo_reason" : "repo_content";
            sb.append(" AND ").append(col).append(" LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
    }

    private ReportVO mapRow(java.sql.ResultSet rs) throws java.sql.SQLException {
        ReportVO r = new ReportVO();
        r.setReportId(rs.getInt("report_id"));
        r.setRepoReviewId(rs.getInt("review_id"));
        r.setRepoBoardId(rs.getInt("board_id"));
        r.setRepoMemberId(rs.getInt("member_id"));
        r.setRepoReason(rs.getString("repo_reason"));
        r.setRepoContent(rs.getString("repo_content"));
        r.setRepoStatus(rs.getString("repo_status"));
        r.setRepoCreated(rs.getDate("repo_created_date"));
        return r;
    }

    // 3. 단건 조회 (Select One)
    public ReportVO getReportById(int reportId) {
        String sql = "SELECT * FROM report WHERE report_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, reportId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // board 삭제 전 해당 board를 참조하는 신고 전체 삭제
    public int deleteReportsByBoardId(int boardId) {
        String sql = "DELETE FROM report WHERE board_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, boardId);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // review 삭제 전 해당 review를 참조하는 신고 전체 삭제
    public int deleteReportsByReviewId(int reviewId) {
        String sql = "DELETE FROM report WHERE review_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, reviewId);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // 4. 상태 변경 (Update)
    public int updateReportStatus(int reportId, String status) {
        String sql = "UPDATE report SET repo_status = ? WHERE report_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, reportId);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // 4. 신고 삭제 (Delete)
    public int deleteReport(int reportId) {
        String sql = "DELETE FROM report WHERE report_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, reportId);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // 5. 중복 신고 방지 체크
    public boolean checkDuplicate(int memberId, int reviewId, int boardId) {
        String sql;
        int targetId;
        if (reviewId > 0) {
            sql = "SELECT COUNT(*) FROM report WHERE member_id = ? AND review_id = ?";
            targetId = reviewId;
        } else {
            sql = "SELECT COUNT(*) FROM report WHERE member_id = ? AND board_id = ?";
            targetId = boardId;
        }
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, memberId);
            pstmt.setInt(2, targetId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 💡 [추가된 기능 1] 원문 삭제 시 신고 상태를 완료로 바꾸고 식별자를 NULL 처리함
    public int updateReportStatusToResolvedAndNullify(int reportId) {
        String sql = "UPDATE report SET board_id = NULL, review_id = NULL, repo_status = 'RESOLVED' WHERE report_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, reportId);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // 💡 [추가된 기능 2] 회원 번호로 닉네임만 가져오는 메서드
    public String getNicknameByMemberId(int memberId) {
        String sql = "SELECT nickname FROM member WHERE member_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("nickname");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return String.valueOf(memberId);
    }

    // 💡 [선민 추가] 유저가 처리 중인 신고가 있는지 체크
    public boolean hasPendingReport(int memberId) {
        String sql = "SELECT COUNT(*) FROM report WHERE member_id = ? AND repo_status = 'PENDING'";
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}

