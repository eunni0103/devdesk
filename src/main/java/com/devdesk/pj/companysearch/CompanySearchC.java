package com.devdesk.pj.companysearch;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/company-search")
public class CompanySearchC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        List<String> industries = CompanySearchDAO.COMPANY_SEARCH_DAO.getAllIndustries();
        List<String> locations = CompanySearchDAO.COMPANY_SEARCH_DAO.getAllLocation();
        int totalCompanyCount = CompanySearchDAO.COMPANY_SEARCH_DAO.getTotalCompanyCount();
        request.setAttribute("totalCompanyCount", totalCompanyCount);
        request.setAttribute("locations", locations);
        request.setAttribute("industries", industries);
        request.setAttribute("content", "/company/company-search/company_search.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }


    public void destroy() {
    }
}