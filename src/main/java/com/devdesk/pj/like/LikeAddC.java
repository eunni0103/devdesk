package com.devdesk.pj.like;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

import com.google.gson.Gson;

@WebServlet(name = "LikeAddC", value = "/like_add")
public class LikeAddC extends HttpServlet {

    private LikeDAO likeDAO = new LikeDAO();
    private Gson gson = new Gson();


    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {


    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        // 1. 파라미터 추출
        int board_id = Integer.parseInt(request.getParameter("board_id"));
        int member_id = Integer.parseInt(request.getParameter("member_id"));

        // 2. DAO에게 모든 로직을 맡김 (한 줄로 끝!)
        LikeResult result = likeDAO.toggleLike(board_id, member_id);

        // 3. 결과만 JSON으로 출력
        response.getWriter().print(gson.toJson(result));
    }

    public void destroy() {
    }
}