let currentFilterPage = 1;

$(document).ready(function () {
// 필터/정렬 변경 시
    $('#filterType, #filterResult, #sortOrder').on('change', function () {
        currentFilterPage = 1;
        loadFilteredReviews(1);
    });
});

function loadFilteredReviews(page) {
    currentFilterPage = page;

    $.ajax({
        url: contextPath + '/review/filter/ajax',
        type: 'get',
        dataType: 'json',
        data: {
            companyId: companyId,
            interviewType: $('#filterType').val(),
            result: $('#filterResult').val(),
            sort: $('#sortOrder').val(),
            page: page
        }
    }).done(function (data) {
        renderReviewCards(data.reviews);
        renderReviewPaging(data.totalPages);
        $('.cd-count').text('총 ' + data.totalCount + '건의 후기');
    });
}

function renderReviewCards(reviews) {
    let container = $('#reviewListArea');
    container.empty();

    if (!reviews || reviews.length === 0) {
        container.html('<div class="no-result">조건에 맞는 후기가 없습니다.</div>');
        return;
    }

    let typeText = {CODING: '코딩테스트', TECH: '기술면접', PERSONAL: '인성면접', EXEC: '임원면접', GROUP: '그룹면접', PT: 'PT면접'};
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
            + (r.reviewRating > 0 ? '    <span class="card-rating">'
                + (function () {
                    let stars = '';
                    for (let s = 1; s <= 5; s++) {
                        stars += '<span class="card-star ' + (s <= r.reviewRating ? 'on' : '') + '">★</span>';
                    }
                    return stars;
                })()
                + '      <span class="card-rating-num">' + r.reviewRating + '.0</span>'
                + '    </span>' : '')
            + '  </div>'
            + '  <div class="footer-right"><span>' + dateStr + '</span></div>'
            + '</div>'
            + '</div>';
    });

    container.html(html);
}

function renderReviewPaging(totalPages) {
    let pagingArea = $('#reviewPaging');
    pagingArea.empty();

    if (totalPages <= 1) return;

    let html = '';
    if (currentFilterPage > 1) {
        html += '<a class="cd-page" onclick="loadFilteredReviews(' + (currentFilterPage - 1) + ')">이전</a>';
    }
    for (let i = 1; i <= totalPages; i++) {
        html += '<a class="cd-page ' + (i === currentFilterPage ? 'active' : '') + '" onclick="loadFilteredReviews(' + i + ')">' + i + '</a>';
    }
    if (currentFilterPage < totalPages) {
        html += '<a class="cd-page" onclick="loadFilteredReviews(' + (currentFilterPage + 1) + ')">다음</a>';
    }
    pagingArea.html(html);
}
