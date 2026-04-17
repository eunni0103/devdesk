<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="ctx" content="${pageContext.request.contextPath}">
    <title>이력서 블록 라이브러리 — DevDesk</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/workspace-ui.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/til.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/resume-block.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
<div class="page-wrap">

    <%-- ── Sidebar ── --%>
    <button class="hamburger">☰</button>
    <div class="sidebar-overlay"></div>
    <aside class="sidebar">
        <div class="sidebar-logo">
            <span class="logo-mark">취뽀 워크스페이스</span>
            <span class="logo-sub">IT 취업 준비 플랫폼</span>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section-label">메인</div>
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item">
                <span class="nav-icon">🏠</span>대시보드
            </a>
            <div class="nav-section-label">취업 관리</div>
            <a href="${pageContext.request.contextPath}/application-list" class="nav-item">
                <span class="nav-icon">📋</span>지원 현황
            </a>
            <a href="${pageContext.request.contextPath}/calendar" class="nav-item">
                <span class="nav-icon">📅</span>면접 일정
            </a>
            <div class="nav-section-label">이력서</div>
            <a href="${pageContext.request.contextPath}/resume-block" class="nav-item active">
                <span class="nav-icon">📝</span>블록 라이브러리
            </a>
            <div class="nav-section-label">학습</div>
            <a href="${pageContext.request.contextPath}/til-list" class="nav-item">
                <span class="nav-icon">📚</span>TIL
            </a>
            <div class="nav-section-label">커뮤니티</div>
            <a href="${pageContext.request.contextPath}/review" class="nav-item">
                <span class="nav-icon">💬</span>면접 후기
            </a>
            <a href="${pageContext.request.contextPath}/board" class="nav-item">
                <span class="nav-icon">📢</span>게시판
            </a>
        </nav>

    </aside>

    <%-- ── Main content ── --%>
    <main class="content-area">
        <div class="page-header-row"
             style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:24px">
            <div>
                <h1 style="font-size:22px;font-weight:700;color:var(--text);margin-bottom:4px">
                    이력서 블록 라이브러리
                </h1>
                <p style="font-size:13px;color:var(--text3)">
                    이력서 항목을 블록 단위로 관리 — 지원 동기, 자기 PR, 장단점을 체계적으로 정리하세요
                </p>
            </div>
        </div>

        <%-- ── Tabs ── --%>
        <div class="rb-tabs">
            <button class="rb-tab active" data-tab="library" onclick="switchTab('library')">블록 라이브러리</button>
            <button class="rb-tab" data-tab="compose" onclick="switchTab('compose')">이력서 조합</button>
        </div>

        <%-- ══════════════════════════════════════
             TAB 1: 블록 라이브러리
        ══════════════════════════════════════ --%>
        <div id="panel-library" class="rb-panel active">

            <%-- Stats --%>
            <div class="rb-stats">
                <div class="rb-stat-chip">
                    <div class="rb-stat-val">${totalCount}</div>
                    <div class="rb-stat-key">전체 블록</div>
                </div>
                <div class="rb-stat-chip">
                    <div class="rb-stat-val">${categoryCount}</div>
                    <div class="rb-stat-key">카테고리</div>
                </div>
                <div class="rb-stat-chip">
                    <div class="rb-stat-val">${starCount}</div>
                    <div class="rb-stat-key">즐겨찾기</div>
                </div>
            </div>

            <%-- Section header + Add button --%>
            <div class="rb-section-bar">
                <span class="rb-section-title">내 블록</span>
                <button class="btn btn-primary btn-sm" onclick="openNewBlockModal()">+ 새 블록</button>
            </div>

            <%-- Filter chips --%>
            <div class="rb-filters">
                <a href="${pageContext.request.contextPath}/resume-block?filter=all"
                   class="rb-filter-chip ${currentFilter == 'all' || currentFilter == null ? 'active' : ''}">전체</a>
                <a href="${pageContext.request.contextPath}/resume-block?filter=star"
                   class="rb-filter-chip ${currentFilter == 'star' ? 'active' : ''}">⭐ 즐겨찾기</a>
                <a href="${pageContext.request.contextPath}/resume-block?filter=shimei"
                   class="rb-filter-chip ${currentFilter == 'shimei' ? 'active' : ''}">지원 동기</a>
                <a href="${pageContext.request.contextPath}/resume-block?filter=jikopr"
                   class="rb-filter-chip ${currentFilter == 'jikopr' ? 'active' : ''}">자기 PR</a>
                <a href="${pageContext.request.contextPath}/resume-block?filter=chosho"
                   class="rb-filter-chip ${currentFilter == 'chosho' ? 'active' : ''}">장단점</a>
                <a href="${pageContext.request.contextPath}/resume-block?filter=keireki"
                   class="rb-filter-chip ${currentFilter == 'keireki' ? 'active' : ''}">직무 경력</a>
                <a href="${pageContext.request.contextPath}/resume-block?filter=other"
                   class="rb-filter-chip ${currentFilter == 'other' ? 'active' : ''}">기타</a>
            </div>

            <%-- Block list --%>
            <c:choose>
                <c:when test="${empty blockList}">
                    <div class="empty-state">
                        <div class="icon">📝</div>
                        <p>아직 작성된 블록이 없습니다<br>
                            <strong>+ 새 블록</strong> 버튼을 눌러 첫 번째 블록을 만들어보세요</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="block" items="${blockList}">
                        <div class="rb-card" data-block-id="${block.blockId}">
                            <div class="rb-card-header">
                                <span class="rb-cat-badge cat-${block.categoryId}">
                                    <c:choose>
                                        <c:when test="${block.categoryId == 'shimei'}">지원 동기</c:when>
                                        <c:when test="${block.categoryId == 'jikopr'}">자기 PR</c:when>
                                        <c:when test="${block.categoryId == 'chosho'}">장단점</c:when>
                                        <c:when test="${block.categoryId == 'keireki'}">직무 경력</c:when>
                                        <c:otherwise>기타</c:otherwise>
                                    </c:choose>
                                </span>
                                <div class="rb-card-meta">
                                    <span class="rb-ver-badge">v${block.latestVersion}</span>
                                    <button class="rb-star-btn ${block.isStar == 1 ? 'starred' : ''}"
                                            onclick="toggleStar(${block.blockId})"
                                            title="즐겨찾기">
                                            ${block.isStar == 1 ? '★' : '☆'}
                                    </button>
                                </div>
                            </div>

                            <div class="rb-card-title">${fn:escapeXml(block.title)}</div>
                            <div class="rb-card-preview"
                                 data-full-content="${fn:escapeXml(block.content)}">
                                    ${fn:escapeXml(block.content)}
                            </div>

                            <div class="rb-card-footer">
                                <div class="rb-tags">
                                    <c:if test="${not empty block.tags}">
                                        <c:forEach var="tag" items="${fn:split(block.tags, ',')}">
                                            <span class="rb-tag">${fn:trim(tag)}</span>
                                        </c:forEach>
                                    </c:if>
                                    <span class="rb-char-count">
                                        <c:set var="contentLen" value="${fn:length(block.content)}"/>
                                        ${contentLen}자
                                        <c:if test="${block.charLimit > 0 && contentLen > block.charLimit}">
                                            <span class="rb-char-warn">(제한 ${block.charLimit}자 초과)</span>
                                        </c:if>
                                    </span>
                                </div>
                                <div class="rb-card-actions">
                                    <button class="btn btn-ghost btn-sm"
                                            onclick="copyBlock(${block.blockId})">복사
                                    </button>
                                    <button class="btn btn-ghost btn-sm"
                                            onclick="openVersionModal(${block.blockId})">버전
                                    </button>
                                    <button class="btn btn-ghost btn-sm"
                                            onclick="openEditModal(
                                                ${block.blockId},
                                                    '${block.categoryId}',
                                                    '${fn:escapeXml(block.title)}',
                                                    document.querySelector('[data-block-id=&quot;${block.blockId}&quot;] .rb-card-preview').getAttribute('data-full-content'),
                                                    '${fn:escapeXml(block.tags)}',
                                                ${block.charLimit}
                                                    )">편집
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <%-- ══════════════════════════════════════
             TAB 2: 이력서 조합
        ══════════════════════════════════════ --%>
        <div id="panel-compose" class="rb-panel">
            <p class="rb-compose-desc">
                각 항목에서 저장된 블록을 선택하면 내용이 채워집니다.
                <strong>복사</strong> 버튼으로 외부 지원 사이트에 바로 붙여넣기 할 수 있어요.
            </p>

            <%-- 지원 동기 --%>
            <div class="rb-compose-card">
                <div class="rb-compose-header">
                    <span class="rb-cat-badge cat-shimei">지원 동기</span>
                    <select id="compose-sel-shimei" class="rb-compose-select"
                            onchange="selectCompose('shimei')">
                        <option value="">블록 선택...</option>
                        <c:forEach var="b" items="${allBlocks}">
                            <c:if test="${b.categoryId == 'shimei'}">
                                <option value="${b.blockId}">${fn:escapeXml(b.title)} (v${b.latestVersion})</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="rb-compose-content" id="compose-content-shimei">블록을 선택해주세요</div>
                <div class="rb-compose-footer">
                    <button class="btn btn-ghost btn-sm" onclick="copyCompose('shimei')">복사</button>
                </div>
            </div>

            <%-- 자기 PR --%>
            <div class="rb-compose-card">
                <div class="rb-compose-header">
                    <span class="rb-cat-badge cat-jikopr">자기 PR</span>
                    <select id="compose-sel-jikopr" class="rb-compose-select"
                            onchange="selectCompose('jikopr')">
                        <option value="">블록 선택...</option>
                        <c:forEach var="b" items="${allBlocks}">
                            <c:if test="${b.categoryId == 'jikopr'}">
                                <option value="${b.blockId}">${fn:escapeXml(b.title)} (v${b.latestVersion})</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="rb-compose-content" id="compose-content-jikopr">블록을 선택해주세요</div>
                <div class="rb-compose-footer">
                    <button class="btn btn-ghost btn-sm" onclick="copyCompose('jikopr')">복사</button>
                </div>
            </div>

            <%-- 장단점 --%>
            <div class="rb-compose-card">
                <div class="rb-compose-header">
                    <span class="rb-cat-badge cat-chosho">장단점</span>
                    <select id="compose-sel-chosho" class="rb-compose-select"
                            onchange="selectCompose('chosho')">
                        <option value="">블록 선택...</option>
                        <c:forEach var="b" items="${allBlocks}">
                            <c:if test="${b.categoryId == 'chosho'}">
                                <option value="${b.blockId}">${fn:escapeXml(b.title)} (v${b.latestVersion})</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="rb-compose-content" id="compose-content-chosho">블록을 선택해주세요</div>
                <div class="rb-compose-footer">
                    <button class="btn btn-ghost btn-sm" onclick="copyCompose('chosho')">복사</button>
                </div>
            </div>

            <%-- 직무 경력 --%>
            <div class="rb-compose-card">
                <div class="rb-compose-header">
                    <span class="rb-cat-badge cat-keireki">직무 경력</span>
                    <select id="compose-sel-keireki" class="rb-compose-select"
                            onchange="selectCompose('keireki')">
                        <option value="">블록 선택...</option>
                        <c:forEach var="b" items="${allBlocks}">
                            <c:if test="${b.categoryId == 'keireki'}">
                                <option value="${b.blockId}">${fn:escapeXml(b.title)} (v${b.latestVersion})</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="rb-compose-content" id="compose-content-keireki">블록을 선택해주세요</div>
                <div class="rb-compose-footer">
                    <button class="btn btn-ghost btn-sm" onclick="copyCompose('keireki')">복사</button>
                </div>
            </div>

            <div class="rb-compose-actions">
                <button class="btn btn-primary" onclick="copyAllCompose()">전체 복사</button>
            </div>
        </div>

    </main>
</div>

<%-- ── Modal ── --%>
<div class="modal-overlay" id="rbModalOverlay">
    <div class="modal modal-lg" id="rbModalBody">
    </div>
</div>

<%-- ── Toast ── --%>
<div class="rb-toast" id="rbToast"></div>

<%-- ── allBlocks JSON (이력서 조합 탭용) ── --%>
<script>
    var allBlocksData = [
        <c:forEach var="b" items="${allBlocks}" varStatus="s">
        {
            blockId: ${b.blockId},
            categoryId: '${b.categoryId}',
            title: '${fn:escapeXml(b.title)}',
            content: `${fn:escapeXml(b.content)}`
        }<c:if test="${!s.last}">, </c:if>
        </c:forEach>
    ];
</script>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="${pageContext.request.contextPath}/js/resume-block.js"></script>

