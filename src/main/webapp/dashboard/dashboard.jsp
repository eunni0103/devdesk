<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="color-scheme" content="light">
    <title>대시보드 — 취뽀 워크스페이스</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Gowun+Batang:wght@400;700&family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="css/workspace-ui.css">
    <link rel="stylesheet" href="css/til.css">
    <link rel="stylesheet" href="css/index.css">
    <link rel="stylesheet" href="css/dashboard.css">
    <link rel="stylesheet" href="css/sidebar.css">
    <script>
        const TAG_STATS = [];
        const RAW_EVENTS = [];
        const CTX_PATH = '${pageContext.request.contextPath}';
    </script>
    <script src="js/til/til.js"></script>
</head>
<body>
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
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item active">
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


        <div id="sidebar-mini-calendar">
            <div class="g-cal-header">
                <div class="g-cal-title" id="g-cal-title">2026년 4월</div>
                <div class="g-cal-nav">
                    <button class="g-nav-btn" id="g-prev-month">‹</button>
                    <button class="g-nav-btn" id="g-next-month">›</button>
                </div>
            </div>
            <div class="g-cal-weekdays">
                <div>일</div>
                <div>월</div>
                <div>화</div>
                <div>수</div>
                <div>목</div>
                <div>금</div>
                <div>토</div>
            </div>
            <div class="g-cal-days" id="g-cal-days">
            </div>
        </div>
    </aside>

    <!-- ════════════════════════════
         본문
    ════════════════════════════ -->
    <main class="content-area">

        <!-- 헤더 -->
        <div class="dash-header">
            <div>
                <h1 class="dash-title">안녕하세요, ${sessionScope.user.nickname}님 👋</h1>
                <p class="dash-sub">
                    <%-- Java에서 넘겨준 오늘 날짜 문자열 --%>
                    ${todayStr}
                </p>
            </div>
            <div class="dash-header-actions">
                <a href="application-list" class="btn btn-ghost btn-sm">지원 현황 관리</a>
                <button onclick="openTilEditor()" class="btn btn-primary btn-sm">+ TIL 작성</button>
            </div>
        </div>

        <!-- ── 단계 요약 스트립 ────────────────────────── -->
        <%--
          Java(Servlet)에서 StageCountVO stageCounts 를 request에 담아서 전달.

          [StageCountVO.java]
            public class StageCountVO {
                private int applied;        // 이력서 제출
                private int documentPass;   // 서류 합격
                private int firstInterview; // 1차 면접
                private int secondInterview;// 2차 면접
                private int thirdInterview; // 3차 면접
                private int codingTest;     // 코딩테스트
                private int passed;         // 합격
                // + getter / setter
            }

          [DashboardServlet.java]
            StageCountVO stageCounts = new StageCountVO();
            stageCounts.setApplied(appDao.countByStage("APPLIED", memberId));
            stageCounts.setDocumentPass(appDao.countByStage("DOCUMENT_PASS", memberId));
            stageCounts.setFirstInterview(appDao.countByStage("FIRST_INTERVIEW", memberId));
            stageCounts.setSecondInterview(appDao.countByStage("SECOND_INTERVIEW", memberId));
            stageCounts.setThirdInterview(appDao.countByStage("THIRD_INTERVIEW", memberId));
            stageCounts.setCodingTest(appDao.countByStage("CODING_TEST", memberId));
            stageCounts.setPassed(appDao.countByStage("PASSED", memberId));
            request.setAttribute("stageCounts", stageCounts);
        --%>
        <div class="stage-strip">

            <a href="application-list?stage=APPLIED" class="stage-chip" style="--chip-color:#9da3b8">
                <span class="stage-chip-icon">📄</span>
                <span class="stage-chip-name">이력서 제출</span>
                <span class="stage-chip-count">${stageCounts.applied}</span>
                <span class="stage-chip-unit">회</span>
            </a>

            <a href="application-list?stage=DOCUMENT" class="stage-chip" style="--chip-color:#ffd166">
                <span class="stage-chip-icon">✅</span>
                <span class="stage-chip-name">서류 합격</span>
                <span class="stage-chip-count">${stageCounts.documentPass}</span>
                <span class="stage-chip-unit">회</span>
            </a>

            <a href="application-list?stage=FIRST_INTERVIEW" class="stage-chip" style="--chip-color:#4ecdc4">
                <span class="stage-chip-icon">🗣</span>
                <span class="stage-chip-name">1차 면접</span>
                <span class="stage-chip-count">${stageCounts.firstInterview}</span>
                <span class="stage-chip-unit">회</span>
            </a>

            <a href="application-list?stage=SECOND_INTERVIEW" class="stage-chip" style="--chip-color:#5b7cf8">
                <span class="stage-chip-icon">💬</span>
                <span class="stage-chip-name">2차 면접</span>
                <span class="stage-chip-count">${stageCounts.secondInterview}</span>
                <span class="stage-chip-unit">회</span>
            </a>

            <a href="application-list?stage=THIRD_INTERVIEW" class="stage-chip" style="--chip-color:#8b6ef5">
                <span class="stage-chip-icon">🔮</span>
                <span class="stage-chip-name">3차 면접</span>
                <span class="stage-chip-count">${stageCounts.thirdInterview}</span>
                <span class="stage-chip-unit">회</span>
            </a>

            <a href="application-list?stage=PASS" class="stage-chip" style="--chip-color:#56e39f">
                <span class="stage-chip-icon">🎉</span>
                <span class="stage-chip-name">합격</span>
                <span class="stage-chip-count">${stageCounts.passed}</span>
                <span class="stage-chip-unit">회</span>
            </a>


        </div>


        <!-- ── 2×2 카드 그리드 ────────────────────────── -->
        <div class="dash-grid">

            <!-- ① 전환율 파이프라인 ─────────────────────── -->
            <%--
              Java에서 List<Map> funnelData 전달.
              각 Map: { fromLabel, toLabel, fromColor, toColor, pct }
            --%>
            <div class="card dash-card" style="animation-delay:.05s">
                <div class="card-title">전환율 파이프라인</div>

                <c:choose>
                    <c:when test="${empty funnelData}">
                        <div class="empty-state">
                            <div class="icon">📊</div>
                            <p>지원 데이터가 없습니다</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="row" items="${funnelData}">
                            <div class="funnel-row">
                                <div class="funnel-labels">
                                    <span>${row.fromLabel} → ${row.toLabel}</span>
                                    <span style="color:${row.toColor}; font-weight:600">${row.pct}%</span>
                                </div>
                                <div class="funnel-track">
                                    <div class="funnel-fill"
                                         style="width:${row.pct}%;
                                                 background: linear-gradient(90deg, ${row.fromColor}, ${row.toColor})">
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- ② 예정 일정 ──────────────────────────────── -->
            <%--
              Java에서 List<ScheduleVO> upcomingSchedules 전달 (최대 5건, 오늘 이후).
              ScheduleVO 필드: scheduleId, company, type, date(String "MM월 dd일"), day(int), month(String), time, isToday(boolean)
            --%>
            <div class="card dash-card" style="animation-delay:.1s">
                <div class="card-title">
                    예정 일정
                    <a href="calendar" style="margin-left:auto; font-size:11px; color:var(--accent);
        letter-spacing:0; text-transform:none; font-weight:400">
                        전체 보기 →
                    </a>
                </div>

                <c:forEach var="s" items="${upcomingSchedules}">
                    <div class="sch-row">
                        <div class="sch-date">
                            <div class="sch-mon">${s.month}</div>
                            <div class="sch-day">${s.day}</div>
                        </div>
                        <div class="sch-vline"></div>
                        <div class="sch-info">
                            <div class="sch-company">${s.company}</div>
                            <div class="sch-time">⏰ ${empty s.time ? '시간 미정' : s.time}</div>
                        </div>
                        <span class="badge" style="background:${s.badgeBg}; color:${s.badgeColor}">
                                ${s.type}
                        </span>
                    </div>
                </c:forEach>

            </div>
        </div>

        <!-- ③ 최근 TIL ──────────────────────────────── -->
        <%--
          Java에서 List<TilVO> recentTils 전달 (최대 5건).
          TilVO 필드: tilId, title, tag, tagColor, tagBg, timeAgo
        --%>
        <div class="card dash-card" style="animation-delay:.15s">
            <div class="card-title">
                최근 TIL
                <a href="til-list"
                   style="margin-left:auto; font-size:11px; color:var(--accent);
                    letter-spacing:0; text-transform:none; font-weight:400">
                    전체 보기 →
                </a>
            </div>

            <c:choose>
                <c:when test="${empty recentTils}">
                    <div class="empty-state">
                        <div class="icon">📖</div>
                        <p>TIL을 작성해 보세요</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="t" items="${recentTils}" varStatus="vs">
                        <div class="til-row" id="til_data_${t.tilId}"
                             data-title="${fn:escapeXml(t.title)}"
                             data-tag="${t.tag}"
                             data-time="${t.studyTime}"
                             data-date="${t.timeAgo}"
                             data-content="${fn:escapeXml(t.content)}"
                             onclick="openDashTilDetail('${t.tilId}')">
                            <span class="til-num">${vs.count < 10 ? '0' : ''}${vs.count}</span>
                            <div class="til-dot" style="background:${t.tagColor}"></div>
                            <div class="til-info">
                                <div class="til-title">${t.title}</div>
                                <div class="til-meta">
                    <span class="badge"
                          style="background:${t.tagBg}; color:${t.tagColor};
                                  font-size:10px; padding:2px 7px">
                            ${t.tag}
                    </span>
                                    <span>${t.timeAgo}</span>
                                </div>
                            </div>
                            <span class="til-arrow">›</span>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ④ 이번 달 학습 분포 ──────────────────────── -->
        <%--
          Java에서 List<Map> tilTagStats 전달.
          각 Map: { tag, color, pct }
          도넛 차트는 나중에 Canvas로 그릴 자리.
          지금은 범례만 표시.
        --%>
        <div class="card dash-card" style="animation-delay:.2s">
            <div class="card-title">이번 달 학습 분포</div>

            <div class="chart-wrap">

                <%-- 기존 donut-placeholder 제거하고 아래로 교체 --%>
                <div class="donut-wrap" style="position:relative; width:140px; height:140px; flex-shrink:0;">
                    <canvas id="donutCanvas" width="140" height="140"></canvas>
                    <div class="donut-center-text"
                         style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;pointer-events:none;">
                        <div class="donut-num">${tilTagStats.size()}</div>
                        <div class="donut-label">총 항목</div>
                    </div>
                </div>

                <%-- 범례 --%>
                <div class="chart-legend">
                    <c:choose>
                        <c:when test="${empty tilTagStats}">
                            <p style="font-size:12px; color:var(--text3)">학습 데이터가 없어요</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="stat" items="${tilTagStats}">
                                <div class="legend-row">
                                    <div class="legend-dot" style="background:${stat.color}"></div>
                                    <span class="legend-name">${stat.tag}</span>
                                    <span class="legend-pct" style="color:${stat.color}">${stat.pct}%</span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>

