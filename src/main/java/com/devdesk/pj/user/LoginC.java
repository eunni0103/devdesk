package com.devdesk.pj.user;

import com.devdesk.pj.main.RecaptchaUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginC", value = "/login")
public class LoginC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        request.setAttribute("content", "user/login.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("g-recaptcha-response");
        System.out.println("[reCAPTCHA] token: [" + token + "]");
        if (!RecaptchaUtil.verify(token)) {
            request.setAttribute("msg", "보안 인증에 실패했습니다. 다시 시도해주세요.");
            request.setAttribute("content", "user/login.jsp");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        MemberDAO.MBAO.login(request);

        HttpSession session = request.getSession();

        if (session.getAttribute("user") != null) {

            String dest = (String) session.getAttribute("dest");

            if (dest != null) {
                session.removeAttribute("dest");
                response.sendRedirect(dest);
            } else {
                response.sendRedirect(request.getContextPath() + "/");
            }

        } else {
            request.setAttribute("content", "user/login.jsp");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }

    public void destroy() {
    }
}
