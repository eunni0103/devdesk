/* ═══════════════════════════════
   RESUME BLOCK LIBRARY — JS
═══════════════════════════════ */

const ctx = document.querySelector('meta[name="ctx"]')?.content || '';

/* ── Tab 전환 ── */
function switchTab(tabName) {
    document.querySelectorAll('.rb-tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.rb-panel').forEach(p => p.classList.remove('active'));
    document.querySelector('.rb-tab[data-tab="' + tabName + '"]').classList.add('active');
    document.getElementById('panel-' + tabName).classList.add('active');
}

/* ── Toast ── */
function showToast(msg) {
    const t = document.getElementById('rbToast');
    t.textContent = msg;
    t.classList.add('show', 'success');
    setTimeout(() => t.classList.remove('show', 'success'), 2000);
}

/* ── 클립보드 복사 ── */
function copyText(text) {
    if (!text || text.trim() === '') {
        showToast('복사할 내용이 없습니다');
        return;
    }
    navigator.clipboard.writeText(text).then(() => {
        showToast('클립보드에 복사되었습니다');
    }).catch(() => {
        // fallback
        const ta = document.createElement('textarea');
        ta.value = text;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
        showToast('클립보드에 복사되었습니다');
    });
}

/* ── 블록 내용 복사 (data-content 속성에서) ── */
function copyBlock(blockId) {
    const el = document.querySelector('[data-block-id="' + blockId + '"] .rb-card-preview');
    if (el) {
        copyText(el.getAttribute('data-full-content'));
    }
}

/* ── 즐겨찾기 토글 (AJAX) ── */
function toggleStar(blockId) {
    $.post(ctx + '/resume-block-star', {blockId: blockId}, function (data) {
        if (data.success) {
            location.reload();
        }
    }, 'json');
}

/* ── 모달 열기/닫기 ── */
function openModal() {
    document.getElementById('rbModalOverlay').classList.add('open');
}

function closeModal() {
    document.getElementById('rbModalOverlay').classList.remove('open');
}

// 오버레이 클릭으로 닫기
document.addEventListener('DOMContentLoaded', function () {
    const overlay = document.getElementById('rbModalOverlay');
    if (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) closeModal();
        });
    }
});

/* ── 새 블록 추가 모달 ── */
function openNewBlockModal() {
    const html = `
        <div class="modal-header">
            <span class="modal-title">새 블록 추가</span>
            <button class="modal-close" onclick="closeModal()">✕</button>
        </div>
        <form action="${ctx}/resume-block-add" method="post">
            <div class="form-group">
                <label class="form-label">카테고리</label>
                <select name="categoryId" class="form-select" required>
                    <option value="shimei">지원 동기</option>
                    <option value="jikopr">자기 PR</option>
                    <option value="chosho">성격의 장단점</option>
                    <option value="keireki">직무 경험</option>
                    <option value="other">그 외</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">제목</label>
                <input type="text" name="title" class="form-input" 
                       placeholder="예: A회사 지망동기" required>
            </div>
            <div class="form-group">
                <label class="form-label">내용</label>
                <textarea name="content" class="form-textarea" rows="6"
                          placeholder="내용을 작성하세요..."
                          oninput="updateCharCount(this)" required></textarea>
                <div style="text-align:right;margin-top:4px">
                    <span class="rb-char-count" id="modalCharCount">0자</span>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">태그 (쉼표 구분)</label>
                    <input type="text" name="tags" class="form-input" placeholder="IT, 공통">
                </div>
                <div class="form-group">
                    <label class="form-label">글자 수 제한</label>
                    <input type="number" name="charLimit" class="form-input" value="400">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-ghost" onclick="closeModal()">취소</button>
                <button type="submit" class="btn btn-primary">저장</button>
            </div>
        </form>
    `;
    document.getElementById('rbModalBody').innerHTML = html;
    // form action에 ctx 적용
    const form = document.querySelector('#rbModalBody form');
    form.action = ctx + '/resume-block-add';
    openModal();
}

