<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/review/review-board.css">

<script>
    var contextPath = '${pageContext.request.contextPath}';
    var currentCompanyId = '${not empty companyId ? companyId : ""}';
</script>
<script src="${pageContext.request.contextPath}/js/company/company-search-modal.js"></script>
<script src="${pageContext.request.contextPath}/js/review/review-board.js"></script>

<jsp:include page="/company/company-search/company_search.jsp"/>


<div class="board-container">

    <c:if test="${empty reviews}">
        <div class="no-result">등록된 면접 후기가 없습니다.</div>
    </c:if>


    <div class="review-toolbar">
        <div class="review-filter-bar">
            <select id="filterType">
                <option value="">면접 유형 전체</option>
                <option value="CODING">코딩테스트</option>
                <option value="TECH">기술면접</option>
                <option value="PERSONAL">인성면접</option>
                <option value="EXEC">임원면접</option>
                <option value="GROUP">그룹면접</option>
                <option value="PT">PT면접</option>
            </select>
            <select id="filterResult">
                <option value="">결과 전체</option>
                <option value="PASS">합격</option>
                <option value="FAIL">불합격</option>
                <option value="PENDING">대기중</option>
            </select>
            <select id="sortOrder">
                <option value="latest">최신순</option>
                <option value="like_desc">추천순</option>
            </select>
        </div>
        <a href="${pageContext.request.contextPath}/review/write" class="btn-write">
            + 후기 작성
        </a>
    </div>
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
    <%-- reviewListArea --%>

    <div id="reviewPaging" class="pagination"></div>
</div>


<jsp:include page="/company/company-search/company_search_modal.jsp"/>