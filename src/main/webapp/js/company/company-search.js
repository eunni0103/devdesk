$(function () {
    let totalCompanyCount = parseInt($('#resultCount').text()) || 0;
    initToggleBtns();
    initSearch();
    initClear(totalCompanyCount);
    // doSearch();
    $('#resultArea').html('<div class="cs-no-result">검색 조건을 선택하고 검색 버튼을 눌러주세요.</div>');
});

/* ===== 토글 버튼 (업종, 지역) ===== */
function initToggleBtns() {
    $(document).on('click', '.cs-opt-btn', function () {
        let container = $(this).closest('.cs-options');

        if ($(this).attr('data-value') === '') {
            container.find('.cs-opt-btn').removeClass('active');
            $(this).addClass('active');
            return;
        }
        container.find('.cs-opt-btn[data-value=""]').removeClass('active');
        $(this).toggleClass('active');

        if (container.find('.cs-opt-btn.active').length === 0) {
            container.find('.cs-opt-btn[data-value=""]').addClass('active');
        }
    });
}

/* ===== 검색 ===== */

let currentPage = 1;
let currentFilteredReviewPage = 1;
let activeSearchConditions = null;

function doSearch(page) {
    if (!page) page = 1;
    currentPage = page;

    let industries = [];
    $('#industryBtns .cs-opt-btn.active').each(function () {
        let val = $(this).attr('data-value');
        if (val) industries.push(val);
    });
    let locations = [];
    $('#locationBtns .cs-opt-btn.active').each(function () {
        let val = $(this).attr('data-value');
        if (val) locations.push(val);
    });

    $.ajax({
        url: $('#contextPath').val() + '/company-search/ajax',
        type: 'get',
        dataType: 'json',
        data: {
            companyName: $('#companyName').val(),
            companyIndustry: industries.join(','),
            companyLocation: locations.join(','),
            minRating: $('#minRating').val(),
            maxRating: $('#maxRating').val(),
            minSize: $('#minSize').val(),
            maxSize: $('#maxSize').val(),
            page: page
        }
    }).done(function (data) {
        $('#resultCount').text(data.totalCount);
        showResult(data.companies);
        renderPagination(data.totalPages);

        let conditions = {
            companyName: $('#companyName').val(),
            companyIndustry: industries.join(','),
            companyLocation: locations.join(','),
            minRating: $('#minRating').val(),
            maxRating: $('#maxRating').val(),
            companyIds: data.allCompanyIds ? data.allCompanyIds.join(',') : ''
        };
        if (data.totalCount > 0) {
            loadFilteredReviews(conditions, 1);
        } else {
            activeSearchConditions = null;
            $('#reviewListArea').html('<div class="no-result">검색된 면접 후기가 없습니다.</div>');
            $('#reviewPaging').empty();
        }
    });
}

function loadFilteredReviews(conditions, page) {
    activeSearchConditions = conditions;
    currentFilteredReviewPage = page;
    let cp = $('#contextPath').val();
    $.ajax({
        url: cp + '/review/filter/ajax',
        type: 'get',
        dataType: 'json',
        data: {
            companyIds: conditions.companyIds || '',
            companyName: conditions.companyName || '',
            companyIndustry: conditions.companyIndustry || '',
            companyLocation: conditions.companyLocation || '',
            minRating: conditions.minRating || '',
            maxRating: conditions.maxRating || '',
            interviewType: $('#filterType').val(),
            result: $('#filterResult').val(),
            sort: $('#sortOrder').val(),
            page: page
        }
    }).done(function (data) {
        console.log('[companySearch] review filter response:', data);
        try {
            renderReviews(data.reviews);
        } catch (e) {
            console.error('[companySearch] renderReviews error:', e);
        }
        renderFilteredPaging(data.totalPages);
    }).fail(function (xhr, status, err) {
        console.error('[companySearch] review filter AJAX failed:', xhr.status, status, err);
        $('#reviewListArea').html('<div class="no-result">후기를 불러오는 중 오류가 발생했습니다.</div>');
    });
}