/* ── 블록 편집 모달 ── */
function openEditModal(blockId, categoryId, title, content, tags, charLimit) {
    const html = `
        <div class="modal-header">
            <span class="modal-title">블록 편집</span>
            <button class="modal-close" onclick="closeModal()">✕</button>
        </div>
        <form action="${ctx}/resume-block-update" method="post">
            <input type="hidden" name="blockId" value="${blockId}">
            <div class="form-group">
                <label class="form-label">카테고리</label>
                <select name="categoryId" class="form-select" id="editCat">
                    <option value="shimei">지원 동기</option>
                    <option value="jikopr">자기PR</option>
                    <option value="chosho">성격의 장단점</option>
                    <option value="keireki">직무 경험</option>
                    <option value="other">기타</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">제목</label>
                <input type="text" name="title" class="form-input" id="editTitle" required>
            </div>
            <div class="form-group">
                <label class="form-label">내용</label>
                <textarea name="content" class="form-textarea" rows="6" id="editContent"
                          oninput="updateCharCount(this)" required></textarea>
                <div style="text-align:right;margin-top:4px">
                    <span class="rb-char-count" id="modalCharCount">0자</span>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">태그 (쉼표 구분)</label>
                    <input type="text" name="tags" class="form-input" id="editTags">
                </div>
                <div class="form-group">
                    <label class="form-label">글자 수 제한</label>
                    <input type="number" name="charLimit" class="form-input" id="editCharLimit">
                </div>
            </div>
            <div class="modal-footer" style="justify-content:space-between">
                <button type="button" class="btn btn-danger" onclick="deleteBlock(${blockId})">삭제</button>
                <div style="display:flex;gap:8px">
                    <button type="button" class="btn btn-ghost" onclick="closeModal()">취소</button>
                    <button type="submit" class="btn btn-primary">저장</button>
                </div>
            </div>
        </form>
    `;
    document.getElementById('rbModalBody').innerHTML = html;

    // form action 및 hidden input에 ctx 적용
    const form = document.querySelector('#rbModalBody form');
    form.action = ctx + '/resume-block-update';
    form.querySelector('input[name="blockId"]').value = blockId;

    // 삭제 버튼 재바인딩 (blockId 문자열 이스케이프 문제 방지)
    form.querySelector('.btn-danger').onclick = function () {
        deleteBlock(blockId);
    };

    // 값 채우기
    document.getElementById('editCat').value = categoryId;
    document.getElementById('editTitle').value = title;
    document.getElementById('editContent').value = content;
    document.getElementById('editTags').value = tags || '';
    document.getElementById('editCharLimit').value = charLimit;
    document.getElementById('modalCharCount').textContent = content.length + '자';
    openModal();
}

/* ── 블록 삭제 ── */
function deleteBlock(blockId) {
    if (!confirm('이 블록을 삭제하시겠습니까?\n버전 히스토리도 함께 삭제됩니다.')) return;

    const form = document.createElement('form');
    form.method = 'POST';
    form.action = ctx + '/resume-block-delete';

    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'blockId';
    input.value = blockId;
    form.appendChild(input);

    document.body.appendChild(form);
    form.submit();
}

/* ── 글자 수 카운터 ── */
function updateCharCount(textarea) {
    const count = textarea.value.length;
    const el = document.getElementById('modalCharCount');
    if (el) el.textContent = count + '자';
}

