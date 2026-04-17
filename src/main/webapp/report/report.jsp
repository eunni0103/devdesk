<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 🌟 어드민 공통 CSS와 리포트 전용 CSS 연결 --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
<%--<link rel="stylesheet" href="${pageContext.request.contextPath}/css/board-all.css">--%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/report/report.css">

<%-- 🌟 어드민 껍데기 시작 --%>
<div class="admin-wrapper">

    <%-- 🌟 왼쪽 사이드바 (신고 관리에 불 켜기: active) --%>
    <div class="admin-sidebar">
        <h3>Admin Panel</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/admin">📊 대시보드</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/member">👥 회원 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/board">📝 게시글 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/report" class="active">🚨 신고 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/company">🏢 기업 정보 관리</a></li>
        </ul>
    </div>

    <%-- 🌟 오른쪽 메인 컨텐츠 --%>
    <div class="admin-content">

        <div class="board-container report-container-admin">
            <div class="board-header">
                <h2>🚨 신고 관리</h2>
                <p class="admin-page-desc">악성 게시글 및 댓글 신고 내역을 관리합니다.</p>

                <div class="board-actions">
                    <form action="report" method="get" class="search-form">
                        <select name="searchType" class="search-type">
                            <option value="repoContent" ${param.searchType == 'repoContent' ? 'selected' : ''}>신고 내용
                            </option>
                            <option value="repoReason"  ${param.searchType == 'repoReason'  ? 'selected' : ''}>신고 사유
                            </option>
                        </select>
                        <input type="text" name="keyword" class="search-input" placeholder="검색어를 입력하세요"
                               value="${param.keyword}">

                        <button type="submit" class="search-btn">검색</button>

                        <c:if test="${not empty param.keyword}">
                            <button type="button" class="reset-btn" onclick="location.href='report'">목록으로</button>
                        </c:if>
                    </form>

                    <%-- 신고 대상 유형 필터 --%>
                    <select name="targetType"
                            onchange="location.href='report?targetType=' + this.value + '&status=${param.status}&searchType=${param.searchType}&keyword=${param.keyword}'">
                        <option value="ALL"    ${param.targetType == 'ALL' or empty param.targetType ? 'selected' : ''}>
                            전체 유형
                        </option>
                        <option value="review" ${param.targetType == 'review' ? 'selected' : ''}>리뷰</option>
                        <option value="board"  ${param.targetType == 'board'  ? 'selected' : ''}>게시글</option>
                    </select>

                    <%-- 처리 상태 필터 --%>
                    <select name="status"
                            onchange="location.href='report?status=' + this.value + '&targetType=${param.targetType}&searchType=${param.searchType}&keyword=${param.keyword}'">
                        <option value="ALL"       ${param.status == 'ALL' or empty param.status ? 'selected' : ''}>전체
                            상태
                        </option>
                        <option value="PENDING"   ${param.status == 'PENDING'   ? 'selected' : ''}>미처리</option>
                        <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>처리완료</option>
                    </select>
                </div>
            </div>

            <div class="report-list">
                <c:choose>
                    <c:when test="${not empty reports}">
                        <c:forEach var="r" items="${reports}">
                            <div class="board-row"
                                 onclick="location.href='${pageContext.request.contextPath}/reportDetail?id=${r.reportId}'">

                                <c:choose>
                                    <c:when test="${r.repoReviewId > 0}">
                                        <div class="report-type-badge review">리뷰</div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="report-type-badge board">게시글</div>
                                    </c:otherwise>
                                </c:choose>

                                <div class="report-reason-badge"><c:out value="${r.repoReason}"/></div>
                                <div class="col-title"><c:out value="${r.repoContent}"/></div>

                                <div class="col-date">
                                    <div class="date-info">${r.repoCreated}</div>
                                    <div class="report-status-badge ${r.repoStatus == 'PENDING' ? 'pending' : 'done'}">
                                            ${r.repoStatus == 'PENDING' ? '미처리' : '처리완료'}
                                    </div>
                                </div>

                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <%-- 빈 목록 메시지도 깔끔하게 클래스로 처리 --%>
                        <div class="empty-report-msg">
                            신고 내역이 없습니다.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- 🌟 페이징 버튼이 들어갈 빈 껍데기 (데이터만 JS로 넘겨줍니다) --%>
            <div id="report-pagination" class="pagination"
                 data-current="${currentPage}"
                 data-total="${totalPage}"
                 data-target="${param.targetType}"
                 data-status="${param.status}"
                 data-search="${param.searchType}"
                 data-keyword="${param.keyword}">
            </div>
        </div>
    </div>
</div>

<%-- 🌟 맨 아랫줄에 페이징 전용 JS 파일 연결! --%>
<script src="${pageContext.request.contextPath}/js/admin/admin-report.js"></script>
