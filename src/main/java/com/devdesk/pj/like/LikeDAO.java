package com.devdesk.pj.like;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.devdesk.pj.main.DBManager_new;

public class LikeDAO {

    // [1] 좋아요 여부 확인
    public boolean isLiked(int board_id, int member_id) {
        String sql = "SELECT 1 FROM board_like WHERE board_id = ? AND member_id = ?";
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, board_id);
            pstmt.setInt(2, member_id);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next(); // 데이터가 있으면 true, 없으면 false
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // [2] 좋아요 추가 (시퀀스 사용)
    public int insertLike(int board_id, int member_id) {
        String sql = "INSERT INTO board_like (like_id, board_id, member_id) VALUES (seq_board_like.NEXTVAL, ?, ?)";
        // try-with-resources 구문
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setInt(1, board_id);
            pstmt.setInt(2, member_id);
            int result = pstmt.executeUpdate();

            // ★ 추가: 수동으로 커밋을 실행하여 트리거가 작동하게 함
            if (!con.getAutoCommit()) {
                con.commit();
            }

            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // [3] 좋아요 삭제
    public int deleteLike(int board_id, int member_id) {
        String sql = "DELETE FROM board_like WHERE board_id = ? AND member_id = ?";

        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, board_id);
            pstmt.setInt(2, member_id);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // [4] 최신 좋아요 개수 조회 (board 테이블의 like_count 컬럼 읽기)
    public int getLikeCount(int board_id) {
        String sql = "SELECT b_like_count FROM board WHERE b_board_id = ?";
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, board_id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt("b_like_count");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // [5] 통합 토글 메서드 (컨트롤러에서 호출할 유일한 메서드)
    public LikeResult toggleLike(int board_id, int member_id) {
        // 내부 메서드 호출 시 변수명을 정확히 전달
        boolean alreadyLiked = this.isLiked(board_id, member_id);
        boolean success = false;
        String message = "";
        boolean finalState = false;

        if (alreadyLiked) {
            // 이미 좋아요 상태 -> 삭제
            if (this.deleteLike(board_id, member_id) > 0) {
                success = true;
                message = "좋아요가 취소되었습니다.";
                finalState = false;
            }
        } else {
            // 좋아요 아닌 상태 -> 추가
            if (this.insertLike(board_id, member_id) > 0) {
                success = true;
                message = "좋아요가 추가되었습니다.";
                finalState = true;
            }
        }

        // 트리거가 계산해준 최신 개수 가져오기
        int currentCount = this.getLikeCount(board_id);

        // LikeResult 객체 반환 (생성자 파라미터 순서 확인 필수!)
        return new LikeResult(success, currentCount, finalState, message);
    }
}
