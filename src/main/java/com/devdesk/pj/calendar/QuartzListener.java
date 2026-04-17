package com.devdesk.pj.calendar;

import org.quartz.*;
import org.quartz.impl.StdSchedulerFactory;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class QuartzListener implements ServletContextListener {
    private Scheduler scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            scheduler = StdSchedulerFactory.getDefaultScheduler();
            scheduler.start();

            // 1. 실행할 Job 클래스 지정
            JobDetail job = JobBuilder.newJob(CalendarSyncJob.class)
                    .withIdentity("googleSyncJob", "calendarGroup")
                    .build();

            // 2. Cron 주기 설정 (여기를 발표 때 변경하시면 됩니다!)
//             [초기 설정] 0 0 */12 * * ? : 12시간마다 실행
            // [발표용 설정] 0/30 * * * * ? : 30초마다 실행
            // [발표용 설정] 0 * * * * ? : 1분마다 실행
            String cronExpression = "0 0 */12 * * ?";  // <- 기본세팅
            // ↑ 서버 시연할때 수정할 부분 서버가 (현재세팅 12시간)에 한번씩 돌아서 구글 캘린더에 접속을 합니다
           //  String cronExpression = "0/30 * * * * ?";         // 시연할때 세팅

            Trigger trigger = TriggerBuilder.newTrigger()
                    .withIdentity("googleSyncTrigger", "calendarGroup")
                    .withSchedule(CronScheduleBuilder.cronSchedule(cronExpression))
                    .build();

            scheduler.scheduleJob(job, trigger);
            System.out.println("✅ [Quartz] 구글 캘린더 동기화 스케줄러 시작 완료 (주기: " + cronExpression + ")");

        } catch (SchedulerException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        try {
            if (scheduler != null) {
                scheduler.shutdown();
                System.out.println("🛑 [Quartz] 구글 캘린더 동기화 스케줄러 종료");
            }
        } catch (SchedulerException e) {
            e.printStackTrace();
        }
    }
}