</div>
<%-- /.dash-grid --%>
</main>

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


<%-- TIL 상세 모달 --%>
<div class="modal-overlay" id="tilDetailModal">
    <div class="modal modal-lg">
        <div class="modal-header">
            <div class="modal-title" id="detailTitle"></div>
            <button class="modal-close" onclick="closeDashTilDetail()">✕</button>
        </div>
        <div class="modal-body">
            <div id="detailMeta" style="margin-bottom:12px"></div>
            <div id="detailContent" style="line-height:1.7"></div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-ghost" onclick="closeDashTilDetail()">닫기</button>
        </div>
    </div>
</div>

<script>
    // 1. 도넛 차트 그리기
    (function () {
        var stats = [
            <c:forEach var="stat" items="${tilTagStats}" varStatus="loop">
            {tag: "${stat.tag}", color: "${stat.color}", pct: ${stat.pct}}<c:if test="${!loop.last}">, </c:if>
            </c:forEach>
        ];

        if (!stats.length) return;

        var canvas = document.getElementById("donutCanvas");
        if (!canvas) return;

        var ctx = canvas.getContext("2d");
        var cx = 70, cy = 70, outerR = 62, innerR = 38, gap = 0.03;
        var total = stats.reduce(function (a, s) {
            return a + s.pct;
        }, 0);
        var startAngle = -Math.PI / 2;

        stats.forEach(function (s) {
            var slice = (s.pct / total) * (Math.PI * 2);
            var endAngle = startAngle + slice - gap;
            ctx.beginPath();
            ctx.moveTo(cx + outerR * Math.cos(startAngle + gap / 2),
                cy + outerR * Math.sin(startAngle + gap / 2));
            ctx.arc(cx, cy, outerR, startAngle + gap / 2, endAngle);
            ctx.arc(cx, cy, innerR, endAngle, startAngle + gap / 2, true);
            ctx.closePath();
            ctx.fillStyle = s.color;
            ctx.fill();
            startAngle += slice;
        });
    })();

    // 2. TIL 모달 및 마크다운 관련 함수 모음 (TAG_CONFIG 는 til.js 에서 로드됨)
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

    function openDashTilDetail(id) {
        var el = document.getElementById('til_data_' + id);
        if (!el) return;
        var cfg = TAG_CONFIG[el.dataset.tag] || TAG_CONFIG['기타'];

        document.getElementById('detailTitle').textContent = el.dataset.title;
        document.getElementById('detailMeta').innerHTML =
            '<span class="badge" style="background:' + cfg.bg + ';color:' + cfg.color + '">' + el.dataset.tag + '</span>' +
            '<span style="font-size:12px;color:var(--text3);margin-left:8px">' + el.dataset.date + '</span>' +
            (el.dataset.time > 0
                ? '<span style="font-size:12px;color:var(--text3);margin-left:8px">⏱ ' + el.dataset.time + 'h</span>'
                : '');

        document.getElementById('detailContent').innerHTML = renderMarkdown(el.dataset.content);

        var editBtn = document.getElementById('detailEditBtn');
        if (editBtn) editBtn.href = 'til?id=' + id;

        var modal = document.getElementById('tilDetailModal');
        if (modal) modal.classList.add('open');
    }

    function closeDashTilDetail() {
        var modal = document.getElementById('tilDetailModal');
        if (modal) modal.classList.remove('open');
    }

    // ESC 키 & 오버레이 클릭으로 닫기
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') closeDashTilDetail();
    });

    var modalOverlay = document.getElementById('tilDetailModal');
    if (modalOverlay) {
        modalOverlay.addEventListener('click', function (e) {
            if (e.target === e.currentTarget) closeDashTilDetail();
        });
    }

    // 3. 대시보드 미니 캘린더 관련 스크립트 (점 찍는 기능 포함)
    document.addEventListener('DOMContentLoaded', function () {

        // 서버에서 받아온 면접 일정 리스트
        const rawEvents = [
            <c:forEach var="sch" items="${schList}">
            '<fmt:formatDate value="${sch.schedule_date}" pattern="yyyy-MM-dd" />',
            </c:forEach>
        ];

        // 날짜별로 일정이 몇 개인지 카운트 ({'2026-04-10': 2, '2026-04-15': 1 ...})
        const eventCounts = {};
        rawEvents.forEach(date => {
            if (date && date.trim() !== '') {
                const pureDate = date.split(' ')[0];
                eventCounts[pureDate] = (eventCounts[pureDate] || 0) + 1;
            }
        });

        let currentDispDate = new Date();
        const todayStr = '${todayStr}'; // 컨트롤러에서 내려주는 오늘 날짜 문자열

        // 달력을 그리는 핵심 함수
        function renderMiniCalendar(date) {
            const year = date.getFullYear();
            const month = date.getMonth();

            const firstDay = new Date(year, month, 1);
            const lastDay = new Date(year, month + 1, 0);
            const prevMonthLastDay = new Date(year, month, 0).getDate();
            let firstDayIndex = firstDay.getDay();

            const calTitle = document.getElementById('g-cal-title');
            if (calTitle) calTitle.textContent = year + '년 ' + (month + 1) + '월';

            let daysHTML = '';

            // 지난 달 날짜 (회색 처리)
            // 1. 이전 달 날짜 흐리게 채우기
            for (let i = firstDayIndex; i > 0; i--) {
                daysHTML += `<div class="g-day-cell" onclick="location.href='${pageContext.request.contextPath}/calendar'">
                                <div class="g-day-num other-month">\${prevMonthLastDay - i + 1}</div>
                             </div>`;
            }

            // 2. 이번 달 1일부터 말일까지 채우기 및 일정 점 찍기
            for (let i = 1; i <= lastDay.getDate(); i++) {
                const dateStr = year + '-' + String(month + 1).padStart(2, '0') + '-' + String(i).padStart(2, '0');
                let isToday = (dateStr === todayStr) ? ' today' : '';

                // 🚨 추가됨: 일요일(0)이면 'sun' 클래스를 추가해서 빨갛게 만듭니다!
                let isSun = new Date(year, month, i).getDay() === 0 ? ' sun' : '';

                let dotsHTML = '';
                if (eventCounts[dateStr]) {
                    dotsHTML = '<div class="g-dots">';
                    let dotCount = Math.min(eventCounts[dateStr], 3); // 최대 3개까지만 표시
                    for (let k = 0; k < dotCount; k++) {
                        dotsHTML += '<span class="g-dot"></span>';
                    }
                    dotsHTML += '</div>';
                }

                daysHTML += `<div class="g-day-cell" onclick="location.href='${CTX_PATH}/calendar'">
                                <div class="g-day-num\${isToday}\${isSun}">\${i}</div>
                                \${dotsHTML}
                              </div>`;
            }

            // 3. 달력 모양 유지를 위해 남은 빈칸은 다음 달 날짜로 채우기
            const totalCells = firstDayIndex + lastDay.getDate();
            let nextMonthDay = 1;
            while (totalCells + nextMonthDay - 1 < 42) {
                daysHTML += `<div class="g-day-cell" onclick="location.href='${pageContext.request.contextPath}/calendar'">
                                <div class="g-day-num other-month">\${nextMonthDay}</div>
                             </div>`;
                nextMonthDay++;
            }
            document.getElementById('g-cal-days').innerHTML = daysHTML;
        }

        // 이전 달 버튼 이벤트
        const prevBtn = document.getElementById('g-prev-month');
        if (prevBtn) {
            prevBtn.addEventListener('click', () => {
                currentDispDate.setMonth(currentDispDate.getMonth() - 1);
                renderMiniCalendar(currentDispDate);
            });
        }

        // 다음 달 버튼 이벤트
        const nextBtn = document.getElementById('g-next-month');
        if (nextBtn) {
            nextBtn.addEventListener('click', () => {
                currentDispDate.setMonth(currentDispDate.getMonth() + 1);
                renderMiniCalendar(currentDispDate);
            });
        }

        // 페이지 로드 시 최초 달력 렌더링
        renderMiniCalendar(currentDispDate);
    });

    /* til ── 등록 / 수정 모달 ── */
    function openTilEditor(id) {
        var form = document.getElementById('tilForm');
        document.getElementById('editorTitle').textContent = id ? 'TIL 수정' : 'TIL 작성';
        form.action = id ? 'til_update' : 'til_insert';

        document.getElementById('editorPreview').style.display = 'none';
        document.getElementById('tilContent').style.display = 'block';
        document.getElementById('previewBtn').textContent = '👁 미리보기';

        if (id) {
            var el = document.getElementById('til_data_' + id);
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


</script>
</body>
</html>
