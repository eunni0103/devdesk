<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/company/company-detail.css">
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
                <option value="difficulty_desc">난이도 높은순</option>
                <option value="difficulty_asc">난이도 낮은순</option>
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
            <div class="cd-card">
                <div class="cd-card-top">
                    <span class="cd-card-position"><c:out value="${r.reviewJobPosition}"/></span>
                    <span class="cd-card-stars">
                    <c:forEach begin="1" end="5" var="i">
                        <span class="star-sm ${i <= r.reviewDifficulty ? 'on' : ''}">★</span>
                    </c:forEach>
                </span>
                </div>
                <a href="${pageContext.request.contextPath}/review/detail?reviewId=${r.reviewId}"
                   class="cd-card-title"><c:out value="${r.reviewTitle}"/></a>
                <div class="cd-card-tags">
                <span class="cd-tag">
                    <c:choose>
                        <c:when test="${r.reviewInterviewType == 'CODING'}">코딩테스트</c:when>
                        <c:when test="${r.reviewInterviewType == 'TECH'}">기술면접</c:when>
                        <c:when test="${r.reviewInterviewType == 'PERSONAL'}">인성면접</c:when>
                        <c:when test="${r.reviewInterviewType == 'EXEC'}">임원면접</c:when>
                        <c:when test="${r.reviewInterviewType == 'GROUP'}">그룹면접</c:when>
                        <c:otherwise><c:out value="${r.reviewInterviewType}"/></c:otherwise>
                    </c:choose>
                </span>
                    <c:if test="${r.reviewInterviewerCount > 0}">
                        <span class="cd-tag">면접관 ${r.reviewInterviewerCount}명</span>
                    </c:if>
                    <c:if test="${not empty r.reviewAtmosphere}">
                    <span class="cd-tag">
                        <c:choose>
                            <c:when test="${r.reviewAtmosphere == 'FRIENDLY'}">화기애애</c:when>
                            <c:when test="${r.reviewAtmosphere == 'NORMAL'}">보통</c:when>
                            <c:when test="${r.reviewAtmosphere == 'SERIOUS'}">엄숙</c:when>
                            <c:when test="${r.reviewAtmosphere == 'PRESSURE'}">압박</c:when>
                            <c:otherwise><c:out value="${r.reviewAtmosphere}"/></c:otherwise>
                        </c:choose>
                    </span>
                    </c:if>
                    <span class="cd-tag result-${r.reviewResult}">
                    <c:choose>
                        <c:when test="${r.reviewResult == 'PASS'}">합격</c:when>
                        <c:when test="${r.reviewResult == 'FAIL'}">불합격</c:when>
                        <c:when test="${r.reviewResult == 'PENDING'}">대기중</c:when>
                        <c:otherwise><c:out value="${r.reviewResult}"/></c:otherwise>
                    </c:choose>
                </span>
                </div>
                <div class="cd-card-bottom">
                    <span>[추천] ${r.reviewLikeCount}</span>
                    <span><fmt:formatDate value="${r.reviewCreatedDate}" pattern="yyyy년 M월 d일"/></span>
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

