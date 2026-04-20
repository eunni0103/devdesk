package com.devdesk.pj.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AccountDoneC", value = "/account-done")
public class AccountDoneC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // URL에 달고 온 닉네임을 다시 꺼내서 화면에 뿌려줄 준비를 합니다.
        String welcomeName = request.getParameter("name");
        request.setAttribute("welcomeName", welcomeName);

        // 껍데기(index.jsp)에 알맹이(accountSuccess.jsp)를 씌워서 보여줍니다.
        request.setAttribute("content", "user/account_done.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {




    }

    public void destroy() {

    }
}