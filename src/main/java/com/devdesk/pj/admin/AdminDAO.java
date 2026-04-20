package com.devdesk.pj.admin;


import com.devdesk.pj.main.DBManager_new;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    public static final AdminDAO ADAO = new AdminDAO();

    private AdminDAO() {
    }

    // 🌟 [회원 관리 전용] 전체 회원 목록 조회 (탈퇴 회원 포함 100%)
    public List<AdminVO> getAllMembersForAdmin() {
        List<AdminVO> memberList = new ArrayList<>();

        // 여기서는 WHERE 조건 없이 모든 회원을 다 가져옵니다!
        String sql = "SELECT member_id, email, nickname, job_category, login_type, role, status, TO_CHAR(created_date, 'YYYY-MM-DD') as created_date " +
                "FROM member ORDER BY member_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AdminVO vo = new AdminVO();
                vo.setMember_id(rs.getInt("member_id"));
                vo.setEmail(rs.getString("email"));
                vo.setNickname(rs.getString("nickname"));
                vo.setJob_category(rs.getString("job_category"));
                vo.setLogin_type(rs.getString("login_type"));
                vo.setRole(rs.getString("role"));
                vo.setStatus(rs.getString("status") != null ? rs.getString("status") : "active");
                vo.setCreated_date(rs.getString("created_date"));
                memberList.add(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return memberList;
    }

    // 🌟 [대시보드 전용] 최근 가입한 활성 회원 Top 5만 조회
    public List<AdminVO> getRecentActiveMembers() {
        List<AdminVO> memberList = new ArrayList<>();

        // 대시보드는 현재 살아있는 회원 위주로 5명만 딱 끊어서 보여줍니다!
        String sql = "SELECT * FROM ( " +
                "  SELECT member_id, nickname, job_category, role, status, TO_CHAR(created_date, 'YYYY-MM-DD') as created_date " +
                "  FROM member " +
                "  WHERE status = 'active' " +
                "  ORDER BY created_date DESC " +
                ") WHERE ROWNUM <= 5";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AdminVO vo = new AdminVO();
                vo.setMember_id(rs.getInt("member_id"));
                vo.setNickname(rs.getString("nickname"));
                vo.setJob_category(rs.getString("job_category"));
                vo.setRole(rs.getString("role"));
                vo.setStatus(rs.getString("status"));
                vo.setCreated_date(rs.getString("created_date"));
                memberList.add(vo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return memberList;
    }

    // 🌟 [대시보드] 통계 데이터 가져오기
    // 여러 종류의 데이터를 한 번에 담아오기 위해 Map을 사용합니다.
    public java.util.Map<String, Object> getDashboardStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();

        try (Connection con = DBManager_new.connect()) {

            // 1️⃣ 총 가입자 수 & 오늘 신규 가입자 수 (🌟 수정됨: 탈퇴 회원 제외 조건 추가)
            String sql1 = "SELECT COUNT(member_id) as total_cnt, " +
                    "COUNT(CASE WHEN TRUNC(created_date) = TRUNC(SYSDATE) THEN 1 END) as today_cnt " +
                    "FROM member " +
                    "WHERE NVL(status, 'active') = 'active'"; // 🌟 탈퇴 회원(deleted) 제외
            try (PreparedStatement ps = con.prepareStatement(sql1);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalMembers", rs.getInt("total_cnt"));
                    stats.put("todayNewMembers", rs.getInt("today_cnt"));
                }
            }

            // 2️⃣ 총 게시글 수
            String sql2 = "SELECT COUNT(*) as board_cnt FROM board";
            try (PreparedStatement ps = con.prepareStatement(sql2);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalBoards", rs.getInt("board_cnt"));
                }
            }

            // 3️⃣ 직무 카테고리 분포 (도넛 차트용)
            // 💡 고정된 5개 항목을 만들고(LEFT JOIN), 조건에서 탈퇴한 회원을 완벽하게 차단합니다.
            // 🌟 수정됨: AND m.role != 'admin' 조건 삭제 (관리자 직무도 통계에 포함)
            String sql3 = "SELECT j.job, NVL(COUNT(m.member_id), 0) as cnt " +
                    "FROM ( " +
                    "  SELECT '프론트엔드' as job FROM dual UNION ALL " +
                    "  SELECT '백엔드' FROM dual UNION ALL " +
                    "  SELECT '데이터/AI' FROM dual UNION ALL " +
                    "  SELECT '기획/디자인' FROM dual UNION ALL " +
                    "  SELECT '미입력(소셜)' FROM dual " +
                    ") j " +
                    "LEFT JOIN member m " +
                    "  ON NVL(m.job_category, '미입력(소셜)') = j.job " +
                    "  AND NVL(m.status, 'active') = 'active' " + // 🌟 탈퇴(deleted) 상태 제외
                    "  AND m.nickname != '탈퇴한 회원' " +        // 🌟 닉네임 변경된 탈퇴 회원 제외
                    "  AND m.email NOT LIKE 'del_%' " +           // 🌟 이메일 지워진 탈퇴 회원 제외
                    "GROUP BY j.job " +
                    "ORDER BY " +
                    "  CASE j.job " +
                    "    WHEN '프론트엔드' THEN 1 " +
                    "    WHEN '백엔드' THEN 2 " +
                    "    WHEN '데이터/AI' THEN 3 " +
                    "    WHEN '기획/디자인' THEN 4 " +
                    "    WHEN '미입력(소셜)' THEN 5 " +
                    "  END";

            try (PreparedStatement ps = con.prepareStatement(sql3);
                 ResultSet rs = ps.executeQuery()) {

                List<String> jobLabels = new ArrayList<>();
                List<Integer> jobData = new ArrayList<>();

                while (rs.next()) {
                    jobLabels.add(rs.getString("job"));
                    jobData.add(rs.getInt("cnt"));
                }
                stats.put("jobLabels", jobLabels);
                stats.put("jobData", jobData);
            }

            // 4️⃣ 최근 7일 가입자 트렌드 (선 차트용)
            // 💡 로직 설명: CONNECT BY를 써서 최근 7일의 '날짜(MM/DD)'를 강제로 만들고, 회원 테이블과 JOIN 합니다.
            String sql4 = "SELECT TO_CHAR(d.dt, 'MM/DD') as label, NVL(COUNT(m.member_id), 0) as cnt " +
                    "FROM (SELECT TRUNC(SYSDATE - 7 + LEVEL) as dt FROM dual CONNECT BY LEVEL <= 7) d " +
                    "LEFT JOIN member m ON TRUNC(m.created_date) = d.dt " +
                    "GROUP BY d.dt ORDER BY d.dt ASC";
            try (PreparedStatement ps = con.prepareStatement(sql4);
                 ResultSet rs = ps.executeQuery()) {
                List<String> trendLabels = new ArrayList<>();
                List<Integer> trendData = new ArrayList<>();
                while (rs.next()) {
                    trendLabels.add(rs.getString("label"));
                    trendData.add(rs.getInt("cnt"));
                }
                stats.put("trendLabels", trendLabels);
                stats.put("trendData", trendData);
            }

        } catch (Exception e) {
            System.out.println("대시보드 통계 조회 중 DB 에러!");
            e.printStackTrace();
        }
        return stats;
    }

    // 🌟 [회원 관리] 관리자 권한으로 강제 탈퇴 (비밀번호 검증 무시)
    public boolean forceDeleteMember(int memberId) {
        try (Connection con = DBManager_new.connect()) {
            con.setAutoCommit(false); // 트랜잭션 시작
            try {
                // 1. 하드 딜리트 (서버 용량을 차지하는 쓰레기 데이터 완벽 파기)
                String[] deleteQueries = {
                        "DELETE FROM schedule WHERE member_id = ?",
                        "DELETE FROM application WHERE member_id = ?",
                        "DELETE FROM til WHERE member_id = ?",
                        "DELETE FROM resume_block_version WHERE block_id IN (SELECT block_id FROM resume_block WHERE member_id = ?)",
                        "DELETE FROM resume_block WHERE member_id = ?",
                        "DELETE FROM resume_field WHERE resume_id IN (SELECT resume_id FROM resume WHERE member_id = ?)",
                        "DELETE FROM resume WHERE member_id = ?"
                };
                for (String sql : deleteQueries) {
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, memberId);
                        ps.executeUpdate();
                    }
                }

                // 2. 소프트 딜리트 (회원 목록에는 유령 회원으로 남기기)
                String updateQuery = "UPDATE member SET " +
                        "email = 'del_' || member_id || '_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS'), " +
                        "password = NULL, " +
                        "nickname = '탈퇴한 회원', " +
                        "job_category = NULL, " +
                        "social_id = NULL, " +
                        "profile_img = NULL, " +
                        "status = 'deleted', " +
                        "update_date = SYSDATE " +
                        "WHERE member_id = ?";

                try (PreparedStatement ps = con.prepareStatement(updateQuery)) {
                    ps.setInt(1, memberId);
                    if (ps.executeUpdate() > 0) {
                        con.commit(); // 모든 과정 성공 시 확정!
                        return true;
                    }
                }
                con.rollback();
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false; // 실패 시 false
    }

    // 🌟 [회원 관리] 특정 회원의 상세 정보 및 활동 내역 조회 (AJAX용)
    public java.util.Map<String, Object> getMemberDetail(int memberId) {
        java.util.Map<String, Object> detail = new java.util.HashMap<>();

        // 유저 정보 + 게시글 수 + 댓글 수 통합 쿼리
        String sql = "SELECT m.*, " +
                "  (SELECT COUNT(*) FROM board WHERE member_id = m.member_id) as board_cnt, " +
                "  (SELECT COUNT(*) FROM comments WHERE member_id = m.member_id) as comment_cnt " +
                "FROM member m WHERE m.member_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    detail.put("id", rs.getInt("member_id"));
                    detail.put("email", rs.getString("email"));
                    detail.put("nickname", rs.getString("nickname"));
                    detail.put("job", rs.getString("job_category"));
                    detail.put("role", rs.getString("role"));
                    detail.put("status", rs.getString("status"));
                    detail.put("loginType", rs.getString("login_type"));
                    detail.put("created", rs.getString("created_date"));
                    detail.put("boardCnt", rs.getInt("board_cnt"));
                    detail.put("commentCnt", rs.getInt("comment_cnt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return detail;
    }

    // 🌟 [게시글 관리] 전체 게시글 목록 조회
    public List<AdminBoardVO> getAllAdminBoards() {
        List<AdminBoardVO> boardList = new ArrayList<>();

        // 최신 글(번호가 큰 글)이 맨 위에 오도록 내림차순(DESC) 정렬
        String sql = "SELECT b.b_board_id, b.b_category, b.b_title, m.nickname, m.email, " +
                "TO_CHAR(b.b_created_date, 'YYYY-MM-DD') as created_date, b.b_view_count " +
                "FROM board b " +
                "JOIN member m ON b.member_id = m.member_id " +
                "ORDER BY b.b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                AdminBoardVO vo = new AdminBoardVO();
                vo.setBoard_id(rs.getInt("b_board_id"));
                vo.setCategory(rs.getString("b_category"));
                vo.setTitle(rs.getString("b_title"));
                vo.setNickname(rs.getString("nickname"));
                vo.setEmail(rs.getString("email"));
                vo.setCreated_date(rs.getString("created_date"));
                vo.setView_count(rs.getInt("b_view_count"));

                boardList.add(vo);
            }
        } catch (Exception e) {
            System.out.println("관리자 게시글 목록 조회 중 DB 에러!");
            e.printStackTrace();
        }
        return boardList;
    }

