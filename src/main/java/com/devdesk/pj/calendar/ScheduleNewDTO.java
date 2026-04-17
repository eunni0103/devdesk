package com.devdesk.pj.calendar;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.servlet.annotation.WebServlet;
import java.util.Date;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ScheduleNewDTO {
    // SCHEDULE 테이블 데이터
    private int schedule_id;
    private java.sql.Date schedule_date;
    private String schedule_time;
    private String interview_type;
    private String schedule_memo;

    // APPLICATION & COMPANY 테이블에서 JOIN으로 가져올 데이터
    private String company_name;  // COMPANY 테이블
    private String position;      // APPLICATION 테이블
    private String stage;         // APPLICATION 테이블 (현재 전형 상태)

}
