<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- 🌟 불필요한 <html>, <head>, <body> 태그 삭제 완료! --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/user/myboard.css">

<%-- 여기서부터 진짜 알맹이 내용만 시작! --%>
<main class="content">
    <div class="myboard-wrap">

        <div class="myboard-header">
            <h2 class="myboard-title">작성한 글 · 댓글</h2>
            <p class="myboard-sub">내가 DevDesk에 남긴 기록들을 확인하고 관리할 수 있습니다.</p>
        </div>

        <div class="tab-menu">
            <button class="tab-btn active" id="btn-posts" onclick="showTab('posts')">내가 쓴 글</button>
            <button class="tab-btn" id="btn-comments" onclick="showTab('comments')">내가 쓴 댓글</button>
        </div>

        <div id="tab-posts" style="display: block;">
            <table class="list-table">
                <colgroup>
                    <col width="15%">
                    <col width="45%">
                    <col width="10%">
                    <col width="10%">
                    <col width="20%">
                </colgroup>
                <thead>
                <tr>
                    <th>카테고리</th>
                    <th>제목</th>
                    <th>조회수</th>
                    <th>좋아요</th>
                    <th>작성일</th>
                </tr>
                </thead>

                <tbody id="posts-tbody">
                <c:if test="${empty myBoardList}">
                    <tr class="empty-msg-row">
                        <td colspan="5" class="empty-msg">아직 작성한 게시글이 없습니다. 첫 글을 남겨보세요! 📝</td>
                    </tr>
                </c:if>

                <c:forEach var="board" items="${myBoardList}">
                    <tr onclick="goToDetail('${pageContext.request.contextPath}/BoardDetailC?id=${board.board_id}')"
                        style="cursor: pointer;">
                        <td><span class="category-badge">${board.category}</span></td>
                        <td class="td-title">
                            <a href="${pageContext.request.contextPath}/BoardDetailC?id=${board.board_id}">${board.title}</a>
                            <span style="color: #ef4444; font-size: 12px; margin-left: 4px;">[${board.comment_count}]</span>
                        </td>
                        <td>${board.view_count}</td>
                        <td>${board.like_count}</td>
                        <td><fmt:formatDate value="${board.created_date}" pattern="yyyy-MM-dd"/></td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>

            <div id="posts-pagination" class="pagination"></div>
        </div>

        <div id="tab-comments" style="display: none;">
            <table class="list-table">
                <colgroup>
                    <col width="50%">
                    <col width="30%">
                    <col width="20%">
                </colgroup>
                <thead>
                <tr>
                    <th>글 제목</th>
                    <th>내 댓글</th>
                    <th>작성일</th>
                </tr>
                </thead>

                <tbody id="comments-tbody">
                <c:if test="${empty myCommentList}">
                    <tr class="empty-msg-row">
                        <td colspan="3" class="empty-msg">아직 작성한 댓글이 없습니다. 💬</td>
                    </tr>
                </c:if>

                <c:forEach var="comment" items="${myCommentList}">
                    <tr onclick="goToDetail('${pageContext.request.contextPath}/BoardDetailC?id=${comment.board_id}')"
                        style="cursor: pointer;">
                        <td class="td-title" style="color: #94a3b8; font-size: 14px;">
                                ${comment.board_title}
                        </td>
                        <td class="td-title">
                            <a href="${pageContext.request.contextPath}/BoardDetailC?id=${comment.board_id}">${comment.content}</a>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty comment.created_date and comment.created_date.length() >= 10}">
                                    ${comment.created_date.substring(0, 10)}
                                </c:when>
                                <c:otherwise>
                                    ${comment.created_date}
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>

            <div id="comments-pagination" class="pagination"></div>
        </div>

    </div>
</main>

<script src="${pageContext.request.contextPath}/js/myboard.js"></script>