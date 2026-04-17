<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>DevDesk</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/user/account-success.css">
</head>
<body>

<div class="signup-wrapper">
    <div class="signup-card success-card">

        <div class="logo-container">
            <div class="success-brand">
                <img src="${pageContext.request.contextPath}/images/DevDesk_new.png" alt="DevDesk Logo">
                <span>DevDesk</span>
            </div>
        </div>

        <h2 class="success-title">회원가입 완료</h2>

        <p class="success-message">
            <strong class="highlight-name">${welcomeName}</strong>님의 회원가입이<br>
            성공적으로 완료되었습니다.
        </p>

        <button type="button" class="btn-login" onclick="location.href='login'">
            로그인 바로가기
        </button>

    </div>
</div>

</body>
</html>