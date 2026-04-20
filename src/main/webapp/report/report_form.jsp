<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="../css/board/board-all.css">
<link rel="stylesheet" href="../css/report/report.css">

<div class="write-container" style="max-width: 600px; margin: 50px auto; padding: 20px;">
    <h2 style="margin-bottom: 24px;">신고하기</h2>

    <div class="report-notice">
        허위 신고 시 운영 정책에 따라 서비스 이용이 제한될 수 있습니다.<br>
        신고 내용은 관리자 검토 후 신속히 처리됩니다.
    </div>

    <form action="${pageContext.request.contextPath}/admin/report" method="post" onsubmit="return validateForm()">
        <%-- REVIEW_ID / BOARD_ID: targetType에 따라 하나만 값 세팅, 나머지는 빈 값 --%>
        <input type="hidden" name="reviewId" value="${param.targetType == 'review' ? param.targetId : ''}">
        <input type="hidden" name="boardId" value="${param.targetType == 'board'  ? param.targetId : ''}">
        <%-- MEMBER_ID는 서버에서 세션으로 처리 --%>

        <div class="report-target-info">
            <span class="report-type-badge ${param.targetType == 'review' ? 'review' : 'board'}">
                ${param.targetType == 'review' ? '리뷰' : '게시글'}
            </span>
            신고 대상: <span><c:out value="${param.targetTitle}"/></span>
        </div>

        <%-- REPO_REASON --%>
        <div class="board-form-group" style="margin-bottom: 20px;">
            <label style="display: block; margin-bottom: 8px; font-weight: 600;">신고 사유</label>
            <select name="repoReason" id="reportReason"
                    style="width: 100%; padding: 10px; border-radius: 4px; border: 1px solid #ddd;" required>
                <option value="">사유를 선택해 주세요</option>
                <option value="욕설/비방">부적절한 언어 (욕설/비방)</option>
                <option value="스팸/광고">스팸/영리적 광고</option>
                <option value="허위정보">잘못된 정보/허위 정보</option>
                <option value="개인정보노출">개인정보 노출 위험</option>
                <option value="기타">기타 사유</option>
            </select>
        </div>

        <%-- REPO_CONTENT --%>
        <div class="board-form-group" style="margin-bottom: 20px;">
            <label style="display: block; margin-bottom: 8px; font-weight: 600;">상세 내용 (최소 10자)</label>
            <textarea name="repoContent" id="reportContent" maxlength="500" rows="6"
                      placeholder="신고 내용을 구체적으로 입력해 주세요."
                      style="width: 100%; padding: 12px; border-radius: 4px; border: 1px solid #ddd; resize: vertical;"
                      required></textarea>
            <div class="report-char-count"><span id="cntSpan">0</span> / 500</div>
        </div>

        <div class="form-actions" style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 30px;">
            <button type="button" class="cancel-btn" onclick="history.back()">취소</button>
            <button type="submit" class="submit-btn">신고 제출</button>
        </div>
    </form>
</div>

<script src="../js/report-form.js"></script>