package com.devdesk.pj.board;

import com.devdesk.pj.main.DBManager_new;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class BoardDAO {
    public static void addBoard(HttpServletRequest request) {
        String sql = "INSERT INTO board (b_board_id, member_id,b_category, b_title, b_content) " +
                " VALUES (board_seq.NEXTVAL, ?, ?, ?, ?)";

        try (
                Connection con = DBManager_new.connect();
                PreparedStatement ps = con.prepareStatement(sql);
        ) {
            request.setCharacterEncoding("UTF-8");

            // ✔ 파라미터 세팅 먼저
            ps.setInt(1, Integer.parseInt(request.getParameter("member_id")));
            ps.setString(2, request.getParameter("category"));
            ps.setString(3, request.getParameter("title"));
            ps.setString(4, request.getParameter("txt"));

            // ✔ 실행은 한 번만
            int result = ps.executeUpdate();

            if (result == 1) {
                System.out.println("add success");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static ArrayList<BoardVO> showAllBoard(HttpServletRequest request) {

        BoardVO bo = null;
        ArrayList<BoardVO> boards = new ArrayList<>();
        String sql = "SELECT b.*, " +
                "(SELECT COUNT(*) FROM comments WHERE b_board_id = b.b_board_id) as comment_count, " +
                "COALESCE(b.b_like_count, 0) as like_count " +
                "FROM board b ORDER BY b.b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery();
        ) {


            while (rs.next()) {
                bo = new BoardVO();
                bo.setBoard_id(rs.getInt("b_board_id"));
                bo.setCategory(rs.getString("b_category"));
                bo.setTitle(rs.getString("b_title"));
                bo.setMember_id(rs.getInt("member_id"));
                bo.setCreated_date(rs.getTimestamp("b_created_date"));
                bo.setView_count(rs.getInt("b_view_count"));
                bo.setComment_count(rs.getInt("comment_count"));
                bo.setLike_count(rs.getInt("like_count"));
                boards.add(bo);
            }
            request.setAttribute("boards", boards);
            return boards;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ArrayList<BoardVO> showPopularBoard(HttpServletRequest request) {

        BoardVO bo = null;
        ArrayList<BoardVO> boards = new ArrayList<>();
        String sql = "SELECT b.*, " +
                "(SELECT COUNT(*) FROM comments WHERE b_board_id = b.b_board_id) as comment_count, " +
                "COALESCE(b.b_like_count, 0) as like_count " +
                "FROM board b ORDER BY b.b_like_count DESC, b.b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery();
        ) {
            while (rs.next()) {
                bo = new BoardVO();
                bo.setBoard_id(rs.getInt("b_board_id"));
                bo.setCategory(rs.getString("b_category"));
                bo.setTitle(rs.getString("b_title"));
                bo.setMember_id(rs.getInt("member_id"));
                bo.setCreated_date(rs.getTimestamp("b_created_date"));
                bo.setView_count(rs.getInt("b_view_count"));
                bo.setComment_count(rs.getInt("comment_count"));
                bo.setLike_count(rs.getInt("like_count"));
                boards.add(bo);
            }
            request.setAttribute("boards", boards);
            return boards;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ArrayList<BoardVO> showViewCountBoard(HttpServletRequest request) {
        ArrayList<BoardVO> boards = new ArrayList<>();
        BoardVO bo = null;
        String sql = "SELECT b.*, " +
                "(SELECT COUNT(*) FROM comments WHERE b_board_id = b.b_board_id) as comment_count, " +
                "COALESCE(b.b_like_count, 0) as like_count " +
                "FROM board b ORDER BY b.b_view_count DESC, b.b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery();
        ) {
            while (rs.next()) {
                bo = new BoardVO();
                bo.setBoard_id(rs.getInt("b_board_id"));
                bo.setCategory(rs.getString("b_category"));
                bo.setTitle(rs.getString("b_title"));
                bo.setMember_id(rs.getInt("member_id"));
                bo.setCreated_date(rs.getTimestamp("b_created_date"));
                bo.setView_count(rs.getInt("b_view_count"));
                bo.setComment_count(rs.getInt("comment_count"));
                bo.setLike_count(rs.getInt("like_count"));
                boards.add(bo);
            }
            request.setAttribute("boards", boards);
            return boards;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void increaseViewCount(int boardId) {
        String sql = "UPDATE board SET b_view_count = b_view_count + 1 WHERE b_board_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
        ) {
            ps.setInt(1, boardId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static BoardVO getBoardById(int boardId) {
        String sql = "SELECT b.*, m.nickname FROM board b JOIN member m ON b.member_id = m.member_id WHERE b.b_board_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, boardId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BoardVO vo = new BoardVO();
                    vo.setMember_id(rs.getInt("member_id"));
                    vo.setBoard_id(rs.getInt("b_board_id"));
                    vo.setTitle(rs.getString("b_title"));
                    vo.setContent(rs.getString("b_content"));
                    vo.setCategory(rs.getString("b_category"));
                    vo.setCreated_date(rs.getTimestamp("b_created_date"));
                    vo.setNickname(rs.getString("nickname"));
                    return vo;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static int delBoardById(int boardId) {
        String delComments = "DELETE FROM comments WHERE b_board_id = ?";
        String delBoard = "DELETE FROM board WHERE b_board_id = ?";
        try (Connection con = DBManager_new.connect()) {
            try (PreparedStatement ps = con.prepareStatement(delComments)) {
                ps.setInt(1, boardId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(delBoard)) {
                ps.setInt(1, boardId);
                return ps.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // [NEW] Handle combined category and sort filtering
    public static ArrayList<BoardVO> searchBoardsByCategoryAndSort(HttpServletRequest request) {
        ArrayList<BoardVO> boards = new ArrayList<>();

        String category = request.getParameter("category");
        String sort = request.getParameter("sort");

        // If category is empty or "All", return sorted boards
        if (category == null || category.trim().isEmpty() || category.equals("All") || category.equals("All")) {
            if ("popular".equals(sort)) {
                return showPopularBoard(request);
            } else if ("viewcount".equals(sort)) {
                return showViewCountBoard(request);
            } else {
                return showAllBoard(request);
            }
        }

        // Build SQL with category filter and sorting
        String sql = "SELECT b.*, " +
                "(SELECT COUNT(*) FROM comments WHERE b_board_id = b.b_board_id) as comment_count, " +
                "COALESCE(b.b_like_count, 0) as like_count, " +
                "m.nickname " +
                "FROM board b " +
                "JOIN member m ON b.member_id = m.member_id " +
                "WHERE b.b_category = ? ";

        // Add sorting based on sort parameter
        if ("popular".equals(sort)) {
            sql += "ORDER BY b.b_like_count DESC, b.b_board_id DESC";
        } else if ("viewcount".equals(sort)) {
            sql += "ORDER BY b.b_view_count DESC, b.b_board_id DESC";
        } else {
            sql += "ORDER BY b.b_board_id DESC"; // default: latest
        }

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
        ) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BoardVO bo = new BoardVO();
                    bo.setBoard_id(rs.getInt("b_board_id"));
                    bo.setCategory(rs.getString("b_category"));
                    bo.setTitle(rs.getString("b_title"));
                    bo.setMember_id(rs.getInt("member_id"));
                    bo.setCreated_date(rs.getTimestamp("b_created_date"));
                    bo.setView_count(rs.getInt("b_view_count"));
                    bo.setComment_count(rs.getInt("comment_count"));
                    bo.setLike_count(rs.getInt("like_count"));
                    bo.setNickname(rs.getString("nickname"));
                    boards.add(bo);
                }
                request.setAttribute("boards", boards);
                return boards;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static int delBoard(HttpServletRequest request) {
        String sql = "DELETE FROM board WHERE b_board_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
        ) {
            ps.setString(1, request.getParameter("id"));
            int result = ps.executeUpdate();
            request.setCharacterEncoding("UTF-8");

            if (result == 1) {
                System.out.println("delete success");
            }
            return result;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public static void getBoard(HttpServletRequest request) {
        String sql = "SELECT b.*, m.nickname FROM board b JOIN member m ON b.member_id = m.member_id WHERE b.b_board_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql);
        ) {
            pstmt.setString(1, request.getParameter("id"));
            try (ResultSet rs = pstmt.executeQuery()) {
                BoardVO boardVO = null;

                if (rs.next()) {
                    int member_id = rs.getInt("member_id");
                    int board_id = rs.getInt("b_board_id");
                    String title = rs.getString("b_title");
                    String content = rs.getString("b_content");
                    String category = rs.getString("b_category");
                    java.util.Date created_date = rs.getTimestamp("b_created_date");
                    java.util.Date updated_date = rs.getTimestamp("b_updated_date");
                    int view_count = rs.getInt("b_view_count");
                    int like_count = rs.getInt("b_like_count");
                    String hiddenYnStr = rs.getString("b_hidden_yn");
                    char hidden_yn = (hiddenYnStr != null && !hiddenYnStr.isEmpty()) ? hiddenYnStr.charAt(0) : 'N';
                    String nickname = rs.getString("nickname");

                    boardVO = new BoardVO();
                    boardVO.setMember_id(member_id);
                    boardVO.setBoard_id(board_id);
                    boardVO.setTitle(title);
                    boardVO.setContent(content);
                    boardVO.setCategory(category);
                    boardVO.setCreated_date(created_date);
                    boardVO.setUpdated_date(updated_date);
                    boardVO.setView_count(view_count);
                    boardVO.setLike_count(like_count);
                    boardVO.setHidden_yn(hidden_yn);
                    boardVO.setNickname(nickname);
                }
                System.out.println(boardVO);
                request.setAttribute("board", boardVO);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // [검색 기능] 게시글 검색 메서드
    public static ArrayList<BoardVO> searchBoards(HttpServletRequest request) {
        ArrayList<BoardVO> boards = new ArrayList<>();

        String searchType = request.getParameter("searchType");
        String keyword = request.getParameter("keyword");

        // 검색어가 없으면 전체 목록 반환
        if (keyword == null || keyword.trim().isEmpty()) {
            return showAllBoard(request);
        }

        String sql = "SELECT b.*, " +
                "(SELECT COUNT(*) FROM comments WHERE b_board_id = b.b_board_id) as comment_count, " +
                "COALESCE(b.b_like_count, 0) as like_count, " +
                "m.nickname " +
                "FROM board b " +
                "JOIN member m ON b.member_id = m.member_id ";

        // 검색 타입에 따른 WHERE 절 추가
        if (searchType == null) {
            return showAllBoard(request);
        }
        switch (searchType) {
            case "title":
                sql += "WHERE b.b_title LIKE ? ";
                break;
            case "content":
                sql += "WHERE b.b_content LIKE ? ";
                break;
            case "author":
                sql += "WHERE m.nickname LIKE ? ";
                break;
            default:
                return showAllBoard(request);
        }

        sql += "ORDER BY b.b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
        ) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BoardVO bo = new BoardVO();
                    bo.setBoard_id(rs.getInt("b_board_id"));
                    bo.setCategory(rs.getString("b_category"));
                    bo.setTitle(rs.getString("b_title"));
                    bo.setMember_id(rs.getInt("member_id"));
                    bo.setCreated_date(rs.getTimestamp("b_created_date"));
                    bo.setView_count(rs.getInt("b_view_count"));
                    bo.setComment_count(rs.getInt("comment_count"));
                    bo.setLike_count(rs.getInt("like_count"));
                    bo.setNickname(rs.getString("nickname"));
                    boards.add(bo);
                }
                request.setAttribute("boards", boards);
                return boards;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // [카테고리별 검색 기능] 카테고리별 게시글 검색 메서드
    public static ArrayList<BoardVO> searchBoardsByCategory(HttpServletRequest request) {
        ArrayList<BoardVO> boards = new ArrayList<>();

        String category = request.getParameter("category");

        // 카테고리가 없거나 "전체"이면 전체 목록 반환
        if (category == null || category.trim().isEmpty() || category.equals("전체")) {
            return showAllBoard(request);
        }

        String sql = "SELECT b.*, " +
                "(SELECT COUNT(*) FROM comments WHERE b_board_id = b.b_board_id) as comment_count, " +
                "COALESCE(b.b_like_count, 0) as like_count, " +
                "m.nickname " +
                "FROM board b " +
                "JOIN member m ON b.member_id = m.member_id " +
                "WHERE b.b_category = ? " +
                "ORDER BY b.b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
        ) {
            ps.setString(1, category);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BoardVO bo = new BoardVO();
                    bo.setBoard_id(rs.getInt("b_board_id"));
                    bo.setCategory(rs.getString("b_category"));
                    bo.setTitle(rs.getString("b_title"));
                    bo.setMember_id(rs.getInt("member_id"));
                    bo.setCreated_date(rs.getTimestamp("b_created_date"));
                    bo.setView_count(rs.getInt("b_view_count"));
                    bo.setComment_count(rs.getInt("comment_count"));
                    bo.setLike_count(rs.getInt("like_count"));
                    bo.setNickname(rs.getString("nickname"));
                    boards.add(bo);
                }
                request.setAttribute("boards", boards);
                return boards;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static int updateBoard(HttpServletRequest request) {
        String sql = "UPDATE board SET b_title = ?, b_content = ?, b_updated_date = SYSDATE WHERE b_board_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
        ) {
            request.setCharacterEncoding("UTF-8");

            ps.setString(1, request.getParameter("title"));
            ps.setString(2, request.getParameter("content"));
            ps.setInt(3, Integer.parseInt(request.getParameter("board_id")));

            int result = ps.executeUpdate();
            if (result == 1) {
                System.out.println("update success");
            }
            return result;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }


    public static void paging(HttpServletRequest request, int pageNum) {
        request.setAttribute("currentPage", pageNum);
        // Get the already filtered boards from request attribute
        @SuppressWarnings("unchecked")
        ArrayList<BoardVO> boards = (ArrayList<BoardVO>) request.getAttribute("boards");

        // If no boards exist, get all boards as fallback
        if (boards == null) {
            boards = showAllBoard(request);
        }
        int total = boards.size();
        int cnt = 8;

        // 페이지수
        int totalPage = (int) Math.ceil((double) total / cnt);
        request.setAttribute("totalPage", totalPage);

        int start = (pageNum - 1) * cnt;
        int end = Math.min(start + cnt, total);

        ArrayList<BoardVO> items = new ArrayList<>();
        for (int i = start; i < end; i++) {
            if (i >= 0 && i < boards.size()) {
                items.add(boards.get(i));
            }
        }

        request.setAttribute("boards", items);

    }

    public static List<BoardVO> getPostsByMember(int memberId) {
        List<BoardVO> list = new ArrayList<>();

        String sql = "SELECT b_board_id, b_title " +
                "FROM board " +
                "WHERE member_id = ? " +
                "ORDER BY b_board_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, memberId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BoardVO vo = new BoardVO();

                    int boardId = rs.getInt("b_board_id");
                    String title = rs.getString("b_title");

                    System.out.println("getPostsByMember - boardId: " + boardId + ", title: " + title);
                    System.out.println("getPostsByMember - title null?: " + (title == null));
                    System.out.println("getPostsByMember - title empty?: " + (title != null && title.isEmpty()));

                    vo.setBoard_id(boardId);
                    vo.setTitle(title);

                    System.out.println("getPostsByMember - vo.getTitle(): " + vo.getTitle());
                    System.out.println("getPostsByMember - vo.getTitle() null?: " + (vo.getTitle() == null));

                    list.add(vo);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
