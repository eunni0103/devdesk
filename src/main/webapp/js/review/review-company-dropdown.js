$(document).on('input', '#companySearchInput', function () {
    const keyword = $(this).val().trim();
    const $dropdown = $(this).siblings('.company-dropdown');
    
    if (keyword.length < 1) {
        $dropdown.hide();
        return;
    }

    $.ajax({
        url: contextPath + '/company-search/ajax',
        type: 'get',
        dataType: 'json',
        data: {companyName: keyword}
    }).done(function (data) {
        let html = '';
        if (data.companies && data.companies.length > 0) {
            $.each(data.companies, function (i, c) {
                html += '<div class="dropdown-item" data-id="' + c.companyId
                    + '" data-name="' + c.companyName + '">'
                    + c.companyName
                    + '<span class="dropdown-meta">' + c.companyIndustry + '</span>'
                    + '</div>';
            });
        } else {
            html = '<div class="dropdown-item no-result">검색 결과가 없습니다.</div>';
        }
        $dropdown.html(html).show();
    });
});

$(document).on('click', '.dropdown-item', function () {
    if ($(this).hasClass('no-result')) return;
    
    const id = $(this).data('id');
    const name = $(this).data('name');
    const $group = $(this).closest('.field-group, .cal-form-group');
    
    $group.find('#selectedCompanyId').val(id);
    $group.find('#companySearchInput').val(name);
    $(this).closest('.company-dropdown').hide();
});

// 드롭다운 외부 클릭 시 닫기
$(document).on('click', function (e) {
    if (!$(e.target).closest('.company-dropdown, #companySearchInput').length) {
        $('.company-dropdown').hide();
    }
});
