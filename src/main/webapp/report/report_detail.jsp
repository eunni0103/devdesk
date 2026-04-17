<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<%-- 🌟 어드민 공통 CSS & 리포트 전용 CSS 연결 --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/admin.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/report/report-detail.css">

<div class="admin-wrapper">

    <%-- 🌟 왼쪽 사이드바 --%>
    <div class="admin-sidebar">
        <h3>Admin Panel</h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/admin">📊 대시보드</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/member">👥 회원 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/board">📝 게시글 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/report" class="active">🚨 신고 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/company">🏢 기업 정보 관리</a></li>
        </ul>
    </div>

    <%-- 🌟 오른쪽 메인 컨텐츠 영역 --%>
    <div class="admin-content">
        <div class="board-container report-container-admin detail" style="padding: 20px;">

            <%-- 상단 헤더 --%>
            <div class="board-header detail"
                 style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px;">
                <div>
                    <h2 style="margin-bottom: 5px;">🚨 신고 상세 내역</h2>
                    <p class="admin-page-desc" style="color: #64748b; font-size: 14px; margin: 0;">신고된 콘텐츠의 상세
                        내용을 확인하고
                        조치합니다.</p>
                </div>
                <div class="board-actions">
                    <button class="write-btn" onclick="location.href='${pageContext.request.contextPath}/admin/report'">
                        목록으로
                    </button>
                </div>
            </div>
            <div class="board-container report-container-admin detail" style="padding: 20px;">

                <%-- 상단 헤더 --%>
                <div class="board-header detail"
                     style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px;">
                    <div>
                        <h2 style="margin-bottom: 5px;">🚨 신고 상세 내역</h2>
                        <p class="admin-page-desc" style="color: #64748b; font-size: 14px; margin: 0;">신고된 콘텐츠의 상세
                            내용을 확인하고
                            조치합니다.</p>
                    </div>
                    <div class="board-actions">
                        <%-- JS로 동작을 넘긴 깔끔한 버튼 --%>
                        <button type="button" id="btnGoList" class="reset-btn"
                                data-url="${pageContext.request.contextPath}/admin/report">목록으로
                        </button>
                    </div>
                </div>

                <div class="detail-view">
                    <%-- 기본 정보 그룹 (2x2 그리드 적용) --%>
                    <div class="detail-info-group grid-2x2">
                        <div class="detail-row">
                            <div class="detail-label">신고 유형</div>
                            <div class="detail-content">
                                <c:choose>
                                    <c:when test="${report.repoReviewId > 0}">
                                        <span class="report-type-badge review">리뷰</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="report-type-badge board">게시글</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">처리 상태</div>
                            <div class="detail-content">
                            <span class="report-status-badge ${report.repoStatus == 'PENDING' ? 'pending' : 'done'}">
                                ${report.repoStatus == 'PENDING' ? '미처리' : '처리완료'}
                            </span>
                            </div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">신고 일시</div>
                            <div class="detail-content">${report.repoCreated}</div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">신고자 ID</div>
                            <div class="detail-content">${report.repoMemberId}</div>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label">신고 사유</div>
                        <div class="detail-content">
                        <span class="report-reason-badge"
                              style="display: inline-block; width: auto; padding: 5px 12px;">
                            <c:out value="${report.repoReason}" escapeXml="false"/>
                        </span>
                        </div>
                    </div>

                    <div class="detail-row">
                        <div class="detail-label">대상 ID</div>
                        <div class="detail-content">
                            ${report.repoReviewId > 0 ? '리뷰 #' += report.repoReviewId : '게시글 #' += report.repoBoardId}
                        </div>
                    </div>

                    <div class="detail-row content-area">
                        <div class="detail-label">상세 내용</div>
                        <div class="detail-content text-box"
                             style="background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; line-height: 1.6;">
                            <c:out value="${report.repoContent}" escapeXml="false"/>
                        </div>
                    </div>

                    <%-- 신고 대상 원문 표시 --%>
                    <c:choose>
                        <c:when test="${not empty targetReview}">
                            <div class="detail-row" style="margin-top: 16px;">
                                <div class="detail-label">리뷰 원문</div>
                                <div class="detail-content"
                                     style="background: #fff; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                    <div style="font-weight: 600; margin-bottom: 4px; color: #1e293b;"><c:out
                                            value="${targetReview.reviewTitle}"/></div>
                                    <div style="color: #64748b; font-size: 13px; margin-bottom: 12px;">
                                            ${targetReview.companyName}
                                        &nbsp;·&nbsp; ${targetReview.reviewCreatedDate}
                                    </div>
                                    <div style="line-height: 1.6; color: #334155;"><c:out
                                            value="${targetReview.reviewContent}"/></div>
                                </div>
                            </div>
                        </c:when>
                        <%--                    <c:when test="${not empty targetBoard}">--%>
                        <%--                        <div class="detail-row" style="margin-top: 16px;">--%>
                        <%--                            <div class="detail-label">게시글 원문</div>--%>
                        <%--                            <div class="detail-content"--%>
                        <%--                                 style="background: #fff; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0;">--%>
                        <%--                                <div style="font-weight: 600; margin-bottom: 4px; color: #1e293b;"><c:out--%>
                        <%--                                        value="${targetBoard.title}"/></div>--%>
                        <%--                                <div style="color: #64748b; font-size: 13px; margin-bottom: 12px;">--%>
                        <%--                                        ${targetBoard.nickname} &nbsp;·&nbsp; ${targetBoard.created_date}--%>
                        <%--                                </div>--%>
                        <%--                                <div style="line-height: 1.6; color: #334155;"><c:out--%>
                        <%--                                        value="${targetBoard.content}"/></div>--%>
                        <%--                            </div>--%>
                        <%--                        </div>--%>
                        <%--                    </c:when>--%>

                        <c:when test="${not empty targetBoard}">
                            <div class="detail-row" style="margin-top: 16px;">
                                <div class="detail-label">게시글 원문</div>
                                <div class="detail-content"
                                     style="background: #fff; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                    <div style="font-weight: 600; margin-bottom: 4px; color: #1e293b;">
                                        <c:out value="${targetBoard.title}"/>
                                    </div>
                                    <div style="color: #64748b; font-size: 13px; margin-bottom: 12px;">
                                            ${targetBoard.nickname} &nbsp;·&nbsp; ${targetBoard.created_date}
                                    </div>
                                        <%-- 🌟 이미지 URL을 <img> 태그로 변환해서 출력 --%>
                                        <%--                                <div style="line-height: 1.6; color: #334155;" id="boardContentArea"></div>--%>
                                    <div style="line-height: 1.6; color: #334155;" id="boardContentArea"
                                         data-content="${targetBoard.content}"></div>
                                </div>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="detail-row" style="margin-top: 16px;">
                                <div class="detail-label">원문</div>
                                <div class="detail-content" style="color: #94a3b8; font-style: italic;">이미 삭제되거나
                                    존재하지 않는
                                    콘텐츠입니다.
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- 👇 액션 버튼 영역 (순수 HTML 폼만 남김) 👇 --%>
                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 30px; padding-top: 20px; border-top: 1px solid #e2e8f0;">

                    <%-- 원문 강제 삭제 폼 (id 추가됨) --%>
                    <form id="deleteContentForm" method="post"
                          action="${pageContext.request.contextPath}/reportDetail"
                          data-type="${report.repoReviewId > 0 ? 'review' : 'board'}" style="margin: 0;">
                        <input type="hidden" name="reportId" value="${report.reportId}">
                        <c:choose>
                            <c:when test="${report.repoReviewId > 0}">
                                <input type="hidden" name="reviewId" value="${report.repoReviewId}">
                                <input type="hidden" name="cmd" value="delReview">
                                <button type="submit" class="search-btn" style="background-color: #ef4444;">리뷰 강제 삭제
                                </button>
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="boardId" value="${report.repoBoardId}">
                                <input type="hidden" name="cmd" value="delBoard">
                                <button type="submit" class="search-btn" style="background-color: #ef4444;">게시글 강제
                                    삭제
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </form>

                    <%-- 신고 기록 삭제 폼 (id 추가됨) --%>
                    <form id="deleteReportForm" method="post"
                          action="${pageContext.request.contextPath}/reportDetail"
                          style="margin: 0;">
                        <input type="hidden" name="reportId" value="${report.reportId}">
                        <input type="hidden" name="cmd" value="delete">
                        <button type="submit" class="reset-btn"
                                style="color: #ef4444; border: 1px solid #fecaca; background: #fff;">신고 내역 폐기
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%-- 🌟 새로 만든 JS 파일 연결! --%>
    <script src="${pageContext.request.contextPath}/js/admin/admin-report-detail.js"></script>
</div>
