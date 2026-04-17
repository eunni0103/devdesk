<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TIL — 취뽀 워크스페이스</title>
    <link rel="stylesheet" href="css/workspace-ui.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <link rel="stylesheet" href="css/til.css">
</head>
<body>
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
            <a href="dashboard" class="nav-item"><span class="nav-icon">🏠</span>대시보드</a>
            <div class="nav-section-label">취업 관리</div>
            <a href="applications" class="nav-item"><span class="nav-icon">📋</span>지원 현황</a>
            <a href="schedule" class="nav-item"><span class="nav-icon">📅</span>면접 일정</a>
            <div class="nav-section-label">학습</div>
            <a href="til" class="nav-item active"><span class="nav-icon">📚</span>TIL</a>
        </nav>
        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">나</div>
                <div>
                    <div class="user-name">${sessionScope.loginUser.name}</div>
                    <div class="user-role">${sessionScope.loginUser.role}</div>
                </div>
            </div>
        </div>
    </aside>

    <main class="content-area">
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
                    <a href="til" class="tag-btn ${empty param.tag ? 'active' : ''}">
                        전체 <span class="tag-cnt">${totalCount}</span>
                    </a>
                    <c:forEach var="entry" items="${tagStats}">
                        <a href="til?tag=${entry.key}"
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
                                            ${fn:substring(t.content, 0, 100)}${fn:length(t.content) > 100 ? '...' : ''}
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


<!-- ══════════════════════════════
     TIL 등록 / 수정 모달
══════════════════════════════ -->
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
                    <button type="button" class="toolbar-btn" onclick="wrapMd('\`','\`')">{ }</button>
                    <button type="button" class="toolbar-btn" onclick="insertMd('- ')">—</button>
                    <button type="button" class="toolbar-btn" onclick="insertMd('\n\`\`\`\n','\n\`\`\`')">⌨</button>
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


<!-- ══════════════════════════════
     TIL 상세 모달 (읽기 전용)
     → 서버에서 받은 데이터를 hidden으로 넘겨서 JS로 채움
══════════════════════════════ -->

<%-- 각 TIL 데이터를 hidden div에 저장해두고 JS에서 꺼내 씀 --%>
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


<!-- ══════════════════════════════
     도넛 차트용 태그 데이터 (서버 → JS)
