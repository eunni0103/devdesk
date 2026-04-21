<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/company/company-detail.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/review/review-board.css">
<script>
    var companyId = '${company.companyId}';
    var contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/company/company-detail.js"></script>

<%-- ===== 다크 헤더 영역 ===== --%>
<div class="cd-hero">
    <div class="cd-hero-inner">
        <div class="cd-hero-left">
            <div class="cd-logo-box">
                <span class="cd-logo-text">
                    ${not empty company.companyName ? company.companyName.substring(0, 1) : '?'}
                </span>
            </div>
            <div class="cd-hero-info">
                <h1 class="cd-company-name"><c:out value="${company.companyName}"/></h1>
                <div class="cd-rating-row">
                    <span class="cd-stars-hero">
                        <c:forEach begin="1" end="5" var="i">
                            <span class="star-h ${i <= stats.avgRating ? 'on' : ''}">★</span>
                        </c:forEach>
                    </span>
                    <span class="cd-rating-num">${stats.avgRating}</span>
                    <span class="cd-review-count">면접 후기(${stats.totalCount}건)</span>
                </div>
                <div class="cd-company-meta">
                    <span>업종 : <c:out value="${company.companyIndustry}"/></span>
                    <span>위치 : <c:out value="${company.companyLocation}"/></span>
                    <span>규모 : <fmt:formatNumber value="${company.companySize}"/>명</span>
                </div>
            </div>
        </div>
        <div class="cd-hero-right">
            <a href="${pageContext.request.contextPath}/review/write?companyId=${company.companyId}"
               class="cd-write-btn">
                면접 후기 작성하기
            </a>
        </div>
    </div>
</div>

