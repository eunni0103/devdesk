let currentBoardPage = 1;

$(document).ready(function () {
    // 필터/정렬 변경 시 1페이지부터 재조회
    $('#filterType, #filterResult, #sortOrder').on('change', function () {
        if (typeof activeSearchConditions !== 'undefined' && activeSearchConditions) {
            loadFilteredReviews(activeSearchConditions, 1);
        } else {
            loadReviews(1);
        }
    });

    // 초기 로드
    loadReviews(1);
});

function loadReviews(page) {
    currentBoardPage = page;

    $.ajax({
        url: contextPath + '/review/filter/ajax',
        type: 'get',
        dataType: 'json',
        data: {
            companyId: currentCompanyId || null,
            interviewType: $('#filterType').val(),
            result: $('#filterResult').val(),
            sort: $('#sortOrder').val(),
            page: page
        }
    }).done(function (data) {
        if (typeof activeSearchConditions !== 'undefined' && activeSearchConditions) return;
        renderReviews(data.reviews);
        renderPaging(data.totalPages);
    }).fail(function () {
        $('#reviewListArea').html('<div class="no-result">후기를 불러오는 중 오류가 발생했습니다.</div>');
    });
}

function renderReviews(reviews) {
    let container = $('#reviewListArea');
    container.empty();

    if (!reviews || reviews.length === 0) {
        container.html('<div class="no-result">조건에 맞는 후기가 없습니다.</div>');
        return;
    }

    let typeText = {CODING: '코딩테스트', TECH: '기술면접', PERSONAL: '인성면접', EXEC: '임원면접', GROUP: '그룹면접', PT: 'PT면접'};
    let resultText = {PASS: '합격', FAIL: '불합격', PENDING: '대기중'};
    let atmosText = {FRIENDLY: '화기애애', NORMAL: '보통', SERIOUS: '엄숙', PRESSURE: '압박'};
    let contactText = {EMAIL: '이메일', PHONE: '전화', WEBSITE: '채용 홈페이지', NONE: '연락 없음'};

    let html = '';
    $.each(reviews, function (i, r) {
        let dateStr = '';
        if (r.reviewCreatedDate) {
            let d = new Date(r.reviewCreatedDate);
            dateStr = d.getFullYear() + '년 ' + (d.getMonth() + 1) + '월 ' + d.getDate() + '일';
        }

        let ic = r.reviewInterviewerCount || 0;
        let sc = r.reviewStudentCount || 0;
        let interviewerStr = (ic > 0 || sc > 0)
            ? '면접관 ' + ic + '명 / 학생 ' + sc + '명'
            : '미응답';

        html += '<div class="card">'
            + '<div class="card-header">'
            + '  <div>'
            + '  <a href="' + contextPath + '/company-detail?companyId=' + r.reviewCompanyId + '">' + (r.companyName || '') + '</a>'
            + '  </div>'
            + '</div>'
            + '<h2 class="card-title">' + r.reviewTitle + '</h2>'
            + '<div class="card-body">'
            + '  <div class="avatar"></div>'
            + '  <div class="info-grid">'
            + '    <div class="info-row">'
            + '      <span class="info-label">면접관/학생</span>'
            + '      <span class="info-value">' + interviewerStr + '</span>'
            + '      <span class="info-label">연락 방법</span>'
            + '      <span class="tag">' + (contactText[r.reviewContactMethod] || '미응답') + '</span>'
            + (r.reviewRating > 0 ? '    <span class="info-label">기업평점</span>'
                + '    <span class="card-rating" style="display: inline-flex; align-items: center; gap: 1px;">'
                + (function () {
                    let stars = '';
                    for (let s = 1; s <= 5; s++) {
                        let isOn = s <= r.reviewRating;
                        stars += '<span class="card-star' + (isOn ? ' on' : '') + '" style="font-size: 0.9em; color: ' + (isOn ? '#ffd700' : '#ddd') + ';">★</span>';
                    }
                    return stars;
                })()
                + '      <span class="card-rating-num" style="margin-left: 4px; font-size: 0.85em; color: #666;">' + r.reviewRating + '.0</span>'
                + '    </span>' : '')
            + '    </div>'
            + '    <div class="info-row">'
            + '      <span class="info-label">분위기</span>'
            + '      <span class="info-value">' + (atmosText[r.reviewAtmosphere] || '미응답') + '</span>'
            + '      <span class="info-label">면접 유형</span>'
            + '      <span class="tag">' + (typeText[r.reviewInterviewType] || '미응답') + '</span>'
            + '    </div>'
            + '  </div>'
            + '</div>'
            + '<div class="read-more-container">'
            + '  <a href="' + contextPath + '/review/detail?reviewId=' + r.reviewId + '" class="read-more-btn">계속 읽기</a>'
            + '</div>'
            + '<div class="card-footer">'
            + '  <div class="footer-left">'
            + '    <span class="card-like">♥ <span class="like-num">' + r.reviewLikeCount + '</span></span>'
            + '  </div>'
            + '  <div class="footer-right"><span>' + dateStr + '</span></div>'
            + '</div>'
            + '</div>';
    });

    container.html(html);
}

function renderPaging(totalPages) {
    let pagingArea = $('#reviewPaging');
    pagingArea.empty();

    if (totalPages <= 1) return;

    let html = '';
    if (currentBoardPage > 1) {
        html += '<a class="page-btn" onclick="loadReviews(' + (currentBoardPage - 1) + ')">이전</a>';
    }
    for (let i = 1; i <= totalPages; i++) {
        html += '<a class="page-btn ' + (i === currentBoardPage ? 'active' : '') + '" onclick="loadReviews(' + i + ')">' + i + '</a>';
    }
    if (currentBoardPage < totalPages) {
        html += '<a class="page-btn" onclick="loadReviews(' + (currentBoardPage + 1) + ')">다음</a>';
    }
    pagingArea.html(html);
}