package com.devdesk.pj.comment;

import com.devdesk.pj.main.DBManager_new;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class CommentDAO {
    public static int addComment(HttpServletRequest request) {
        String sql = "insert into comments (c_comments_id, b_board_id, member_id, c_content, parent_id, c_created_date) " +
                "values (seq_comments.nextval, ?, ?, ?, ?, sysdate)";
        int generatedId = -1;

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql, new String[]{"c_comments_id"})) {

            request.setCharacterEncoding("UTF-8");

            ps.setInt(1, Integer.parseInt(request.getParameter("board_id")));
            ps.setInt(2, Integer.parseInt(request.getParameter("member_id")));
            ps.setString(3, request.getParameter("content"));

            String parentIdStr = request.getParameter("parent_id");
            if (parentIdStr == null || parentIdStr.trim().isEmpty()) {
                ps.setNull(4, java.sql.Types.INTEGER);
            } else {
                ps.setInt(4, Integer.parseInt(parentIdStr));
            }

            int result = ps.executeUpdate();
            if (result == 1) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedId = rs.getInt(1);
                    }
                }
                System.out.println("add success, id: " + generatedId);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return generatedId;
    }

    public static ArrayList<CommentVO> getComment(HttpServletRequest request, int boardId) {

        ArrayList<CommentVO> comments = new ArrayList<>();

        String sql = "SELECT c.*, m.nickname " +
                "FROM comments c " +
                "JOIN member m ON c.member_id = m.member_id " +
                "WHERE c.b_board_id = ? " +
                "ORDER BY NVL(c.parent_id, c.c_comments_id), c.c_created_date";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, boardId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CommentVO c = new CommentVO();
                    c.setComments_id(rs.getInt("c_comments_id"));
                    c.setMember_id(rs.getInt("member_id"));
                    c.setContent(rs.getString("c_content"));
                    c.setCreated_date(String.valueOf(rs.getDate("c_created_date")));
                    c.setNickname(rs.getString("nickname"));
                    c.setParent_id(rs.getObject("parent_id") != null ? rs.getInt("parent_id") : null); // parent_id 설정 추가
                    comments.add(c);
                }
            }

            System.out.println("댓글 개수: " + comments.size());
            request.setAttribute("commentList", comments);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return comments;
    }

    public static boolean delComment(HttpServletRequest request) {
        String sql = "DELETE FROM comments WHERE c_comments_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            request.setCharacterEncoding("UTF-8");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));

            int result = ps.executeUpdate();

            if (result == 1) {
                System.out.println("delete success");
                return true;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean updateComment(HttpServletRequest request) {
        String commentId = request.getParameter("comment_id");
        String content = request.getParameter("content");

        String sql = "UPDATE comments SET c_content = ? WHERE c_comments_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {

            pstmt.setString(1, content);
            pstmt.setString(2, commentId);

            int result = pstmt.executeUpdate();

            if (result == 1) {
                System.out.println("댓글 수정 성공");
                return true;
            } else {
                System.out.println("댓글 수정 실패");
                return false;
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("댓글 수정 실패 - 예외 발생");
            return false;
        }
    }
}
