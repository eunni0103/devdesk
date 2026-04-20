<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/review/review-write.css">

<div class="write-wrap">
    <div class="company-header">
        <div class="company-badge">기업 등록</div>
        <h2 class="company-name">새 기업 추가</h2>
    </div>

    <form action="${pageContext.request.contextPath}/company/insert" method="post" id="companyForm">
        <div class="form-section">
            <div class="section-title">
                <span class="section-number">01</span>
                기업 정보
            </div>

            <div class="field-row">
                <div class="field-group">
                    <label class="field-label required">기업명</label>
                    <input type="text" name="companyName" placeholder="예) 삼성전자" maxlength="50"/>
                </div>
            </div>

            <div class="field-row two-col">
                <div class="field-group">
                    <label class="field-label required">업종</label>
                    <select name="companyIndustry">
                        <option value="">선택하세요</option>
                        <option value="IT/서비스">IT/서비스</option>
                        <option value="IT/전자">IT/전자</option>
                        <option value="IT/플랫폼">IT/플랫폼</option>
                        <option value="IT/게임">IT/게임</option>
                        <option value="IT/보안">IT/보안</option>
                        <option value="IT/SI">IT/SI</option>
                        <option value="IT/솔루션">IT/솔루션</option>
                        <option value="기타">기타</option>
                    </select>
                </div>
                <div class="field-group">
                    <label class="field-label required">지역</label>
                    <label>
                        <select name="companyLocation">
                            <option value="">선택하세요</option>
                            <option value="서울">서울</option>
                            <option value="경기">경기</option>
                            <option value="인천">인천</option>
                            <option value="부산">부산</option>
                            <option value="대구">대구</option>
                            <option value="대전">대전</option>
                            <option value="광주">광주</option>
                            <option value="울산">울산</option>
                            <option value="세종">세종</option>
                            <option value="강원">강원</option>
                            <option value="충북">충북</option>
                            <option value="충남">충남</option>
                            <option value="전북">전북</option>
                            <option value="전남">전남</option>
                            <option value="경북">경북</option>
                            <option value="경남">경남</option>
                            <option value="제주">제주</option>
                        </select>
                    </label>
                </div>
            </div>

            <div class="field-row two-col">
                <div class="field-group">
                    <label class="field-label">평점</label>
                    <input type="number" name="companyRating" min="0" max="5" step="0.5"
                           placeholder="0.0 ~ 5.0"
                           style="height:38px; padding:0 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:14px; background:#f8fafc;"/>
                </div>
                <div class="field-group">
                    <label class="field-label">규모 (인원)</label>
                    <input type="number" name="companySize" min="0"
                           placeholder="예) 5000"
                           style="height:38px; padding:0 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:14px; background:#f8fafc;"/>
                </div>
            </div>

            <div class="field-row two-col">
                <div class="field-group">
                    <label class="field-label">설립일</label>
                    <input type="date" name="companyCreatedDate"
                           style="height:38px; padding:0 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:14px; background:#f8fafc;"/>
                </div>
                <div class="field-group">
                    <label class="field-label">채용 공고일</label>
                    <input type="date" name="companyApplicationDate"
                           style="height:38px; padding:0 12px; border:1px solid #e2e8f0; border-radius:8px; font-size:14px; background:#f8fafc;"/>
                </div>
            </div>
        </div>

        <div class="form-actions">
            <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
            <button type="submit" class="btn-submit">등록하기</button>
        </div>
    </form>
</div>
<c:if test="${param.success == 'true'}">
    <div class="modal-overlay" id="successModal">
        <div class="modal-box">
            <p>등록 완료</p>
            <button onclick="document.getElementById('successModal').style.display='none'">확인</button>
        </div>
    </div>
</c:if>
<c:if test="${param.success == 'false'}">
    <div class="modal-overlay" id="failModal">
        <div class="modal-box">
            <p>등록 실패</p>
            <button onclick="document.getElementById('failModal').style.display='none'">확인</button>
        </div>
    </div>
</c:if>