<%-- ===== 통계 카드 ===== --%>
<div class="cd-content">
    <div class="cd-stats-row">
        <div class="cd-stat-card">
            <span class="cd-stat-label">총 후기</span>
            <span class="cd-stat-value">${stats.totalCount}<span class="cd-stat-unit">건</span></span>
        </div>
        <div class="cd-stat-card">
            <span class="cd-stat-label">평균 난이도</span>
            <span class="cd-stat-value">${stats.avgDifficulty}<span class="cd-stat-unit">/ 5</span></span>
        </div>
        <div class="cd-stat-card">
            <span class="cd-stat-label">합격률</span>
            <span class="cd-stat-value">${stats.passRate}<span class="cd-stat-unit">%</span></span>
        </div>
    </div>

    <%-- ===== 필터 + 정렬 ===== --%>
    <div class="cd-filter-bar">
        <div class="cd-filter-group">
            <span class="cd-filter-label">필터</span>
            <select id="filterType">
                <option value="">면접 유형 전체</option>
                <option value="CODING">코딩테스트</option>
                <option value="TECH">기술면접</option>
                <option value="PERSONAL">인성면접</option>
                <option value="EXEC">임원면접</option>
                <option value="GROUP">그룹면접</option>
            </select>
            <select id="filterResult">
                <option value="">결과 전체</option>
                <option value="PASS">합격</option>
                <option value="FAIL">불합격</option>
                <option value="PENDING">대기중</option>
            </select>
        </div>
        <div class="cd-filter-group">
            <span class="cd-filter-label">정렬</span>
            <select id="sortOrder">
                <option value="latest">최신순</option>
                <option value="like_desc">추천순</option>
            </select>
        </div>
    </div>

    <%-- ===== 후기 목록 ===== --%>
    <div class="cd-toolbar">
        <span class="cd-count">총 ${stats.totalCount}건의 후기</span>
    </div>

    <c:if test="${empty reviews}">
        <div class="cd-no-result">
            아직 등록된 면접 후기가 없습니다.<br/>
            첫 번째 후기를 작성해보세요!
        </div>
    </c:if>
    <div id="reviewListArea">
        <c:forEach var="r" items="${reviews}">
            <div class="card">
                <div class="card-header">
                    <div>
                        <c:set var="viewedReviews" value="${sessionScope.viewedReviews}"/>
                        <c:if test="${empty viewedReviews || !viewedReviews.contains(r.reviewId)}">
                            <span class="badge-new">NEW</span>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/review?companyId=${r.reviewCompanyId}">
                                ${r.companyName}
                        </a>
                    </div>
                </div>
                <h2 class="card-title">${r.reviewTitle} </h2>
                <div class="card-body">
                    <div class="avatar"></div>
                    <div class="info-grid">
                        <div class="info-row">
                            <span class="info-label">면접관/학생</span>
                            <span class="info-value">
                            면접관 ${r.reviewInterviewerCount}명
                            / 학생 ${r.reviewStudentCount}명
                        </span>
                            <span class="info-label">연락 방법</span>
                            <span class="tag">
                            <c:choose>
                                <c:when test="${r.reviewContactMethod == 'EMAIL'}">이메일</c:when>
                                <c:when test="${r.reviewContactMethod == 'PHONE'}">전화</c:when>
                                <c:when test="${r.reviewContactMethod == 'WEBSITE'}">채용 홈페이지</c:when>
                                <c:otherwise>${r.reviewContactMethod}</c:otherwise>
                            </c:choose>
                        </span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">분위기</span>
                            <span class="info-value">
                            <c:choose>
                                <c:when test="${r.reviewAtmosphere == 'FRIENDLY'}">화기애애</c:when>
                                <c:when test="${r.reviewAtmosphere == 'NORMAL'}">보통</c:when>
                                <c:when test="${r.reviewAtmosphere == 'SERIOUS'}">엄숙</c:when>
                                <c:when test="${r.reviewAtmosphere == 'PRESSURE'}">압박</c:when>
                                <c:otherwise>${r.reviewAtmosphere}</c:otherwise>
                            </c:choose>
                        </span>
                            <span class="info-label">면접 유형</span>
                            <span class="tag">
                            <c:choose>
                                <c:when test="${r.reviewInterviewType == 'CODING'}">코딩테스트</c:when>
                                <c:when test="${r.reviewInterviewType == 'TECH'}">기술면접</c:when>
                                <c:when test="${r.reviewInterviewType == 'PERSONAL'}">인성면접</c:when>
                                <c:when test="${r.reviewInterviewType == 'EXEC'}">임원면접</c:when>
                                <c:when test="${r.reviewInterviewType == 'GROUP'}">그룹면접</c:when>
                                <c:otherwise>${r.reviewInterviewType}</c:otherwise>
                            </c:choose>
                        </span>
                        </div>
                    </div>
                </div>

                <div class="read-more-container">
                    <a href="${pageContext.request.contextPath}/review/detail?reviewId=${r.reviewId}"
                       class="read-more-btn">계속 읽기</a>
                </div>

                <div class="card-footer">
                    <div class="footer-left">
                        <span class="card-like">♥ <span class="like-num">${r.reviewLikeCount}</span></span>
                        <c:if test="${r.reviewRating > 0}">
                            <span class="card-rating">
                                <c:forEach begin="1" end="5" var="i">
                                    <span class="card-star ${i <= r.reviewRating ? 'on' : ''}">★</span>
                                </c:forEach>
                                <span class="card-rating-num">${r.reviewRating}.0</span>
                            </span>
                        </c:if>
                    </div>
                    <div class="footer-right">
                        <span><fmt:formatDate value="${r.reviewCreatedDate}" pattern="yyyy년 M월 d일"/></span>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    <%-- 페이징 (추후 동적 처리) --%>
    <div id="reviewPaging" class="cd-paging">
        <c:if test="${currentPage > 1}">
            <a onclick="loadFilteredReviews(${currentPage - 1})" class="cd-page" style="cursor:pointer;">이전</a>
        </c:if>
        <c:forEach begin="1" end="${totalPages}" var="p">
            <a onclick="loadFilteredReviews(${p})" class="cd-page ${p == currentPage ? 'active' : ''}"
               style="cursor:pointer;">${p}</a>
        </c:forEach>
        <c:if test="${currentPage < totalPages}">
            <a onclick="loadFilteredReviews(${currentPage + 1})" class="cd-page" style="cursor:pointer;">다음</a>
        </c:if>
    </div>
</div>

