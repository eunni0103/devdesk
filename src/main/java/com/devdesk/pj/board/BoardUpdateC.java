package com.devdesk.pj.board;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "BoardUpdateC", value = "/board_update")
public class BoardUpdateC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        //일
        BoardDAO.getBoard(request);
        // loginCheck
        request.setAttribute("content", "board/board_up.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //일
        BoardDAO.updateBoard(request);

        response.sendRedirect("board");
    }

    public void destroy() {
    }
}