package com.devdesk.pj.like;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LikeVO {
    private int like_id;
    private int board_id;
    private int member_id;
    private String created_date;
}
