package com.devdesk.pj.main;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Properties;
import java.util.UUID;

public class SupabaseDAO {

//  강사님ver  public static final SupabaseDAO SUPADAO = new SupabaseDAO();
//
//    private SupabaseDAO() {
//
//    }
//
//    public String upload(HttpServletRequest request, HttpServletResponse response) {
//        try {
//            Properties prop = new Properties();
//            InputStream input = getClass().getClassLoader().getResourceAsStream("conf.properties");
//            prop.load(input);

    public static String upload(HttpServletRequest request, HttpServletResponse response) {
        try {
            Properties prop = new Properties();
            InputStream input = SupabaseDAO.class.getClassLoader().getResourceAsStream("conf.properties");
            if (input == null) {
                throw new RuntimeException("conf.properties file not found in classpath");
            }
            try {
                prop.load(input);
            } finally {
                input.close();
            }
            String SUPABASE_URL = prop.getProperty("supabase.url");
            if (SUPABASE_URL != null) {
                SUPABASE_URL = SUPABASE_URL.replaceAll("/+$", "");
            }
            String API_KEY = prop.getProperty("service.role");
            Part filePart = request.getPart("file");

            String originFileName = filePart.getSubmittedFileName();
            String ext = originFileName.substring(originFileName.lastIndexOf("."));

            String fileName = UUID.randomUUID().toString().split("-")[0];
            fileName += ext;
            System.out.println("save file name : " + fileName);

            InputStream fileContent = filePart.getInputStream();

            // Supabase 업로드 URL
            String uploadUrl = SUPABASE_URL + "/storage/v1/object/upload/file/" + fileName;

            URL url = new URL(uploadUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("POST");
            conn.setDoOutput(true);

            conn.setRequestProperty("Authorization", "Bearer " + API_KEY);
            conn.setRequestProperty("Content-Type", filePart.getContentType());

            OutputStream os = conn.getOutputStream();
            byte[] buffer = new byte[4096];
            int bytesRead;

            while ((bytesRead = fileContent.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }

            os.flush();
            os.close();

            int responseCode = conn.getResponseCode();

            if (responseCode == 200 || responseCode == 201) {
                String fileUrl = SUPABASE_URL + "/storage/v1/object/public/upload/file/" + fileName;

                // 👉 여기서 DB 저장하면 됨
                response.getWriter().println("업로드 성공: " + fileUrl);
                return fileUrl;
            } else {
                response.getWriter().println("업로드 실패: " + responseCode);
            }

            // 업로드 완료된 그 url return
        } catch (Exception e) {
            e.printStackTrace();
            try {
                response.getWriter().println("업로드 에러: " + e.getMessage());
            } catch (Exception ex) {
                System.err.println("Error writing response: " + ex.getMessage());
            }
        }
        return "";
    }
}
