package com.devdesk.pj.review;

import com.devdesk.pj.companysearch.CompanySearchDAO;
import com.devdesk.pj.companysearch.CompanySearchVO;
import com.devdesk.pj.user.MemberDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;


@WebServlet("/review/edit")
public class ReviewEditC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        int reviewId = Integer.parseInt(request.getParameter("reviewId"));
        MemberDTO user = (MemberDTO) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }
        ReviewVO review = ReviewDAO.REVIEW_DAO.getReviewById(reviewId);
        if (review == null || review.getReviewMemberId() != user.getMember_id()) {
            response.sendRedirect(request.getContextPath() + "/review");
            return;
        }
        CompanySearchVO company = CompanySearchDAO.COMPANY_SEARCH_DAO.getCompanyById(review.getReviewCompanyId());
        request.setAttribute("r", review);
        request.setAttribute("company", company);
        request.setAttribute("content", "/review/review_edit.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("utf-8");
        MemberDTO user = (MemberDTO) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }
        int memberId = user.getMember_id();
        int reviewId = Integer.parseInt(request.getParameter("reviewId"));
        ReviewVO review = ReviewDAO.REVIEW_DAO.getReviewById(reviewId);
        if (review == null || review.getReviewMemberId() != memberId) {
            response.sendRedirect(request.getContextPath() + "/review");
            return;
        }
        ReviewVO vo = new ReviewVO();
        vo.setReviewId(reviewId);
        vo.setReviewTitle(request.getParameter("title"));
        vo.setReviewJobPosition(request.getParameter("jobPosition"));
        vo.setReviewInterviewType(request.getParameter("interviewType"));
        vo.setReviewDifficulty(Integer.parseInt(request.getParameter("difficulty")));
        vo.setReviewResult(request.getParameter("result"));
        vo.setReviewContent(request.getParameter("content"));
        String ratingParam = request.getParameter("rating");
        if (ratingParam != null && !ratingParam.isBlank()) vo.setReviewRating(Integer.parseInt(ratingParam));

        String ic = request.getParameter("interviewerCount");
        if (ic != null && !ic.isBlank()) vo.setReviewInterviewerCount(Integer.parseInt(ic));
        String sc = request.getParameter("studentCount");
        if (sc != null && !sc.isBlank()) vo.setReviewStudentCount(Integer.parseInt(sc));
        vo.setReviewAtmosphere(request.getParameter("atmosphere"));
        vo.setReviewContactMethod(request.getParameter("contactMethod"));
        String cd = request.getParameter("contactDays");
        if (cd != null && !cd.isBlank()) vo.setReviewContactDays(Integer.parseInt(cd));

        ReviewDAO.REVIEW_DAO.updateReview(vo);
        response.sendRedirect(request.getContextPath() + "/review/detail?reviewId=" + reviewId);

    }

    public void destroy() {
    }
}