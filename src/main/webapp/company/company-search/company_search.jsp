<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/company/company-search.css">

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<input type="hidden" id="userRole" value="${sessionScope.user.nickname == '관리자' ? 'ADMIN' : 'USER'}"/>
<input type="hidden" id="contextPath" value="${pageContext.request.contextPath}"/>

<div class="cs-wrap">
    <h2 class="cs-title">기업 검색</h2>

    <%-- ===== 검색 폼 ===== --%>
    <div class="cs-search-box">

        <div class="cs-row">
            <span class="cs-label">업종</span>
            <div class="cs-options" id="industryBtns">
                <button type="button" class="cs-opt-btn active" data-value="">전체</button>
                <c:forEach var="ind" items="${industries}">
                    <button type="button" class="cs-opt-btn" data-value="${ind}">${ind}</button>
                </c:forEach>
            </div>
        </div>

        <div class="cs-divider"></div>

        <div class="cs-row">
            <span class="cs-label">지역</span>
            <div class="cs-options" id="locationBtns">
                <button type="button" class="cs-opt-btn active" data-value="">전체</button>
                <c:forEach var="loc" items="${locations}">
                    <button type="button" class="cs-opt-btn" data-value="${loc}">${loc}</button>
                </c:forEach>
            </div>
        </div>

        <div class="cs-divider"></div>

        <div class="cs-row">
            <span class="cs-label">평점</span>
            <div class="cs-range-group">
                <select id="minRating">
                    <c:forEach var="r" begin="0" end="10">
                        <option value="${r / 2}">${r / 2}</option>
                    </c:forEach>
                </select>
                <span class="cs-tilde">~</span>
                <select id="maxRating">
                    <c:forEach var="r" begin="0" end="10">
                        <c:set var="val" value="${(10 - r) / 2}"/>
                        <option value="${val}" ${val == 5.0 ? 'selected' : ''}>${val}</option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <div class="cs-divider"></div>

        <div class="cs-row">
            <span class="cs-label">규모</span>
            <div class="cs-range-group">
                <input type="number" id="minSize" placeholder="0" min="0"/>
                <span class="cs-tilde">~</span>
                <input type="number" id="maxSize" placeholder="10000" min="0"/>
                <span class="cs-range-unit">명</span>
            </div>
        </div>

        <div class="cs-divider"></div>

        <div class="cs-row">
            <span class="cs-label">기업명</span>
            <div class="cs-input-group">
                <input type="text" id="companyName" placeholder="기업명을 입력하세요"/>
            </div>
        </div>
    </div>

    <%-- ===== 검색 바 ===== --%>
    <div class="cs-action-bar">
        <div class="cs-result-count">
            등록 기업 : <span id="resultCount">${totalCompanyCount}</span>개
        </div>
        <div class="cs-action-btns">
            <button type="button" class="cs-clear-btn" id="clearBtn">조건 초기화</button>
            <button type="button" class="cs-search-btn" id="searchBtn">검색</button>
        </div>
    </div>

    <%-- ===== 검색 결과 (카드) ===== --%>
    <div id="resultArea"></div>
    <div id="companyPaging" class="cs-paging"></div>
</div>

<script src="${pageContext.request.contextPath}/js/company/company-search.js"></script>