function renderFilteredPaging(totalPages) {
    let pagingArea = $('#reviewPaging');
    pagingArea.empty();
    if (totalPages <= 1) return;

    let html = '';
    if (currentFilteredReviewPage > 1) {
        html += '<a class="page-btn" onclick="loadFilteredReviews(activeSearchConditions, ' + (currentFilteredReviewPage - 1) + ')">이전</a>';
    }
    for (let i = 1; i <= totalPages; i++) {
        html += '<a class="page-btn ' + (i === currentFilteredReviewPage ? 'active' : '') + '" onclick="loadFilteredReviews(activeSearchConditions, ' + i + ')">' + i + '</a>';
    }
    if (currentFilteredReviewPage < totalPages) {
        html += '<a class="page-btn" onclick="loadFilteredReviews(activeSearchConditions, ' + (currentFilteredReviewPage + 1) + ')">다음</a>';
    }
    pagingArea.html(html);
}

function renderPagination(totalPages) {
    if (totalPages <= 1) {
        $('#companyPaging').empty();
        return;
    }

    let html = '';
    if (currentPage > 1) {
        html += '<button class="cs-page" onclick="doSearch(' + (currentPage - 1) + ')">이전</button>';
    }

    for (let i = 1; i <= totalPages; i++) {
        html += '<button class="cs-page ' + (i === currentPage ? 'active' : '')
            + '" onclick="doSearch(' + i + ')">' + i + '</button>';
    }

    if (currentPage < totalPages) {
        html += '<button class="cs-page" onclick="doSearch(' + (currentPage + 1) + ')">다음</button>';
    }

    $('#companyPaging').html(html);
}

// 검색 버튼은 항상 1페이지부터
function initSearch() {
    $('#searchBtn').on('click', function () {
        doSearch(1);
    });

    $('#companyName').on('keypress', function (e) {
        if (e.which === 13) doSearch(1);
    });
}

/* ===== 결과 카드 렌더링 ===== */
function showResult(data) {
    let container = $('#resultArea');
    container.empty();

    if (!data || data.length === 0) {
        container.html('<div class="cs-no-result">검색 결과가 없습니다.</div>');
        return;
    }

    let role = $('#userRole').val();
    let html = '<div class="cs-grid">';

    $.each(data, function (i, c) {
        let rating = c.calcRating || 0;
        let stars = '';
        for (let s = 1; s <= 5; s++) {
            stars += '<span class="' + (s <= rating ? 'on' : '') + '">★</span>';
        }

        let editLink = '';
        if (role === 'ADMIN') {
            editLink = '<span class="cs-action" onclick="event.preventDefault(); location.href=\'/company/edit?companyId=' + c.companyId + '\'">수정</span>';
        }

        html += '<a class="cs-card" href="/company-detail?companyId=' + c.companyId + '">'
            + '<div class="cs-card-top">'
            + '  <div class="cs-logo">' + c.companyName.substring(0, 1) + '</div>'
            + '  <div class="cs-info">'
            + '    <p class="cs-name">' + c.companyName + '</p>'
            + '    <span class="cs-industry-text">' + c.companyIndustry + ' · ' + c.companyLocation + '</span>'
            + '  </div>'
            + '</div>'
            + '<div class="cs-card-body">'
            + '  <div class="cs-meta-item">'
            + '    <span class="cs-meta-label">평점</span>'
            + '    <span class="cs-stars">' + stars + '</span>'
            + '  </div>'
            + '  <div class="cs-meta-item">'
            + '    <span class="cs-meta-label">규모</span>'
            + '    <span class="cs-meta-value">' + c.companySize.toLocaleString() + '명</span>'
            + '  </div>'
            + '  <div class="cs-actions">'
            + editLink
            + '    <span class="cs-action primary" onclick="event.preventDefault(); location.href=\'/review/write?companyId=' + c.companyId + '\'">후기쓰기</span>'
            + '  </div>'
            + '</div>'
            + '</a>';
    });

    html += '</div>';
    container.html(html);
}

/* ===== 조건 초기화 ===== */
function initClear(totalCompanyCount) {
    $('#clearBtn').on('click', function () {
        // 모든 입력 필드 및 버튼 상태 초기화
        $('.cs-options').each(function () {
            $(this).find('.cs-opt-btn').removeClass('active');
            $(this).find('.cs-opt-btn').first().addClass('active');
        });
        $('#companyName').val('');
        $('#minRating').val('0');
        $('#maxRating').val('5.0');
        $('#minSize').val('');
        $('#maxSize').val('');

        // 결과 영역을 초기 상태 메시지로 변경
        $('#resultArea').html('<div class="cs-no-result">검색 조건을 선택하고 검색 버튼을 눌러주세요.</div>');

        // 개수 표시를 초기 전체 개수로 복구
        $('#resultCount').text(totalCompanyCount);
        $('#companyPaging').empty();

    });

}
