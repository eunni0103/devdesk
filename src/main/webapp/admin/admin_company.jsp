<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin-member.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin-company.css">

<div class="admin-wrapper">

    <%-- 사이드바 --%>
    <div class="admin-sidebar">
        <h3>Admin Panel</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/admin">📊 대시보드</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/member">👥 회원 관리</a></li>
            <%-- 🌟 게시글 관리 주소도 연결 완료! --%>
            <li><a href="${pageContext.request.contextPath}/admin/board">📝 게시글 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/report">🚨 신고 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/company" class="active">🏢 기업 정보 관리</a></li>
        </ul>
    </div>

    <%-- 메인 컨텐츠 --%>
    <div class="admin-content">
        <h2>🏢 기업 정보 관리</h2>
        <p class="admin-page-desc">유저가 등록한 기업을 승인하고, 중복 기업을 정리합니다.</p>

        <%-- 상단 요약 카드 --%>
        <div class="company-stat-cards">
            <div class="stat-card stat-card--pending">
                <div class="stat-card__label">승인 대기</div>
                <div class="stat-card__value">${pendingCount} 건</div>
            </div>
            <div class="stat-card stat-card--total">
                <div class="stat-card__label">전체 기업</div>
                <div class="stat-card__value">${totalAllCompanies} 개</div>
            </div>
        </div>

        <%-- 필터 탭 + 검색 --%>
        <div class="company-toolbar">
            <div class="filter-tabs">
                <a href="${pageContext.request.contextPath}/admin/company"
                   class="filter-tab ${currentFilter == '' ? 'active' : ''}">전체</a>
                <a href="?filter=N&keyword=${keyword}"
                   class="filter-tab filter-tab--pending ${currentFilter == 'N' ? 'active' : ''}">
                    승인 대기
                    <c:if test="${pendingCount > 0}">
                        <span class="badge-count">${pendingCount}</span>
                    </c:if>
                </a>
                <a href="?filter=Y&keyword=${keyword}" class="filter-tab ${currentFilter == 'Y' ? 'active' : ''}">승인
                    완료</a>
            </div>

            <div class="search-box">
                <form method="get" action="${pageContext.request.contextPath}/admin/company"
                      style="display:flex;gap:8px;">
                    <input type="hidden" name="filter" value="${currentFilter}">
                    <input type="text" name="keyword" value="${keyword}"
                           class="search-input" placeholder="기업명 검색...">
                    <button type="submit" class="btn-search">검색</button>
                </form>
            </div>
        </div>

        <%-- 병합 안내 --%>
        <div class="merge-guide">
            <strong>중복 기업 병합:</strong> 표에서 <strong>기업 체크박스를 2개</strong> 선택한 뒤 [선택 병합] 버튼을 누르세요.
        </div>

        <%-- 병합 버튼 (체크박스 선택 시 활성화) --%>
        <div class="bulk-action-bar" id="bulkBar" style="display:none;">
            <span id="selectedInfo">0개 선택됨</span>
            <button class="btn-merge" onclick="openMergeModal()">선택 병합</button>
        </div>

        <%-- 기업 목록 테이블 --%>
        <div class="latest-members-section">
            <table class="admin-table" id="companyTable">
                <thead>
                <tr>
                    <th><input type="checkbox" id="checkAll" onclick="toggleAll(this)"></th>
                    <th>ID</th>
                    <th>기업명</th>
                    <th>업종</th>
                    <th>지역</th>
                    <th>규모(명)</th>
                    <th>리뷰 수</th>
                    <th>등록일</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="c" items="${companies}">
                    <tr data-id="${c.company_id}" data-name="${c.company_name}"
                        class="${c.is_verified == 'N' ? 'row-pending' : ''}">
                        <td>
                            <input type="checkbox" class="company-check"
                                   value="${c.company_id}" data-name="${c.company_name}"
                                   onchange="onCheckChange()">
                        </td>
                        <td>${c.company_id}</td>
                        <td class="company-name-cell">${c.company_name}</td>
                        <td>${not empty c.company_industry ? c.company_industry : '-'}</td>
                        <td>${not empty c.company_location ? c.company_location : '-'}</td>
                        <td>${c.company_size > 0 ? c.company_size : '-'}</td>
                        <td>${c.review_count}</td>
                        <td>${c.company_created_date}</td>
                        <td>
                            <c:choose>
                                <c:when test="${c.is_verified == 'Y'}">
                                    <span class="badge badge--approved">✅ 승인</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge--pending">⏳ 대기</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="action-cell">
                            <c:choose>
                                <c:when test="${c.is_verified == 'N'}">
                                    <%-- 승인 대기: 승인 + 삭제만 --%>
                                    <button class="btn-approve"
                                            onclick="approveCompany(${c.company_id}, '${c.company_name}')">승인
                                    </button>
                                    <button class="btn-delete"
                                            onclick="deleteCompany(${c.company_id}, '${c.company_name}')">삭제
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <%-- 승인 완료: 수정 + 삭제만 --%>
                                    <button class="btn-edit"
                                            onclick="openEditModal(${c.company_id},'${c.company_name}','${c.company_industry}','${c.company_location}',${c.company_rating},${c.company_size})">
                                        수정
                                    </button>
                                    <button class="btn-delete"
                                            onclick="deleteCompany(${c.company_id}, '${c.company_name}')">삭제
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty companies}">
                    <tr>
                        <td colspan="10" style="text-align:center; padding:40px; color:#94a3b8;">
                            조건에 맞는 기업이 없습니다.
                        </td>
                    </tr>
                </c:if>
                </tbody>
            </table>
        </div>

        <%-- 페이징 --%>
        <c:if test="${totalPages > 1}">
            <div class="pagination">
                    <%-- 이전 버튼 --%>
                <c:choose>
                    <c:when test="${currentPage > 1}">
                        <a href="?filter=${currentFilter}&keyword=${keyword}&page=${currentPage - 1}" class="page-btn">&#8249;</a>
                    </c:when>
                    <c:otherwise>
                        <span class="page-btn page-btn--disabled">&#8249;</span>
                    </c:otherwise>
                </c:choose>

                    <%-- 페이지 번호 (최대 5개씩 묶어서 표시) --%>
                <c:set var="startPage" value="${currentPage - 2 > 1 ? currentPage - 2 : 1}"/>
                <c:set var="endPage" value="${startPage + 4 < totalPages ? startPage + 4 : totalPages}"/>

                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                    <a href="?filter=${currentFilter}&keyword=${keyword}&page=${i}"
                       class="page-btn ${i == currentPage ? 'page-btn--active' : ''}">${i}</a>
                </c:forEach>

                    <%-- 다음 버튼 --%>
                <c:choose>
                    <c:when test="${currentPage < totalPages}">
                        <a href="?filter=${currentFilter}&keyword=${keyword}&page=${currentPage + 1}" class="page-btn">&#8250;</a>
                    </c:when>
                    <c:otherwise>
                        <span class="page-btn page-btn--disabled">&#8250;</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>

    </div>
