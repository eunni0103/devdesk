package com.devdesk.pj.comment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/comment_update")
public class CommentUpdateC extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        boolean isSuccess = CommentDAO.updateComment(request);

        PrintWriter out = response.getWriter();
        out.print("{\"success\": " + isSuccess + "}");
        out.flush();
    }
}
