package com.devdesk.pj.board;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "BoardAddC", value = "/board_add")
@MultipartConfig
public class BoardAddC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        //일
//        BoardDAO.addBoard(request);
        // loginCheck
        request.setAttribute("content", "board/board_add.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        BoardDAO.addBoard(request);
        // loginCheck
        response.sendRedirect("board");
    }

    public void destroy() {
    }
}