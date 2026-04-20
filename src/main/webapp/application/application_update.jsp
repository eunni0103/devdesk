<%@ page contentType="text/html;charset=UTF-8" %>

<form action="application_update" method="post">

    <input type="hidden" name="app_id" value="${app.appId}">

    회사명: ${app.companyName} <br><br>

    직무:
    <input type="text" name="position" value="${app.position}"><br><br>

    상태:
    <select name="status" id="statusSelect">
        <option value="APPLIED" ${app.status=='APPLIED'?'selected':''}>지원완료</option>
        <option value="INTERVIEW" ${app.status=='INTERVIEW'?'selected':''}>면접</option>
        <option value="PASS" ${app.status=='PASS'?'selected':''}>합격</option>
        <option value="FAIL" ${app.status=='FAIL'?'selected':''}>불합격</option>
    </select><br><br>

    날짜:
    <input type="date" name="appDate" value="${app.appDate}"><br><br>

    메모:
    <textarea name="memo">${app.memo}</textarea><br><br>

    <!-- 🔥 면접 영역 -->
    <div id="interviewSection" style="display:none;">

        면접 날짜:
        <input type="date" name="interview_date"
               value="${app.interviewDate}"><br><br>

        면접 시간:
        <input type="time" name="interview_time"
               value="${app.interviewTime}"><br><br>

        면접 유형:
        <select name="interview_type">
            <option value="">-- 선택 --</option>
            <option value="ONLINE" ${app.interviewType=='ONLINE'?'selected':''}>화상</option>
            <option value="OFFLINE" ${app.interviewType=='OFFLINE'?'selected':''}>대면</option>
            <option value="PHONE" ${app.interviewType=='PHONE'?'selected':''}>전화</option>
        </select><br><br>

    </div>

    <button type="submit">수정 완료</button>

</form>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const statusSelect = document.getElementById("statusSelect");
        const interviewSection = document.getElementById("interviewSection");

        function toggleInterview() {
            if (statusSelect.value === "INTERVIEW") {
                interviewSection.style.display = "block";
            } else {
                interviewSection.style.display = "none";
            }
        }

        statusSelect.addEventListener("change", toggleInterview);

        // 🔥 초기 상태 반영 (중요)
        toggleInterview();
    });
</script>