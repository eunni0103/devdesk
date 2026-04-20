<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/board/board-all.css">

<!DOCTYPE html>
<html>
<head>
    <title>커뮤니티</title>
</head>

<body>
<div class="board-container">
    <div class="board-header">
        <h2>자유게시판</h2>

        <div class="board-actions">
            <form action="board" method="get" class="search-form">
                <select name="searchType" class="search-type">
                    <option value="title" ${param.searchType == 'title' ? 'selected' : ''}>제목</option>
                    <option value="content" ${param.searchType == 'content' ? 'selected' : ''}>내용</option>
                    <option value="author" ${param.searchType == 'author' ? 'selected' : ''}>작성자</option>
                </select>
                <input type="text" name="keyword" class="search-input" placeholder="검색어를 입력하세요"
                       value="${param.keyword}">
                <button type="submit" class="search-btn">검색</button>
                <c:if test="${not empty param.keyword}">
                    <button type="button" class="reset-btn" onclick="location.href='board'">목록으로</button>
                </c:if>
            </form>
            <%--  onchange 선택 시 즉시 필터링 적용 --%>
            <select name="category"
                    onchange="location.href='board?category=' + this.value + '&sort=${param.sort != null ? param.sort : ""}&searchType=${param.searchType != null ? param.searchType : ""}&keyword=${param.keyword != null ? param.keyword : ""}'">
                <option value="전체" ${param.category == '전체' or param.category == null ? 'selected' : ''}>전체</option>
                <option value="자유토크" ${param.category == '자유토크' ? 'selected' : ''}>자유토크</option>
                <option value="TIL" ${param.category == 'TIL' ? 'selected' : ''}>TIL</option>
                <option value="이력서" ${param.category == '이력서' ? 'selected' : ''}>이력서</option>
                <option value="TIP" ${param.category == 'TIP' ? 'selected' : ''}>자기만의TIP</option>
            </select>

            <select onchange="location.href='board?sort=' + this.value + '&category=${param.category != null ? param.category : ""}&searchType=${param.searchType != null ? param.searchType : ""}&keyword=${param.keyword != null ? param.keyword : ""}'">
                <option value="" ${param.sort == null or param.sort == '' ? 'selected' : ''}>최신순</option>
                <option value="popular" ${param.sort == 'popular' ? 'selected' : ''}>인기순</option>
                <option value="viewcount" ${param.sort == 'viewcount' ? 'selected' : ''}>조회순</option>
            </select>

            <button class="write-btn"><a href="board_add">글쓰기</a></button>
        </div>
    </div>

    <div>
        <c:forEach var="b" items="${boards}">
            <div class="board-row" onclick="location.href='BoardDetailC?id=${b.board_id}'">
                <div class="col-category">${b.category}</div>
                <div class="col-title">
                        ${b.title}
                    <span class="comment-count">[${b.comment_count}]</span>
                </div>
                <div class="col-date">
                    <div class="date-info">
                        <c:choose>
                            <%-- 최종 수정일이 있으면 수정일 표시 --%>
                            <c:when test="${not empty b.updated_date}">
                                ${b.updated_date} <span style="font-size: 0.8em; color: #7c3aed;">(수정됨)</span>
                            </c:when>
                            <%-- 없으면 최초 작성일 표시 --%>
                            <c:otherwise>
                                ${b.created_date}
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="meta-info">
                        <span class="like-count">❤️ ${b.like_count}</span>
                        <c:if test="${b.like_count > 3}">  <%-- 4개 이상이여야 인기글 배지 --%>
                            <span class="popular-badge">🔥 인기글</span>
                        </c:if>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <div class="pagination">
        <c:if test="${currentPage > 1}">
            <a href="board?p=${currentPage - 1}&category=${param.category != null ? param.category : ""}&sort=${param.sort != null ? param.sort : ""}&searchType=${param.searchType != null ? param.searchType : ""}&keyword=${param.keyword != null ? param.keyword : ""}"
               class="page-btn">이전</a>
        </c:if>

        <c:forEach begin="1" end="${totalPage}" var="i">
            <c:choose>
                <c:when test="${i == currentPage}">
                    <span class="current-page">${i}</span>
                </c:when>
                <%-- 중복된 c:otherwise를 제거하고 하나로 합쳤습니다. --%>
                <c:otherwise>
                    <a href="board?p=${i}&category=${param.category != null ? param.category : ''}&sort=${param.sort != null ? param.sort : ''}&searchType=${param.searchType != null ? param.searchType : ''}&keyword=${param.keyword != null ? param.keyword : ''}"
                       class="page-link">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <%-- href 안에서 줄바꿈이 일어나면 링크가 깨질 수 있어 한 줄로 합쳤습니다. --%>
        <c:if test="${currentPage < totalPage}">
            <a href="board?p=${currentPage + 1}&category=${param.category != null ? param.category : ''}&sort=${param.sort != null ? param.sort : ''}&searchType=${param.searchType != null ? param.searchType : ''}&keyword=${param.keyword != null ? param.keyword : ''}"
               class="page-btn">다음</a>
        </c:if>
    </div>

</div>

</body>
</html>