/**
 * admin_company.js
 * 기업 정보 관리 페이지 전용 스크립트
 * 경로: src/main/webapp/js/admin/admin_company.js
 */

const AJAX_URL = contextPath + '/admin/company/ajax';

// ── 체크박스 ──────────────────────────────────────────
function toggleAll(master) {
    document.querySelectorAll('.company-check').forEach(cb => cb.checked = master.checked);
    onCheckChange();
}

function onCheckChange() {
    const checked = getChecked();
    const bar = document.getElementById('bulkBar');
    bar.style.display = checked.length >= 1 ? 'flex' : 'none';
    document.getElementById('selectedInfo').textContent = checked.length + '개 선택됨';
    // 2개 초과 선택 방지
    if (checked.length > 2) {
        const allChecked = document.querySelectorAll('.company-check:checked');
        allChecked[allChecked.length - 1].checked = false;
        alert('병합은 2개까지만 선택 가능합니다.');
        onCheckChange();
    }
}

function getChecked() {
    return [...document.querySelectorAll('.company-check:checked')];
}

// ── 승인 ──────────────────────────────────────────────
function approveCompany(id, name) {
    if (!confirm('【' + name + '】 기업을 승인하시겠습니까?\n승인 시 기업 검색 목록에 노출됩니다.')) return;
    callAjax({action: 'approve', companyId: id}, function (ok) {
        if (ok) {
            alert('승인 완료!');
            location.reload();
        } else alert('승인 처리 중 오류가 발생했습니다.');
    });
}

// ── 반려 ──────────────────────────────────────────────
function rejectCompany(id, name) {
    if (!confirm('【' + name + '】 기업을 반려(미승인)하시겠습니까?')) return;
    callAjax({action: 'reject', companyId: id}, function (ok) {
        if (ok) {
            alert('반려 처리 완료.');
            location.reload();
        } else alert('처리 중 오류가 발생했습니다.');
    });
}

// ── 삭제 ──────────────────────────────────────────────
function deleteCompany(id, name) {
    if (!confirm('⚠️ 【' + name + '】 기업을 삭제하시겠습니까?\n관련 리뷰도 함께 삭제됩니다. 이 작업은 되돌릴 수 없습니다.')) return;
    callAjax({action: 'delete', companyId: id}, function (ok) {
        if (ok) {
            alert('삭제 완료.');
            location.reload();
        } else alert('삭제 중 오류가 발생했습니다.');
    });
}

// ── 수정 모달 ─────────────────────────────────────────
function openEditModal(id, name, industry, location, rating, size) {
    document.getElementById('edit_companyId').value = id;
    document.getElementById('edit_name').value = name;
    document.getElementById('edit_industry').value = industry !== 'null' ? industry : '';
    document.getElementById('edit_location').value = location !== 'null' ? location : '';
    document.getElementById('edit_rating').value = rating;
    document.getElementById('edit_size').value = size;
    document.getElementById('editModal').style.display = 'flex';
}

function submitEdit() {
    const params = {
        action: 'update',
        companyId: document.getElementById('edit_companyId').value,
        companyName: document.getElementById('edit_name').value.trim(),
        companyIndustry: document.getElementById('edit_industry').value.trim(),
        companyLocation: document.getElementById('edit_location').value.trim(),
        companyRating: document.getElementById('edit_rating').value,
        companySize: document.getElementById('edit_size').value
    };
    if (!params.companyName) {
        alert('기업명을 입력해주세요.');
        return;
    }
    callAjax(params, function (ok) {
        if (ok) {
            alert('수정 완료!');
            location.reload();
        } else alert('수정 중 오류가 발생했습니다.');
    });
}

// ── 병합 모달 ─────────────────────────────────────────
let mergeData = [];

function openMergeModal() {
    const checked = getChecked();
    if (checked.length !== 2) {
        alert('기업을 정확히 2개 선택해주세요.');
        return;
    }

    mergeData = checked.map(cb => ({id: cb.value, name: cb.dataset.name}));

    document.getElementById('mergeName1').textContent = mergeData[0].name;
    document.getElementById('mergeId1').textContent = '(ID: ' + mergeData[0].id + ')';
    document.getElementById('mergeName2').textContent = mergeData[1].name;
    document.getElementById('mergeId2').textContent = '(ID: ' + mergeData[1].id + ')';

    document.querySelectorAll('input[name="keepCompany"]').forEach(r => r.checked = false);
    document.getElementById('mergeModal').style.display = 'flex';
}

function submitMerge() {
    const selected = document.querySelector('input[name="keepCompany"]:checked');
    if (!selected) {
        alert('남길 기업을 선택해주세요.');
        return;
    }

    const keepIdx = parseInt(selected.value) - 1;
    const deleteIdx = keepIdx === 0 ? 1 : 0;
    const keepId = mergeData[keepIdx].id;
    const deleteId = mergeData[deleteIdx].id;
    const keepName = mergeData[keepIdx].name;
    const delName = mergeData[deleteIdx].name;

    if (!confirm('【' + delName + '】을(를) 【' + keepName + '】으로 병합합니다.\n이 작업은 되돌릴 수 없습니다.')) return;

    callAjax({action: 'merge', keepId: keepId, deleteId: deleteId}, function (ok, msg) {
        if (ok) {
            alert('병합 완료!');
            location.reload();
        } else alert('병합 실패: ' + (msg || '오류가 발생했습니다.'));
    });
}

// ── 모달 닫기 ─────────────────────────────────────────
function closeModal(id) {
    document.getElementById(id).style.display = 'none';
}

// 모달 바깥 클릭 시 닫기
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', function (e) {
            if (e.target === this) this.style.display = 'none';
        });
    });
});

// ── 공통 AJAX 호출 ────────────────────────────────────
function callAjax(params, callback) {
    const body = new URLSearchParams(params);
    fetch(AJAX_URL, {method: 'POST', body: body})
        .then(res => res.json())
        .then(data => callback(data.success, data.msg))
        .catch(err => {
            console.error(err);
            callback(false, '네트워크 오류');
        });
}