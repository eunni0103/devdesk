/* =========================================
   DevDesk 관리자 - 신고 관리 JS (서버 페이징)
========================================= */

document.addEventListener("DOMContentLoaded", function () {
    renderReportPagination();
});

// 🌟 JSP에서 넘겨준 데이터를 읽어서 보라색 꺾쇠 페이징을 그리는 함수
function renderReportPagination() {
    const container = document.getElementById("report-pagination");
    if (!container) return;

    // JSP에서 data- 속성으로 넘겨준 값들 꺼내기
    const currentPage = parseInt(container.dataset.current) || 1;
    const totalPage = parseInt(container.dataset.total) || 1;

    if (totalPage <= 0) return; // 페이지가 없으면 그리지 않음

    const targetType = container.dataset.target || '';
    const status = container.dataset.status || '';
    const searchType = container.dataset.search || '';
    const keyword = container.dataset.keyword || '';

    // 🔗 파라미터를 유지하면서 이동할 URL을 만들어주는 헬퍼 함수
    function makeUrl(page) {
        let url = `report?p=${page}`;
        if (targetType) url += `&targetType=${targetType}`;
        if (status) url += `&status=${status}`;
        if (searchType) url += `&searchType=${searchType}`;
        if (keyword) url += `&keyword=${keyword}`;
        return url;
    }

    container.innerHTML = ""; // 기존 내용 초기화

    // ◀ 이전 버튼 (1페이지면 회색으로 비활성화)
    if (currentPage > 1) {
        const prevBtn = document.createElement("a");
        prevBtn.href = makeUrl(currentPage - 1);
        prevBtn.className = "page-btn";
        prevBtn.innerHTML = "&#8249;"; // 꺾쇠 아이콘 ‹
        container.appendChild(prevBtn);
    } else {
        const prevDisabled = document.createElement("span");
        prevDisabled.className = "page-btn page-btn--disabled";
        prevDisabled.innerHTML = "&#8249;";
        container.appendChild(prevDisabled);
    }

    // 🌟 페이지 번호 로직 (최대 5개까지만 보여주기)
    let startPage = Math.max(1, currentPage - 2);
    let endPage = Math.min(totalPage, startPage + 4);
    if (endPage - startPage < 4) {
        startPage = Math.max(1, endPage - 4);
    }

    for (let i = startPage; i <= endPage; i++) {
        const btn = document.createElement("a");
        btn.href = makeUrl(i);
        btn.className = `page-btn ${i === currentPage ? "page-btn--active" : ""}`;
        btn.innerText = i;
        container.appendChild(btn);
    }

    // ▶ 다음 버튼 (마지막 페이지면 회색으로 비활성화)
    if (currentPage < totalPage) {
        const nextBtn = document.createElement("a");
        nextBtn.href = makeUrl(currentPage + 1);
        nextBtn.className = "page-btn";
        nextBtn.innerHTML = "&#8250;"; // 꺾쇠 아이콘 ›
        container.appendChild(nextBtn);
    } else {
        const nextDisabled = document.createElement("span");
        nextDisabled.className = "page-btn page-btn--disabled";
        nextDisabled.innerHTML = "&#8250;";
        container.appendChild(nextDisabled);
    }


}