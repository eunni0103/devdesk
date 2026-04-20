package com.devdesk.pj.companysearch;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/company/edit")
public class CompanyUpdateC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        int companyId = Integer.parseInt(request.getParameter("companyId"));
        CompanySearchVO company = CompanySearchDAO.COMPANY_SEARCH_DAO.getCompanyById(companyId);
        request.setAttribute("company", company);
        request.setAttribute("content", "/company/company-search/company_update_form.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");

        CompanySearchVO vo = new CompanySearchVO();
        vo.setCompanyId(Integer.parseInt(request.getParameter("companyId")));
        vo.setCompanyName(request.getParameter("companyName"));
        vo.setCompanyIndustry(request.getParameter("companyIndustry"));
        vo.setCompanyLocation(request.getParameter("companyLocation"));

        String rating = request.getParameter("companyRating");
        if (rating != null && !rating.isBlank()) vo.setCompanyRating(Double.parseDouble(rating));

        String size = request.getParameter("companySize");
        if (size != null && !size.isBlank()) vo.setCompanySize(Integer.parseInt(size));

        String appDate = request.getParameter("companyApplicationDate");
        if (appDate != null && !appDate.isBlank()) vo.setCompanyApplicationDate(java.sql.Date.valueOf(appDate));

        CompanySearchDAO.COMPANY_SEARCH_DAO.updateCompany(vo);
        response.sendRedirect(request.getContextPath() + "/company/edit?companyId=" + vo.getCompanyId() + "&success=true");
    }
}