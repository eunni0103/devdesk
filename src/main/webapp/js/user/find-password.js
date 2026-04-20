// DOM 로드 후 실행 (안정성 ↑)
document.addEventListener("DOMContentLoaded", function () {

    // 비밀번호 요소들
    const pwInput = document.getElementById('new_password');
    const confirmInput = document.getElementById('confirm_password');
    const pwMatchMsg = document.getElementById('pwMatchMsg');
    const submitBtn = document.getElementById('submitBtn');

    // 비밀번호 일치 확인
    if (pwInput && confirmInput) {
        function checkMatch() {
            if (confirmInput.value === '') {
                pwMatchMsg.innerText = '';
                submitBtn.disabled = true;
                return;
            }

            if (pwInput.value === confirmInput.value) {
                pwMatchMsg.style.color = '#7C3AED';
                pwMatchMsg.innerText = '비밀번호가 일치합니다.';
                submitBtn.disabled = false;
            } else {
                pwMatchMsg.style.color = '#FF4D4F';
                pwMatchMsg.innerText = '비밀번호가 일치하지 않습니다.';
                submitBtn.disabled = true;
            }
        }

        pwInput.addEventListener('input', checkMatch);
        confirmInput.addEventListener('input', checkMatch);
    }

});


// 모달 함수 (전역에서 쓰기 위해 밖에 둠)
function showModal(msg, redirectUrl, showBackButton = false) {
    const modalOverlay = document.getElementById('customAlertModal');
    const modalMessage = document.getElementById('customModalMessage');
    const modalConfirmBtn = document.getElementById('customModalConfirmBtn');
    const modalBackBtn = document.getElementById('customModalBackBtn');

    if (!modalOverlay || !modalMessage) return;

    modalMessage.innerText = msg;
    modalOverlay.style.display = 'flex';

    // 이전 버튼
    if (showBackButton) {
        modalBackBtn.style.display = 'block';
        modalBackBtn.onclick = function () {
            modalOverlay.style.display = 'none';
            history.back();
        };
    } else {
        modalBackBtn.style.display = 'none';
    }

    // 확인 버튼
    modalConfirmBtn.onclick = function () {
        modalOverlay.style.display = 'none';
        if (redirectUrl) {
            window.location.href = redirectUrl;
        }
    };
}