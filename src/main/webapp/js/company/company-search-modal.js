// 1. 미니 모달 열기/닫기


function openCompanyModal() {
    $('#companySearchModal').css('display', 'flex');
}

function closeCompanyModal() {
    $('#companySearchModal').hide();
}

// 2. 회사 검색 (기존 Ajax 컨트롤러 재사용)
function searchMiniCompany() {
    console.log('search func?')
    let keyword = $('#miniSearchInput').val();
    let url = $('#contextPath').val() + '/company-search/ajax';
    console.log(url)
    $.ajax({
        url: url,
        type: 'GET',
        data: {companyName: keyword}, // 이름만 보내서 검색
        dataType: 'json'
    }).done(function (res) {
        let html = '';
        if (res.companies.length > 0) {
            // 검색 결과가 있으면 리스트 출력
            res.companies.forEach(c => {
                // 선택 시 부모 폼에 값을 꽂아주는 함수 호출
                let safeName = c.companyName.replace(/'/g, "\\'");
                html += `<li><a href="#" onclick="selectCompany(${c.companyId}, '${safeName}')">${c.companyName}</a></li>`;
            });
        } else {
            // ★ 핵심 로직: 결과가 없으면 '직접 등록' 버튼을 동적으로 생성 ★
            html += `<p>검색 결과가 없습니다.</p>`;
            html += `<button type="button" onclick="directInsertCompany('${keyword}')"> '${keyword}' 직접 등록하고 선택하기 </button>`;
        }
        $('#miniResultList').html(html);
    }).fail(function (err) {
        console.log("검색 요청 실패", err);
    });
}

// 3. 기존 회사 선택 시 (정상 흐름)
function selectCompany(id, name) {
    // 부모 창(리뷰 작성 폼 등)의 input에 값 세팅
    $('#selectedCompanyId').val(id);     // hidden input (DB 저장용 FK)
    $('#selectedCompanyName').val(name); // text input (사용자 노출용)
    closeCompanyModal();
}

// 4. 직접 등록 로직 (선(先) 등록, 후(後) 검수)
function directInsertCompany(newCompanyName) {
    $.ajax({
        // 이 컨트롤러는 새로 하나 만드셔야 합니다 (이름과 is_verified='N'만 insert 하고 ID를 반환하는 용도)
        url: $('#contextPath').val() + '/company-search/direct-insert/ajax',
        type: 'POST',
        data: {companyName: newCompanyName},
        dataType: 'json'
    }).done(function (res) {
        if (res.newId) {
            selectCompany(res.newId, newCompanyName);
            alert("임시 기업으로 등록되어 선택되었습니다. 관리자 승인 후 정식 노출됩니다.");
        } else {
            alert("등록 중 오류가 발생했습니다.");
        }
    }).fail(function (err) {
            console.error("임시 등록 실패:", err);
            alert("임시 기업 등록에 실패했습니다.");
        }
    );
}