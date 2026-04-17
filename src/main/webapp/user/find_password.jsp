<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 컨트롤러에서 넘겨준 step 값으로 어느 단계를 보여줄지 결정
    String step = (String) request.getAttribute("step");    // "reset" or null
    boolean isReset = "reset".equals(step);
%>
<html>
<head>
    <meta charset="utf-8">
    <title>DevDesk - 비밀번호 찾기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/user/account.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/user/find-password.css">
</head>
<body class="account-body">

<div class="signup-wrapper">
    <div class="signup-card">

        <% if (!isReset) { %>

        <div class="signup-header">
            <h2>비밀번호 찾기</h2>
            <p>가입 시 등록한 닉네임과 이메일을 입력해주세요.</p>
        </div>

        <form action="find-password" method="post" class="signup-form">
            <div class="form-group">
                <label>닉네임 <span class="required">*</span></label>
                <input type="text" name="nickname" placeholder="가입 시 사용한 닉네임" required>
            </div>

            <div class="form-group">
                <label>이메일 (아이디) <span class="required">*</span></label>
                <input type="email" name="email" placeholder="example@gmail.com" required>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit">본인 확인</button>
                <button type="button" class="btn-cancel" onclick="history.back()">돌아가기</button>
            </div>
        </form>

        <% } else { %>

        <div class="signup-header">
            <h2>비밀번호 재설정</h2>
            <p>새로운 비밀번호를 입력해주세요.</p>
        </div>

        <form action="find-password?step=reset" method="post" class="signup-form" id="resetForm">
            <div class="form-group">
                <label>새 비밀번호 <span class="required">*</span></label>
                <input type="password" name="new_password" id="new_password"
                       placeholder="문자, 숫자, 특수문자 포함 8~20자" required>
            </div>

            <div class="form-group">
                <label>새 비밀번호 확인 <span class="required">*</span></label>
                <input type="password" name="confirm_password" id="confirm_password"
                       placeholder="비밀번호를 한 번 더 입력해주세요" required>
                <span id="pwMatchMsg" class="check-msg"></span>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn-submit" id="submitBtn" disabled>비밀번호 재설정</button>
            </div>
        </form>

        <% } %>

    </div>
</div>

<div id="customAlertModal" class="custom-modal-overlay">
    <div class="custom-modal-content">
        <p id="customModalMessage" class="custom-modal-text"></p>
        <div class="custom-modal-btns">
            <button id="customModalConfirmBtn" class="custom-modal-btn">확인</button>
            <button id="customModalBackBtn" class="custom-modal-btn-back" style="display: none;">이전</button>
        </div>
    </div>
</div>

<script>
    // 1. 비밀번호 일치 확인 로직
    const pwInput = document.getElementById('new_password');
    const confirmInput = document.getElementById('confirm_password');
    const pwMatchMsg = document.getElementById('pwMatchMsg');
    const submitBtn = document.getElementById('submitBtn');

    if (confirmInput) {
        function checkMatch() {
            if (confirmInput.value === '') {
                pwMatchMsg.innerText = '';
                submitBtn.disabled = true;
                return;
            }
            if (pwInput.value === confirmInput.value) {
                pwMatchMsg.style.color = '#7C3AED';
                pwMatchMsg.innerText = '비밀번호가 일치합니다.';
                if (submitBtn) submitBtn.disabled = false;
            } else {
                pwMatchMsg.style.color = '#FF4D4F';
                pwMatchMsg.innerText = '비밀번호가 일치하지 않습니다.';
                if (submitBtn) submitBtn.disabled = true;
            }
        }

        pwInput.addEventListener('input', checkMatch);
        confirmInput.addEventListener('input', checkMatch);
    }
</script>

<script src="${pageContext.request.contextPath}/js/user/find-password.js"></script>

<script>
    // 2. 모달창 띄우기 함수 (CSS 클래스 버전에 맞춤)
    function showModal(msg, redirectUrl, showBackButton = false) {
        const modalOverlay = document.getElementById('customAlertModal');
        const modalMessage = document.getElementById('customModalMessage');
        const modalConfirmBtn = document.getElementById('customModalConfirmBtn');
        const modalBackBtn = document.getElementById('customModalBackBtn');

        if (!modalOverlay || !modalMessage) return;

        modalMessage.innerText = msg;
        modalOverlay.style.display = 'flex'; // CSS에서 display:none 이었던 것을 flex로 변경하여 보여줌

        // "이전" 버튼 표시 여부
        if (showBackButton) {
            modalBackBtn.style.display = 'block';
            modalBackBtn.onclick = function () {
                modalOverlay.style.display = 'none';
                history.back(); // 이전 페이지로 이동
            };
        } else {
            modalBackBtn.style.display = 'none';
        }

        // "확인" 버튼 클릭 이벤트
        modalConfirmBtn.onclick = function () {
            modalOverlay.style.display = 'none';
            if (redirectUrl) {
                window.location.href = redirectUrl; // 지정된 URL이 있으면 리다이렉트
            }
        };
    }

    // 3. 컨트롤러에서 전달받은 메시지가 있을 경우 페이지 로드 시 모달 실행
    window.onload = function () {
        <% if (request.getAttribute("showErrorModal") != null) { %>
        // 에러 모달: 가입된 회원이 아닌 경우 "이전" 버튼도 함께 표시
        showModal('<%= request.getAttribute("showErrorModal") %>', null, true);
        <% } %>

        <% if (request.getAttribute("showSuccessModal") != null) { %>
        // 성공 모달: 확인 누르면 로그인 페이지로 리다이렉트
        showModal('비밀번호가 변경되었습니다.\n새로운 비밀번호로 로그인해주세요.', '${pageContext.request.contextPath}/login');
        <% } %>
    };
</script>

</body>
</html>