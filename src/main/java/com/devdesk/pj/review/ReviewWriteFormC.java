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

@WebServlet("/review/write")
public class ReviewWriteFormC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String companyIdP = request.getParameter("companyId");
        if (companyIdP != null && !companyIdP.isBlank()) {
            CompanySearchVO company = CompanySearchDAO.COMPANY_SEARCH_DAO.getCompanyById(Integer.parseInt(companyIdP));
            request.setAttribute("company", company);
        }

        request.setAttribute("content", "/review/review_write.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("utf-8");

        String companyId = request.getParameter("companyId");
        String difficulty = request.getParameter("difficulty");

        if (companyId == null || companyId.isBlank() || difficulty == null || difficulty.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/review/write");
            return;
        }

        MemberDTO loginUser = (MemberDTO) request.getSession().getAttribute("user");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }
        ReviewVO vo = new ReviewVO();
        vo.setReviewCompanyId(Integer.parseInt(companyId));
        vo.setReviewMemberId(loginUser.getMember_id());
        vo.setReviewTitle(request.getParameter("title"));
        vo.setReviewJobPosition(request.getParameter("jobPosition"));
        vo.setReviewInterviewType(request.getParameter("interviewType"));
        vo.setReviewDifficulty(Integer.parseInt(difficulty));
        vo.setReviewResult(request.getParameter("result"));
        vo.setReviewContent(request.getParameter("content"));

        String ic = request.getParameter("interviewerCount");
        if (ic != null && !ic.isBlank()) vo.setReviewInterviewerCount(Integer.parseInt(ic));
        String sc = request.getParameter("studentCount");
        if (sc != null && !sc.isBlank()) vo.setReviewStudentCount(Integer.parseInt(sc));
        vo.setReviewAtmosphere(request.getParameter("atmosphere"));
        vo.setReviewContactMethod(request.getParameter("contactMethod"));
        String cd = request.getParameter("contactDays");
        if (cd != null && !cd.isBlank()) vo.setReviewContactDays(Integer.parseInt(cd));
        String rating = request.getParameter("rating");
        if (rating != null && !rating.isBlank()) vo.setReviewRating(Integer.parseInt(rating));
        ReviewDAO.REVIEW_DAO.insertReview(vo);
        response.sendRedirect(request.getContextPath() + "/review");


    }

    public void destroy() {
    }
}