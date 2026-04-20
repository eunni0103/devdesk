package com.devdesk.pj.companysearch;

import com.devdesk.pj.main.DBManager_new;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

public class CompanySearchDAO {
    public static final CompanySearchDAO COMPANY_SEARCH_DAO = new CompanySearchDAO();

    private CompanySearchDAO() {

    }


//    public List<String> companySearch(Map<String, String> conditions) {
//        Set<String> allowedText = Set.of("company_name", "company_industry", "company_location");
//        Set<String> allowedRange = Set.of("company_rating", "company_size");
//        StringBuilder SQL = new StringBuilder("SELECT c.*, "
//                + "NVL(ROUND(AVG(r.r_rating), 1), 0) AS calc_rating, "
//                + "COUNT(r.r_id) AS review_count "
//                + "FROM company c "
//                + "LEFT JOIN review r ON c.company_id = r.r_company_id "
//                + "WHERE c.is_verified = 'Y'");
//        List<Object> params = new ArrayList<>();
//
//        for (String col : allowedText) {
//            if (conditions.containsKey(col)) {
//                sql.append(" and c.").append(col).append(" like ?");
//                params.add("%" + conditions.get(col) + "%");
//            }
//
//        }
//        for (String col : allowedRange) {
//            String minVal = conditions.get("min_" + col);
//            String maxVal = conditions.get("max_" + col);
//            if (minVal != null && !minVal.isBlank()) {
//                sql.append(" and c. ").append(col).append(">= ?");
//                params.add(Double.parseDouble(minVal));
//            }
//            if (maxVal != null && !maxVal.isBlank()) {
//                sql.append(" and c.").append(col).append("<= ?");
//                params.add(Double.parseDouble(maxVal));
//            }
//        }
//        sql.append(" GROUP BY c.company_id, c.company_name, c.company_industry, "
//                + "c.company_location, c.company_rating, c.company_size, "
//                + "c.company_created_date, c.company_application_date, c.is_verified");
//
//
//        List<String> companies = new ArrayList<>();
//        try (Connection con = DBManager_new.connect();
//             PreparedStatement pstmt = con.prepareStatement(sql.toString())
//        ) {
//            for (int i = 0; i < params.size(); i++) {
//                pstmt.setObject(i + 1, params.get(i));
//            }
//            try (ResultSet rs = pstmt.executeQuery()) {
//                CompanySearchVO company = new CompanySearchVO();
//                while (rs.next()) {
//                    company = CompanySearchVO.fromRS(rs);
//                    companies.add(company.toJson());
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//
//        return companies;
//    }

