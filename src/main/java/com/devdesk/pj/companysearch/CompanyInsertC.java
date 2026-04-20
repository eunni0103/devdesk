package com.devdesk.pj.companysearch;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/company/insert")
public class CompanyInsertC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        request.setAttribute("content", "/company/company-search/company_insert.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");

        CompanySearchVO vo = new CompanySearchVO();
        vo.setCompanyName(request.getParameter("companyName"));
        vo.setCompanyIndustry(request.getParameter("companyIndustry"));
        vo.setCompanyLocation(request.getParameter("companyLocation"));

        String rating = request.getParameter("companyRating");
        if (rating != null && !rating.isBlank()) vo.setCompanyRating(Double.parseDouble(rating));

        String size = request.getParameter("companySize");
        if (size != null && !size.isBlank()) vo.setCompanySize(Integer.parseInt(size));

        String created = request.getParameter("companyCreatedDate");
        if (created != null && !created.isBlank()) vo.setCompanyCreatedDate(java.sql.Date.valueOf(created));

        String appDate = request.getParameter("companyApplicationDate");
        if (appDate != null && !appDate.isBlank()) vo.setCompanyApplicationDate(java.sql.Date.valueOf(appDate));

        int result = CompanySearchDAO.COMPANY_SEARCH_DAO.insertCompany(vo);
        if (result > 0) {
            response.sendRedirect(request.getContextPath() + "/company/insert?success=true");
        } else {
            response.sendRedirect(request.getContextPath() + "/company/insert?success=false");
        }
    }
}