══════════════════════════════ -->
<script>
    // 서버에서 받은 태그별 통계를 JS 배열로 변환
    const TAG_STATS = [
        <c:forEach var="entry" items="${tagStats}" varStatus="vs">
        {tag: '${entry.key}', count: ${entry.value}}${vs.last ? '' : ','}
        </c:forEach>
    ];

    const TAG_CONFIG = {
        'Java': {color: '#ff9f69', bg: 'rgba(255,159,105,0.12)'},
        'Spring': {color: '#56e39f', bg: 'rgba(86,227,159,0.12)'},
        'SQL': {color: '#4ecdc4', bg: 'rgba(78,205,196,0.12)'},
        'JavaScript': {color: '#ffd166', bg: 'rgba(255,209,102,0.12)'},
        'Git': {color: '#ff6b6b', bg: 'rgba(255,107,107,0.12)'},
        'Python': {color: '#5b7cf8', bg: 'rgba(91,124,248,0.12)'},
        'CSS': {color: '#8b6ef5', bg: 'rgba(139,110,245,0.12)'},
        'React': {color: '#4ecdc4', bg: 'rgba(78,205,196,0.12)'},
        '기타': {color: '#9da3b8', bg: 'rgba(157,163,184,0.12)'},
    };


    /* ── 도넛 차트 ── */
    function drawDonut() {
        if (!TAG_STATS.length) return;
        const total = TAG_STATS.reduce((a, d) => a + d.count, 0);
        const canvas = document.getElementById('donutCanvas');
        const ctx = canvas.getContext('2d');
        const cx = 65, cy = 65, r = 50, ir = 30, gap = 0.04;
        let angle = -Math.PI / 2;

        TAG_STATS.forEach(d => {
            const cfg = TAG_CONFIG[d.tag] || TAG_CONFIG['기타'];
            const sweep = (d.count / total) * Math.PI * 2 - gap;
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, r, angle + gap / 2, angle + sweep + gap / 2);
            ctx.closePath();
            ctx.fillStyle = cfg.color;
            ctx.fill();
            angle += sweep + gap;
        });

        ctx.beginPath();
        ctx.arc(cx, cy, ir, 0, Math.PI * 2);
        ctx.fillStyle = getComputedStyle(document.documentElement)
            .getPropertyValue('--surface') || '#141720';
        ctx.fill();

        document.getElementById('chartLegend').innerHTML = TAG_STATS.map(d => {
            const cfg = TAG_CONFIG[d.tag] || TAG_CONFIG['기타'];
            const pct = Math.round(d.count / total * 100);
            // ✅ 템플릿 리터럴 대신 문자열 연결로 변경
            return '<div class="legend-row">' +
                '<div class="legend-dot" style="background:' + cfg.color + '"></div>' +
                '<span class="legend-name">' + d.tag + '</span>' +
                '<span class="legend-pct" style="color:' + cfg.color + '">' + pct + '%</span>' +
                '</div>';
        }).join('');
    }


    // ✅ 수정 — 그냥 바로 호출
    drawDonut();


    /* ── 등록 / 수정 모달 ── */
    function openTilEditor(id) {
        const form = document.getElementById('tilForm');
        document.getElementById('editorTitle').textContent = id ? 'TIL 수정' : 'TIL 작성';
        form.action = id ? 'til_update' : 'til_insert';

        // 미리보기 초기화
        document.getElementById('editorPreview').style.display = 'none';
        document.getElementById('tilContent').style.display = 'block';
        document.getElementById('previewBtn').textContent = '👁 미리보기';

        if (id) {
            const el = document.getElementById('til_data_' + id);
            document.getElementById('formTilId').value = id;
            document.getElementById('tilTitle').value = el.dataset.title;
            document.getElementById('tilTag').value = el.dataset.tag;
            document.getElementById('tilTime').value = el.dataset.time;
            document.getElementById('tilContent').value = el.dataset.content;
        } else {
            document.getElementById('formTilId').value = '';
            document.getElementById('tilTitle').value = '';
            document.getElementById('tilTag').value = 'Java';
            document.getElementById('tilTime').value = '';
            document.getElementById('tilContent').value = '';
        }

        document.getElementById('tilEditorModal').classList.add('open');
        document.getElementById('tilTitle').focus();
    }

    function closeEditor() {
        document.getElementById('tilEditorModal').classList.remove('open');
    }


    /* ── 상세 모달 ── */
    function openDetail(id) {
        const el = document.getElementById('til_data_' + id);
        if (!el) return;
        const cfg = TAG_CONFIG[el.dataset.tag] || TAG_CONFIG['기타'];

        document.getElementById('detailTitle').textContent = el.dataset.title;
        document.getElementById('detailMeta').innerHTML =
            '<span class="badge" style="background:' + cfg.bg + ';color:' + cfg.color + '">' + el.dataset.tag + '</span>' +
            '<span style="font-size:12px;color:var(--text3);margin-left:8px">' + el.dataset.date + '</span>' +
            (el.dataset.time > 0
                ? '<span style="font-size:12px;color:var(--text3);margin-left:8px">⏱ ' + el.dataset.time + 'h</span>'
                : '');

        document.getElementById('detailContent').innerHTML = renderMarkdown(el.dataset.content);
        document.getElementById('detailEditBtn').onclick = function () {
            closeDetail();
            openTilEditor(id);
        };
        document.getElementById('detailDeleteBtn').onclick = function () {
            closeDetail();
            openDeleteConfirm(id, el.dataset.title);
        };

        document.getElementById('tilDetailModal').classList.add('open');
    }

    function closeDetail() {
        document.getElementById('tilDetailModal').classList.remove('open');
    }


    /* ── 삭제 확인 ── */
    function openDeleteConfirm(id, title) {
        document.getElementById('confirmMsg').textContent = '"' + title + '" 를 삭제할까요? 이 작업은 되돌릴 수 없습니다.';
        document.getElementById('deleteTilId').value = id;
        document.getElementById('confirmOverlay').classList.add('open');
    }

    function closeConfirm() {
        document.getElementById('confirmOverlay').classList.remove('open');
    }


    /* ── 마크다운 렌더러 ── */
    function renderMarkdown(text) {
        if (!text) return '<p style="color:var(--text3)">내용이 없어요.</p>';
        return text
            .replace(/```([\s\S]*?)```/g, '<pre class="md-code">$1</pre>')
            .replace(/`([^`]+)`/g, '<code class="md-inline">$1</code>')
            .replace(/^### (.+)$/gm, '<h3 class="md-h3">$1</h3>')
            .replace(/^## (.+)$/gm, '<h2 class="md-h2">$1</h2>')
            .replace(/^# (.+)$/gm, '<h1 class="md-h1">$1</h1>')
            .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
            .replace(/^- (.+)$/gm, '<li class="md-li">$1</li>')
            .replace(/\n\n/g, '</p><p class="md-p">')
            .replace(/\n/g, '<br>');
    }


    /* ── 에디터 툴바 ── */
    function insertMd(prefix) {
        const ta = document.getElementById('tilContent');
        const s = ta.selectionStart;
        ta.value = ta.value.slice(0, s) + prefix + ta.value.slice(ta.selectionEnd);
        ta.selectionStart = ta.selectionEnd = s + prefix.length;
        ta.focus();
    }

    function wrapMd(open, close) {
        const ta = document.getElementById('tilContent');
        const s = ta.selectionStart, e = ta.selectionEnd;
        const sel = ta.value.slice(s, e) || 'text';
        ta.value = ta.value.slice(0, s) + open + sel + close + ta.value.slice(e);
        ta.selectionStart = s + open.length;
        ta.selectionEnd = s + open.length + sel.length;
        ta.focus();
    }

    let showPreview = false;

    function togglePreview() {
        showPreview = !showPreview;
        const ta = document.getElementById('tilContent');
        const pre = document.getElementById('editorPreview');
        const btn = document.getElementById('previewBtn');
        if (showPreview) {
            pre.innerHTML = renderMarkdown(ta.value);
            pre.style.display = 'block';
            ta.style.display = 'none';
            btn.textContent = '✏️ 편집';
        } else {
            pre.style.display = 'none';
            ta.style.display = 'block';
            btn.textContent = '👁 미리보기';
        }
    }


    /* ── 키보드 / 오버레이 닫기 ── */
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') {
            closeEditor();
            closeDetail();
            closeConfirm();
        }
    });
    document.getElementById('tilEditorModal').addEventListener('click', e => {
        if (e.target === e.currentTarget) closeEditor();
    });
    document.getElementById('tilDetailModal').addEventListener('click', e => {
        if (e.target === e.currentTarget) closeDetail();
    });
    document.getElementById('confirmOverlay').addEventListener('click', e => {
        if (e.target === e.currentTarget) closeConfirm();
    });




</script>
</body>
</html>