// =====================================================================
    // 🏢 기업 정보 관리 메서드들 (AdminDAO.java 하단에 추가)
    // =====================================================================

    // 🌟 [기업 관리] 페이징 포함 기업 목록 조회
    public java.util.Map<String, Object> getCompaniesPaged(String filter, String keyword, int page, int pageSize) {
        StringBuilder baseSql = new StringBuilder(
                "SELECT c.company_id, c.company_name, c.company_industry, " +
                        "c.company_location, c.company_rating, c.company_size, c.is_verified, " +
                        "TO_CHAR(c.company_created_date, 'YYYY-MM-DD') as company_created_date, " +
                        "COUNT(r.r_id) as review_count " +
                        "FROM company c " +
                        "LEFT JOIN review r ON c.company_id = r.r_company_id "
        );

        List<Object> params = new ArrayList<>();
        boolean hasWhere = false;

        if (filter != null && (filter.equals("Y") || filter.equals("N"))) {
            baseSql.append("WHERE c.is_verified = ? ");
            params.add(filter);
            hasWhere = true;
        }
        if (keyword != null && !keyword.isBlank()) {
            baseSql.append(hasWhere ? "AND " : "WHERE ").append("c.company_name LIKE ? ");
            params.add("%" + keyword + "%");
        }

        baseSql.append("GROUP BY c.company_id, c.company_name, c.company_industry, " +
                "c.company_location, c.company_rating, c.company_size, " +
                "c.is_verified, c.company_created_date " +
                "ORDER BY c.company_id DESC");

        String countSql = "SELECT COUNT(*) FROM (" + baseSql + ")";
        String pagedSql = "SELECT * FROM (" +
                "  SELECT ROWNUM rn, t.* FROM (" + baseSql + ") t " +
                ") WHERE rn BETWEEN ? AND ?";

        int start = (page - 1) * pageSize + 1;
        int end = page * pageSize;

        java.util.Map<String, Object> result = new java.util.HashMap<>();

        try (Connection con = DBManager_new.connect()) {

            // 전체 건수
            try (PreparedStatement ps = con.prepareStatement(countSql)) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) result.put("totalCount", rs.getInt(1));
                }
            }

            // 페이징 데이터
            try (PreparedStatement ps = con.prepareStatement(pagedSql)) {
                for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                ps.setInt(params.size() + 1, start);
                ps.setInt(params.size() + 2, end);

                List<AdminCompanyVO> list = new ArrayList<>();
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        AdminCompanyVO vo = new AdminCompanyVO();
                        vo.setCompany_id(rs.getInt("company_id"));
                        vo.setCompany_name(rs.getString("company_name"));
                        vo.setCompany_industry(rs.getString("company_industry"));
                        vo.setCompany_location(rs.getString("company_location"));
                        vo.setCompany_rating(rs.getDouble("company_rating"));
                        vo.setCompany_size(rs.getInt("company_size"));
                        vo.setIs_verified(rs.getString("is_verified"));
                        vo.setCompany_created_date(rs.getString("company_created_date"));
                        vo.setReview_count(rs.getInt("review_count"));
                        list.add(vo);
                    }
                }
                result.put("companies", list);
            }

            int totalCount = (int) result.getOrDefault("totalCount", 0);
            result.put("totalPages", (int) Math.ceil((double) totalCount / pageSize));
            result.put("currentPage", page);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 🌟 [기업 관리] 승인 처리 (is_verified = 'N' → 'Y')
    public boolean approveCompany(int companyId) {
        String sql = "UPDATE company SET is_verified = 'Y' WHERE company_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, companyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🌟 [기업 관리] 반려 처리 (is_verified = 'Y' → 'N')
    public boolean rejectCompany(int companyId) {
        String sql = "UPDATE company SET is_verified = 'N' WHERE company_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, companyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🌟 [기업 관리] 기업 삭제 (review도 함께 삭제)
    public boolean deleteCompanyAdmin(int companyId) {
        String sqlDelRev = "DELETE FROM review WHERE r_company_id = ?";
        String sqlDelComp = "DELETE FROM company WHERE company_id = ?";
        try (Connection con = DBManager_new.connect()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(sqlDelRev)) {
                    ps.setInt(1, companyId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(sqlDelComp)) {
                    ps.setInt(1, companyId);
                    ps.executeUpdate();
                }
                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🌟 [기업 관리] 기업 정보 수정
    public boolean updateCompanyAdmin(int companyId, String name, String industry,
                                      String location, double rating, int size) {
        String sql = "UPDATE company SET company_name=?, company_industry=?, " +
                "company_location=?, company_rating=?, company_size=? " +
                "WHERE company_id=?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, industry);
            ps.setString(3, location);
            ps.setDouble(4, rating);
            ps.setInt(5, size);
            ps.setInt(6, companyId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🌟 [기업 관리] 중복 기업 병합
    public boolean mergeCompanies(int keepId, int deleteId) {
        try (Connection con = DBManager_new.connect()) {
            con.setAutoCommit(false);
            try {
                String sqlApp = "UPDATE application SET company_id = ? WHERE company_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sqlApp)) {
                    ps.setInt(1, keepId);
                    ps.setInt(2, deleteId);
                    ps.executeUpdate();
                }
                String sqlRev = "UPDATE review SET r_company_id = ? WHERE r_company_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sqlRev)) {
                    ps.setInt(1, keepId);
                    ps.setInt(2, deleteId);
                    ps.executeUpdate();
                }
                String sqlDel = "DELETE FROM company WHERE company_id = ?";
                try (PreparedStatement ps = con.prepareStatement(sqlDel)) {
                    ps.setInt(1, deleteId);
                    ps.executeUpdate();
                }
                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 🌟 [기업 관리] 승인 대기 건수
    public int getPendingCompanyCount() {
        String sql = "SELECT COUNT(*) FROM company WHERE is_verified = 'N'";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 🌟 [기업 관리] 전체 기업 수 (필터 무관, 카드용)
    public int getTotalAllCompanyCount() {
        String sql = "SELECT COUNT(*) FROM company";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 🌟 [게시글 관리] 관리자 권한으로 게시글 강제 삭제 (댓글 포함 완벽 파기)
    public boolean deleteBoardAdmin(int boardId) {
        // 외래키(FK) 제약 조건 에러를 막기 위해 댓글부터 싹 지우고 게시글을 지웁니다!
        String sqlDelComments = "DELETE FROM comments WHERE b_board_id = ?";
        String sqlDelBoard = "DELETE FROM board WHERE b_board_id = ?";

        try (Connection con = DBManager_new.connect()) {
            con.setAutoCommit(false); // 트랜잭션 시작 (안전장치)

            try {
                // 1. 자식 데이터(댓글) 삭제
                try (PreparedStatement ps = con.prepareStatement(sqlDelComments)) {
                    ps.setInt(1, boardId);
                    ps.executeUpdate(); // 댓글이 없어도 에러 안 남
                }

                // 2. 부모 데이터(게시글) 삭제
                try (PreparedStatement ps = con.prepareStatement(sqlDelBoard)) {
                    ps.setInt(1, boardId);
                    int result = ps.executeUpdate();
                    if (result > 0) {
                        con.commit(); // 🌟 모두 성공하면 확정!
                        return true;
                    }
                }
                con.rollback();
            } catch (Exception e) {
                con.rollback(); // 에러 나면 롤백!
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }


}
