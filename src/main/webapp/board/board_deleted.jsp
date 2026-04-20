<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link rel="stylesheet" href="../css/board/board-all.css">

<div class="board-container detail">
    <div class="board-header detail">
        <h2>게시글</h2>
        <div class="board-actions">
            <button class="write-btn" onclick="location.href='${pageContext.request.contextPath}/board'">목록으로</button>
        </div>
    </div>
    <div class="detail-view" style="text-align: center; padding: 60px 0; color: #888;">
        <p style="font-size: 18px; margin-bottom: 8px;">삭제된 게시글입니다.</p>
        <p style="font-size: 13px;">관리자에 의해 삭제되었거나 존재하지 않는 게시글입니다.</p>
    </div>
</div>