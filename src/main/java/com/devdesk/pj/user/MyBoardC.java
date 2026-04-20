package com.devdesk.pj.user;

import com.devdesk.pj.comment.CommentVO;
import com.devdesk.pj.board.BoardVO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "MyBoardC", value = "/my-board")
public class MyBoardC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        HttpSession hs = request.getSession();
        MemberDTO user = (MemberDTO) hs.getAttribute("user");

        if (user != null) {
            ArrayList<BoardVO> myBoardList = MemberDAO.MBAO.getMyBoardList(user.getMember_id());
            request.setAttribute("myBoardList", myBoardList);

            ArrayList<CommentVO> myCommentList = MemberDAO.MBAO.getMyCommentList(user.getMember_id());
            request.setAttribute("myCommentList", myCommentList);
        }


        request.setAttribute("content", "user/myboard.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }

    public void destroy() {
    }
}