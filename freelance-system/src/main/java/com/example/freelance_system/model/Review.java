package com.example.freelance_system.model;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int rating;

    private String feedback;

    private Long reviewerId;
    private Long revieweeId;

    private Long jobId;

    private LocalDateTime reviewTime;

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

	public Long getReviewerId() {
		return reviewerId;
	}

	public void setReviewerId(Long reviewerId) {
		this.reviewerId = reviewerId;
	}

	public Long getRevieweeId() {
		return revieweeId;
	}

	public void setRevieweeId(Long revieweeId) {
		this.revieweeId = revieweeId;
	}

	public Long getJobId() {
		return jobId;
	}

	public void setJobId(Long jobId) {
		this.jobId = jobId;
	}

	public LocalDateTime getReviewTime() {
		return reviewTime;
	}

	public void setReviewTime(LocalDateTime reviewTime) {
		this.reviewTime = reviewTime;
	}

    
}

