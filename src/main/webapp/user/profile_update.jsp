<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/user/mypage.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/user/profile-update.css">

<div class="mypage-wrapper">
    <h2 class="mypage-title">프로필 수정</h2>

    <form action="profile-update" method="post">
        <div class="update-container">

            <div class="photo-upload-section">
                <div class="profile-avatar large-avatar">
                    ${sessionScope.user.nickname.substring(0,1)}
                </div>
            </div>

            <div class="info-input-section">
                <div class="input-group static-group">
                    <p><strong>계정(이메일):</strong> ${sessionScope.user.email} <span class="badge-lock">(수정 불가)</span></p>
                </div>

                <div class="input-group">
                    <label for="nickname">닉네임</label>
                    <input type="text" id="nickname" name="nickname" value="${sessionScope.user.nickname}">
                </div>

                <div class="input-group">
                    <label for="job_category">관심 직무</label>
                    <select id="job_category" name="job_category">
                        <option value="프론트엔드" ${sessionScope.user.job_category == '프론트엔드' ? 'selected' : ''}>프론트엔드
                        </option>
                        <option value="백엔드" ${sessionScope.user.job_category == '백엔드' ? 'selected' : ''}>백엔드</option>
                        <option value="데이터/AI" ${sessionScope.user.job_category == '풀스택' ? 'selected' : ''}>데이터/AI
                        </option>
                        <option value="기획/디자인" ${sessionScope.user.job_category == '디자인' ? 'selected' : ''}>기획/디자인
                        </option>
                    </select>
                </div>
            </div>
        </div>

        <div class="update-actions">
            <button type="button" onclick="history.back()" class="btn-cancel">취소</button>
            <button type="submit" class="btn-submit">수정 완료</button>
        </div>
    </form>
</div>