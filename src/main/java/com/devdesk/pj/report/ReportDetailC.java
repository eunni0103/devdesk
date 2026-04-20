package com.devdesk.pj.report;

import com.devdesk.pj.board.BoardDAO;
import com.devdesk.pj.review.ReviewDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/reportDetail")
public class ReportDetailC extends HttpServlet {

    private final ReportDAO reportDAO = ReportDAO.REPORT_DAO;

    // GET /reportDetail?id={reportId} → 신고 상세 (관리자 전용)
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/report");
            return;
        }

        ReportVO report = reportDAO.getReportById(Integer.parseInt(idStr));
        if (report == null) {
            response.sendRedirect(request.getContextPath() + "/admin/report");
            return;
        }

        request.setAttribute("report", report);


        if (report.getRepoReviewId() > 0) {
            request.setAttribute("targetReview",
                    com.devdesk.pj.review.ReviewDAO.REVIEW_DAO.getReviewById(report.getRepoReviewId()));
        } else if (report.getRepoBoardId() > 0) {
            request.setAttribute("targetBoard",
                    com.devdesk.pj.board.BoardDAO.getBoardById(report.getRepoBoardId()));
        }

        request.setAttribute("content", "report/report-detail.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    // POST /reportDetail → 상태 변경(cmd=status) or 삭제(cmd=delete)
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        request.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("reportId");
        String cmd = request.getParameter("cmd");
        int reportId = Integer.parseInt(idStr);

        if ("delete".equals(cmd)) {
            reportDAO.deleteReport(reportId);
            response.sendRedirect(request.getContextPath() + "/admin/report");

        } else if ("status".equals(cmd)) {
            String status = request.getParameter("status");
            reportDAO.updateReportStatus(reportId, status);
            response.sendRedirect(request.getContextPath() + "/reportDetail?id=" + reportId);

        } else if ("delBoard".equals(cmd)) {
            String boardIdStr = request.getParameter("boardId");
            if (boardIdStr != null && !boardIdStr.isEmpty()) {
                int boardId = Integer.parseInt(boardIdStr);
                reportDAO.deleteReportsByBoardId(boardId);  // 관련 신고 전체 삭제 후 board 삭제
                BoardDAO.delBoardById(boardId);
            }
            response.sendRedirect(request.getContextPath() + "/admin/report");

        } else if ("delReview".equals(cmd)) {
            String reviewIdStr = request.getParameter("reviewId");
            if (reviewIdStr != null && !reviewIdStr.isEmpty()) {
                int reviewId = Integer.parseInt(reviewIdStr);
                reportDAO.deleteReportsByReviewId(reviewId);  // 관련 신고 전체 삭제 후 review 삭제
                ReviewDAO.REVIEW_DAO.deleteReview(reviewId);
            }
            response.sendRedirect(request.getContextPath() + "/admin/report");
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        Object user = session.getAttribute("user");
        String role = "";
        if (user instanceof com.devdesk.pj.user.MemberDTO) {
            role = ((com.devdesk.pj.user.MemberDTO) user).getRole();
        }
        if (!"admin".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/main");
            return false;
        }
        return true;
    }
}
