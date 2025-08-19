package com.example.freelance_system.dto;

import java.time.LocalDateTime;

public class ReviewDTO {
    private Long id;
    private int rating;
    private String feedback;
    private String reviewerName;  // reviewer/client name
    private String jobTitle;
    private LocalDateTime reviewTime;

    public ReviewDTO(Long id, int rating, String feedback, String reviewerName, String jobTitle, LocalDateTime reviewTime) {
        this.id = id;
        this.rating = rating;
        this.feedback = feedback;
        this.reviewerName = reviewerName;
        this.jobTitle = jobTitle;
        this.reviewTime = reviewTime;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }

    public String getJobTitle() {
        return jobTitle;
    }

    public void setJobTitle(String jobTitle) {
        this.jobTitle = jobTitle;
    }

    public LocalDateTime getReviewTime() {
        return reviewTime;
    }

    public void setReviewTime(LocalDateTime reviewTime) {
        this.reviewTime = reviewTime;
    }
}
