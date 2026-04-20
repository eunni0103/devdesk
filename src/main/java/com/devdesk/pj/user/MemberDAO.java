package com.devdesk.pj.user;

import com.devdesk.pj.comment.CommentVO;
import com.devdesk.pj.board.BoardVO;
import com.devdesk.pj.main.DBManager_new;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;


public class MemberDAO {

    public static final MemberDAO MBAO = new MemberDAO();

    MemberDAO() {
    }

    // 로그인 상태를 확인하는 전용 문지기 메서드

    public int idCheak(String email) {
        int result = 0;
        String sql = "select count(*) from member where email = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    result = rs.getInt(1);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return result;
    }

    public boolean signUp(HttpServletRequest request) {

        boolean result = false;

        String sql = "INSERT INTO MEMBER (MEMBER_ID, EMAIL, PASSWORD, NICKNAME, JOB_CATEGORY) "
                + "VALUES (member_id_seq.NEXTVAL, ?, ?, ?, ?)";

        try {
            // 🚨 DAO 안에서 request 상자를 뜯어서 값을 꺼냅니다!
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String nickname = request.getParameter("nickname");
            String jobCategory = request.getParameter("jobCategory");

            try (Connection con = DBManager_new.connect();
                 PreparedStatement pstmt = con.prepareStatement(sql)) {

                // 꺼낸 값을 쿼리의 물음표에 채워 넣습니다.
                pstmt.setString(1, email);
                pstmt.setString(2, password);
                pstmt.setString(3, nickname);
                pstmt.setString(4, jobCategory);

                if (pstmt.executeUpdate() == 1) { // 1줄 들어가면 성공!
                    result = true;
                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        return result;
    }

    public void login(HttpServletRequest request) {

        try {
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            String sql = "select * from member where email = ?";

            try (Connection con = DBManager_new.connect();
                 PreparedStatement pstmt = con.prepareStatement(sql)) {

                pstmt.setString(1, email);

                try (ResultSet rs = pstmt.executeQuery()) {
                    String msg = null;

                    if (rs.next()) {

                        if (rs.getString("password").equals(password)) {
                            // 로그인 성공
                            System.out.println("로그인 성공");

                            MemberDTO memberDTO = new MemberDTO();

                            memberDTO.setMember_id(rs.getInt("member_id"));
                            memberDTO.setEmail(rs.getString("email"));
                            memberDTO.setNickname(rs.getString("nickname"));
                            memberDTO.setJob_category(rs.getString("job_category"));
                            memberDTO.setRole(rs.getString("role"));

                            HttpSession hs = request.getSession();
                            hs.setAttribute("user", memberDTO);
                            hs.setMaxInactiveInterval(30 * 60);

                        } else {
                            //비번
                            System.out.println("비번에러");
                            msg = "비밀번호가 일치하지 않습니다.";
                        }
                    } else {
                        // 유저없음
                        System.out.println("유저 없음");
                        msg = "등록되지 않은 회원입니다.";
                    }
                    request.setAttribute("msg", msg);
                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }

    }

    public boolean updateProfile(HttpServletRequest request) {

        try {
            String nickname = request.getParameter("nickname");
            String job_category = request.getParameter("job_category");

            HttpSession hs = request.getSession();
            MemberDTO user = (MemberDTO) hs.getAttribute("user");

            String sql = "UPDATE MEMBER SET nickname = ?, job_category = ? WHERE email = ?";

            try (Connection con = DBManager_new.connect();
                 PreparedStatement pstmt = con.prepareStatement(sql)) {

                pstmt.setString(1, nickname);
                pstmt.setString(2, job_category);
                pstmt.setString(3, user.getEmail());

                if (pstmt.executeUpdate() == 1) {
                    System.out.println("프로필 텍스트 수정 성공!");

                    // 세션 정보 업데이트
                    user.setNickname(nickname);
                    user.setJob_category(job_category);

                    hs.setAttribute("user", user);
                    return true;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        return false;
    }


    public boolean passwordUpdate(HttpServletRequest request, HttpServletResponse response) {
        MemberDTO user = (MemberDTO) request.getSession().getAttribute("user");

        String sql = "UPDATE MEMBER SET password = ? WHERE member_id = ? AND password = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            String new_password = request.getParameter("new_password");
            String old_password = request.getParameter("old_password");
            pstmt.setString(1, new_password);
            pstmt.setInt(2, user.getMember_id());
            pstmt.setString(3, old_password);

            if (pstmt.executeUpdate() == 1) {
                System.out.println("비밀번호 변경 성공!");
                return true;
            } else {
                System.out.println("비밀번호 변경 실패: 현재 비밀번호 불일치");
                return false;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public ArrayList<BoardVO> getMyBoardList(int member_id) {
        ArrayList<BoardVO> boards = new ArrayList<>();

        String sql = "SELECT b.*, " +
                "(SELECT COUNT(*) FROM comments WHERE b_board_id = b.b_board_id) as comment_count, " +
                "COALESCE(b.b_like_count, 0) as like_count " +
                "FROM board b " +
                "WHERE member_id = ? " +
                "ORDER BY b.b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, member_id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BoardVO bo = new BoardVO();
                    bo.setBoard_id(rs.getInt("b_board_id"));
                    bo.setCategory(rs.getString("b_category"));
                    bo.setTitle(rs.getString("b_title"));
                    bo.setMember_id(rs.getInt("member_id"));
                    bo.setCreated_date(rs.getString("b_created_date"));
                    bo.setView_count(rs.getInt("b_view_count"));
                    bo.setComment_count(rs.getInt("comment_count"));
                    bo.setLike_count(rs.getInt("like_count"));
                    boards.add(bo);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return boards;
    }

    public ArrayList<CommentVO> getMyCommentList(int member_id) {
        ArrayList<CommentVO> comments = new ArrayList<>();

        String sql = "SELECT c.c_comments_id, c.b_board_id, c.c_content, c.c_created_date, b.b_title " +
                "FROM comments c " +
                "JOIN board b ON c.b_board_id = b.b_board_id " +
                "WHERE c.member_id = ? " +
                "ORDER BY c.c_comments_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, member_id);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CommentVO c = new CommentVO();
                    c.setComments_id(rs.getInt("c_comments_id"));
                    c.setBoard_id(rs.getInt("b_board_id"));
                    c.setContent(rs.getString("c_content"));

                    c.setCreated_date(String.valueOf(rs.getDate("c_created_date")));
                    c.setBoard_title(rs.getString("b_title"));

                    comments.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return comments;
    }

    // [회원 탈퇴] 비밀번호 검증 + 개인 데이터 삭제 + 회원 정보 비식별화
    public int deleteAccount(int memberId, String inputPassword) {

        try (Connection con = DBManager_new.connect()) {

            // 🌟 1. 비밀번호가 맞는지 검증부터 합니다!
            String checkSql = "SELECT password FROM member WHERE member_id = ?";
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, memberId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        if (!rs.getString("password").equals(inputPassword)) {
                            return 0;
                        }
                    } else {
                        return -1; // 유저를 찾을 수 없음
                    }
                }
            }

            // 🌟 2. 비밀번호가 맞으면 본격적인 탈퇴 로직 시작 (트랜잭션)
            con.setAutoCommit(false);
            try {
                // [하드 딜리트] 개인 워크스페이스 삭제
                String[] deleteQueries = {
                        // 1. 지원서 및 일정
                        "DELETE FROM schedule WHERE member_id = ?",
                        "DELETE FROM application WHERE member_id = ?",

                        // 2. TIL (오늘의 학습)
                        "DELETE FROM til WHERE member_id = ?",

                        // 3. 🌟 이력서 블록 (자식인 '버전' 먼저 -> 부모인 '블록' 나중)
                        "DELETE FROM resume_block_version WHERE block_id IN (SELECT block_id FROM resume_block WHERE member_id = ?)",
                        "DELETE FROM resume_block WHERE member_id = ?",

                        // 4. 🌟 기본 이력서 (자식인 '필드' 먼저 -> 부모인 '이력서' 나중)
                        "DELETE FROM resume_field WHERE resume_id IN (SELECT resume_id FROM resume WHERE member_id = ?)",
                        "DELETE FROM resume WHERE member_id = ?"
                };

                for (String sql : deleteQueries) {
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, memberId);
                        ps.executeUpdate();
                    }
                }

                // [소프트 딜리트] 회원 개인정보 파기 (비식별화)
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
                    int updateCount = ps.executeUpdate();

                    if (updateCount > 0) {
                        con.commit(); // 모든 과정 성공 시 확정!
                        System.out.println("회원 탈퇴 완료 (ID: " + memberId + ")");
                        return 1;
                    } else {
                        con.rollback();
                        return -1;
                    }
                }
            } catch (Exception e) {
                con.rollback();
                throw e;
            }

        } catch (Exception e) {
            System.out.println("회원 탈퇴 중 DB 에러 발생! 롤백합니다.");
            e.printStackTrace();
            return -1;
        }
    }


    public MemberDTO getMemberByEmail(String email) {

        String sql = "SELECT * FROM member WHERE email = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    MemberDTO dto = new MemberDTO();
                    dto.setMember_id(rs.getInt("member_id"));
                    dto.setEmail(rs.getString("email"));
                    dto.setNickname(rs.getString("nickname"));
                    dto.setJob_category(rs.getString("job_category"));
                    dto.setLogin_type(rs.getString("login_type"));
                    dto.setSocial_id(rs.getString("social_id"));
                    dto.setRole(rs.getString("role"));
                    dto.setStatus(rs.getString("status"));
                    dto.setProfile_img(rs.getString("profile_img"));
                    return dto;
                }
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    public void insertGoogleMember(String email, String nickname, String socialId) {

        String sql = "INSERT INTO MEMBER (MEMBER_ID, EMAIL, NICKNAME, LOGIN_TYPE, SOCIAL_ID) "
                + "VALUES (member_id_seq.NEXTVAL, ?, ?, 'GOOGLE', ?)";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, email);
            pstmt.setString(2, nickname);
            pstmt.setString(3, socialId);
            pstmt.executeUpdate();

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // 🌟 구글 리프레시 토큰을 DB에 저장/업데이트 하는 메서드
    public void updateGoogleRefreshToken(String email, String refreshToken) {
        Connection con = null;
        PreparedStatement pstmt = null;
        try {
            // 프로젝트에서 사용하시는 DB 연결 클래스명(DBManager 등)에 맞게 확인해 주세요.
            con = DBManager_new.connect();
            String sql = "UPDATE MEMBER SET GOOGLE_REFRESH_TOKEN = ? WHERE EMAIL = ?";

            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, refreshToken);
            pstmt.setString(2, email);

            pstmt.executeUpdate();
            System.out.println("✅ DB에 Refresh Token 저장 완료 (" + email + ")");

        } catch (Exception e) {
            System.out.println("❌ Refresh Token DB 저장 실패!");
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
    }


    /**
     * 비밀번호 찾기 STEP1 - 닉네임 + 이메일로 회원 존재 여부 확인
     *
     * @return true : 일치하는 회원 있음 / false : 없음
     */
    public boolean findMemberByNicknameAndEmail(String nickname, String email) {
        String sql = "SELECT COUNT(*) FROM member WHERE nickname = ? AND email = ? AND status != 'deleted'";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, nickname);
            pstmt.setString(2, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return false;
    }

    /**
     * 비밀번호 찾기 STEP2 - 이메일로 비밀번호 업데이트
     *
     * @return true : 성공 / false : 실패
     */
    public boolean resetPassword(String email, String newPassword) {
        String sql = "UPDATE member SET password = ? WHERE email = ? AND status != 'deleted'";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, newPassword);
            pstmt.setString(2, email);

            return pstmt.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 닉네임 중복 확인
     *
     * @return 1 : 이미 사용 중 / 0 : 사용 가능
     */
    public int nicknameCheck(String nickname) {
        int result = 0;
        String sql = "SELECT COUNT(*) FROM member WHERE nickname = ? AND status != 'deleted'";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, nickname);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    result = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return result;
    }

    /**
     * 기존 비밀번호와 동일한지 확인
     *
     * @return true : 기존 비밀번호와 같음 / false : 다름
     */
    public boolean isSameAsOldPassword(String email, String newPassword) {
        String sql = "SELECT password FROM member WHERE email = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // DB에 저장된 비밀번호와 새로 입력한 비밀번호가 일치하면 true 반환
                    return newPassword.equals(rs.getString("password"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}
