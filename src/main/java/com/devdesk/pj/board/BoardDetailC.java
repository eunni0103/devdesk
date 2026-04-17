package com.devdesk.pj.board;

import com.devdesk.pj.comment.CommentDAO;
import com.devdesk.pj.like.LikeDAO;
import com.devdesk.pj.user.MemberDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "BoardDetailC", value = "/BoardDetailC")
public class BoardDetailC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");

        // 0. 게시글 번호 받기
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect("board");
            return;
        }
        int boardId;
        try {
            boardId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("board");
            return;
        }

        // 1. 게시물 정보 가져오기
        BoardDAO.getBoard(request);

        // 삭제된 게시글 처리
        if (request.getAttribute("board") == null) {
            request.setAttribute("content", "board/board_deleted.jsp");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        // 2. 조회수 증가
        BoardDAO.increaseViewCount(boardId);

// 3. 핵심 : 로그인한 유저별로 "좋아요 여부" 체크
        HttpSession session = request.getSession();
        MemberDTO user = (MemberDTO) session.getAttribute("user");
        boolean isLiked = false;

        if (user != null) {
            LikeDAO likeDAO = new LikeDAO();
            isLiked = likeDAO.isLiked(boardId, user.getMember_id());
        }

// 4. 결과값을 jsp로 전달
        request.setAttribute("isLiked", isLiked);

        // 5. 댓글 리스트 조회
        CommentDAO.getComment(request, boardId);

        request.setAttribute("content", "board/board_detail.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void destroy() {
    }
}
