package com.devdesk.pj.auth;

import com.devdesk.pj.user.MemberDTO;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

@WebFilter("/*")
public class LoginCheckFilter implements Filter {
    // 로그인 없이 접근 가능한 경로 (정확히 일치)
    private static final Set<String> PUBLIC_EXACT = Set.of(
            "/", "/main", "/login", "/logout",
            "/account", "/account-done",
            "/google-login", "/find-password",
            "/user-checkId", "/user-checkNickname",
            "/review", "/review/detail", "/review/filter/ajax",
            "/company-search", "/company-search/ajax", "/company-detail",
            "/board", "/BoardDetailC", "/member-posts",
            "/like", "/review/like",
            "/ws"
    );

    // 로그인 없이 접근 가능한 경로 접두어 (하위 경로 포함)
    private static final String[] PUBLIC_PREFIX = {
            "/css/", "/js/", "/images/", "/fonts/",
            "/admin/"  // AdminCheckFilter가 별도로 처리
    };

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // 공개 경로 → 필터 통과
        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 로그인 확인
        HttpSession session = req.getSession();
        MemberDTO user = (MemberDTO) session.getAttribute("user");

        if (user != null) {
            chain.doFilter(request, response);
        } else {
            System.out.println("필터 작동: 비로그인 사용자 접근 차단 → " + path);

            String originalUrl = req.getRequestURI();
            String queryString = req.getQueryString();
            if (queryString != null) {
                originalUrl += "?" + queryString;
            }
            session.setAttribute("dest", originalUrl);
            res.sendRedirect(req.getContextPath() + "/login");
        }
    }

    private boolean isPublic(String path) {
        if (PUBLIC_EXACT.contains(path)) return true;
        for (String prefix : PUBLIC_PREFIX) {
            if (path.startsWith(prefix)) return true;
        }
        // 정적 파일 확장자
        return path.endsWith(".css") || path.endsWith(".js")
                || path.endsWith(".png") || path.endsWith(".jpg")
                || path.endsWith(".gif") || path.endsWith(".ico")
                || path.endsWith(".svg") || path.endsWith(".woff2")
                || path.endsWith(".woff") || path.endsWith(".ttf");
    }

    @Override
    public void destroy() {
    }
}