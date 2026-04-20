<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/review/review-detail.css">


<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/review/review.js"></script>
<div class="detail-wrap">

    <div class="detail-header">
        <div class="company-badge"><c:out value="${company.companyName}"/></div>
        <p class="company-meta"><c:out value="${company.companyIndustry}"/> · <c:out value="${company.companyLocation}"/> · ${company.companySize}명</p>
        <h2 class="detail-title"><c:out value="${r.reviewTitle}"/></h2>
        <div class="detail-meta">
            <span><fmt:formatDate value="${r.reviewCreatedDate}" pattern="yyyy년 M월 d일"/></span>
            <span>조회 ${r.reviewViewCount}</span>
        </div>
    </div>

    <%-- 섹션 01: 기본 정보 --%>
    <div class="detail-section">
        <div class="section-title">
            <span class="section-number">01</span>
            기본 정보
        </div>
        <div class="info-grid-detail">
            <div class="info-item">
                <span class="info-label">지원 직무</span>
                <span class="info-value"><c:out value="${r.reviewJobPosition}"/></span>
            </div>
            <div class="info-item">
                <span class="info-label">면접 유형</span>
                <span class="info-value">
                    <c:choose>
                        <c:when test="${r.reviewInterviewType == 'CODING'}">코딩테스트</c:when>
                        <c:when test="${r.reviewInterviewType == 'TECH'}">기술면접</c:when>
                        <c:when test="${r.reviewInterviewType == 'PERSONAL'}">인성면접</c:when>
                        <c:when test="${r.reviewInterviewType == 'EXEC'}">임원면접</c:when>
                        <c:when test="${r.reviewInterviewType == 'GROUP'}">그룹면접</c:when>
                        <c:otherwise><c:out value="${r.reviewInterviewType}"/></c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="info-item">
                <span class="info-label">전형 결과</span>
                <span class="info-value result-${r.reviewResult}">
                    <c:choose>
                        <c:when test="${r.reviewResult == 'PASS'}">합격</c:when>
                        <c:when test="${r.reviewResult == 'FAIL'}">불합격</c:when>
                        <c:when test="${r.reviewResult == 'PENDING'}">대기중</c:when>
                        <c:otherwise><c:out value="${r.reviewResult}"/></c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="info-item">
                <span class="info-label">난이도</span>
                <span class="info-value">
                    <c:forEach begin="1" end="5" var="i">
                        <span class="star ${i <= r.reviewDifficulty ? 'on' : ''}">★</span>
                    </c:forEach>
                </span>
            </div>
            <div class="info-item">
                <span class="info-label">기업 평점</span>
                <span class="info-value">
                    <c:forEach begin="1" end="5" var="i">
                        <span class="star rating-star ${i <= r.reviewRating ? 'on' : ''}">★</span>
                    </c:forEach>
                    <span class="rating-num">${r.reviewRating}.0</span>
                </span>
            </div>
        </div>
    </div>

    <%-- 섹션 02: 면접 상세 --%>
    <div class="detail-section">
        <div class="section-title">
            <span class="section-number">02</span>
            면접 상세
        </div>
        <div class="info-grid-detail">
            <c:if test="${r.reviewInterviewerCount > 0}">
                <div class="info-item">
                    <span class="info-label">면접관 수</span>
                    <span class="info-value">${r.reviewInterviewerCount}명</span>
                </div>
            </c:if>
            <c:if test="${r.reviewStudentCount > 0}">
                <div class="info-item">
                    <span class="info-label">학생 수</span>
                    <span class="info-value">${r.reviewStudentCount}명</span>
                </div>
            </c:if>
            <c:if test="${not empty r.reviewAtmosphere}">
                <div class="info-item">
                    <span class="info-label">분위기</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${r.reviewAtmosphere == 'FRIENDLY'}">화기애애</c:when>
                            <c:when test="${r.reviewAtmosphere == 'NORMAL'}">보통</c:when>
                            <c:when test="${r.reviewAtmosphere == 'SERIOUS'}">엄숙</c:when>
                            <c:when test="${r.reviewAtmosphere == 'PRESSURE'}">압박</c:when>
                            <c:otherwise><c:out value="${r.reviewAtmosphere}"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>
            <c:if test="${not empty r.reviewContactMethod}">
                <div class="info-item">
                    <span class="info-label">연락 방법</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${r.reviewContactMethod == 'EMAIL'}">이메일</c:when>
                            <c:when test="${r.reviewContactMethod == 'PHONE'}">전화</c:when>
                            <c:when test="${r.reviewContactMethod == 'WEBSITE'}">채용 홈페이지</c:when>
                            <c:otherwise><c:out value="${r.reviewContactMethod}"/></c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>
            <c:if test="${r.reviewContactDays > 0}">
                <div class="info-item">
                    <span class="info-label">연락 소요일</span>
                    <span class="info-value">
                        <c:choose>
                            <c:when test="${r.reviewContactDays == 1}">당일</c:when>
                            <c:when test="${r.reviewContactDays == 3}">3일 이내</c:when>
                            <c:when test="${r.reviewContactDays == 7}">1주일 이내</c:when>
                            <c:when test="${r.reviewContactDays == 14}">2주일 이내</c:when>
                            <c:when test="${r.reviewContactDays == 30}">1개월 이상</c:when>
                            <c:otherwise>${r.reviewContactDays}일</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </c:if>
        </div>
    </div>

    <%-- 섹션 03: 상세 후기 --%>
    <div class="detail-section">
        <div class="section-title">
            <span class="section-number">03</span>
            상세 후기
        </div>
        <div class="detail-content">
            <c:out value="${r.reviewContent}"/>
        </div>
    </div>

    <%-- 하단 버튼 --%>
    <div class="rd-social-center">
        <button class="rd-pill rd-pill-like ${isLiked ? 'active' : ''}"
                id="likeBtn" data-id="${r.reviewId}">
            ♥ 추천 <span id="likeCount">${r.reviewLikeCount}</span>
        </button>
    </div>

    <%-- 삭제 / 목록 / 수정 --%>
    <div class="rd-nav">
        <div class="rd-nav-left">
            <%-- sessionScope.user.member_id 로 변경 --%>
            <c:if test="${sessionScope.user != null && (sessionScope.user.member_id == r.reviewMemberId || sessionScope.user.role == 'ADMIN')}">
                <button class="rd-nav-btn rd-nav-del" onclick="confirmDelete(${r.reviewId})">삭제</button>
            </c:if>
            <%-- 로그인 했고, 본인 글이 아닌 경우에만 신고 버튼 표시 --%>
            <c:if test="${sessionScope.user != null && sessionScope.user.member_id != r.reviewMemberId}">
                <a href="${pageContext.request.contextPath}/report_form?targetType=review&targetId=${r.reviewId}&targetTitle=${r.reviewTitle}"
                   class="rd-nav-btn rd-nav-del">신고</a>
            </c:if>
        </div>
        <div class="rd-nav-right">
            <button class="rd-nav-btn" onclick="location.href='${pageContext.request.contextPath}/review'">목록으로</button>
            <%-- sessionScope.user.member_id 로 변경 --%>
            <c:if test="${sessionScope.user != null && (sessionScope.user.member_id == r.reviewMemberId || sessionScope.user.role == 'ADMIN')}">
                <a href="${pageContext.request.contextPath}/review/edit?reviewId=${r.reviewId}"
                   class="rd-nav-btn rd-nav-edit">수정</a>
            </c:if>
        </div>
    </div>
</div>


<div class="modal-overlay" id="deleteModal" style="display:none">
    <div class="modal-box">
        <p>정말 삭제하시겠습니까?</p>
        <div class="modal-btns">
            <button class="btn-cancel"
                    onclick="document.getElementById('deleteModal').style.display='none'">취소
            </button>
            <form id="deleteForm" method="post"
                  action="${pageContext.request.contextPath}/review/delete" style="display:inline">
                <input type="hidden" name="reviewId" id="deleteReviewId"/>
                <button type="submit" class="btn-delete-confirm">삭제</button>
            </form>
        </div>
    </div>
</div>
<script>
    function confirmDelete(reviewId) {
        document.getElementById('deleteReviewId').value = reviewId;
        document.getElementById('deleteModal').style.display = 'flex';
    }
</script>