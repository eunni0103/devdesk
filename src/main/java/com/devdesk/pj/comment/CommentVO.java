package com.devdesk.pj.comment;

import lombok.Data;

@Data
public class CommentVO {
    private int comments_id;
    private int board_id;
    private int member_id;
    private Integer parent_id;
    private String content;
    private String created_date;

    private String nickname;
    private String board_title; // 영은 추가

}
