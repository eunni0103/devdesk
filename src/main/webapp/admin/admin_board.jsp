<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 기존 어드민 기본 CSS와 회원관리용 CSS(리스트 디자인)를 재활용합니다! --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin-member.css">

<div class="admin-wrapper">

    <%-- 🌟 왼쪽 사이드바 --%>
    <div class="admin-sidebar">
        <h3>Admin Panel</h3>
        <ul>
            <%-- 대시보드에 있던 active 삭제! --%>
            <li><a href="${pageContext.request.contextPath}/admin">📊 대시보드</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/member">👥 회원 관리</a></li>

            <%-- 👇 게시글 관리에 active 추가! 👇 --%>
            <li><a href="${pageContext.request.contextPath}/admin/board" class="active">📝 게시글 관리</a></li>

            <li><a href="${pageContext.request.contextPath}/admin/report">🚨 신고 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/company">🏢 기업 정보 관리</a></li>
        </ul>
    </div>

    <%-- 🌟 메인 컨텐츠 영역 --%>
    <div class="admin-content">
        <h2>📝 게시글 관리</h2>
        <p class="admin-page-desc">DevDesk 커뮤니티에 등록된 모든 게시글을 조회하고 관리합니다.</p>

        <div class="latest-members-section">

            <%-- 상단 타이틀 & 검색창 --%>
            <div class="member-list-header">
                <h3 class="member-list-title">전체 게시글 목록</h3>
                <div class="search-box">
                    <input type="text" id="boardSearch" class="search-input" placeholder="제목 또는 작성자 검색...">
                    <button onclick="searchBoard()" class="btn-search">검색</button>
                </div>
            </div>

            <%-- 게시글 리스트 표 --%>
            <table class="admin-table">
                <thead>
                <tr>
                    <th>글 번호</th>
                    <th>카테고리</th>
                    <th style="width: 35%;">제목</th>
                    <th>작성자</th>
                    <th>조회수</th>
                    <th>작성일</th>
                    <th>관리</th>
                </tr>
                </thead>
                <tbody id="board-tbody">

                <c:forEach var="b" items="${boards}">
                    <tr class="board-row">
                        <td>${b.board_id}</td>

                            <%-- 카테고리 뱃지 --%>
                        <td>
                            <span style="background:#f1f5f9; color:#475569; padding:4px 8px; border-radius:4px; font-size:12px; font-weight:bold;">
                                    ${b.category}
                            </span>
                        </td>

                        <td class="title-cell" style="font-weight: bold; text-align: left; padding-left: 15px;">
                                <%-- 글 제목을 누르면 해당 게시글 상세 페이지로 이동! --%>
                            <a href="${pageContext.request.contextPath}/BoardDetailC?id=${b.board_id}" target="_blank"
                               style="color: #1e293b;">
                                    ${b.title}
                            </a>
                        </td>

                        <td class="nickname-cell">${b.nickname}</td>
                        <td>${b.view_count}</td>
                        <td>${b.created_date}</td>

                            <%-- 강제 삭제 버튼 --%>
                        <td>
                            <button onclick="deleteBoard(${b.board_id}, '${b.title}')" class="btn-delete-member">
                                글 삭제
                            </button>
                        </td>
                    </tr>
                </c:forEach>

                </tbody>
            </table>

            <%-- 페이징 영역 --%>
            <div id="board-pagination" class="pagination pagination-wrapper"></div>

        </div>
    </div>
</div>

<%-- 나중에 추가할 자바스크립트 연결 --%>
<script src="${pageContext.request.contextPath}/js/admin/admin-board.js"></script>