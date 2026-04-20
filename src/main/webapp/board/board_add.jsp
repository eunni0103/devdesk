<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/workspace-ui.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/board/board-all.css">
<div class="write-container">


    <h2>✍ 글 작성하기</h2>

    <form action="board_add" method="post">

        <!-- hidden: 컨트롤러 분기용 -->
        <input type="hidden" name="cmd" value="write">

        <!-- hidden: 로그인 사용자 ID -->
        <input type="hidden" name="member_id" value="${sessionScope.user.member_id}">

        <!-- 카테고리 -->
        <div class="board-form-group">
            <label>카테고리</label>
            <select name="category" required>
                <option value="">선택하세요</option>
                <option value="자유토크">자유토크</option>
                <option value="TIL">TIL</option>
                <option value="이력서">이력서</option>
                <option value="자기만의TIP">자기만의TIP</option>
            </select>
        </div>

        <!-- 제목 -->
        <div class="board-form-group">
            <label>제목</label>
            <input type="text" name="title" placeholder="제목을 입력하세요" required>
        </div>

        <!-- 내용 -->
        <div class="board-form-group">
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 8px;">
                <label style="margin-bottom: 0;">내용</label>
                <div style="text-align: right;">
                    <label for="imageFile"
                           style="cursor: pointer; border: 1px solid var(--border, #d1d5db); padding: 6px 12px; border-radius: 6px; background-color: var(--surface, #fff); font-size: 0.85rem; color: var(--text, #495057); transition: all 0.2s ease-in-out; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                        <span style="margin-right: 4px;">📷</span>이미지 첨부
                    </label>
                    <input type="file" id="imageFile" style="display: none;" accept="image/*"/>
                </div>
            </div>
            <textarea name="txt" maxlength="1500" rows="10" placeholder="내용을 입력하세요" required></textarea>
            <br> <span id="cntSpan">0</span> / 1500
        </div>

        <!-- 버튼 -->

        <div class="form-actions">
            <button type="submit" class="submit-btn">등록</button>
            <button type="button" class="cancel-btn" onclick="history.back()">취소</button>
        </div>
    </form>

    <script type="text/javascript">


    </script>
    <script src="${pageContext.request.contextPath}/js/board/board-add.js"></script>
</div>

