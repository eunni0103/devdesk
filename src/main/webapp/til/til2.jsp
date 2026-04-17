<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<link rel="stylesheet" href="css/workspace-ui.css">
<link rel="stylesheet" href="css/index.css">
<link rel="stylesheet" href="css/sidebar.css">
<link rel="stylesheet" href="css/til.css">
<div class="page-wrap">

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
            <a href="${pageContext.request.contextPath}/resume-block" class="nav-item">
                <span class="nav-icon">📝</span>블록 라이브러리
            </a>
            <div class="nav-section-label">학습</div>
            <a href="${pageContext.request.contextPath}/til-list" class="nav-item active">
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

        <div id="sidebar-mini-calendar" style="margin-top: auto; ">
<%-- 원본서식 :border-top: 1px solid var(--border, #e2e8f0); padding-top: 15px; padding-bottom: 20px;--%>
            <div class="g-cal-header">
                <button class="g-nav-btn" id="g-prev-month">❮</button>
                <span class="g-cal-title" id="g-cal-title"></span>
                <button class="g-nav-btn" id="g-next-month">❯</button>
            </div>
            <div class="g-cal-weekdays">
                <div class="sun">일</div><div>월</div><div>화</div><div>수</div><div>목</div><div>금</div><div>토</div>
            </div>
            <div class="g-cal-days" id="g-cal-days"></div>
        </div>
    </aside>

    <main class="content-area">
        <!-- 여기부터 본문 -->
        <div class="page-header-row">
            <div>
                <h1 class="page-title">TIL</h1>
                <p class="page-sub">Today I Learned — 오늘 배운 것을 기록하세요</p>
            </div>
            <button class="btn btn-primary" onclick="openTilEditor()">+ TIL 작성</button>
        </div>

        <!-- Stats strip -->
        <div class="til-stats">
            <div class="stat-chip">
                <div class="stat-chip-val">${totalCount}</div>
                <div class="stat-chip-key">총 TIL</div>
            </div>
            <div class="stat-chip">
                <div class="stat-chip-val">${totalHours}h</div>
                <div class="stat-chip-key">총 학습 시간</div>
            </div>
            <div class="stat-chip">
                <div class="stat-chip-val">${avgHours}h</div>
                <div class="stat-chip-key">평균 학습 시간</div>
            </div>
            <div class="stat-chip">
                <div class="stat-chip-val" style="font-size:15px">${empty topTag ? '-' : topTag}</div>
                <div class="stat-chip-key">최다 학습 태그</div>
            </div>
        </div>

        <!-- Main layout -->
        <div class="til-layout">

            <!-- Left: tag filter + list -->
            <div class="til-main">

                <!-- Tag filter -->
                <div class="tag-filter">
                    <a href="til-list" class="tag-btn ${empty param.tag ? 'active' : ''}">
                        전체 <span class="tag-cnt">${totalCount}</span>
                    </a>
                    <c:forEach var="entry" items="${tagStats}">
                        <a href="til-list?tag=${entry.key}"
                           class="tag-btn ${param.tag == entry.key ? 'active' : ''}">
                                ${entry.key} <span class="tag-cnt">${entry.value}</span>
                        </a>
                    </c:forEach>
                </div>

                <!-- TIL cards -->
                <c:choose>
                    <c:when test="${empty tilList}">
                        <div class="empty-state">
                            <div class="icon">✍️</div>
                            <p>${empty param.tag ? 'TIL을 작성해보세요' : param.tag.concat(' 태그의 TIL이 없어요')}</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="t" items="${tilList}" varStatus="vs">
                            <div class="til-card anim-fade-up" style="animation-delay:${vs.index * 40}ms"
                                 onclick="openDetail('${t.tilId}')">
                                <div class="til-card-top">
                                    <span class="badge tag-badge-${t.tag}">${t.tag}</span>
                                    <span class="til-card-time">
                                        <c:if test="${t.studyTime > 0}">${t.studyTime}h</c:if>
                                    </span>
                                </div>
                                <div class="til-card-title">${t.title}</div>
                                <c:if test="${not empty t.content}">
                                    <div class="til-card-preview">
                                            ${fn:escapeXml(fn:substring(t.content, 0, 100))}${fn:length(t.content) > 100 ? '...' : ''}
                                    </div>
                                </c:if>
                                <div class="til-card-footer">
                                    <span>${t.createdAt}</span>
                                    <div class="til-card-actions" onclick="event.stopPropagation()">
                                        <button class="btn btn-ghost btn-sm btn-icon"
                                                onclick="openTilEditor('${t.tilId}')">✏️
                                        </button>
                                        <button class="btn btn-ghost btn-sm btn-icon"
                                                onclick="openDeleteConfirm('${t.tilId}', '${t.title}')">🗑
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>

            </div>

            <!-- Right: chart + stats -->
            <div class="til-side">
                <div class="card">
                    <div class="card-title">월간 학습 분포</div>
                    <div class="side-chart-wrap">
                        <div class="donut-wrap">
                            <canvas id="donutCanvas" width="130" height="130"></canvas>
                            <div class="donut-center">
                                <div class="donut-num">${fn:length(tagStats)}</div>
                                <div class="donut-label">태그 수</div>
                            </div>
                        </div>
                        <div class="chart-legend" id="chartLegend"></div>
                    </div>
                </div>

                <div class="card" style="margin-top:16px">
                    <div class="card-title">학습 통계</div>
                    <c:choose>
                        <c:when test="${empty tagHours}">
                            <p style="color:var(--text3);font-size:13px">데이터 없음</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="entry" items="${tagHours}">
                                <div class="study-stat-row">
                                    <div class="study-stat-label">
                                        <span class="tag-color-${entry.key}">${entry.key}</span>
                                        <span style="color:var(--text3)">${entry.value}h</span>
                                    </div>
                                    <div class="study-stat-bar">
                                        <div class="study-stat-fill tag-fill-${entry.key}"
                                             style="width:${entry.value / maxHours * 100}%"></div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
    </main>
</div>


<!-- TIL 등록 / 수정 모달 -->
<div class="modal-overlay" id="tilEditorModal">
    <div class="modal modal-lg">
        <div class="modal-header">
            <div class="modal-title" id="editorTitle">TIL 작성</div>
            <button class="modal-close" onclick="closeEditor()">✕</button>
        </div>

        <form id="tilForm" method="post">
            <input type="hidden" name="til_id" id="formTilId">
            <input type="hidden" name="member_id" value="${sessionScope.loginUser.memberId}">

            <div class="form-group">
                <label class="form-label">제목 *</label>
                <input class="form-input" name="title" id="tilTitle"
                       placeholder="오늘 배운 것을 한 줄로 요약해보세요" required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">태그</label>
                    <select class="form-select" name="tag" id="tilTag">
                        <option value="Java">Java</option>
                        <option value="Spring">Spring</option>
                        <option value="SQL">SQL</option>
                        <option value="JavaScript">JavaScript</option>
                        <option value="Git">Git</option>
                        <option value="Python">Python</option>
                        <option value="CSS">CSS</option>
                        <option value="React">React</option>
                        <option value="기타">기타</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">학습 시간 (시간)</label>
                    <input class="form-input" name="study_time" id="tilTime"
                           type="number" min="0.5" max="24" step="0.5" placeholder="예: 2">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">내용</label>
                <div class="editor-toolbar">
                    <button type="button" class="toolbar-btn" onclick="insertMd('## ')">H2</button>
                    <button type="button" class="toolbar-btn" onclick="insertMd('### ')">H3</button>
                    <button type="button" class="toolbar-btn" onclick="wrapMd('**','**')"><b>B</b></button>
                    <button type="button" class="toolbar-btn" onclick="wrapMd('&grave;','&grave;')">{ }</button>
                    <button type="button" class="toolbar-btn" onclick="insertMd('- ')">—</button>
                    <button type="button" class="toolbar-btn" onclick="insertMd('\n```\n','\n```')">⌨</button>
                    <span class="toolbar-sep"></span>
                    <button type="button" class="toolbar-btn preview-toggle"
                            onclick="togglePreview()" id="previewBtn">👁 미리보기
                    </button>
                </div>
                <textarea class="form-textarea editor-textarea" name="content" id="tilContent"
                          placeholder="## 오늘 배운 내용&#10;&#10;- 핵심 개념&#10;&#10;## 느낀 점"
                          style="min-height:220px"></textarea>
                <div class="editor-preview" id="editorPreview" style="display:none"></div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeEditor()">취소</button>
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    </div>
</div>


<!-- TIL 상세 모달 -->
<c:forEach var="t" items="${tilList}">
    <div id="til_data_${t.tilId}" style="display:none"
         data-title="${t.title}"
         data-tag="${t.tag}"
         data-time="${t.studyTime}"
         data-date="${t.createdAt}"
         data-content="${fn:escapeXml(t.content)}">
    </div>
</c:forEach>

<div class="modal-overlay" id="tilDetailModal">
    <div class="modal modal-lg">
        <div class="modal-header">
            <div>
                <div class="modal-title" id="detailTitle"></div>
                <div class="detail-meta" id="detailMeta"></div>
            </div>
            <button class="modal-close" onclick="closeDetail()">✕</button>
        </div>
        <div class="detail-content" id="detailContent"></div>
        <div class="modal-footer">
            <button class="btn btn-danger btn-sm" id="detailDeleteBtn">삭제</button>
            <div style="flex:1"></div>
            <button class="btn btn-ghost" onclick="closeDetail()">닫기</button>
            <button class="btn btn-primary" id="detailEditBtn">수정</button>
        </div>
    </div>
</div>

<!-- 삭제 확인 다이얼로그 -->
<div class="confirm-overlay" id="confirmOverlay">
    <div class="confirm-box">
        <div class="confirm-title">TIL 삭제</div>
        <div class="confirm-msg" id="confirmMsg">이 작업은 되돌릴 수 없습니다.</div>
        <div class="confirm-btns">
            <button class="btn btn-ghost btn-sm" onclick="closeConfirm()">취소</button>
            <form id="deleteForm" action="til_delete" method="post" style="display:inline">
                <input type="hidden" name="til_id" id="deleteTilId">
                <button type="submit" class="btn btn-danger btn-sm">삭제</button>
            </form>
        </div>
    </div>
</div>

<div class="toast-container" id="toastContainer"></div>

<script>
    // 1. 서버 데이터(JSTL)를 JS 변수로 변환 (이 부분은 외부 JS파일에서 실행 불가하므로 JSP에 남겨야 함)
    const TAG_STATS = [
        <c:forEach var="entry" items="${tagStats}" varStatus="vs">
        {tag: '${entry.key}', count: ${entry.value}}${vs.last ? '' : ','}
        </c:forEach>
    ];

    const RAW_EVENTS = [
        <c:forEach var="sch" items="${schList}">
        '<fmt:formatDate value="${sch.schedule_date}" pattern="yyyy-MM-dd" />',
        </c:forEach>
    ];

    const CTX_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/js/til/til.js"></script>

