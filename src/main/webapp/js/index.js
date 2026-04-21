// $(".test").click(function () {
//     console.log($(".test").val());
//
//     if ($(".test").val() == 'night mode') {
//         $('body').css("background-color", "black").css("color", "#7c3aed");
//         $(".test").val("day mode");
//         $(".test").text("day mode"); // value가 없는 버튼은 text로 글자를 바꿔주면 됨
//     } else {
//         $('body').css("background-color", "white").css("color", "#7c3aed");
//         $(".test").val("night mode");
//         $(".test").text("night mode"); // value가 없는 버튼은 text로 글자를 바꿔주면 됨
//     }
// });
//
// $(document).ready(function () {
//     // 저장된 테마 불러오기
//     const savedTheme = localStorage.getItem('theme') || 'light';
//     applyTheme(savedTheme);
//
//     $(".test").click(function () {
//         const currentTheme = $("html").attr("data-theme") || 'light';
//         const newTheme = currentTheme === 'light' ? 'dark' : 'light';
//         applyTheme(newTheme);
//     });
//
//     function applyTheme(theme) {
//         $("html").attr("data-theme", theme);
//         localStorage.setItem('theme', theme);
//
//         if (theme === 'dark') {
//             $(".test").text("day mode");
//         } else {
//             $(".test").text("night mode");
//         }
//     }
// });

/* ═══════════════════════════════════════════════════
   EASTER EGG 1: 코나미 코드 → 합격 축하 애니메이션
   입력: ↑ ↑ ↓ ↓ ← → ← → B A
═══════════════════════════════════════════════════ */
(function () {
    var KONAMI = ['ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight', 'b', 'a'];
    var idx = 0;

    var style = document.createElement('style');
    style.textContent =
        '@keyframes konami-pop{from{opacity:0;transform:scale(0.3)}to{opacity:1;transform:scale(1)}}' +
        '@keyframes confetti-fall{to{top:110%;transform:rotate(720deg);opacity:0}}';
    document.head.appendChild(style);

    document.addEventListener('keydown', function (e) {
        if (e.key === KONAMI[idx]) {
            idx++;
            if (idx === KONAMI.length) {
                idx = 0;
                launchCelebration();
            }
        } else {
            idx = (e.key === KONAMI[0]) ? 1 : 0;
        }
    });

    function launchCelebration() {
        var overlay = document.createElement('div');
        overlay.id = 'konami-overlay';
        overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;z-index:99999;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,0.65);backdrop-filter:blur(5px);cursor:pointer;';

        var msg = document.createElement('div');
        msg.style.cssText = 'text-align:center;color:#fff;animation:konami-pop 0.5s cubic-bezier(0.175,0.885,0.32,1.275);pointer-events:none;';
        msg.innerHTML =
            '<div style="font-size:80px;margin-bottom:16px;">🎉</div>' +
            '<div style="font-size:34px;font-weight:800;margin-bottom:10px;text-shadow:0 2px 12px rgba(0,0,0,0.4);">합격을 기원합니다!</div>' +
            '<div style="font-size:16px;opacity:0.85;margin-bottom:28px;">당신의 노력은 반드시 빛을 발할 거예요 ✨</div>' +
            '<div style="font-size:12px;opacity:0.45;">아무 곳이나 클릭하면 닫힙니다</div>';

        overlay.appendChild(msg);
        document.body.appendChild(overlay);

        var colors = ['#ff6b6b', '#ffd166', '#06d6a0', '#118ab2', '#8b6ef5', '#56e39f', '#ff9f1c', '#f72585'];
        for (var i = 0; i < 90; i++) {
            var el = document.createElement('div');
            var size = Math.random() * 10 + 6;
            el.style.cssText =
                'position:absolute;top:-20px;' +
                'left:' + (Math.random() * 100) + '%;' +
                'width:' + size + 'px;height:' + size + 'px;' +
                'background:' + colors[Math.floor(Math.random() * colors.length)] + ';' +
                'border-radius:' + (Math.random() > 0.5 ? '50%' : '2px') + ';' +
                'animation:confetti-fall ' + (Math.random() * 2 + 2) + 's ' + (Math.random() * 2.5) + 's ease-in forwards;' +
                'transform:rotate(' + (Math.random() * 360) + 'deg);pointer-events:none;';
            overlay.appendChild(el);
        }

        overlay.addEventListener('click', function () {
            overlay.remove();
        });
        setTimeout(function () {
            if (overlay.parentNode) overlay.remove();
        }, 7000);
    }
})();

