package com.devdesk.pj.report;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/report")
public class ReportC extends HttpServlet {

    private final ReportDAO reportDAO = ReportDAO.REPORT_DAO;

    // GET /admin/report → 신고 목록 (관리자 전용)
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 어드민 권한 체크 — UserVO의 role 필드명에 맞게 캐스팅 필요 시 수정
        Object user = session.getAttribute("user");
        String role = "";
        if (user instanceof com.devdesk.pj.user.MemberDTO) {
            role = ((com.devdesk.pj.user.MemberDTO) user).getRole();
        }
        if (!"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/main");
            return;
        }

        String targetType = request.getParameter("targetType");
        String status = request.getParameter("status");
        String searchType = request.getParameter("searchType");
        String keyword = request.getParameter("keyword");
        String pageStr = request.getParameter("p");

        if (targetType == null || targetType.isEmpty()) targetType = "ALL";
        if (status == null || status.isEmpty()) status = "ALL";
        if (searchType == null || searchType.isEmpty()) searchType = "repoContent";
        if (keyword == null) keyword = "";

        final int PAGE_SIZE = 10;
        int currentPage = 1;
        try {
            currentPage = Integer.parseInt(pageStr);
        } catch (Exception ignored) {
        }
        if (currentPage < 1) currentPage = 1;

        int totalCount = reportDAO.countReports(targetType, status, searchType, keyword);
        int totalPage = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        if (totalPage < 1) totalPage = 1;
        if (currentPage > totalPage) currentPage = totalPage;

        List<ReportVO> reports = reportDAO.getReports(targetType, status, searchType, keyword, currentPage, PAGE_SIZE);

        request.setAttribute("reports", reports);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPage", totalPage);

        request.setAttribute("content", "report/report.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    // POST /report → 신고 접수 (report_form.jsp에서 submit)
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 세션에서 로그인 회원 ID 가져오기
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int memberId = ((com.devdesk.pj.user.MemberDTO) session.getAttribute("user")).getMember_id();

        // REVIEW_ID / BOARD_ID (둘 중 하나만 값 있음)
        String reviewIdStr = request.getParameter("reviewId");
        String boardIdStr = request.getParameter("boardId");

        int reviewId = (reviewIdStr != null && !reviewIdStr.isEmpty()) ? Integer.parseInt(reviewIdStr) : 0;
        int boardId = (boardIdStr != null && !boardIdStr.isEmpty()) ? Integer.parseInt(boardIdStr) : 0;

        // REPO_REASON, REPO_CONTENT
        String repoReason = request.getParameter("repoReason");
        String repoContent = request.getParameter("repoContent");

        // 중복 신고 체크
        if (reportDAO.checkDuplicate(memberId, reviewId, boardId)) {
            response.sendRedirect(request.getContextPath() + "/report_form?done=true&duplicate=true");
            return;
        }

        // 처리 중인 다른 신고가 있는지 체크 // 선민 수정
        if (reportDAO.hasPendingReport(memberId)) {
            response.sendRedirect(request.getContextPath() + "/report_form?done=true&pending=true");
            return;
        }

        // VO 세팅 후 INSERT
        ReportVO vo = new ReportVO();
        vo.setRepoReviewId(reviewId);
        vo.setRepoBoardId(boardId);
        vo.setRepoMemberId(memberId);
        vo.setRepoReason(repoReason);
        vo.setRepoContent(repoContent);

        int result = reportDAO.insertReport(vo);
        System.out.println("Final Insert result in ReportC: " + result);

        // 신고 완료 페이지로 이동
        response.sendRedirect(request.getContextPath() + "/report_form?done=true");
    }

}