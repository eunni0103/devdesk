<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/review/review-write.css">

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="${pageContext.request.contextPath}/js/company/company-search-modal.js"></script>

<div class="write-wrap">

    <form action="${pageContext.request.contextPath}/review/write" method="post" id="reviewForm">
        <%-- ===== 상단: 기업 정보 (자동 표시) ===== --%>
        <c:choose>
            <c:when test="${not empty company}">
                <%-- companyId로 들어온 경우: 기업 정보 표시 --%>
                <input type="hidden" name="companyId" value="${company.companyId}"/>
                <div class="company-header">
                    <div class="company-badge">면접 후기 작성</div>
                    <h2 class="company-name">${company.companyName}</h2>
                    <p class="company-meta">
                            ${company.companyIndustry} · ${company.companyLocation}
                    </p>
                </div>
            </c:when>
            <c:otherwise>
                <%-- 직접 들어온 경우: 기업 검색 --%>
                <div class="company-header">
                    <div class="company-badge">면접 후기 작성</div>
                    <div class="field-group">
                        <label class="field-label required">기업 검색</label>
                        <div style="display:flex; align-items:center; gap:8px;">
                            <input type="text" id="selectedCompanyName" readonly placeholder="기업을 선택해주세요"
                                   style="cursor:pointer;" onclick="openCompanyModal()"/>
                            <button type="button" onclick="openCompanyModal()" class="btn-search">기업 선택</button>
                        </div>
                        <jsp:include page="/company/company-search/company_search_modal.jsp"/>
                        <input type="hidden" name="companyId" id="selectedCompanyId"/>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>

        <%-- ===== 섹션 1: 기본 정보 ===== --%>
        <div class="form-section">
            <div class="section-title">
                <span class="section-number">01</span>
                기본 정보
            </div>

            <div class="field-row">
                <div class="field-group">
                    <label class="field-label required">제목</label>
                    <input type="text" name="title" id="title"
                           placeholder="면접 후기 제목을 입력하세요" maxlength="50"/>
                    <span class="char-count"><span id="titleCount">0</span>/50</span>
                </div>
            </div>

            <div class="field-row two-col">
                <div class="field-group">
                    <label class="field-label required">지원 직무</label>
                    <input type="text" name="jobPosition" id="jobPosition"
                           placeholder="예) 백엔드 개발자, SE, 기획" maxlength="20"/>
                </div>
                <div class="field-group">
                    <label class="field-label required">면접 유형</label>
                    <select name="interviewType" id="interviewType">
                        <option value="">선택하세요</option>
                        <option value="CODING">코딩테스트</option>
                        <option value="TECH">기술면접</option>
                        <option value="PERSONAL">인성면접</option>
                        <option value="EXEC">임원면접</option>
                        <option value="GROUP">그룹면접</option>
                        <option value="PT">PT면접</option>
                    </select>
                </div>
            </div>
            <div class="field-group">
                <label class="field-label required">전형 결과</label>
                <select name="result" id="result">
                    <option value="">선택하세요</option>
                    <option value="PASS">합격</option>
                    <option value="FAIL">불합격</option>
                    <option value="PENDING">대기중</option>
                </select>
            </div>

            <div class="field-row two-col">
                <div class="field-group">
                    <label class="field-label required">난이도</label>
                    <div class="difficulty-stars" id="difficultyStars">
                        <input type="hidden" name="difficulty" id="difficulty" value=""/>
                        <span class="star" data-value="1">★</span>
                        <span class="star" data-value="2">★</span>
                        <span class="star" data-value="3">★</span>
                        <span class="star" data-value="4">★</span>
                        <span class="star" data-value="5">★</span>
                        <span class="difficulty-label" id="difficultyLabel"></span>
                    </div>
                </div>
                <div class="field-group">
                    <label class="field-label required">기업 평점</label>
                    <div class="difficulty-stars" id="ratingStars">
                        <input type="hidden" name="rating" id="rating" value=""/>
                        <span class="star" data-value="1">★</span>
                        <span class="star" data-value="2">★</span>
                        <span class="star" data-value="3">★</span>
                        <span class="star" data-value="4">★</span>
                        <span class="star" data-value="5">★</span>
                        <span class="difficulty-label" id="ratingLabel"></span>
                    </div>
                </div>
            </div>
        </div>
        <%-- ===== 섹션 2: 면접 상세 ===== --%>
        <div class="form-section">
            <div class="section-title">
                <span class="section-number">02</span>
                면접 상세
            </div>

            <div class="field-row three-col">
                <div class="field-group">
                    <label class="field-label">면접관 수</label>
                    <select name="interviewerCount" id="interviewerCount">
                        <option value="">선택하세요</option>
                        <c:forEach var="i" begin="1" end="10">
                            <option value="${i}">${i}명</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="field-group">
                    <label class="field-label">학생 수</label>
                    <select name="studentCount" id="studentCount">
                        <option value="">선택하세요</option>
                        <c:forEach var="i" begin="1" end="10">
                            <option value="${i}">${i}명</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="field-group">
                    <label class="field-label">면접 분위기</label>
                    <select name="atmosphere" id="atmosphere">
                        <option value="">선택하세요</option>
                        <option value="FRIENDLY">화기애애</option>
                        <option value="NORMAL">보통</option>
                        <option value="SERIOUS">엄숙</option>
                        <option value="PRESSURE">압박</option>
                    </select>
                </div>
            </div>

            <div class="field-row two-col">
                <div class="field-group">
                    <label class="field-label">합격 연락 방법</label>
                    <select name="contactMethod" id="contactMethod">
                        <option value="">선택하세요</option>
                        <option value="EMAIL">이메일</option>
                        <option value="PHONE">전화</option>
                        <option value="WEBSITE">채용 홈페이지</option>
                        <option value="NONE">연락 없음 (불합격)</option>
                    </select>
                </div>
                <div class="field-group">
                    <label class="field-label">연락까지 소요일</label>
                    <select name="contactDays" id="contactDays">
                        <option value="">선택하세요</option>
                        <option value="1">당일</option>
                        <option value="3">3일 이내</option>
                        <option value="7">1주일 이내</option>
                        <option value="14">2주일 이내</option>
                        <option value="30">1개월 이상</option>
                    </select>
                </div>
            </div>
        </div>

        <%-- ===== 섹션 3: 상세 후기 ===== --%>
        <div class="form-section">
            <div class="section-title">
                <span class="section-number">03</span>
                상세 후기
            </div>

            <div class="field-row">
                <div class="field-group">
                    <label class="field-label required">면접 내용</label>
                    <p class="field-hint">면접에서 받은 질문, 본인의 답변, 면접 준비 방법 등을 자유롭게 작성해주세요.</p>
                    <textarea name="content" id="content" rows="12"
                              placeholder="예) 1차 면접에서는 기술 질문 위주로 진행되었습니다. 주요 질문은..."></textarea>
                    <div class="textarea-footer">
                        <span class="char-count"><span id="contentCount">0</span>자</span>
                        <span class="char-min">50자 이상 작성해주세요</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- ===== 하단 버튼 ===== --%>
        <div class="form-actions">
            <button type="button" class="btn-cancel"
                    onclick="location.href='${pageContext.request.contextPath}/review?companyId=${company.companyId}'">
                취소
            </button>
            <button type="submit" class="btn-submit" id="submitBtn">등록하기</button>
        </div>
    </form>
</div>

<script>var contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/review/review-write.js"></script>
<script src="${pageContext.request.contextPath}/js/review/review-company-dropdown.js"></script>
