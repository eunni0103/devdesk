package com.devdesk.pj.board;


import lombok.Data;
import java.util.Date;

@Data
public class BoardVO {
    private int board_id;
    private int member_id;
    private String category;
    private String title;
    private String content;
    private int view_count;
    private int like_count;
    private char hidden_yn;
    private Date created_date;
    private Date updated_date;
    private String nickname;
    private int comment_count; // 댓글 수 필드 추가

}
