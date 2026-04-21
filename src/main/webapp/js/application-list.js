/*
 *  application_list.js
 *  ─────────────────────────────────────────
 *  JSP 맨 아래에서 로드 → 모든 DOM이 이미 존재.
 *  모달 표시/숨김은 jQuery로 직접 제어 (CSS class 의존 X).
 */

/* ══════════════════════════════
   1. DOM 캐시
══════════════════════════════ */
var $insertModal    = $('#insertModal');
var $insertForm     = $('#insertForm');
var $modalStage     = $('#modalStage');
var $modalApplyDate = $('#modalApplyDate');
var $interviewSec   = $('#interviewSection');
var $confirmOverlay = $('#confirmOverlay');
var $confirmMsg     = $('#confirmMsg');
var $deleteAppId    = $('#deleteAppId');

/* ══════════════════════════════
   2. STAGE 설정
══════════════════════════════ */
var STAGE_MAP = {
    APPLIED:          {label: '지원완료', icon: '📄', color: '#9da3b8', bg: 'rgba(157,163,184,0.12)', line: '#9da3b8'},
    DOCUMENT:         {label: '서류통과', icon: '📋', color: '#ffd166', bg: 'rgba(255,209,102,0.12)', line: '#ffd166'},
    FIRST_INTERVIEW:  {label: '1차 면접', icon: '🗣',  color: '#4ecdc4', bg: 'rgba(78,205,196,0.12)',  line: '#4ecdc4'},
    SECOND_INTERVIEW: {label: '2차 면접', icon: '💬', color: '#5b7cf8', bg: 'rgba(91,124,248,0.12)',  line: '#5b7cf8'},
    THIRD_INTERVIEW:  {label: '3차 면접', icon: '🔮', color: '#8b6ef5', bg: 'rgba(139,110,245,0.12)', line: '#8b6ef5'},
    PASS:             {label: '합격',     icon: '🎉', color: '#56e39f', bg: 'rgba(86,227,159,0.12)',  line: '#56e39f'},
    FAIL:             {label: '불합격',   icon: '💔', color: '#ff6b6b', bg: 'rgba(255,107,107,0.12)', line: '#ff6b6b'}
};

var INTERVIEW_STAGES = ['FIRST_INTERVIEW', 'SECOND_INTERVIEW', 'THIRD_INTERVIEW'];

/* ══════════════════════════════
   3. 카드 초기화
══════════════════════════════ */
$('[id^="init_status_"]').each(function () {
    var id  = this.id.replace('init_status_', '');
    var cfg = STAGE_MAP[this.value] || STAGE_MAP['APPLIED'];

    $('#badge_' + id)
        .text(cfg.icon + ' ' + cfg.label)
        .css({background: cfg.bg, color: cfg.color});
    $('#card_' + id).css('--stage-color', cfg.line);
    $('#status_text_' + id).text(cfg.label);
});

// 카운트
(function () {
    var counts = {};
    Object.keys(STAGE_MAP).forEach(function (k) { counts[k] = 0; });
    $('[id^="init_status_"]').each(function () {
        if (counts[this.value] !== undefined) counts[this.value]++;
    });
    Object.keys(counts).forEach(function (k) {
        $('#cnt-' + k).text(counts[k]);
    });
})();

/* ══════════════════════════════
   4. 등록 모달 — 열기 / 닫기
      display:flex ↔ display:none (jQuery 직접 제어)
══════════════════════════════ */
function openInsertModal() {
    $modalApplyDate.val(new Date().toISOString().split('T')[0]);
    $modalStage.val('APPLIED');
    $interviewSec.removeClass('visible');
    $insertModal.css('display', 'flex');   // 보이기
    $('body').css('overflow', 'hidden');
}

function closeInsertModal() {
    $insertModal.hide();                   // 숨기기
    $('body').css('overflow', '');
    $insertForm[0].reset();
    $interviewSec.removeClass('visible');
    if (typeof closeCompanyModal === 'function') closeCompanyModal();
}

$('#btnOpenInsert').on('click', openInsertModal);
$('#selectedCompanyName').on('click', function () {
    if (typeof openCompanyModal === 'function') openCompanyModal();
});
$('#btnOpenCompany').on('click', function () {
    if (typeof openCompanyModal === 'function') openCompanyModal();
});
$('#btnCloseInsert, #btnCancelInsert').on('click', closeInsertModal);
$insertModal.on('click', function (e) {
    if (e.target === this) closeInsertModal();
});

/* ══════════════════════════════
   5. 면접 일정 섹션 토글
══════════════════════════════ */
$modalStage.on('change', function () {
    if (INTERVIEW_STAGES.indexOf(this.value) !== -1) {
        $interviewSec.addClass('visible');
    } else {
        $interviewSec.removeClass('visible');
    }
});

