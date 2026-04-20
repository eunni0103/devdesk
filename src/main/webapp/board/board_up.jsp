<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/board/board-all.css">

<html>
<head>
    <title>게시글 수정</title>
</head>
<body>
<div class="write-container">

    <h2>✏️ 게시글 수정하기</h2>

    <form action="board_update" method="post">
        <input type="hidden" name="board_id" value="${board.board_id}">

        <div class="board-form-group">
            <label>카테고리</label>
            <select name="category" required>
                <option value="자유토크" ${board.category == '자유토크' ? 'selected' : ''}>자유토크</option>
                <option value="TIL" ${board.category == 'TIL' ? 'selected' : ''}>TIL</option>
                <option value="이력서" ${board.category == '이력서' ? 'selected' : ''}>이력서</option>
                <option value="TIP" ${board.category == 'TIP' ? 'selected' : ''}>자기만의TIP</option>
            </select>
        </div>

        <div class="board-form-group">
            <label>제목</label>
            <input type="text" name="title" value="${board.title}" required>
        </div>

        <div class="board-form-group">
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 8px;">
                <label style="margin-bottom: 0;">내용</label>
                <div style="text-align: right;">
                    <label for="imageFile"
                           style="cursor: pointer; border: 1px solid #d1d5db; padding: 6px 12px; border-radius: 6px; background-color: #fff; font-size: 0.85rem; color: #495057; transition: all 0.2s ease-in-out; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                        <span style="margin-right: 4px;">📷</span>이미지 첨부
                    </label>
                    <input type="file" id="imageFile" style="display: none;" accept="image/*"/>
                </div>
            </div>
            <textarea name="content" rows="15" required>${board.content}</textarea>
        </div>

        <div class="form-actions">
            <button type="submit" class="submit-btn">수정 완료</button>
            <button type="button" class="cancel-btn" onclick="history.back()">취소</button>
        </div>
    </form>
    <script type="text/javascript">

    </script>
    <script src="${pageContext.request.contextPath}/js/board/board-up.js"></script>
</div>
</body>
</html>