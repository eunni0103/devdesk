package com.devdesk.pj.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;

@WebServlet("/review/filter/ajax")
public class ReviewFilterAjaxC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");

        // 기업 검색 조건 파라미터 (기업검색 페이지 연동)
        String companyName     = request.getParameter("companyName");
        String companyIndustry = request.getParameter("companyIndustry");
        String companyLocation = request.getParameter("companyLocation");
        String minRating       = request.getParameter("minRating");
        String maxRating       = request.getParameter("maxRating");
        String companyIds      = request.getParameter("companyIds");

        // 기업 단건 조회용 (기업상세 페이지)
        String companyId = request.getParameter("companyId");

        String interviewType = request.getParameter("interviewType");
        String result = request.getParameter("result");
        String sort = request.getParameter("sort");
        int page = 1;
        int pageSize = 10;
        if (request.getParameter("page") != null) {
            page = Integer.parseInt(request.getParameter("page"));
        }

        Map<String, Object> data;
        if (companyIds != null && !companyIds.isBlank()) {
            // 여러 회사 ID가 주어진 경우 (기업 검색 결과 연동)
            data = ReviewDAO.REVIEW_DAO.getFilteredReviews(
                    companyIds, interviewType, result, sort, page, pageSize);
        } else if ((companyName != null && !companyName.isBlank())
                || (companyIndustry != null && !companyIndustry.isBlank())
                || (companyLocation != null && !companyLocation.isBlank())
                || (minRating != null && !minRating.isBlank())
                || (maxRating != null && !maxRating.isBlank())) {
            // 기존 조건부 검색
            data = ReviewDAO.REVIEW_DAO.getFilteredReviewsByCondition(
                    companyName, companyIndustry, companyLocation, minRating, maxRating,
                    interviewType, result, sort, page, pageSize);
        } else {
            // companyId 단건 또는 조건 없는 전체 조회
            data = ReviewDAO.REVIEW_DAO
                    .getFilteredReviews(companyId, interviewType, result, sort, page, pageSize);
        }
        com.google.gson.Gson gson = new com.google.gson.GsonBuilder()
                .setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
                .create();
        String json = gson.toJson(data);

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(json);

    }

    public void destroy() {
    }
}