/* ═══════════════════════════════════════════════════
   EASTER EGG 2: DevDesk 로고 10회 클릭 → 팀 크레딧 모달
═══════════════════════════════════════════════════ */
(function () {
    var clickCount = 0;
    var timer = null;

    $(document).ready(function () {
        $('.title a').on('click', function (e) {
            e.preventDefault();
            clickCount++;
            clearTimeout(timer);
            timer = setTimeout(function () {
                clickCount = 0;
            }, 3000);

            if (clickCount >= 10) {
                clickCount = 0;
                showCredits();
            }
        });
    });

    function showCredits() {
        if ($('#credits-modal').length) return;

        var modal = $(
            '<div id="credits-modal" style="position:fixed;top:0;left:0;width:100%;height:100%;z-index:99999;background:rgba(0,0,0,0.7);backdrop-filter:blur(6px);display:flex;align-items:center;justify-content:center;">' +
            '<div style="background:var(--surface,#fff);border-radius:20px;padding:40px 36px;max-width:420px;width:90%;text-align:center;color:var(--text,#1a202c);box-shadow:0 25px 60px rgba(0,0,0,0.35);animation:konami-pop 0.4s cubic-bezier(0.175,0.885,0.32,1.275);">' +
            '<div style="font-size:52px;margin-bottom:12px;">👨\u200d💻</div>' +
            '<div style="font-size:24px;font-weight:800;color:var(--accent,#8e5ae5);margin-bottom:4px;">DevDesk</div>' +
            '<div style="font-size:12px;color:var(--text3,#a0aec0);margin-bottom:28px;">© 2026 Team 오조사마(SM1004)</div>' +
            '<div style="display:flex;flex-direction:column;gap:10px;margin-bottom:24px;text-align:left;">' +
            '<div style="background:var(--surface2,#f8fafc);border-radius:10px;padding:13px 16px;font-size:13px;color:var(--text,#1a202c);">🏗️ <strong>동균</strong> — 지원 현황 · 이력서 폼 · TIL </div>' +
            '<div style="background:var(--surface2,#f8fafc);border-radius:10px;padding:13px 16px;font-size:13px;color:var(--text,#1a202c);">🎨 <strong>선민</strong> — 자유게시판 · 공통 레이아웃 · 공통css</div>' +
            '<div style="background:var(--surface2,#f8fafc);border-radius:10px;padding:13px 16px;font-size:13px;color:var(--text,#1a202c);">🎨 <strong>지영</strong> — Calendar · 면접 일정 · 구글 api 연동</div>' +
            '<div style="background:var(--surface2,#f8fafc);border-radius:10px;padding:13px 16px;font-size:13px;color:var(--text,#1a202c);">🎨 <strong>상준</strong> — Review · Company Search · 비동기 필터링 </div>' +
            '<div style="background:var(--surface2,#f8fafc);border-radius:10px;padding:13px 16px;font-size:13px;color:var(--text,#1a202c);">🎨 <strong>영은</strong> — 회원관리 시스템 · 소셜 로그인 · 마이페이지&관리자</div>' +
            '</div>' +
            '<div style="font-size:12px;color:var(--text3,#a0aec0);margin-bottom:22px;">취업 준비, 함께라서 덜 외로웠어요 🤝</div>' +
            '<button id="credits-close" style="background:var(--accent,#8e5ae5);color:#fff;border:none;border-radius:10px;padding:11px 32px;font-size:14px;font-weight:700;cursor:pointer;">닫기</button>' +
            '</div></div>'
        );

        $('body').append(modal);
        modal.on('click', function (e) {
            if (e.target === this) modal.remove();
        });
        $('#credits-close').on('click', function () {
            modal.remove();
        });
    }
})();

$(document).ready(function () {
    const savedTheme = localStorage.getItem('theme') || 'light';
    applyTheme(savedTheme);

    // .test 버튼을 클릭했을 때 아이콘과 테마 변경
    $(".test").click(function () {
        const currentTheme = $("html").attr("data-theme") || 'light';
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        applyTheme(newTheme);
    });

    function applyTheme(theme) {
        $("html").attr("data-theme", theme);
        localStorage.setItem('theme', theme);

        // 아이콘 제어를 위해 버튼에도 상태 클래스를 추가해줍니다.
        if (theme === 'dark') {
            $(".test").addClass("is-dark");
        } else {
            $(".test").removeClass("is-dark");
        }
    }
});

