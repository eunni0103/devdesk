<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<link rel="stylesheet" href="${ctx}/css/application-list.css">
<link rel="stylesheet" href="${ctx}/css/index.css">
<link rel="stylesheet" href="${ctx}/css/resume-block.css">
<link rel="stylesheet" href="${ctx}/css/index.css">
<!-- 선민 수정 -->

<!-- 페이지 헤더 -->
<div class="page-header">
    <div class="page-info">
        <h1 class="page-title">지원한 회사 목록</h1>
        <p class="page-sub">지원 현황을 한눈에 확인하고 단계를 관리하세요</p>
    </div>
    <div class="three-btn">
        <div class="right-btns">

            <a href="${pageContext.request.contextPath}/til-list">
                <button class="btn-til">TIL</button>
            </a>

            <button class="btn-add" id="btnOpenInsert">+ 지원 추가</button>
            <form class="rb-filter" action="application-star" method="get">
                <button>즐겨찾기✨</button>
            </form>
            <form class="rb-filter" action="application-list" method="get">
                <button>전체보기</button>
            </form>
        </div>
    </div>
</div>

<!-- 단계별 요약 카운트 -->
<div class="stage-bar" id="stageBar">
    <div class="stage-chip" style="--chip-c:#9da3b8">
        <span class="stage-chip-icon">📄</span>
        <div class="stage-chip-cnt" id="cnt-APPLIED">0</div>
        <div class="stage-chip-name">지원완료</div>
    </div>
    <div class="stage-chip" style="--chip-c:#ffd166">
        <span class="stage-chip-icon">📋</span>
        <div class="stage-chip-cnt" id="cnt-DOCUMENT">0</div>
        <div class="stage-chip-name">서류통과</div>
    </div>
    <div class="stage-chip" style="--chip-c:#4ecdc4">
        <span class="stage-chip-icon">🗣</span>
        <div class="stage-chip-cnt" id="cnt-FIRST_INTERVIEW">0</div>
        <div class="stage-chip-name">1차 면접</div>
    </div>
    <div class="stage-chip" style="--chip-c:#5b7cf8">
        <span class="stage-chip-icon">💬</span>
        <div class="stage-chip-cnt" id="cnt-SECOND_INTERVIEW">0</div>
        <div class="stage-chip-name">2차 면접</div>
    </div>
    <div class="stage-chip" style="--chip-c:#8b6ef5">
        <span class="stage-chip-icon">🔮</span>
        <div class="stage-chip-cnt" id="cnt-THIRD_INTERVIEW">0</div>
        <div class="stage-chip-name">3차 면접</div>
    </div>
    <div class="stage-chip" style="--chip-c:#56e39f">
        <span class="stage-chip-icon">🎉</span>
        <div class="stage-chip-cnt" id="cnt-PASS">0</div>
        <div class="stage-chip-name">합격</div>
    </div>
    <div class="stage-chip" style="--chip-c:#ff6b6b">
        <span class="stage-chip-icon">💔</span>
        <div class="stage-chip-cnt" id="cnt-FAIL">0</div>
        <div class="stage-chip-name">불합격</div>
    </div>
</div>

