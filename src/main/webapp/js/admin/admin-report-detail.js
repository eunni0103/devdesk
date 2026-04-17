/* =========================================
   DevDesk 관리자 - 신고 상세 페이지 JS
   (경고창 및 페이지 이동 로직 전담)
========================================= */

document.addEventListener("DOMContentLoaded", function () {

    // 1. 원문(리뷰/게시글) 강제 삭제 폼 경고창
    const delContentForm = document.getElementById("deleteContentForm");
    if (delContentForm) {
        delContentForm.addEventListener("submit", function (e) {
            const isReview = this.dataset.type === 'review';
            const msg = (isReview ? "리뷰를 영구 삭제하시겠습니까?" : "게시글을 영구 삭제하시겠습니까?")
                + "\n신고글은 자동으로 처리완료로 변경됩니다.";
            if (!confirm("🚨 " + msg)) {
                e.preventDefault(); // 취소 누르면 삭제 멈춤!
            }
        });
    }

    // 2. 신고 내역 폐기 폼 경고창
    const delReportForm = document.getElementById("deleteReportForm");
    if (delReportForm) {
        delReportForm.addEventListener("submit", function (e) {
            if (!confirm("⚠️ 이 신고 내역만 목록에서 폐기하시겠습니까?")) {
                e.preventDefault();
            }
        });
    }

    // 3. '목록으로' 버튼 이동 이벤트
    const btnGoList = document.getElementById("btnGoList");
    if (btnGoList) {
        btnGoList.addEventListener("click", function () {
            // 버튼에 숨겨둔 URL(data-url)로 이동
            location.href = this.dataset.url;
        });
    }
});

// 게시글 content 안의 수파베이스 이미지 URL을 <img>로 변환
(function renderBoardContent() {
    const area = document.getElementById("boardContentArea");
    if (!area) return;

    // JSP에서 content를 data 속성으로 넘겨받음
    const raw = area.dataset.content || "";
    if (!raw) return;

    // URL 패턴을 찾아서 이미지면 <img>, 아니면 텍스트로 처리
    const imageExtensions = /\.(jpg|jpeg|png|gif|webp|svg)(\?.*)?$/i;
    const urlPattern = /(https?:\/\/[^\s]+)/g;

    const html = raw.replace(urlPattern, (url) => {
        if (imageExtensions.test(url)) {
            return `<img src="${url}" alt="첨부 이미지">`;
        }
        return `<a href="${url}" target="_blank" style="color:#7c3aed;">${url}</a>`;
    });

    // 줄바꿈 처리
    area.innerHTML = html.replace(/\n/g, "<br>");
})();