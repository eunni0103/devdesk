package com.devdesk.pj.comment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "CommentAddC", value = "/comment_add")
public class CommentAddC extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        int generatedId = CommentDAO.addComment(request);

        PrintWriter out = response.getWriter();
        if (generatedId != -1) {
            out.print("{\"success\": true, \"comment_id\": " + generatedId + "}");
        } else {
            out.print("{\"success\": false}");
        }
        out.flush();
    }
}
