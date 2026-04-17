package com.devdesk.pj.like;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

import com.google.gson.Gson;

@WebServlet(name = "LikeDelC", value = "/like_del")
public class LikeDelC extends HttpServlet {
    private LikeDAO likeDAO = new LikeDAO();
    private Gson gson = new Gson();


    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {


    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        int board_id = Integer.parseInt(request.getParameter("board_id"));
        int member_id = Integer.parseInt(request.getParameter("member_id"));

        LikeResult result = likeDAO.toggleLike(board_id, member_id);

        out.print(gson.toJson(result));
        out.flush();
    }

    public void destroy() {
    }
}