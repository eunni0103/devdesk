package com.devdesk.pj.resumeblock;

import com.devdesk.pj.user.MemberDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ResumeBlockC", value = "/resume-block")
public class ResumeBlockC extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        MemberDTO loginUser = (MemberDTO) request.getSession().getAttribute("user");
        if (loginUser == null) {
            response.sendRedirect("login");
            return;
        }

        int memberId = loginUser.getMember_id();
        String filter = request.getParameter("filter"); // all, star, shimei, jikopr, ...

        ResumeBlockDAO dao = new ResumeBlockDAO();

        List<ResumeBlockVO> blockList;
        if ("star".equals(filter)) {
            blockList = dao.selectStarBlocks(memberId);
        } else if (filter != null && !filter.isEmpty() && !"all".equals(filter)) {
            blockList = dao.selectBlocksByCategory(memberId, filter);
        } else {
            blockList = dao.selectAllBlocks(memberId);
        }

        // 전체 블록 목록 (이력서 조합 탭용 - 카테고리별로 필요)
        List<ResumeBlockVO> allBlocks = dao.selectAllBlocks(memberId);

        // 통계
        int totalCount = dao.countBlocks(memberId);
        int starCount = dao.countStarBlocks(memberId);
        int categoryCount = dao.countCategories(memberId);

        request.setAttribute("blockList", blockList);
        request.setAttribute("allBlocks", allBlocks);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("starCount", starCount);
        request.setAttribute("categoryCount", categoryCount);
        request.setAttribute("currentFilter", filter != null ? filter : "all");

        request.setAttribute("content", "/resume-block/resume_block.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