    public CompanySearchVO getCompanyById(int companyId) {
        String sql = "select * from company where company_id = ? ";
        try (
                Connection con = DBManager_new.connect();
                PreparedStatement pstmt = con.prepareStatement(sql)
        ) {
            pstmt.setInt(1, companyId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return CompanySearchVO.fromRS(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<String> getAllIndustries() {
        String sql = "select distinct company_industry from company where company_industry != '미정' order by company_industry";
        List<String> list = new ArrayList<>();
        try (
                Connection con = DBManager_new.connect();
                PreparedStatement pstmt = con.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery()
        ) {
            while (rs.next()) {
                list.add(rs.getString("company_industry"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<String> getAllLocation() {
        String sql = "SELECT DISTINCT company_location FROM company"
                + " WHERE company_location IS NOT NULL AND company_location != '미정'"
                + " ORDER BY company_location";
        List<String> list = new ArrayList<>();
        try (
                Connection con = DBManager_new.connect();
                PreparedStatement pstmt = con.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery()
        ) {
            while (rs.next()) {
                String region = rs.getString("company_location");
                if (region != null && !region.isBlank()) {
                    list.add(region);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insertCompany(CompanySearchVO vo) {
        String sql = "insert into company(company_id, company_name, company_industry, " +
                "company_location, company_rating, company_size, company_created_date, company_application_date, is_verified) " +
                //"values(company_seq.nextval, ?, ?, ?, ?, ?, ?, ?, 'Y')";
                "values(company_seq.nextval, ?, ?, ?, ?, ?, ?, ?, 'N')"; // 영은 추가-기업 승인용
        try (
                Connection con = DBManager_new.connect();
                PreparedStatement pstmt = con.prepareStatement(sql)
        ) {
            pstmt.setString(1, vo.getCompanyName());
            pstmt.setString(2, vo.getCompanyIndustry());
            pstmt.setString(3, vo.getCompanyLocation());
            pstmt.setDouble(4, vo.getCompanyRating());
            pstmt.setInt(5, vo.getCompanySize());
            pstmt.setDate(6, (Date) vo.getCompanyCreatedDate());
            pstmt.setDate(7, (Date) vo.getCompanyApplicationDate());

            if (pstmt.executeUpdate() > 0) {
                System.out.println("Company insert success");
                return 1;
            } else {
                System.out.println("Company insert fail");
                return 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }

    }

    public void deleteCompany(int companyId) {


        String sqlDelSch = "DELETE FROM schedule WHERE app_id IN (SELECT app_id FROM application WHERE company_id = ?)";
        String sqlDelApp = "DELETE FROM application WHERE company_id = ?";
        String sqlDelRev = "delete from review where r_company_id = ?";
        String sqlDelComp = "delete from company where company_id = ?";


        try (
                Connection con = DBManager_new.connect()
        ) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement pstmt = con.prepareStatement(sqlDelSch)) {
                    pstmt.setInt(1, companyId);
                    pstmt.executeUpdate();
                }
                try (PreparedStatement pstmt = con.prepareStatement(sqlDelApp)) {
                    pstmt.setInt(1, companyId);
                    pstmt.executeUpdate();
                }
                try (PreparedStatement pstmt = con.prepareStatement(sqlDelRev)) {
                    pstmt.setInt(1, companyId);
                    pstmt.executeUpdate();
                }
                try (PreparedStatement pstmt = con.prepareStatement(sqlDelComp)) {
                    pstmt.setInt(1, companyId);
                    pstmt.executeUpdate();
                }
                con.commit();
            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateCompany(CompanySearchVO vo) {
        String sql = "update company set company_name=?, company_industry=?, " +
                "company_location=?, company_rating=?, company_size=? , company_application_date=? " +
                " where company_id=?";
        try (
                Connection con = DBManager_new.connect();
                PreparedStatement pstmt = con.prepareStatement(sql)
        ) {
            pstmt.setString(1, vo.getCompanyName());
            pstmt.setString(2, vo.getCompanyIndustry());
            pstmt.setString(3, vo.getCompanyLocation());
            pstmt.setDouble(4, vo.getCompanyRating());
            pstmt.setInt(5, vo.getCompanySize());
            pstmt.setDate(6, (Date) vo.getCompanyApplicationDate());
            pstmt.setInt(7, vo.getCompanyId());

            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Map<String, Object> getCompanyStats(int companyId) {
        String sql = "SELECT COUNT(*) AS total_count,"
                + " ROUND(AVG(r_difficulty), 1) AS avg_difficulty,"
                + " ROUND(AVG(r_rating), 1) AS avg_rating,"
                + " ROUND(COUNT(CASE WHEN r_result='PASS' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1) AS pass_rate"
                + " FROM review WHERE r_company_id = ?";
        Map<String, Object> stats = new HashMap<>();
        try (Connection con = DBManager_new.connect();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            pstmt.setInt(1, companyId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalCount", rs.getInt("total_count"));
                    stats.put("avgDifficulty", rs.getDouble("avg_difficulty"));
                    stats.put("avgRating", rs.getDouble("avg_rating"));
                    stats.put("passRate", rs.getDouble("pass_rate"));
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return stats;

    }

    public int getTotalCompanyCount() {
        String sql = "select count(*) from company where is_verified = 'Y'";
        try (
                Connection con = DBManager_new.connect();
                PreparedStatement pstmt = con.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery()
        ) {

            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println(count); // 값을 변수에 담아 출력
                return count;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Map<String, Object> companySearchPaged(Map<String, String> conditions, int page, int pageSize) {
        Set<String> allowedText = Set.of("company_name", "company_industry", "company_location");
        Set<String> allowedRange = Set.of("company_size");

        StringBuilder baseSql = new StringBuilder(
                "SELECT c.*, "
                        + "NVL(ROUND(AVG(r.r_rating), 1), 0) AS calc_rating, "
                        + "COUNT(r.r_id) AS review_count "
                        + "FROM company c "
                        + "LEFT JOIN review r ON c.company_id = r.r_company_id "
                        + "where c.is_verified = 'Y' "
        );

        List<Object> params = new ArrayList<>();

        for (String col : allowedText) {
            if (conditions.containsKey(col)) {
                String val = conditions.get(col);

                if (col.equals("company_name")) {
                    baseSql.append(" AND c.").append(col).append(" LIKE ?");
                    params.add("%" + val + "%");
                } else if (val.contains(",")) {
                    String[] values = val.split(",");
                    baseSql.append(" AND c.").append(col).append(" IN (");
                    for (int i = 0; i < values.length; i++) {
                        baseSql.append(i > 0 ? ",?" : "?");
                        params.add(values[i].trim());
                    }
                    baseSql.append(")");
                } else {
                    baseSql.append(" AND c.").append(col).append(" LIKE ?");
                    params.add("%" + val + "%");
                }
            }
        }
        for (String col : allowedRange) {
            String minVal = conditions.get("min_" + col);
            String maxVal = conditions.get("max_" + col);
            if (minVal != null && !minVal.isBlank()) {
                baseSql.append(" AND c.").append(col).append(" >= ?");
                params.add(Double.parseDouble(minVal));
            }
            if (maxVal != null && !maxVal.isBlank()) {
                baseSql.append(" AND c.").append(col).append(" <= ?");
                params.add(Double.parseDouble(maxVal));
            }
        }
        baseSql.append(" GROUP BY c.company_id, c.company_name, c.company_industry, "
                + "c.company_location, c.company_rating, c.company_size, "
                + "c.company_created_date, c.company_application_date" +
                ", c.is_verified");

        // 유저 평점(리뷰 평균) 필터 — WHERE 절 대신 HAVING 절 사용
        String minRating = conditions.get("min_company_rating");
        String maxRating = conditions.get("max_company_rating");
        if (minRating != null && !minRating.isBlank()) {
            baseSql.append(" HAVING NVL(ROUND(AVG(r.r_rating), 1), 0) >= ?");
            params.add(Double.parseDouble(minRating));
            if (maxRating != null && !maxRating.isBlank()) {
                baseSql.append(" AND NVL(ROUND(AVG(r.r_rating), 1), 0) <= ?");
                params.add(Double.parseDouble(maxRating));
            }
        } else if (maxRating != null && !maxRating.isBlank()) {
            baseSql.append(" HAVING NVL(ROUND(AVG(r.r_rating), 1), 0) <= ?");
            params.add(Double.parseDouble(maxRating));
        }


        String countSql = "SELECT COUNT(*) FROM (" + baseSql + ")";
        // 페이징
        String pagedSql = "SELECT * FROM ("
                + "  SELECT ROWNUM rn, t.* FROM (" + baseSql + ") t"
                + ") WHERE rn BETWEEN ? AND ?";

        int start = (page - 1) * pageSize + 1;
        int end = page * pageSize;

        Map<String, Object> result = new HashMap<>();

        try (Connection con = DBManager_new.connect()) {
            // 전체 건수
            try (PreparedStatement pstmt = con.prepareStatement(countSql)) {
                for (int i = 0; i < params.size(); i++) {
                    pstmt.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) result.put("totalCount", rs.getInt(1));
                }
            }

            // 페이징 데이터
            try (PreparedStatement pstmt = con.prepareStatement(pagedSql)) {
                for (int i = 0; i < params.size(); i++) {
                    pstmt.setObject(i + 1, params.get(i));
                }
                pstmt.setInt(params.size() + 1, start);
                pstmt.setInt(params.size() + 2, end);

                List<CompanySearchVO> companies = new ArrayList<>();
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        companies.add(CompanySearchVO.fromRS(rs));
                    }
                }
                result.put("companies", companies);
            }

            // 매칭되는 전체 회사 ID (리뷰 필터 연동용 — 페이지와 무관)
            String idSql = "SELECT company_id FROM (" + baseSql + ")";
            try (PreparedStatement pstmt = con.prepareStatement(idSql)) {
                for (int i = 0; i < params.size(); i++) {
                    pstmt.setObject(i + 1, params.get(i));
                }
                List<Integer> ids = new ArrayList<>();
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) ids.add(rs.getInt("company_id"));
                }
                result.put("allCompanyIds", ids);
            }

            int totalCount = (int) result.get("totalCount");
            result.put("totalPages", (int) Math.ceil((double) totalCount / pageSize));
            result.put("currentPage", page);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }


    public int directInsertCompany(String companyName) {
        int newCompanyId = 0;
        String sql = "insert into company(" +
                "company_id , company_name , company_industry , company_location , company_rating , company_size , company_created_date, company_application_date, is_verified" +
                " ) values (" +
                "company_seq.nextval, ? , '미정', '미정', 0, 0, sysdate, sysdate, 'N')";
        try (
                Connection con = DBManager_new.connect();
                PreparedStatement pstmt = con.prepareStatement(sql, new String[]{"company_id"})
        ) {
            pstmt.setString(1, companyName);
            pstmt.executeUpdate();
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    newCompanyId = rs.getInt(1);

                }
            }


        } catch (Exception e) {
            e.printStackTrace();
        }

        return newCompanyId;
    }


}
