package com.devdesk.pj.like;

import lombok.Data;

@Data
public class LikeResult {
    private boolean success; // 성공 여부
    private int count;       // 전체 좋아요 개수
    private boolean liked;   // 현재 유저의 좋아요 여부 (true/false)
    private String message;

    // 생성자 (success, count, liked, message 순서)
    public LikeResult(boolean success, int count, boolean liked, String message) {
        this.success = success;
        this.count = count;
        this.liked = liked;
        this.message = message;
    }
    // Getter, Setter 생략...
}