</div>

<%-- ===================== 수정 모달 ===================== --%>
<div id="editModal" class="modal-overlay" style="display:none;">
    <div class="modal-box">
        <h3>✏️ 기업 정보 수정</h3>
        <input type="hidden" id="edit_companyId">
        <div class="modal-form-group">
            <label>기업명</label>
            <input type="text" id="edit_name" class="modal-input">
        </div>
        <div class="modal-form-group">
            <label>업종</label>
            <input type="text" id="edit_industry" class="modal-input">
        </div>
        <div class="modal-form-group">
            <label>지역</label>
            <input type="text" id="edit_location" class="modal-input">
        </div>
        <div class="modal-form-group">
            <label>평점</label>
            <input type="number" id="edit_rating" class="modal-input" step="0.1" min="0" max="5">
        </div>
        <div class="modal-form-group">
            <label>규모 (명)</label>
            <input type="number" id="edit_size" class="modal-input" min="0">
        </div>
        <div class="modal-btn-row">
            <button class="btn-cancel" onclick="closeModal('editModal')">취소</button>
            <button class="btn-confirm" onclick="submitEdit()">저장</button>
        </div>
    </div>
</div>

<%-- ===================== 병합 모달 ===================== --%>
<div id="mergeModal" class="modal-overlay" style="display:none;">
    <div class="modal-box">
        <h3>중복 기업 병합</h3>
        <p class="modal-desc">두 기업 중 <strong>남길 기업</strong>을 선택하세요.<br>
            선택하지 않은 기업의 리뷰·지원이력이 남길 기업으로 이전된 후 삭제됩니다.</p>
        <div class="merge-option">
            <label>
                <input type="radio" name="keepCompany" value="1">
                <span id="mergeName1"></span>
                <small id="mergeId1" style="color:#94a3b8;"></small>
            </label>
        </div>
        <div class="merge-option">
            <label>
                <input type="radio" name="keepCompany" value="2">
                <span id="mergeName2"></span>
                <small id="mergeId2" style="color:#94a3b8;"></small>
            </label>
        </div>
        <div class="modal-btn-row">
            <button class="btn-cancel" onclick="closeModal('mergeModal')">취소</button>
            <button class="btn-confirm btn-confirm--danger" onclick="submitMerge()">병합 실행</button>
        </div>
    </div>
</div>

<%-- JS 연결 --%>
<script>const contextPath = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/js/admin/admin-company.js"></script>
