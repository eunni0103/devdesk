<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- 🌟 분리한 외부 CSS 파일 연결 --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
<%-- 🌟 상세 모달창 디자인을 위해 회원관리용 CSS도 같이 불러옵니다! --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin-member.css">

<%-- 🌟 Chart.js 라이브러리 연결 --%>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<%-- 관리자 화면 뼈대 시작 --%>
<div class="admin-wrapper">

    <div class="admin-sidebar">
        <h3>Admin Panel</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/admin" class="active">📊 대시보드</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/member">👥 회원 관리</a></li>
            <%-- 🌟 게시글 관리 주소도 연결 완료! --%>
            <li><a href="${pageContext.request.contextPath}/admin/board">📝 게시글 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/report">🚨 신고 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/company">🏢 기업 정보 관리</a></li>
        </ul>
    </div>

    <div class="admin-content">
        <h2>📊 관리자 대시보드</h2>
        <p style="color: #64748b; margin-bottom: 30px;">DevDesk의 실시간 서비스 현황입니다.</p>

        <div class="dashboard-layout">

            <div class="dashboard-cards">
                <div class="card">
                    <div class="card-title">총 가입자 수</div>
                    <div class="card-value">${totalMembers} 명</div>
                </div>

                <div class="card">
                    <div class="card-title">총 커뮤니티 게시글</div>
                    <div class="card-value">${totalBoards} 개</div>
                </div>

                <div class="card">

                    <div class="card-title">오늘의 신규 가입</div>
                    <div class="card-value" style="color: var(--success-color);">+ ${todayNewMembers} 명</div>
                </div>
            </div>

            <div class="chart-container">
                <h3 class="chart-title">📈 가입자 트렌드 (최근 7일)</h3>
                <div class="chart-canvas-wrapper">
                    <canvas id="memberTrendChart"></canvas>
                </div>
            </div>

            <div class="chart-container">
                <h3 class="chart-title">👥 직무 카테고리 분포</h3>
                <div class="chart-canvas-wrapper">
                    <canvas id="jobDistributionChart"></canvas>
                </div>
            </div>

            <div class="latest-members-section">
                <h3 style="margin-bottom: 15px; color: #334155;">최근 가입한 회원</h3>
                <table class="admin-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>닉네임</th>
                        <th>직무</th>
                        <th>권한</th>
                        <th>가입일</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="m" items="${members}" begin="0" end="4">
                        <%-- 🌟 대시보드에도 탈퇴 회원 취소선 로직(is-deleted) 적용! --%>
                        <tr class="${m.status == 'deleted' ? 'is-deleted' : ''}">
                            <td>${m.member_id}</td>
                            <td class="nickname">${m.nickname}</td>
                            <td>${m.job_category != null ? m.job_category : '미입력(소셜)'}</td>
                            <td class="${m.role == 'admin' ? 'role-admin-text' : ''}">
                                    ${m.role == 'admin' ? '⭐ 관리자' : '일반'}
                            </td>
                            <td>${m.created_date}</td>
                            <td>
                                    <%-- 🌟 껍데기 버튼을 진짜 상세 모달 버튼으로 교체 완료! --%>
                                <button onclick="showDetail(${m.member_id})" class="btn-view-detail">
                                    상세 보기
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <div style="text-align: center; margin-top: 20px;">
                    <a href="${pageContext.request.contextPath}/admin/member"
                       style="color: var(--primary-color); font-weight: 600; text-decoration: underline;">전체 회원 목록 보러가기
                        ➔</a>
                </div>
            </div>

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

<%-- ======================================================= --%>
<%-- JavaScript 데이터 세팅 및 외부 파일 불러오기 --%>
<%-- ======================================================= --%>
<script>
    // 1. 선 차트 (최근 7일 트렌드)
    const chartLabels_trend = [
        <c:forEach var="item" items="${trendLabels}">"${item}", </c:forEach>
    ];
    const chartData_trend = [
        <c:forEach var="item" items="${trendData}">${item}, </c:forEach>
    ];

    // 2. 도넛 차트 (직무 분포)
    const chartLabels_job = [
        <c:forEach var="item" items="${jobLabels}">"${item}", </c:forEach>
    ];
    const chartData_job = [
        <c:forEach var="item" items="${jobData}">${item}, </c:forEach>
    ];
</script>

<%-- 차트 그리는 JS --%>
<script src="${pageContext.request.contextPath}/js/admin/admin-charts.js"></script>

<%-- 🌟 상세 모달창을 띄우기 위해 admin-member.js 도 추가로 불러옵니다! --%>
<script src="${pageContext.request.contextPath}/js/admin/admin-member.js"></script>