<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/board/board-all.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/board/comment.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
<script>
    // JSP에서 EL 표현식으로 값을 읽어 전역 JS 변수로 설정 (외부 JS 파일에서 참조하기 위함)
    const GLOBAL_BOARD_ID = "${board.board_id}";
    const GLOBAL_MEMBER_ID = "${not empty sessionScope.user ? sessionScope.user.member_id : ''}";
    const GLOBAL_USER_NICKNAME = "${not empty sessionScope.user ? sessionScope.user.nickname : ''}";
</script>
<script src="${pageContext.request.contextPath}/js/board/board-detail.js" defer></script>


<html>
<head>
    <title>Title</title>
</head>
<body>
<div class="board-container">
    <div class="board-header">
        <h2>게시글 상세페이지</h2>
        <div class="board-actions">
            <!-- 좋아요 기능 -->
            <c:if test="${not empty sessionScope.user}">
                <div class="like-section">
                    <button type="button" class="like-btn" id="likeBtn" onclick="toggleLike()">
                        <span id="likeIcon">${isLiked ? '❤️' : '🤍'}</span>
                        <span id="likeCount">${board.like_count}</span>
                    </button>
                </div>
            </c:if>
            <button type="button" class="write-btn" onclick="location.href='board'">목록으로</button>
        </div>
    </div>

    <div class="detail-view">
        <div class="detail-row">
            <div class="detail-label">제목</div>
            <div class="detail-content title-bold"><c:out value="${board.title}"/></div>
        </div>

        <div class="detail-info-group">
            <div class="detail-row">
                <div class="detail-label">작성자</div>
                <div class="detail-content">(ID:
                    <span class="writer" data-id="${board.member_id}">
                        <c:out value="${board.nickname}"/>
                    </span>)
                </div>
            </div>
            <div class="detail-row">
                <div class="detail-label">작성일</div>
                <div class="detail-content">${board.created_date}</div>
            </div>
            <div class="detail-row">
                <div class="detail-label">조회수</div>
                <div class="detail-content">${board.view_count}</div>
            </div>
        </div>

        <div class="detail-row board-content-area">
            <div class="detail-label">내용</div>
            <div class="detail-content text-box"><c:out value="${board.content}"/></div>
        </div>
    </div>

    <div class="detail-buttons">
        <%-- 작성자 본인: 수정/삭제 --%>
        <c:if test="${sessionScope.user.member_id == board.member_id}">
            <button class="edit-btn" onclick="location.href='board_update?id=${board.board_id}'">수정</button>
            <button class="delete-btn" onclick="deleteBoard(${board.board_id})">삭제</button>
        </c:if>
        <%-- 로그인 했고, 본인 글이 아닌 경우에만 신고 버튼 표시 --%>
        <c:if test="${sessionScope.user != null && sessionScope.user.member_id != board.member_id}">
            <a href="${pageContext.request.contextPath}/report_form?targetType=board&targetId=${board.board_id}&targetTitle=${board.title}"
               class="delete-btn">신고</a>
        </c:if>
    </div>

    <div class="comment-section">
        <hr class="comment-divider">
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <h3 style="margin-bottom: 0;">댓글</h3>
            <button type="button" class="write-btn" onclick="location.href='board'" style="margin-right: 30px;">목록으로
            </button>
        </div>
        <hr class="comment-divider">

        <c:if test="${not empty sessionScope.user}">
            <div class="comment-form">
                <form id="commentForm">
                    <input type="hidden" name="board_id" value="${board.board_id}">
                    <input type="hidden" name="member_id" value="${sessionScope.user.member_id}">
                    <div class="comment-input-wrapper">
                        <textarea name="content" placeholder="댓글을 입력하세요" required></textarea>
                        <button type="submit">댓글 등록</button>
                    </div>
                </form>
            </div>
        </c:if>

        <div class="comment-list">
            <c:forEach var="comment" items="${commentList}">
                <!-- 부모 댓글만 표시 -->
                <c:if test="${empty comment.parent_id}">
                    <div class="comment-item" data-comment-id="${comment.comments_id}">
                        <div class="comment-info">
                            <span class="comment-writer">사용자(ID: <c:out value="${comment.nickname}"/>)</span>
                            <span class="comment-date">${comment.created_date}</span>
                        </div>
                        <div class="comment-content">
                                <c:out value="${comment.content}"/>
                        </div>

                        <button class="reply-btn"
                                onclick="showReplyForm(${comment.comments_id}, ${board.board_id}, '${sessionScope.user.member_id}')">
                            답글
                        </button>

                        <c:if test="${sessionScope.user.member_id == comment.member_id}">
                            <div class="comment-actions">
                                <button type="button" class="c-edit-btn"
                                        onclick="openEdit(${comment.comments_id})">수정
                                </button>
                                <button type="button" class="c-delete-btn"
                                        onclick="delComment(${comment.comments_id}, ${board.board_id})">삭제
                                </button>
                            </div>
                        </c:if>
                    </div>

                    <!-- 이 부모 댓글에 대한 대댓글 표시 -->
                    <c:forEach var="reply" items="${commentList}">
                        <c:if test="${reply.parent_id == comment.comments_id}">
                            <div class="reply-item" data-reply-id="${reply.comments_id}">
                                <div class="reply-info">
                                    <span class="reply-writer">사용자(ID: <c:out value="${reply.nickname}"/>)</span>
                                    <span class="reply-date">${reply.created_date}</span>
                                </div>
                                <div class="reply-content">
                                        <c:out value="${reply.content}"/>
                                </div>
                                <c:if test="${sessionScope.user.member_id == reply.member_id}">
                                    <div class="reply-actions">
                                        <button type="button" class="c-edit-btn"
                                                onclick="openEdit(${reply.comments_id})">수정
                                        </button>
                                        <button type="button" class="c-delete-btn"
                                                onclick="delComment(${reply.comments_id}, ${board.board_id})">삭제
                                        </button>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>
                    </c:forEach>
                </c:if>
            </c:forEach>

            <c:if test="${empty commentList}">
                <p class="no-comments">아직 작성된 댓글이 없습니다.</p>
            </c:if>
        </div>
    </div>

    <!-- 🔥 여기 추가 -->
    <div id="modal" class="modal">
        <div class="modal-content">
            <span class="close-btn">&times;</span>
            <h3>작성자의 게시글</h3>
            <ul id="postList"></ul>
        </div>
    </div>
</div>

<script>
    // 좋아요 상태 로드
    function loadLikeStatus() {
        const boardId = GLOBAL_BOARD_ID;
        const memberId = GLOBAL_MEMBER_ID;

        if (!boardId || !memberId) return;

        fetch(`/like?board_id=${boardId}&member_id=${memberId}`)
            .then(response => response.json())
            .then(data => {
                isLiked = data.isLiked;
                likeCount = data.likeCount;
                updateLikeUI(isLiked, likeCount);
            })
            .catch(error => console.error('Error:', error));
    }

    // 초기 좋아요 상태 설정 (JSP 로딩 시 서버 데이터를 자바스크립트 변수에 저장)
    let currentIsLiked = ${isLiked != null ? isLiked : false}; // 기본값
    let isLiked = currentIsLiked;
</script>

</body>
</html>
