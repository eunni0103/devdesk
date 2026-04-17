/* =========================================
   DevDesk 관리자 - 게시글 관리 JS (페이징 & 검색)
========================================= */

let currentPage = 1;
const rowsPerPage = 10; // 한 페이지에 10개씩 노출
let filteredRows = [];  // 검색 필터링된 행들을 담을 배열

document.addEventListener("DOMContentLoaded", function () {
    // 최초 로딩 시 테이블의 모든 <tr>을 가져와서 세팅
    const allRows = Array.from(document.querySelectorAll(".board-row"));
    filteredRows = allRows;
    renderTable();

    // 검색창 엔터키 이벤트 달아주기
    document.getElementById("boardSearch")?.addEventListener("keyup", function (e) {
        if (e.key === "Enter") searchBoard();
    });
});

// 🌟 1. 실시간 검색 기능
function searchBoard() {
    const keyword = document.getElementById("boardSearch").value.toLowerCase();
    const allRows = Array.from(document.querySelectorAll(".board-row"));

    // 제목이나 닉네임에 검색어가 포함된 행만 필터링
    filteredRows = allRows.filter(row => {
        const title = row.querySelector(".title-cell").innerText.toLowerCase();
        const nickname = row.querySelector(".nickname-cell").innerText.toLowerCase();
        return title.includes(keyword) || nickname.includes(keyword);
    });

    currentPage = 1; // 검색하면 무조건 1페이지로 리셋
    renderTable();
}

// 🌟 2. 테이블 화면 그리기 (페이징 자르기)
function renderTable() {
    const allRows = Array.from(document.querySelectorAll(".board-row"));
    // 일단 모든 행 숨기기
    allRows.forEach(row => row.style.display = "none");

    const totalPages = Math.ceil(filteredRows.length / rowsPerPage) || 1;
    const startIdx = (currentPage - 1) * rowsPerPage;
    const endIdx = startIdx + rowsPerPage;

    // 현재 페이지 번호에 해당하는 10개만 화면에 표시
    filteredRows.slice(startIdx, endIdx).forEach(row => {
        row.style.display = "";
    });

    renderPagination(totalPages);
}

// 🌟 3. 완벽하게 똑같은 보라색 꺾쇠 페이징 생성기
function renderPagination(totalPages) {
    const paginationWrapper = document.getElementById("board-pagination");
    paginationWrapper.innerHTML = ""; // 초기화

    if (totalPages <= 0) return;

    // ◀ 이전 버튼 (첫 페이지면 회색으로 비활성화)
    if (currentPage > 1) {
        const prevBtn = document.createElement("button");
        prevBtn.className = "page-btn";
        prevBtn.innerHTML = "&#8249;"; // 꺾쇠 아이콘 ‹
        prevBtn.onclick = () => {
            currentPage--;
            renderTable();
        };
        paginationWrapper.appendChild(prevBtn);
    } else {
        const prevDisabled = document.createElement("span");
        prevDisabled.className = "page-btn page-btn--disabled";
        prevDisabled.innerHTML = "&#8249;";
        paginationWrapper.appendChild(prevDisabled);
    }

    // 🌟 페이지 번호 (너무 많아지지 않게 최대 5개씩만 노출되도록 계산!)
    let startPage = Math.max(1, currentPage - 2);
    let endPage = Math.min(totalPages, startPage + 4);
    if (endPage - startPage < 4) {
        startPage = Math.max(1, endPage - 4);
    }

    for (let i = startPage; i <= endPage; i++) {
        const btn = document.createElement("button");
        // admin_company.css와 완벽 호환되는 클래스명 (page-btn--active)
        btn.className = `page-btn ${i === currentPage ? "page-btn--active" : ""}`;
        btn.innerText = i;
        btn.onclick = () => {
            currentPage = i;
            renderTable();
        };
        paginationWrapper.appendChild(btn);
    }

    // ▶ 다음 버튼 (마지막 페이지면 회색으로 비활성화)
    if (currentPage < totalPages) {
        const nextBtn = document.createElement("button");
        nextBtn.className = "page-btn";
        nextBtn.innerHTML = "&#8250;"; // 꺾쇠 아이콘 ›
        nextBtn.onclick = () => {
            currentPage++;
            renderTable();
        };
        paginationWrapper.appendChild(nextBtn);
    } else {
        const nextDisabled = document.createElement("span");
        nextDisabled.className = "page-btn page-btn--disabled";
        nextDisabled.innerHTML = "&#8250;";
        paginationWrapper.appendChild(nextDisabled);
    }
}

// 🌟 4. 게시글 강제 삭제 (비동기 처리)
function deleteBoard(boardId, title) {
    if (confirm(`🚨 정말로 [${title}] 게시글을 삭제하시겠습니까?\n(달려있는 댓글도 모두 삭제되며 복구 불가능합니다)`)) {

        fetch(window.location.pathname, {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: `action=delete&board_id=${boardId}`
        })
            .then(response => response.text())
            .then(data => {
                if (data.trim() === 'success') {
                    alert('🗑️ 게시글이 깔끔하게 삭제되었습니다!');
                    location.reload(); // 새로고침해서 리스트 갱신
                } else {
                    alert('❌ 삭제 실패 (DB 에러 또는 이미 지워진 글입니다.)');
                }
            });
    }
}