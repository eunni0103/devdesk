package com.devdesk.pj.calendar;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

public class CalendarSyncJob implements Job {
    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println("🔄 [Quartz Job] 구글 캘린더 동기화 작업 실행 중...");
        try {
            // DAO에 만들어둔 동기화 메서드 호출
            ScheduleNewDAO.SCAO.syncGoogleCalendarToDB();
        } catch (Exception e) {
            System.err.println("❌ [Quartz Job] 동기화 중 에러 발생: " + e.getMessage());
        }
    }
}