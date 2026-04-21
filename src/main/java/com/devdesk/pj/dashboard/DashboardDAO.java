package com.devdesk.pj.dashboard;

import com.devdesk.pj.main.DBManager_new;
import com.devdesk.pj.user.MemberDTO;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class DashboardDAO {
    public static StageCountVO countGroupbystage(HttpServletRequest request) {
        String sql = "SELECT STAGE, COUNT(*) AS CNT " +
                "FROM APPLICATION " +
                "WHERE MEMBER_ID = ? " +
                "GROUP BY STAGE";
        StageCountVO vo = new StageCountVO();

        // ① 세션에서 꺼내는 것도 try 안으로
        MemberDTO loginUser = (MemberDTO) request.getSession().getAttribute("user");

        // ② null 체크 추가
        if (loginUser == null) {
            return vo; // 로그인 안 된 상태면 빈 VO 반환
        }

        int memberId = loginUser.getMember_id();
        System.out.println(memberId);

        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, memberId);

            System.out.println("쿼리 실행됨, memberId    : " + memberId);

            try (ResultSet rs = pstmt.executeQuery()) {
                System.out.println("RS received");

                while (rs.next()) {
                    String stage = rs.getString("STAGE");
                    int cnt = rs.getInt("CNT");

                    System.out.println("STAGE: [" + stage + "], CNT: " + cnt);
                    // 실제 DB에서 오는 STAGE 값 확인

                    switch (stage) {
                        case "APPLIED":
                            vo.setApplied(cnt);
                            break;
                        case "DOCUMENT":       // DOCUMENT_PASS → DOCUMENT
                            vo.setDocumentPass(cnt);
                            break;
                        case "PASS":           // PASSED → PASS
                            vo.setPassed(cnt);
                            break;
                        case "FAIL":           // 새로 추가
                            vo.setFailed(cnt);
                            break;
                        case "FIRST_INTERVIEW":
                            vo.setFirstInterview(cnt);
                            break;
                        case "SECOND_INTERVIEW":
                            vo.setSecondInterview(cnt);
                            break;
                        case "THIRD_INTERVIEW":
                            vo.setThirdInterview(cnt);
                            break;
                        case "CODING_TEST":
                            vo.setCodingTest(cnt);
                            break;
                        case "PASSED":
                            vo.setPassed(cnt);
                            break;
                    }
                }                               // while 닫기
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("stageCounts", vo);
        return vo;  // ✅ finally 밖으로
    }

    public static List<Map<String, Object>> getFunnelData(StageCountVO sc) {
        List<Map<String, Object>> funnelData = new ArrayList<>();

        // 각 단계는 DB에서 현재 상태만 저장되므로, 누적 합계로 계산해야 100% 초과를 막을 수 있음.
        // ex) DOCUMENT로 진행하면 APPLIED에서 빠지기 때문에 documentPass / applied 가 100% 초과 가능.
        int total          = sc.getApplied() + sc.getDocumentPass() + sc.getFirstInterview()
                           + sc.getSecondInterview() + sc.getThirdInterview()
                           + sc.getPassed() + sc.getFailed();
        int docAndAbove    = sc.getDocumentPass() + sc.getFirstInterview()
                           + sc.getSecondInterview() + sc.getThirdInterview()
                           + sc.getPassed() + sc.getFailed();
        int firstAndAbove  = sc.getFirstInterview() + sc.getSecondInterview()
                           + sc.getThirdInterview() + sc.getPassed() + sc.getFailed();
        int secondAndAbove = sc.getSecondInterview() + sc.getThirdInterview()
                           + sc.getPassed() + sc.getFailed();
        int thirdAndAbove  = sc.getThirdInterview() + sc.getPassed() + sc.getFailed();
        int passed         = sc.getPassed();

        addFunnel(funnelData, "이력서 제출", "서류 합격",
                "#9da3b8", "#ffd166",
                total, docAndAbove);

        addFunnel(funnelData, "서류 합격", "1차 면접",
                "#ffd166", "#4ecdc4",
                docAndAbove, firstAndAbove);

        addFunnel(funnelData, "1차 면접", "2차 면접",
                "#4ecdc4", "#5b7cf8",
                firstAndAbove, secondAndAbove);

        addFunnel(funnelData, "2차 면접", "3차 면접",
                "#5b7cf8", "#8b6ef5",
                secondAndAbove, thirdAndAbove);

        addFunnel(funnelData, "3차 면접", "합격",
                "#8b6ef5", "#56e39f",
                thirdAndAbove, passed);

        return funnelData;
    }


    // 헬퍼 메서드
    private static void addFunnel(List<Map<String, Object>> list,
                                  String fromLabel, String toLabel,
                                  String fromColor, String toColor,
                                  int from, int to) {
        Map<String, Object> map = new HashMap<>();
        map.put("fromLabel", fromLabel);
        map.put("toLabel", toLabel);
        map.put("fromColor", fromColor);
        map.put("toColor", toColor);
        if (from == 0) {
            // 분모가 0이면 데이터 없음 → JSP에서 "-" 표시
            map.put("pct", 0);
            map.put("noData", true);
        } else {
            int pct = (int) Math.round((double) to / from * 100);
            map.put("pct", Math.min(pct, 100)); // 누적 오차로 인한 100% 초과 안전 처리
            map.put("noData", false);
        }
        list.add(map);
    }


}