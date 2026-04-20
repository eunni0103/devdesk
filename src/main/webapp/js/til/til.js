/* TAG_STATS, RAW_EVENTS, CTX_PATH 는 til2.jsp 인라인 스크립트에서 주입됩니다. */

const TAG_CONFIG = {
    'Java': {color: '#ff9f69', bg: 'rgba(255,159,105,0.12)'},
    'Spring': {color: '#56e39f', bg: 'rgba(86,227,159,0.12)'},
    'SQL': {color: '#4ecdc4', bg: 'rgba(78,205,196,0.12)'},
    'JavaScript': {color: '#ffd166', bg: 'rgba(255,209,102,0.12)'},
    'Git': {color: '#ff6b6b', bg: 'rgba(255,107,107,0.12)'},
    'Python': {color: '#5b7cf8', bg: 'rgba(91,124,248,0.12)'},
    'CSS': {color: '#8b6ef5', bg: 'rgba(139,110,245,0.12)'},
    'React': {color: '#4ecdc4', bg: 'rgba(78,205,196,0.12)'},
    '기타': {color: '#9da3b8', bg: 'rgba(157,163,184,0.12)'}
};

/* ── 도넛 차트 ── */
function drawDonut() {
    if (!TAG_STATS.length) return;
    var total = TAG_STATS.reduce(function (a, d) {
        return a + d.count;
    }, 0);
    var canvas = document.getElementById('donutCanvas');
    var ctx = canvas.getContext('2d');
    var cx = 65, cy = 65, r = 50, ir = 30, gap = 0.04;
    var angle = -Math.PI / 2;

    TAG_STATS.forEach(function (d) {
        var cfg = TAG_CONFIG[d.tag] || TAG_CONFIG['기타'];
        var sweep = (d.count / total) * Math.PI * 2 - gap;
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
    ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue('--surface') || '#141720';
    ctx.fill();

    document.getElementById('chartLegend').innerHTML = TAG_STATS.map(function (d) {
        var cfg = TAG_CONFIG[d.tag] || TAG_CONFIG['기타'];
        var pct = Math.round(d.count / total * 100);
        return '<div class="legend-row">' +
            '<div class="legend-dot" style="background:' + cfg.color + '"></div>' +
            '<span class="legend-name">' + d.tag + '</span>' +
            '<span class="legend-pct" style="color:' + cfg.color + '">' + pct + '%</span>' +
            '</div>';
    }).join('');
}

drawDonut();

/* ── 등록 / 수정 모달 ── */
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

/* ── 상세 모달 ── */
function openDetail(id) {
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
    let result = renderMarkdown(el.dataset.content);
    console.log(result)
    document.getElementById('detailContent').innerHTML = result
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

function escapeHtml(str) {
    return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}


/* ── 마크다운 렌더러 ── */
function renderMarkdown(text) {
    if (!text) return '<p style="color:var(--text3)">내용이 없어요.</p>';
    text = escapeHtml(text);
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
    var ta = document.getElementById('tilContent');
    var s = ta.selectionStart;
    ta.value = ta.value.slice(0, s) + prefix + ta.value.slice(ta.selectionEnd);
    ta.selectionStart = ta.selectionEnd = s + prefix.length;
    ta.focus();
}

function wrapMd(open, close) {
    var ta = document.getElementById('tilContent');
    var s = ta.selectionStart, e = ta.selectionEnd;
    var sel = ta.value.slice(s, e) || 'text';
    ta.value = ta.value.slice(0, s) + open + sel + close + ta.value.slice(e);
    ta.selectionStart = s + open.length;
    ta.selectionEnd = s + open.length + sel.length;
    ta.focus();
}

var showPreview = false;

function togglePreview() {
    showPreview = !showPreview;
    var ta = document.getElementById('tilContent');
    var pre = document.getElementById('editorPreview');
    var btn = document.getElementById('previewBtn');
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
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
        closeEditor();
        closeDetail();
        closeConfirm();
    }
});
document.addEventListener('DOMContentLoaded', function () {
    var tilEditorModal = document.getElementById('tilEditorModal');
    if (tilEditorModal) tilEditorModal.addEventListener('click', function (e) {
        if (e.target === e.currentTarget) closeEditor();
    });
    var tilDetailModal = document.getElementById('tilDetailModal');
    if (tilDetailModal) tilDetailModal.addEventListener('click', function (e) {
        if (e.target === e.currentTarget) closeDetail();
    });
    var confirmOverlay = document.getElementById('confirmOverlay');
    if (confirmOverlay) confirmOverlay.addEventListener('click', function (e) {
        if (e.target === e.currentTarget) closeConfirm();
    });
});

/* ==========================================
   미니 캘린더 렌더링 로직
========================================== */
document.addEventListener('DOMContentLoaded', function () {
    const eventCounts = {};

    // JSP에서 넘겨준 RAW_EVENTS가 정상적으로 있는지 확인 후 점 찍을 데이터 세팅
    if (typeof RAW_EVENTS !== 'undefined') {
        RAW_EVENTS.forEach(date => {
            if (date && date.trim() !== '') {
                const pureDate = date.split(' ')[0];
                eventCounts[pureDate] = (eventCounts[pureDate] || 0) + 1;
            }
        });
    }

    let currentDispDate = new Date();

    function renderMiniCalendar(date) {
        const year = date.getFullYear();
        const month = date.getMonth();

        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const prevMonthLastDay = new Date(year, month, 0).getDate();

        // 일요일(0) 시작
        let firstDayIndex = firstDay.getDay();

        const calTitle = document.getElementById('g-cal-title');
        if (calTitle) calTitle.textContent = year + '년 ' + (month + 1) + '월';

        let daysHTML = '';
        const today = new Date();
        const todayStr = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');

        // 지난 달
        for (let i = firstDayIndex; i > 0; i--) {
            // 🚨 수정 완료: \${prevMonthLastDay} -> ${prevMonthLastDay}
            daysHTML += `<div class="g-day-cell" onclick="location.href='${CTX_PATH}/calendar'">
                            <div class="g-day-num other-month">${prevMonthLastDay - i + 1}</div>
                         </div>`;
        }

        // 이번 달 (점 찍기 포함)
        for (let i = 1; i <= lastDay.getDate(); i++) {
            const dateStr = year + '-' + String(month + 1).padStart(2, '0') + '-' + String(i).padStart(2, '0');
            let isToday = (dateStr === todayStr) ? ' today' : '';
            let isSun = new Date(year, month, i).getDay() === 0 ? ' sun' : ''; // 일요일 빨간색

            let dotsHTML = '';
            if (eventCounts[dateStr]) {
                dotsHTML = '<div class="g-dots">';
                let dotCount = Math.min(eventCounts[dateStr], 3);
                for (let k = 0; k < dotCount; k++) {
                    dotsHTML += '<span class="g-dot"></span>';
                }
                dotsHTML += '</div>';
            }

            // 🚨 수정 완료: \${isToday}, \${isSun} 등 역슬래시 모두 제거!
            daysHTML += `<div class="g-day-cell" onclick="location.href='${CTX_PATH}/calendar'">
                            <div class="g-day-num${isToday}${isSun}">${i}</div>
                            ${dotsHTML}
                         </div>`;
        }

        // 다음 달
        const totalCells = firstDayIndex + lastDay.getDate();
        let nextMonthDay = 1;
        while (totalCells + nextMonthDay - 1 < 42) {
            // 🚨 수정 완료: \${nextMonthDay} -> ${nextMonthDay}
            daysHTML += `<div class="g-day-cell" onclick="location.href='${CTX_PATH}/calendar'">
                            <div class="g-day-num other-month">${nextMonthDay}</div>
                         </div>`;
            nextMonthDay++;
        }

        const calDays = document.getElementById('g-cal-days');
        if (calDays) calDays.innerHTML = daysHTML;
    }

    // 버튼 클릭 이벤트 연결
    const prevBtn = document.getElementById('g-prev-month');
    if (prevBtn) prevBtn.addEventListener('click', () => {
        currentDispDate.setMonth(currentDispDate.getMonth() - 1);
        renderMiniCalendar(currentDispDate);
    });

    const nextBtn = document.getElementById('g-next-month');
    if (nextBtn) nextBtn.addEventListener('click', () => {
        currentDispDate.setMonth(currentDispDate.getMonth() + 1);
        renderMiniCalendar(currentDispDate);
    });

    // 최초 화면 렌더링
    renderMiniCalendar(currentDispDate);
});