<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 기존 대시보드 CSS와 회원관리 전용 CSS 연결 --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin-member.css">

<div class="admin-wrapper">

    <%-- 🌟 왼쪽 사이드바 --%>
    <div class="admin-sidebar">
        <h3>Admin Panel</h3>
        <ul>
            <%-- 대시보드에 있던 active 삭제! --%>
            <li><a href="${pageContext.request.contextPath}/admin">📊 대시보드</a></li>

            <%-- 👇 회원 관리에 active 추가! 👇 --%>
            <li><a href="${pageContext.request.contextPath}/admin/member" class="active">👥 회원 관리</a></li>

            <li><a href="${pageContext.request.contextPath}/admin/board">📝 게시글 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/report">🚨 신고 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/company">🏢 기업 정보 관리</a></li>
        </ul>
    </div>

    <%-- 🌟 메인 컨텐츠 영역 --%>
    <div class="admin-content">
        <h2>👥 회원 관리</h2>
        <p class="admin-page-desc">DevDesk의 전체 회원을 조회하고 관리합니다.</p>

        <div class="latest-members-section">

            <%-- 상단 타이틀 & 검색창 --%>
            <div class="member-list-header">
                <h3 class="member-list-title">전체 회원 목록</h3>
                <div class="search-box">
                    <input type="text" id="memberSearch" class="search-input" placeholder="닉네임 또는 이메일 검색...">
                    <button onclick="searchMember()" class="btn-search">검색</button>
                </div>
            </div>

            <%-- 회원 리스트 표 --%>
            <table class="admin-table">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>이메일</th>
                    <th>닉네임</th>
                    <th>직무</th>
                    <th>상태</th>
                    <th>가입일</th>
                    <th>관리</th>
                </tr>
                </thead>
                <tbody id="member-tbody">

                <c:forEach var="m" items="${members}">
                    <%-- 🌟 탈퇴 회원은 전체 행에 is-deleted 클래스 부여 (취소선 효과) --%>
                    <tr class="member-row ${m.status == 'deleted' ? 'is-deleted' : ''}">
                        <td>${m.member_id}</td>
                        <td class="email-cell">${m.email}</td>
                        <td class="nickname-cell">${m.nickname}</td>
                        <td>${m.job_category != null ? m.job_category : '미입력(소셜)'}</td>

                            <%-- 동적 상태 뱃지 클래스 적용 --%>
                        <td>
                            <span class="status-badge ${m.status == 'active' ? 'status-active' : 'status-deleted'}">
                                    ${m.status == 'active' ? '정상 활동' : '탈퇴 회원'}
                            </span>
                        </td>

                        <td>${m.created_date}</td>

                            <%-- 관리 버튼 분기 처리 --%>
                        <td>
                            <c:choose>
                                <c:when test="${m.role == 'admin'}">
                                    <span class="role-admin-text">⭐ 관리자</span>
                                </c:when>
                                <c:otherwise>
                                    <div style="display:flex; gap:5px; justify-content:center;">
                                            <%-- 🌟 상세 보기 버튼 추가 --%>
                                        <button onclick="showDetail(${m.member_id})" class="btn-view-detail">상세</button>

                                            <%-- 정상 활동 중인 회원에게만 탈퇴 버튼 노출 --%>
                                        <c:if test="${m.status == 'active'}">
                                            <button onclick="deleteMember(${m.member_id}, '${m.nickname}')"
                                                    class="btn-delete-member">탈퇴
                                            </button>
                                        </c:if>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>

                </tbody>
            </table>

            <%-- 페이징 영역 --%>
            <div id="member-pagination" class="pagination pagination-wrapper"></div>

        </div>
    </div>
</div>

<div id="deleteConfirmModal" class="custom-modal" style="display: none;">
    <div class="modal-content">
        <h3 class="modal-title">회원 강제 탈퇴</h3>
        <p class="modal-text">
            정말로 <strong id="modalTargetNickname" style="color: var(--primary-color);"></strong> 회원을 강제 탈퇴 처리하시겠습니까?<br>
            <span style="color: #ef4444; font-size: 13px;">(이 작업은 되돌릴 수 없으며, 해당 회원의 모든 데이터가 파기됩니다.)</span>
        </p>
        <div class="modal-actions">
            <button onclick="closeDeleteModal()" class="btn-modal-cancel">취소</button>
            <button id="btnConfirmDelete" class="btn-modal-confirm">강제 탈퇴</button>
        </div>
    </div>
</div>

<div id="notiModal" class="custom-modal" style="display: none;">
    <div class="modal-content">
        <h3 id="notiTitle" class="modal-title">알림</h3>
        <p id="notiText" class="modal-text"></p>
        <div class="modal-actions">
            <button onclick="closeNotiModal()" class="btn-modal-confirm">확인</button>
        </div>
    </div>
</div>

<div id="detailModal" class="custom-modal" style="display: none;">
    <div class="modal-content profile-card">
        <div class="profile-header">
            <div class="profile-avatar">👤</div>
            <h3 id="detNickname" class="modal-title" style="margin-bottom:5px;">닉네임</h3>
            <p id="detEmail" style="color:#64748b; margin-bottom:15px;">email@example.com</p>
        </div>

        <div class="profile-stats">
            <div class="stat-item">
                <span class="stat-label">작성 글</span>
                <span id="detBoardCnt" class="stat-value">0</span>
            </div>
            <div class="stat-item">
                <span class="stat-label">작성 댓글</span>
                <span id="detCommentCnt" class="stat-value">0</span>
            </div>
        </div>

        <div class="profile-info-list">
            <div class="info-row"><span>직무</span><strong id="detJob">-</strong></div>
            <div class="info-row"><span>가입일</span><strong id="detCreated">-</strong></div>
            <div class="info-row"><span>로그인</span><strong id="detLoginType">-</strong></div>
            <div class="info-row"><span>상태</span><strong id="detStatus">-</strong></div>
        </div>

        <div class="modal-actions" style="margin-top: 25px;">
            <button onclick="closeDetailModal()" class="btn-modal-confirm">확인</button>
        </div>
    </div>
</div>

<%-- 자바스크립트 연결 --%>
<script src="${pageContext.request.contextPath}/js/admin/admin-member.js"></script>