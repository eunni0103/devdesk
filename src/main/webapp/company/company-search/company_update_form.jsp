<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/review/review-write.css">

<form action="${pageContext.request.contextPath}/company/edit" method="post">
    <input type="hidden" name="companyId" value="${company.companyId}"/>

    <div class="field-row">
        <div class="field-group">
            <label class="field-label required">기업명</label>
            <input type="text" name="companyName" value="${company.companyName}"/>
        </div>
    </div>

    <div class="field-row two-col">
        <div class="field-group">
            <label class="field-label required">업종</label>
            <select name="companyIndustry">
                <option value="">선택하세요</option>
                <option value="IT/서비스" ${company.companyIndustry == 'IT/서비스' ? 'selected' : ''}>IT/서비스</option>
                <option value="IT/전자" ${company.companyIndustry == 'IT/전자' ? 'selected' : ''}>IT/전자</option>
                <option value="IT/플랫폼" ${company.companyIndustry == 'IT/플랫폼' ? 'selected' : ''}>IT/플랫폼</option>
                <option value="IT/게임" ${company.companyIndustry == 'IT/게임' ? 'selected' : ''}>IT/게임</option>
                <option value="IT/보안" ${company.companyIndustry == 'IT/보안' ? 'selected' : ''}>IT/보안</option>
                <option value="IT/SI" ${company.companyIndustry == 'IT/SI' ? 'selected' : ''}>IT/SI</option>
                <option value="IT/솔루션" ${company.companyIndustry == 'IT/솔루션' ? 'selected' : ''}>IT/솔루션</option>
                <option value="기타" ${company.companyIndustry == '기타' ? 'selected' : ''}>기타</option>
            </select>
        </div>
        <div class="field-group">
            <label class="field-label required">지역</label>
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
        </div>
    </div>

    <div class="field-row two-col">
        <div class="field-group">
            <label class="field-label">평점</label>
            <input type="number" name="companyRating" value="${company.companyRating}"
                   min="0" max="5" step="0.1"/>
        </div>
        <div class="field-group">
            <label class="field-label">규모 (인원)</label>
            <input type="number" name="companySize" value="${company.companySize}" min="0"/>
        </div>
    </div>

    <div class="form-actions">
        <button type="button" class="btn-delete" onclick="confirmDelete(${company.companyId})">삭제</button>
        <div style="flex:1"></div>
        <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
        <button type="submit" class="btn-submit">수정하기</button>
    </div>
</form>

<%-- 삭제 확인 모달 --%>
<div class="modal-overlay" id="deleteModal" style="display:none">
    <div class="modal-box">
        <p>정말 삭제하시겠습니까?</p>
        <p class="modal-sub">이 기업에 등록된 면접 후기도 함께 삭제됩니다.</p>
        <div class="modal-btns">
            <button class="btn-cancel" onclick="document.getElementById('deleteModal').style.display='none'">취소</button>
            <form id="deleteForm" method="post" action="${pageContext.request.contextPath}/company/delete"
                  style="display:inline">
                <input type="hidden" name="companyId" id="deleteCompanyId"/>
                <button type="submit" class="btn-delete-confirm">삭제</button>
            </form>
        </div>
    </div>
</div>