<!-- 카드 그리드 -->
<div class="card-grid" id="cardGrid">
    <c:choose>
        <c:when test="${empty applicationList}">
            <div class="empty">
                <div class="empty-icon">📭</div>
                <p>아직 지원한 곳이 없어요.<br>+ 지원 추가 버튼을 눌러 첫 지원을 등록해 보세요!</p>
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="app" items="${applicationList}" varStatus="vs">
                <div class="app-card" id="card_${app.appId}" style="animation-delay:${vs.index * 40}ms">
                    <div class="card-top">
                        <div class="card-company">${app.companyName}</div>
                        <span class="stage-badge" id="badge_${app.appId}"></span>
                    </div>
                    <div class="card-position">💼 ${app.position}</div>
                    <c:if test="${not empty app.memo}">
                        <div class="card-memo">${app.memo}</div>
                    </c:if>
                    <div class="status-wrap">
                        <span class="status-text" id="status_text_${app.appId}"></span>
                        <select class="status-select" id="status_select_${app.appId}">
                            <option value="APPLIED">지원완료</option>
                            <option value="DOCUMENT">서류 통과</option>
                            <option value="FIRST_INTERVIEW">1차 면접</option>
                            <option value="SECOND_INTERVIEW">2차 면접</option>
                            <option value="THIRD_INTERVIEW">3차 면접</option>
                            <option value="PASS">합격</option>
                            <option value="FAIL">불합격</option>
                        </select>
                        <button class="btn-status"
                                data-app-id="${app.appId}"
                                data-status="${app.status}">단계 변경
                        </button>
                    </div>
                    <div class="card-footer">
                        <span class="card-date">📅 ${app.appDate}</span>
                        <div class="star-delete">
                            <form class="star-form ${app.isStar == 1 ? 'is-starred' : ''}" action="application-star"
                                  method="post">
                                <input type="hidden" name="app_id" value="${app.appId}">
                                <input type="hidden" name="is_star" value="${app.isStar}">
                                <button class="star-btn" title="즐겨찾기">${app.isStar == 1 ? '★' : '☆'}</button>
                            </form>
                            <div class="card-actions">
                                <button class="btn-delete"
                                        data-app-id="${app.appId}"
                                        data-company="${app.companyName}">삭제
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <input type="hidden" id="init_status_${app.appId}" value="${app.status}">
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<!-- ═══════════ 지원 등록 모달 ═══════════ -->
<div class="modal-overlay" id="insertModal" style="display:none">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-title">지원 등록</div>
            <button class="modal-close" id="btnCloseInsert">✕</button>
        </div>

        <form action="application-insert" method="post" id="insertForm">
            <div class="form-group">
                <label class="form-label">회사 <span class="required">*</span></label>
                <div style="display:flex; align-items:center; gap:8px;">
                    <input type="text" id="selectedCompanyName" class="form-input"
                           readonly placeholder="기업을 선택해주세요" style="cursor:pointer;"/>
                    <button type="button" id="btnOpenCompany" class="csm-btn-search">기업 선택</button>
                </div>
                <jsp:include page="/company/company-search/company_search_modal.jsp"/>
                <input type="hidden" name="companyId" id="selectedCompanyId"/>
            </div>

            <div class="form-group">
                <label class="form-label">지원 직무 <span class="required">*</span></label>
                <input class="form-input" type="text" name="position" placeholder="예: 백엔드 개발자" required>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">지원 상태</label>
                    <select class="form-select" name="stage" id="modalStage">
                        <option value="APPLIED">지원완료</option>
                        <option value="DOCUMENT">서류통과</option>
                        <option value="FIRST_INTERVIEW">1차 면접</option>
                        <option value="SECOND_INTERVIEW">2차 면접</option>
                        <option value="THIRD_INTERVIEW">3차 면접</option>
                        <option value="PASS">합격</option>
                        <option value="FAIL">불합격</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">지원일</label>
                    <input class="form-input" type="date" name="apply_date" id="modalApplyDate">
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">메모</label>
                <textarea class="form-textarea" name="memo"
                          placeholder="준비 사항, 특이 사항 등 자유롭게 입력하세요"></textarea>
            </div>

            <input type="hidden" name="member_id" value="${sessionScope.user.member_id}">

            <div class="interview-section" id="interviewSection">
                <div class="interview-divider"><span>면접 일정</span></div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">면접 날짜</label>
                        <input class="form-input" type="date" name="interview_date">
                    </div>
                    <div class="form-group">
                        <label class="form-label">면접 시간</label>
                        <input class="form-input" type="time" name="interview_time">
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">면접 유형</label>
                    <select class="form-select" name="interview_type">
                        <option value="">-- 선택 --</option>
                        <option value="ONLINE">화상</option>
                        <option value="OFFLINE">대면</option>
                        <option value="PHONE">전화</option>
                    </select>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn-modal-cancel" id="btnCancelInsert">취소</button>
                <button type="submit" class="btn-modal-submit">등록하기</button>
            </div>
        </form>
    </div>
</div>

<!-- ═══════════ 삭제 확인 다이얼로그 ═══════════ -->
<div class="confirm-overlay" id="confirmOverlay" style="display:none">
    <div class="confirm-box">
        <div class="confirm-title">정말 삭제할까요?</div>
        <div class="confirm-msg" id="confirmMsg">이 작업은 되돌릴 수 없습니다.</div>
        <div class="confirm-btns">
            <button class="btn-cancel" id="btnCancelConfirm">취소</button>
            <form id="deleteForm" action="application_delete" method="post" style="display:inline">
                <input type="hidden" name="app_id" id="deleteAppId">
                <button type="submit" class="btn-confirm-del">삭제</button>
            </form>
        </div>
    </div>
</div>

<!-- JS는 모달 HTML 아래에서 로드 → DOM 순서 보장 -->
<script src="${ctx}/js/company/company-search-modal.js"></script>
<script src="${ctx}/js/application-list.js"></script>