/* ── 버전 히스토리 모달 (AJAX) ── */
function openVersionModal(blockId) {
    document.getElementById('rbModalBody').innerHTML =
        '<div style="text-align:center;padding:40px;color:var(--text3)">로딩 중...</div>';
    openModal();

    $.get(ctx + '/resume-block-versions', {blockId: blockId}, function (data) {
        const block = data.block;
        const versions = data.versions;

        let html = `
            <div class="modal-header">
                <span class="modal-title">${escHtml(block.title)} — 버전 히스토리</span>
                <button class="modal-close" onclick="closeModal()">✕</button>
            </div>
        `;

        if (versions.length >= 2) {
            html += `<div style="margin-bottom:16px">
                <button class="btn btn-ghost btn-sm" onclick="openCompareView(${blockId})">
                    최신 2개 버전 비교
                </button>
            </div>`;
        }

        versions.forEach(function (v) {
            html += `
                <div class="rb-version-item">
                    <div class="rb-version-header">
                        <span class="rb-version-label">v${v.versionNum} · ${formatDate(v.createdDate)}</span>
                        <button class="btn btn-ghost btn-sm" onclick="copyText('${escJs(v.content)}')">복사</button>
                    </div>
                    <div class="rb-version-text">${escHtml(v.content)}</div>
                </div>
            `;
        });

        html += `<div class="modal-footer">
            <button class="btn btn-ghost" onclick="closeModal()">닫기</button>
        </div>`;

        document.getElementById('rbModalBody').innerHTML = html;
    }, 'json');
}

/* ── 버전 비교 ── */
function openCompareView(blockId) {
    $.get(ctx + '/resume-block-versions', {blockId: blockId}, function (data) {
        const block = data.block;
        const versions = data.versions;

        if (versions.length < 2) return;

        const newer = versions[0];
        const older = versions[1];

        let html = `
            <div class="modal-header">
                <span class="modal-title">${escHtml(block.title)} — 버전 비교</span>
                <button class="modal-close" onclick="closeModal()">✕</button>
            </div>
            <div class="rb-compare">
                <div class="rb-compare-col">
                    <div class="rb-compare-title">v${older.versionNum} · ${formatDate(older.createdDate)}</div>
                    <div class="rb-compare-text">${escHtml(older.content)}</div>
                </div>
                <div class="rb-compare-col">
                    <div class="rb-compare-title">v${newer.versionNum} · ${formatDate(newer.createdDate)} (최신)</div>
                    <div class="rb-compare-text">${escHtml(newer.content)}</div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-ghost" onclick="openVersionModal(${blockId})">돌아가기</button>
            </div>
        `;
        document.getElementById('rbModalBody').innerHTML = html;
    }, 'json');
}

/* ── 이력서 조합: 블록 선택 ── */
function selectCompose(catId) {
    const sel = document.getElementById('compose-sel-' + catId);
    const display = document.getElementById('compose-content-' + catId);
    const bid = sel.value;

    if (!bid) {
        display.textContent = '블록을 선택해주세요';
        display.classList.remove('filled');
        return;
    }

    // allBlocks 데이터에서 찾기 (JSP에서 전역 변수로 주입)
    if (typeof allBlocksData !== 'undefined') {
        const block = allBlocksData.find(b => b.blockId == bid);
        if (block) {
            display.textContent = block.content;
            display.classList.add('filled');
        }
    }
}

/* ── 이력서 조합: 항목별 복사 ── */
function copyCompose(catId) {
    const display = document.getElementById('compose-content-' + catId);
    if (!display.classList.contains('filled')) {
        showToast('먼저 블록을 선택해주세요');
        return;
    }
    copyText(display.textContent);
}

/* ── 이력서 조합: 전체 복사 ── */
function copyAllCompose() {
    const categories = [
        {id: 'shimei', label: '지원 동기'},
        {id: 'jikopr', label: '자기 PR'},
        {id: 'chosho', label: '성격의 장단점'},
        {id: 'keireki', label: '직무 경험'}
    ];

    let texts = [];
    categories.forEach(function (cat) {
        const el = document.getElementById('compose-content-' + cat.id);
        if (el && el.classList.contains('filled')) {
            texts.push('【' + cat.label + '】\n' + el.textContent);
        }
    });

    if (texts.length === 0) {
        showToast('선택된 블록이 없습니다');
        return;
    }

    copyText(texts.join('\n\n'));
}

/* ── Utility ── */
function escHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;')
        .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function escJs(str) {
    if (!str) return '';
    return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'")
        .replace(/\n/g, '\\n').replace(/\r/g, '');
}

function formatDate(dateStr) {
    if (!dateStr) return '';
    // Oracle DATE 포맷에 따라 조정
    return dateStr.substring(0, 10);
}