/* ══════════════════════════════
   6. 삭제 확인 다이얼로그
══════════════════════════════ */
function openConfirm(appId, companyName) {
    $confirmMsg.text('"' + companyName + '" 지원 내역을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.');
    $deleteAppId.val(appId);
    $confirmOverlay.css('display', 'flex');
}

function closeConfirm() {
    $confirmOverlay.hide();
}

$('#cardGrid').on('click', '.btn-delete', function () {
    openConfirm($(this).data('app-id'), $(this).data('company'));
});
$('#btnCancelConfirm').on('click', closeConfirm);
$confirmOverlay.on('click', function (e) {
    if (e.target === this) closeConfirm();
});

/* ══════════════════════════════
   7. 단계 변경
══════════════════════════════ */
$('#cardGrid').on('click', '.btn-status', function () {
    var appId   = $(this).data('app-id');
    var current = $(this).data('status');
    var $badge  = $('#badge_' + appId);
    var $text   = $('#status_text_' + appId);
    var $select = $('#status_select_' + appId);

    $badge.hide();
    $text.hide();
    $select.show().val(current).focus();
    $select.off('change blur');

    $select.on('change', function () {
        $('<form method="post" action="application_update">' +
            '<input name="app_id" value="' + appId + '">' +
            '<input name="status" value="' + this.value + '">' +
          '</form>').appendTo('body').submit();
    });

    $select.on('blur', function () {
        var b = $badge, t = $text, s = $select;
        setTimeout(function () { s.hide(); b.show(); t.show(); }, 150);
    });
});

/* ══════════════════════════════
   8. 단계 필터링
══════════════════════════════ */
var activeFilter = null;

$('#stageBar').on('click', '.stage-chip', function () {
    var stage = $(this).find('[id^="cnt-"]').attr('id').replace('cnt-', '');

    if (activeFilter === stage) {
        // 같은 칩 다시 클릭 → 필터 해제 (전체 보기)
        activeFilter = null;
        $(this).removeClass('active');
        $('.app-card').show();
    } else {
        activeFilter = stage;
        $('.stage-chip').removeClass('active');
        $(this).addClass('active');

        $('.app-card').each(function () {
            var cardId = this.id.replace('card_', '');
            var cardStage = $('#init_status_' + cardId).val();
            if (cardStage === stage) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    }
});

/* ══════════════════════════════
   9. ESC 키
══════════════════════════════ */
$(document).on('keydown', function (e) {
    if (e.key === 'Escape') {
        closeInsertModal();
        closeConfirm();
    }
});

console.log('[application_list.js] loaded');

/* ══════════════════════════════
   EASTER EGG 3: 불합격 카드 클릭 → 위로 토스트
══════════════════════════════ */
(function () {
    var COMFORT_MSGS = [
        '괜찮아요, 다음 기회가 반드시 있어요 💪',
        '한 번의 불합격이 끝이 아니에요. 계속 도전해요! 🔥',
        '지금 이 경험이 당신을 더 강하게 만들 거예요 ✨',
        '포기하지 않는 사람이 결국 해내더라고요 🌟',
        '이 문이 닫혔다면, 더 좋은 문이 열릴 거예요 🚪'
    ];
    var toastTimer = null;

    $('#cardGrid').on('click', '.app-card', function (e) {
        if ($(e.target).closest('button, select, form, a').length) return;

        var cardId = this.id.replace('card_', '');
        if ($('#init_status_' + cardId).val() !== 'FAIL') return;

        var msg = COMFORT_MSGS[Math.floor(Math.random() * COMFORT_MSGS.length)];

        $('#comfort-toast').remove();
        clearTimeout(toastTimer);

        var toast = $('<div id="comfort-toast"></div>').text(msg).css({
            position: 'fixed',
            bottom: '36px',
            left: '50%',
            transform: 'translateX(-50%) translateY(16px)',
            background: 'linear-gradient(135deg, #8b6ef5, #ff6b6b)',
            color: '#fff',
            padding: '14px 26px',
            borderRadius: '14px',
            fontSize: '14px',
            fontWeight: '600',
            boxShadow: '0 8px 28px rgba(139,110,245,0.45)',
            zIndex: '9999',
            opacity: 0,
            transition: 'opacity 0.3s ease, transform 0.3s cubic-bezier(0.175,0.885,0.32,1.275)',
            whiteSpace: 'nowrap',
            pointerEvents: 'none'
        });

        $('body').append(toast);
        setTimeout(function () {
            toast.css({ opacity: 1, transform: 'translateX(-50%) translateY(0)' });
        }, 10);

        toastTimer = setTimeout(function () {
            toast.css({ opacity: 0, transform: 'translateX(-50%) translateY(16px)' });
            setTimeout(function () { toast.remove(); }, 320);
        }, 3500);
    });
})();
