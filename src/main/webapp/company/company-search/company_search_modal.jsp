<%--
  Created by IntelliJ IDEA.
  User: sangjun
  Date: 2026-04-09
  Time: 오전 9:45
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/company/company-search-modal.css">
<input type="hidden" id="contextPath" value="${pageContext.request.contextPath}"/>
<div id="companySearchModal" class="csm-overlay" style="display:none;">
    <div class="csm-box">
        <h3>기업 검색</h3>
        <div class="csm-search-row">
            <input type="text" id="miniSearchInput" placeholder="기업명을 입력하세요"
                   onkeydown="if(event.key==='Enter') searchMiniCompany()">
            <button type="button" onclick="searchMiniCompany()"
                    style="height:38px; padding:0 16px; background:#7c3aed; color:#fff; border:none; border-radius:0 8px 8px 0; font-size:13px; font-weight:600; font-family:'Pretendard',sans-serif; cursor:pointer; white-space:nowrap; flex-shrink:0;">
                검색
            </button>
        </div>
        <ul id="miniResultList"></ul>
        <button type="button" onclick="closeCompanyModal()">닫기</button>
    </div>
</div>