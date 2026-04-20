package com.devdesk.pj.til;

import lombok.Data;

@Data
public class TilV0 {

    private String tilId;
    private String title;
    private String tag;
    private double studyTime;
    private String content;
    private String createdAt;  // "2025-04-07"
    private String tagColor;
    private String tagBg;
    private String timeAgo;

    public void setTagColor(String tagColor) {
        this.tagColor = tagColor;
    }

    public void setTagBg(String tagBg) {
        this.tagBg = tagBg;
    }
}
